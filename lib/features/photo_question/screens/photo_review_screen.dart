import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/features/chat/presentation/chat_view_model.dart';
import 'package:pally/shared/models/photo_question.dart';

const _teal = Color(0xFF00BAA3);
const _green = Color(0xFF2EC770);
const _purple = Color(0xFF7042ED);
const _amber = Color(0xFFFFB81A);
const _dark = Color(0xFF0F0A1A);

const _kChipColors = [_teal, _green, _purple, _amber];

class _DetectedQuestion {
  _DetectedQuestion({
    required this.index,
    required this.text,
    required this.color,
  }) : controller = TextEditingController(text: text);

  final int index;
  String text;
  final Color color;
  bool selected = true;
  bool isEditing = false;
  final TextEditingController controller;

  void dispose() => controller.dispose();
}

class PhotoReviewScreen extends ConsumerStatefulWidget {
  const PhotoReviewScreen({
    super.key,
    required this.photoFile,
    required this.detectedTexts,
    required this.avatarId,
  });

  final File photoFile;
  final List<String> detectedTexts;
  final String avatarId;

  @override
  ConsumerState<PhotoReviewScreen> createState() => _PhotoReviewScreenState();
}

class _PhotoReviewScreenState extends ConsumerState<PhotoReviewScreen> {
  late final List<_DetectedQuestion> _questions;

  @override
  void initState() {
    super.initState();
    _questions = widget.detectedTexts.asMap().entries.map((e) {
      return _DetectedQuestion(
        index: e.key + 1,
        text: e.value,
        color: _kChipColors[e.key % _kChipColors.length],
      );
    }).toList();
  }

  @override
  void dispose() {
    for (final q in _questions) {
      q.dispose();
    }
    super.dispose();
  }

  void _toggleSelect(int index) {
    setState(() => _questions[index].selected = !_questions[index].selected);
  }

  void _toggleEdit(int index) {
    setState(() {
      for (int i = 0; i < _questions.length; i++) {
        _questions[i].isEditing = (i == index) ? !_questions[i].isEditing : false;
      }
    });
  }

  void _commitEdit(int index) {
    setState(() {
      _questions[index].text = _questions[index].controller.text.trim().isEmpty
          ? _questions[index].text
          : _questions[index].controller.text.trim();
      _questions[index].isEditing = false;
    });
  }

  void _onSend() {
    final selected = _questions
        .where((q) => q.selected)
        .map((q) => PhotoQuestion(
              id: 'pq-${q.index}',
              rawText: q.text,
              questionIndex: q.index,
              isSelected: true,
            ))
        .toList();

    if (selected.isEmpty) return;

    ref
        .read(chatViewModelProvider(widget.avatarId).notifier)
        .sendPhotoMessage(widget.photoFile.path, selected);

    context.pop();
  }

  void _showRetakeSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _RetakeConfirmSheet(
        onKeep: () => Navigator.of(context).pop(),
        onRetake: () {
          Navigator.of(context).pop();
          context.pop();
        },
        onGallery: () async {
          Navigator.of(context).pop();
          final picker = ImagePicker();
          final picked = await picker.pickImage(
              source: ImageSource.gallery, imageQuality: 85);
          if (!mounted) return;
          if (picked != null) {
            if (mounted) context.pop();
            if (mounted) {
              context.push(
                '/photo-preview',
                extra: {'photoPath': picked.path, 'avatarId': widget.avatarId},
              );
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedCount = _questions.where((q) => q.selected).length;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Photo always visible
          Image.file(widget.photoFile, fit: BoxFit.cover),

          // Gradient overlay
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: MediaQuery.of(context).size.height * 0.65,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    _dark.withValues(alpha: 0.92),
                  ],
                ),
              ),
            ),
          ),

          // Top bar
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
                _RetakeButton(onTap: _showRetakeSheet),
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
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Found badge + count
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _teal,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_questions.length} question${_questions.length == 1 ? '' : 's'} found',
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Question chips + inline edit
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(_questions.length, (i) {
                        return _QuestionRow(
                          question: _questions[i],
                          onToggle: () => _toggleSelect(i),
                          onTapEdit: () => _toggleEdit(i),
                          onCommitEdit: () => _commitEdit(i),
                        );
                      }),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Send button
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: selectedCount > 0 ? _onSend : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: _teal,
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
      ),
    );
  }
}

