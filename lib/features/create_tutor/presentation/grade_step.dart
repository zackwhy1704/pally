import 'package:flutter/material.dart';
import 'package:pally/l10n/app_localizations.dart';
import 'package:pally/core/i18n/app_languages.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/ui/pally_button.dart';
import 'package:pally/shared/models/mochi_character.dart';

// Age options for tutor grade level — 13 to 21+.
// Stored as strings for backward-compatibility with existing avatar records.
const _ageOptions = [
  (label: '13', value: '13'),
  (label: '14', value: '14'),
  (label: '15', value: '15'),
  (label: '16', value: '16'),
  (label: '17', value: '17'),
  (label: '18', value: '18'),
  (label: '19', value: '19'),
  (label: '20', value: '20'),
  (label: '21', value: '21'),
  (label: '21+', value: '21+'),
];

// What the user wants Mochi to help with — goal-oriented, not geography-based.
// Icon + backend id only; the DISPLAY label resolves at render via
// _examSystemLabel — a closed id set, same resolver shape as label_localizer.
const _examSystems = [
  ('📝', 'EXAM_PREP'),
  ('🎓', 'UNIVERSITY'),
  ('💻', 'CODING_INTERVIEW'),
  ('📊', 'PROFESSIONAL'),
  ('🌐', 'OTHER'),
];

String _examSystemLabel(AppLocalizations l, String id) => switch (id) {
      'EXAM_PREP' => l.createTutorExamPrep,
      'UNIVERSITY' => l.createTutorUniversity,
      'CODING_INTERVIEW' => l.createTutorCodingInterview,
      'PROFESSIONAL' => l.createTutorProfessional,
      _ => l.createTutorOtherGoal,
    };

class GradeStep extends StatelessWidget {
  const GradeStep({
    super.key,
    required this.gradeLevel,
    required this.curriculumType,
    required this.tutorName,
    required this.selectedCharacter,
    required this.contentLanguage,
    required this.onGradeChanged,
    required this.onCurriculumChanged,
    required this.onContentLanguageChanged,
    required this.isLoading,
    required this.onCreate,
  });

  final String? gradeLevel;
  final String? curriculumType;
  final String tutorName;
  final MochiCharacter? selectedCharacter;

  /// The language this avatar will generate content in — always a valid
  /// [AppLanguages] code (defaulted by the view model, never null here).
  final String contentLanguage;
  final ValueChanged<String?> onGradeChanged;
  final ValueChanged<String?> onCurriculumChanged;
  final ValueChanged<String> onContentLanguageChanged;
  final bool isLoading;
  final VoidCallback? onCreate;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final name = tutorName.isEmpty ? l.mascotName : tutorName;
    final accentColor = selectedCharacter?.primaryColor ?? AppColors.purple;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.createTutorGradeTitle, style: AppTextStyles.heading1),
          const SizedBox(height: AppSpacing.xs),
          Text(l.createTutorGradePrompt(name),
              style: AppTextStyles.body.copyWith(color: AppColors.text2)),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.createTutorAgeLabel,
                      style: AppTextStyles.label.copyWith(
                          color: AppColors.text3, letterSpacing: 0.8)),
                  const SizedBox(height: AppSpacing.sm),
                  // Single dropdown — cleaner than a wall of chips for a
                  // 13–21+ audience who know their age at a glance.
                  DropdownButtonFormField<String>(
                    value: gradeLevel,
                    hint: Text(l.createTutorSelectAge,
                        style: AppTextStyles.body
                            .copyWith(color: AppColors.text3)),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.surf2,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: AppColors.outline),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: AppColors.outline),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: accentColor, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                    ),
                    items: [
                      // "Clear" option so users can deselect
                      DropdownMenuItem<String>(
                        value: null,
                        child: Text(l.createTutorNotSet),
                      ),
                      ..._ageOptions.map((opt) => DropdownMenuItem<String>(
                            value: opt.value,
                            child: Text(opt.label,
                                style: AppTextStyles.body),
                          )),
                    ],
                    onChanged: onGradeChanged,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                      AppLocalizations.of(context).createTutorWishHelp(
                          AppLocalizations.of(context).mascotName),
                      style: AppTextStyles.label.copyWith(
                          color: AppColors.text3, letterSpacing: 0.8)),
                  const SizedBox(height: AppSpacing.sm),
                  ..._examSystems.map((e) {
                    final (icon, id) = e;
                    final label = _examSystemLabel(l, id);
                    final isActive = curriculumType == id;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: GestureDetector(
                        onTap: () =>
                            onCurriculumChanged(isActive ? null : id),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: isActive
                                ? accentColor.withValues(alpha: 0.1)
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: isActive
                                    ? accentColor
                                    : AppColors.outline,
                                width: isActive ? 2 : 1),
                          ),
                          child: Row(
                            children: [
                              Text(icon,
                                  style: const TextStyle(fontSize: 16)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(label,
                                    style: AppTextStyles.body.copyWith(
                                        color: isActive
                                            ? accentColor
                                            : AppColors.text1,
                                        fontWeight: isActive
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                        fontSize: 13)),
                              ),
                              if (isActive)
                                Icon(Icons.check_circle_rounded,
                                    color: accentColor, size: 20),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: AppSpacing.lg),
                  Text(l.createTutorLanguageLabel,
                      style: AppTextStyles.label.copyWith(
                          color: AppColors.text3, letterSpacing: 0.8)),
                  const SizedBox(height: AppSpacing.xs),
                  Text(l.createTutorLanguageHint(name),
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.text3)),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (final lang in AppLanguages.all)
                        _LanguageChip(
                          label: lang.endonym,
                          selected: contentLanguage == lang.code,
                          accentColor: accentColor,
                          onTap: () => onContentLanguageChanged(lang.code),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                top: AppSpacing.sm,
                bottom:
                    AppSpacing.md + MediaQuery.of(context).padding.bottom),
            child: PallyButton(
                label: l.createTutorCreateName(name),
                onPressed: onCreate,
                loading: isLoading,
                fullWidth: true),
          ),
        ],
      ),
    );
  }
}

/// Selectable pill for one [AppLanguages] entry. Deliberately a flat list of
/// registry entries, not a hardcoded en/zh pair — adding a language later is a
/// registry edit (see app_languages.dart), never a change here.
class _LanguageChip extends StatelessWidget {
  const _LanguageChip({
    required this.label,
    required this.selected,
    required this.accentColor,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? accentColor.withValues(alpha: 0.1)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: selected ? accentColor : AppColors.outline,
              width: selected ? 2 : 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: AppTextStyles.body.copyWith(
                    color: selected ? accentColor : AppColors.text1,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.w400,
                    fontSize: 13)),
            if (selected) ...[
              const SizedBox(width: 6),
              Icon(Icons.check_circle_rounded, color: accentColor, size: 16),
            ],
          ],
        ),
      ),
    );
  }
}
