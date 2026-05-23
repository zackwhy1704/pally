import 'package:flutter/material.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/ui/pally_button.dart';
import 'package:pally/shared/models/avatar.dart';

const _suggestions = [
  'Maths',
  'Science',
  'English',
  'History',
  'Geography',
  'Art',
  'Music',
  'Coding',
  'Languages',
  'PE',
];

class SubjectStep extends StatefulWidget {
  const SubjectStep({
    super.key,
    required this.subject,
    required this.selectedCharacter,
    required this.tutorName,
    required this.onSubjectChanged,
    required this.isLoading,
    required this.canCreate,
    required this.error,
    required this.onCreate,
  });

  final String? subject;
  final AvatarCharacter? selectedCharacter;
  final String tutorName;
  final ValueChanged<String> onSubjectChanged;
  final bool isLoading;
  final bool canCreate;
  final String? error;
  final VoidCallback? onCreate;

  @override
  State<SubjectStep> createState() => _SubjectStepState();
}

class _SubjectStepState extends State<SubjectStep> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.subject ?? '');
  }

  @override
  void didUpdateWidget(SubjectStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync if parent pushes a new default (e.g. character changed)
    if (widget.subject != oldWidget.subject &&
        widget.subject != _controller.text) {
      _controller.text = widget.subject ?? '';
      _controller.selection = TextSelection.collapsed(
        offset: _controller.text.length,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _pickSuggestion(String suggestion) {
    _controller.text = suggestion;
    _controller.selection = TextSelection.collapsed(offset: suggestion.length);
    widget.onSubjectChanged(suggestion);
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.tutorName.isEmpty ? 'your tutor' : widget.tutorName;
    final accentColor =
        widget.selectedCharacter?.primaryColor ?? AppColors.purple;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What subject?', style: AppTextStyles.heading1),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'What will $name help you with?',
            style: AppTextStyles.body.copyWith(color: AppColors.text2),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _controller,
            onChanged: widget.onSubjectChanged,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              hintText: 'e.g. Maths, Science, Guitar…',
              prefixIcon: Icon(
                Icons.menu_book_outlined,
                color: accentColor,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: accentColor, width: 2),
              ),
            ),
            style: AppTextStyles.body,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Quick picks',
            style: AppTextStyles.label.copyWith(
              color: AppColors.text3,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: _suggestions.map((s) {
              final isActive =
                  _controller.text.trim().toLowerCase() == s.toLowerCase();
              return ActionChip(
                label: Text(s),
                onPressed: () => _pickSuggestion(s),
                backgroundColor: isActive ? accentColor : AppColors.surface,
                labelStyle: AppTextStyles.bodySmall.copyWith(
                  color: isActive ? Colors.white : AppColors.text2,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                ),
                side: BorderSide(
                  color: isActive ? accentColor : AppColors.outline,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                ),
              );
            }).toList(),
          ),
          const Spacer(),
          PallyButton(
            label: 'Create $name! 🎉',
            onPressed: widget.canCreate ? widget.onCreate : null,
            loading: widget.isLoading,
            fullWidth: true,
          ),
        ],
      ),
    );
  }
}
