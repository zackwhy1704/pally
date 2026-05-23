import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/features/chat/presentation/chat_view_model.dart';
import 'package:pally/features/photo_question/presentation/photo_preview_view_model.dart';
import 'package:pally/shared/models/photo_question.dart';

class PhotoPreviewScreen extends ConsumerWidget {
  const PhotoPreviewScreen({
    super.key,
    required this.photoPath,
    required this.avatarId,
  });

  final String photoPath;
  final String avatarId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(photoPreviewViewModelProvider(photoPath));

    return Scaffold(
      backgroundColor: Colors.black,
      body: switch (state) {
        PhotoPreviewDetecting() => const _DetectingView(),
        PhotoPreviewDetected(:final questions, :final photoPath) =>
          _DetectedView(
            photoPath: photoPath,
            questions: questions,
            onToggle: (id) => ref
                .read(photoPreviewViewModelProvider(photoPath).notifier)
                .toggleQuestion(id),
            onConfirm: () {
              final selected = ref
                  .read(photoPreviewViewModelProvider(photoPath).notifier)
                  .selectedQuestions;
              if (selected.isEmpty) return;
              ref
                  .read(chatViewModelProvider(avatarId).notifier)
                  .sendPhotoMessage(photoPath, selected);
              context.pop();
            },
            onRetake: () => context.pop(),
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
    return const Center(
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
    required this.onRetake,
  });

  final String photoPath;
  final List<PhotoQuestion> questions;
  final void Function(String) onToggle;
  final VoidCallback onConfirm;
  final VoidCallback onRetake;

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
          height: MediaQuery.of(context).size.height * 0.55,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.85),
                ],
              ),
            ),
          ),
        ),

        // Top close button
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 8,
          child: IconButton(
            icon:
                const Icon(Icons.close_rounded, color: Colors.white, size: 28),
            onPressed: onRetake,
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
                  // Header
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
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Question toggles
                  ...questions.map((q) => _QuestionToggleRow(
                        question: q,
                        onToggle: () => onToggle(q.id),
                      )),

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
                            ? 'Send $selectedCount question${selectedCount == 1 ? '' : 's'} to Tutor ✨'
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

class _QuestionToggleRow extends StatelessWidget {
  const _QuestionToggleRow({
    required this.question,
    required this.onToggle,
  });

  final PhotoQuestion question;
  final VoidCallback onToggle;

  static const List<Color> _colors = [
    AppColors.teal,
    AppColors.green,
    AppColors.purple,
    AppColors.amber,
  ];

  @override
  Widget build(BuildContext context) {
    final color = _colors[(question.questionIndex - 1) % _colors.length];
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.xs),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: question.isSelected
              ? color.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: question.isSelected
                ? color.withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: question.isSelected ? color : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: question.isSelected ? color : Colors.white38,
                  width: 1.5,
                ),
              ),
              child: question.isSelected
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 14)
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Q${question.questionIndex}: ${question.rawText}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: question.isSelected ? Colors.white : Colors.white54,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
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
    return Center(
      child: Padding(
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
      ),
    );
  }
}
