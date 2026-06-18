import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/ui/adaptive_center.dart';
import 'package:pally/features/chat/presentation/chat_view_model.dart';
import 'package:pally/features/photo_question/models/ocr_confidence_result.dart';
import 'package:pally/features/photo_question/presentation/photo_preview_view_model.dart';
import 'package:pally/features/photo_question/presentation/widgets/edit_questions_sheet.dart';
import 'package:pally/features/photo_question/presentation/widgets/retake_confirmation_dialog.dart';
import 'package:pally/features/photo_question/screens/ocr_confidence_preview_screen.dart';
import 'package:pally/shared/models/photo_question.dart';

const List<Color> _kQuestionColors = [
  AppColors.teal,
  AppColors.green,
  AppColors.purple,
  AppColors.amber,
];

class PhotoPreviewScreen extends ConsumerStatefulWidget {
  const PhotoPreviewScreen({
    super.key,
    required this.photoPath,
    required this.avatarId,
  });

  final String photoPath;
  final String avatarId;

  @override
  ConsumerState<PhotoPreviewScreen> createState() => _PhotoPreviewScreenState();
}

class _PhotoPreviewScreenState extends ConsumerState<PhotoPreviewScreen> {
  String get _photoPath => widget.photoPath;
  bool _confidenceChecked = false;

  Future<void> _showEditQuestionsSheet(
      BuildContext context, List<PhotoQuestion> questions) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditQuestionsSheet(
        questions: questions,
        onSave: (updated) {
          ref
              .read(photoPreviewViewModelProvider(_photoPath).notifier)
              .updateQuestions(updated);
        },
      ),
    );
  }

  Future<void> _showRetakeConfirmation(BuildContext context) async {
    final choice = await showDialog<RetakeChoice>(
      context: context,
      builder: (_) => const RetakeConfirmationDialog(),
    );
    if (choice == null || !context.mounted) return;

    switch (choice) {
      case RetakeChoice.keepPhoto:
        break;
      case RetakeChoice.retake:
        context.pop();
      case RetakeChoice.gallery:
        final picker = ImagePicker();
        final picked =
            await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
        if (picked != null && context.mounted) {
          // Pop back to chat and push new preview with gallery photo
          context.pop();
          context.push(
            '/photo-preview',
            extra: {'photoPath': picked.path, 'avatarId': widget.avatarId},
          );
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(photoPreviewViewModelProvider(_photoPath));

    // One-time confidence check: push confidence preview for low-confidence results
    if (state is PhotoPreviewDetected && !_confidenceChecked) {
      _confidenceChecked = true;
      final detected = state;
      final texts = detected.questions.map((q) => q.rawText).toList();
      final confidenceResult =
          OcrConfidenceResult.fromOcrTexts(File(_photoPath), texts);
      if (confidenceResult.hasLowConfidence) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (_) => OcrConfidencePreviewScreen(
              result: confidenceResult,
              avatarId: widget.avatarId,
              detectedTexts: texts,
            ),
          ));
        });
      }
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: switch (state) {
        PhotoPreviewDetecting() => const _DetectingView(),
        PhotoPreviewDetected(:final questions, :final photoPath) =>
          _DetectedView(
            photoPath: photoPath,
            questions: questions,
            onToggle: (id) => ref
                .read(photoPreviewViewModelProvider(_photoPath).notifier)
                .toggleQuestion(id),
            onConfirm: () {
              final selected = ref
                  .read(photoPreviewViewModelProvider(_photoPath).notifier)
                  .selectedQuestions;
              if (selected.isEmpty) return;
              ref
                  .read(chatViewModelProvider(widget.avatarId).notifier)
                  .sendPhotoMessage(photoPath, selected);
              context.pop();
            },
            onRetakeTap: () => _showRetakeConfirmation(context),
            onEditTap: () => _showEditQuestionsSheet(context, questions),
          ),
        PhotoPreviewError(:final message) => _ErrorView(
            message: message,
            onRetake: () => context.pop(),
          ),
      },
    );
  }
}

// ── Detecting ────────────────────────────────────────────────────────────────

class _DetectingView extends StatelessWidget {
  const _DetectingView();

  @override
  Widget build(BuildContext context) {
    return const AdaptiveCenter(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.teal),
          SizedBox(height: AppSpacing.md),
          Text(
            'Detecting questions… 🔍',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

// ── Detected ─────────────────────────────────────────────────────────────────

class _DetectedView extends StatelessWidget {
  const _DetectedView({
    required this.photoPath,
    required this.questions,
    required this.onToggle,
    required this.onConfirm,
    required this.onRetakeTap,
    required this.onEditTap,
  });

  final String photoPath;
  final List<PhotoQuestion> questions;
  final void Function(String) onToggle;
  final VoidCallback onConfirm;
  final VoidCallback onRetakeTap;
  final VoidCallback onEditTap;

  @override
  Widget build(BuildContext context) {
    final selectedCount = questions.where((q) => q.isSelected).length;
    return Stack(
      fit: StackFit.expand,
      children: [
        // Photo background
        Image.file(File(photoPath), fit: BoxFit.cover),

        // Dark overlay on bottom half
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: MediaQuery.of(context).size.height * 0.6,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.88),
                ],
              ),
            ),
          ),
        ),

        // Top bar: close (left) + retake (right)
        Positioned(
          top: MediaQuery.of(context).padding.top + 4,
          left: 4,
          right: 12,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close_rounded,
                    color: Colors.white, size: 28),
                onPressed: () => context.pop(),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onRetakeTap,
                child: Container(
                  width: 72,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.4), width: 1),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('↺', style: TextStyle(color: Colors.white, fontSize: 13)),
                      SizedBox(width: 4),
                      Text(
                        'Retake',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Bottom panel
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.lg, AppSpacing.md, AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header row: badge + edit button
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.teal,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${questions.length} question${questions.length == 1 ? '' : 's'} found',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: onEditTap,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('✏️', style: TextStyle(fontSize: 11)),
                              SizedBox(width: 5),
                              Text(
                                'Edit questions',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Pill-chip question toggles
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: questions.map((q) {
                      final color =
                          _kQuestionColors[(q.questionIndex - 1) % _kQuestionColors.length];
                      final isSelected = q.isSelected;
                      return GestureDetector(
                        onTap: () => onToggle(q.id),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 80,
                          height: 34,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? color.withValues(alpha: 0.22)
                                : Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(17),
                            border: Border.all(
                              color: isSelected
                                  ? color
                                  : Colors.white.withValues(alpha: 0.25),
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              isSelected
                                  ? 'Q${q.questionIndex} ✓'
                                  : 'Q${q.questionIndex} ✕',
                              style: TextStyle(
                                color:
                                    isSelected ? color : Colors.white54,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Confirm button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: selectedCount > 0 ? onConfirm : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.teal,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        selectedCount > 0
                            ? 'Send $selectedCount question${selectedCount == 1 ? '' : 's'} to Mochi ✨'
                            : 'Select at least 1 question',
                        style: AppTextStyles.body.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Error ─────────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetake});
  final String message;
  final VoidCallback onRetake;

  @override
  Widget build(BuildContext context) {
    return AdaptiveCenter(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.coral, size: 64),
            const SizedBox(height: AppSpacing.md),
            Text('Could not read photo',
                style: AppTextStyles.title.copyWith(color: Colors.white)),
            const SizedBox(height: AppSpacing.sm),
            Text(message,
                style: AppTextStyles.body.copyWith(color: Colors.white70),
                textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.lg),
            OutlinedButton(
              onPressed: onRetake,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white54),
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
    );
  }
}
