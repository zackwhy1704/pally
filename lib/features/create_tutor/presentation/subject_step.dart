import 'package:flutter/material.dart';
import 'package:pally/l10n/app_localizations.dart';
import 'package:pally/features/create_tutor/presentation/create_tutor_view_model.dart';
import 'package:pally/core/i18n/label_localizer.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/ui/pally_button.dart';
import 'package:pally/shared/models/mochi_character.dart';

// Order reflects the most-used picks for Singapore O/A-level kids first
// (Maths / Science / English / Literature) and falls back to the broader
// "General" catch-all so a child who isn't picking a syllabus subject
// still has a one-tap path forward. These EXACT strings are what tapping a
// chip WRITES into the free-text field (unchanged — the field itself stays
// English-canonical passthrough per label_localizer's documented "never
// machine-translate a teacher's own words" rule); only the chip's own
// visible LABEL localizes below via localizedSubject, same safe display-
// only pattern as create_group_screen's subject chips.
const _suggestions = [
  'Maths',
  'Science',
  'English',
  'Literature',
  'History',
  'Geography',
  'General',
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
  final MochiCharacter? selectedCharacter;
  final String tutorName;
  final ValueChanged<String> onSubjectChanged;
  final bool isLoading;
  final bool canCreate;
  final CreateTutorError? error;
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
    final l = AppLocalizations.of(context);
    final name = widget.tutorName.isEmpty ? l.mascotName : widget.tutorName;
    final accentColor =
        widget.selectedCharacter?.primaryColor ?? AppColors.purple;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.createTutorSubjectTitle, style: AppTextStyles.heading1),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l.createTutorSubjectPrompt(name),
                    style:
                        AppTextStyles.body.copyWith(color: AppColors.text2),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: _controller,
                    onChanged: widget.onSubjectChanged,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: l.createTutorSubjectHint,
                      prefixIcon: Icon(
                        Icons.menu_book_outlined,
                        color: accentColor,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: accentColor, width: 2),
                      ),
                    ),
                    style: AppTextStyles.body,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    l.createTutorQuickPicks,
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
                      final isActive = _controller.text
                              .trim()
                              .toLowerCase() ==
                          s.toLowerCase();
                      return ActionChip(
                        label: Text(localizedSubject(l, s)),
                        onPressed: () => _pickSuggestion(s),
                        backgroundColor:
                            isActive ? accentColor : AppColors.surface,
                        labelStyle: AppTextStyles.bodySmall.copyWith(
                          color:
                              isActive ? Colors.white : AppColors.text2,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                        side: BorderSide(
                          color:
                              isActive ? accentColor : AppColors.outline,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ),
          PallyButton(
            label: l.onboardingNext,
            onPressed: widget.canCreate ? widget.onCreate : null,
            loading: widget.isLoading,
            fullWidth: true,
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 4),
        ],
      ),
    );
  }
}
