import 'package:flutter/material.dart';
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

// Curriculum options — SG-first ordering; CAMBRIDGE id unchanged so existing
// avatar records need no migration. University added for 13–25+ audience.
const _examSystems = [
  ('🇸🇬', 'Singapore / Cambridge (O-Level / A-Level)', 'CAMBRIDGE'),
  ('🇸🇬', 'Singapore PSLE', 'SG_PSLE'),
  ('🌍', 'IB (PYP / MYP / Diploma)', 'IB'),
  ('🇲🇾', 'Malaysia SPM / KSSM', 'MY_SPM'),
  ('🇬🇧', 'UK GCSE / A-Level', 'UK_GCSE'),
  ('🇺🇸', 'US Common Core / AP', 'US_AP'),
  ('🇦🇺', 'Australian Curriculum', 'AU_ATAR'),
  ('🎓', 'University / Self-directed', 'UNIVERSITY'),
  ('🌐', 'Other / Not sure', 'OTHER'),
];

class GradeStep extends StatelessWidget {
  const GradeStep({
    super.key,
    required this.gradeLevel,
    required this.curriculumType,
    required this.tutorName,
    required this.selectedCharacter,
    required this.onGradeChanged,
    required this.onCurriculumChanged,
    required this.isLoading,
    required this.onCreate,
  });

  final String? gradeLevel;
  final String? curriculumType;
  final String tutorName;
  final MochiCharacter? selectedCharacter;
  final ValueChanged<String?> onGradeChanged;
  final ValueChanged<String?> onCurriculumChanged;
  final bool isLoading;
  final VoidCallback? onCreate;

  @override
  Widget build(BuildContext context) {
    final name = tutorName.isEmpty ? 'your tutor' : tutorName;
    final accentColor = selectedCharacter?.primaryColor ?? AppColors.purple;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Almost there! 🎓', style: AppTextStyles.heading1),
          const SizedBox(height: AppSpacing.xs),
          Text('Help $name teach at the right level. (Optional)',
              style: AppTextStyles.body.copyWith(color: AppColors.text2)),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AGE',
                      style: AppTextStyles.label.copyWith(
                          color: AppColors.text3, letterSpacing: 0.8)),
                  const SizedBox(height: AppSpacing.sm),
                  // Single dropdown — cleaner than a wall of chips for a
                  // 13–21+ audience who know their age at a glance.
                  DropdownButtonFormField<String>(
                    value: gradeLevel,
                    hint: Text('Select age (optional)',
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
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('— Not set —'),
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
                  Text('EXAM SYSTEM / CURRICULUM',
                      style: AppTextStyles.label.copyWith(
                          color: AppColors.text3, letterSpacing: 0.8)),
                  const SizedBox(height: AppSpacing.sm),
                  ..._examSystems.map((e) {
                    final (icon, label, id) = e;
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
                label: 'Done — Create $name! 🎉',
                onPressed: onCreate,
                loading: isLoading,
                fullWidth: true),
          ),
        ],
      ),
    );
  }
}
