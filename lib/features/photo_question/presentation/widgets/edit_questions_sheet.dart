import 'package:flutter/material.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/shared/models/photo_question.dart';

const List<Color> _kColors = [
  AppColors.teal,
  AppColors.green,
  AppColors.purple,
  AppColors.amber,
];

class EditQuestionsSheet extends StatefulWidget {
  const EditQuestionsSheet({
    required this.questions,
    required this.onSave,
    super.key,
  });

  final List<PhotoQuestion> questions;
  final void Function(List<PhotoQuestion> updated) onSave;

  @override
  State<EditQuestionsSheet> createState() => _EditQuestionsSheetState();
}

class _EditQuestionsSheetState extends State<EditQuestionsSheet> {
  late final List<TextEditingController> _controllers;
  late List<bool> _isEditing;

  @override
  void initState() {
    super.initState();
    _controllers = widget.questions
        .map((q) => TextEditingController(text: q.rawText))
        .toList();
    _isEditing = List.filled(widget.questions.length, false);
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _activateRow(int i) {
    setState(() {
      _isEditing = List.filled(widget.questions.length, false);
      _isEditing[i] = true;
      _controllers[i].selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controllers[i].text.length,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Container(
              width: 54,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('✏️  Edit Questions',
                          style: AppTextStyles.title.copyWith(fontSize: 16)),
                      const SizedBox(height: 2),
                      Text(
                        'Fix any text Mochi misread',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.text2),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: AppColors.surf2,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '✕',
                        style: AppTextStyles.body
                            .copyWith(color: AppColors.text2, fontSize: 14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: AppColors.outline, height: 1),
          const SizedBox(height: 8),

          // Editable rows
          for (int i = 0; i < widget.questions.length; i++)
            _EditableQuestionRow(
              index: i,
              controller: _controllers[i],
              isEditing: _isEditing[i],
              accentColor: _kColors[i % _kColors.length],
              onTapEdit: () => _activateRow(i),
              onClear: () {
                _controllers[i].clear();
                _activateRow(i);
              },
            ),

          const SizedBox(height: 12),

          // Done button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purple,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 4,
                shadowColor: AppColors.purple.withValues(alpha: 0.28),
              ),
              onPressed: () {
                final updated = widget.questions.asMap().entries.map((e) {
                  final text = _controllers[e.key].text.trim();
                  return e.value.copyWith(
                    rawText: text.isEmpty ? e.value.rawText : text,
                  );
                }).toList();
                widget.onSave(updated);
                Navigator.of(context).pop();
              },
              child: const Text(
                'Done — use these questions ✓',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),

          // Keyboard inset
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 8),
        ],
      ),
    );
  }
}

class _EditableQuestionRow extends StatelessWidget {
  const _EditableQuestionRow({
    required this.index,
    required this.controller,
    required this.isEditing,
    required this.accentColor,
    required this.onTapEdit,
    required this.onClear,
  });

  final int index;
  final TextEditingController controller;
  final bool isEditing;
  final Color accentColor;
  final VoidCallback onTapEdit;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        constraints: const BoxConstraints(minHeight: 60),
        decoration: BoxDecoration(
          color: isEditing ? AppColors.purpleL : AppColors.surf2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEditing ? AppColors.purple : AppColors.outline,
            width: isEditing ? 1.5 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Number circle
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Text field or tappable text
              Expanded(
                child: isEditing
                    ? TextField(
                        controller: controller,
                        autofocus: true,
                        maxLines: null,
                        style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      )
                    : GestureDetector(
                        onTap: onTapEdit,
                        behavior: HitTestBehavior.opaque,
                        child: Text(
                          controller.text,
                          style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
                        ),
                      ),
              ),

              const SizedBox(width: 8),

              // Clear (editing) or Edit pencil (idle)
              if (isEditing)
                GestureDetector(
                  onTap: onClear,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: AppColors.outline,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Center(
                      child: Text(
                        '✕',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.text3, fontSize: 9),
                      ),
                    ),
                  ),
                )
              else
                GestureDetector(
                  onTap: onTapEdit,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surf2,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.outline),
                    ),
                    child: const Text('✏️', style: TextStyle(fontSize: 11)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