// ── Question row with inline edit ─────────────────────────────────────────────

class _QuestionRow extends StatelessWidget {
  const _QuestionRow({
    required this.question,
    required this.onToggle,
    required this.onTapEdit,
    required this.onCommitEdit,
  });

  final _DetectedQuestion question;
  final VoidCallback onToggle;
  final VoidCallback onTapEdit;
  final VoidCallback onCommitEdit;

  @override
  Widget build(BuildContext context) {
    final color = question.color;
    final selected = question.selected;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Chip row
          Row(
            children: [
              GestureDetector(
                onTap: onToggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 80,
                  height: 32,
                  decoration: BoxDecoration(
                    color: selected
                        ? color.withValues(alpha: 0.22)
                        : Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selected
                          ? color
                          : Colors.white.withValues(alpha: 0.25),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      selected ? 'Q${question.index} ✓' : 'Q${question.index} ✕',
                      style: TextStyle(
                        color: selected ? color : Colors.white54,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  question.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(width: 8),

              GestureDetector(
                onTap: onTapEdit,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: question.isEditing
                        ? color.withValues(alpha: 0.25)
                        : Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: question.isEditing
                          ? color
                          : Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    question.isEditing ? '✓' : '✏️',
                    style: TextStyle(
                      fontSize: 11,
                      color: question.isEditing ? color : Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Inline edit panel
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: question.isEditing
                ? Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: color.withValues(alpha: 0.6), width: 1.5),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          TextField(
                            controller: question.controller,
                            autofocus: true,
                            maxLines: null,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 13),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                              hintText: 'Edit question text…',
                              hintStyle: TextStyle(
                                color: Colors.white.withValues(alpha: 0.4),
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: onCommitEdit,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Done',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// ── Retake button ─────────────────────────────────────────────────────────────

class _RetakeButton extends StatelessWidget {
  const _RetakeButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
          border:
              Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1),
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
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Retake confirm bottom sheet ───────────────────────────────────────────────

class _RetakeConfirmSheet extends StatelessWidget {
  const _RetakeConfirmSheet({
    required this.onKeep,
    required this.onRetake,
    required this.onGallery,
  });

  final VoidCallback onKeep;
  final VoidCallback onRetake;
  final VoidCallback onGallery;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.38,
      minChildSize: 0.2,
      maxChildSize: 0.5,
      expand: false,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(
          controller: controller,
          shrinkWrap: true,
          children: [
            // Handle
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 16),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('What would you like to do?',
                  style: AppTextStyles.title.copyWith(fontSize: 16)),
            ),

            const SizedBox(height: 16),

            _SheetOption(
              emoji: '✅',
              label: 'Keep this photo',
              description: 'Continue with current scan',
              color: AppColors.teal,
              onTap: onKeep,
            ),
            _SheetOption(
              emoji: '📸',
              label: 'Retake photo',
              description: 'Take a new photo with camera',
              color: AppColors.purple,
              onTap: onRetake,
            ),
            _SheetOption(
              emoji: '🖼️',
              label: 'Choose from gallery',
              description: 'Pick an existing photo',
              color: AppColors.amber,
              onTap: onGallery,
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  const _SheetOption({
    required this.emoji,
    required this.label,
    required this.description,
    required this.color,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final String description;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                  child: Text(emoji,
                      style: const TextStyle(fontSize: 20))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: AppTextStyles.body
                          .copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(description,
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.text3, fontSize: 10)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.text3, size: 18),
          ],
        ),
      ),
    );
  }
}
