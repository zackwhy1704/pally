import 'package:flutter/material.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/ui/pally_button.dart';
import 'package:pally/shared/models/avatar.dart';

const _gradeLevels = [
  'P1', 'P2', 'P3', 'P4', 'P5', 'P6',
  'S1', 'S2', 'S3', 'S4', 'S5',
  'Year 7', 'Year 8', 'Year 9', 'Year 10',
];

const _curriculums = [
  'Singapore MOE',
  'IB',
  'Cambridge',
  'Australian',
  'US Common Core',
  'Other',
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
  final AvatarCharacter? selectedCharacter;
  final ValueChanged<String?> onGradeChanged;
  final ValueChanged<String?> onCurriculumChanged;
  final bool isLoading;
  final VoidCallback? onCreate;

  @override
  Widget build(BuildContext context) {
    final name = tutorName.isEmpty ? 'your tutor' : tutorName;
    final accentColor = selectedCharacter?.primaryColor ?? AppColors.purple;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Almost there! 🎓', style: AppTextStyles.heading1),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Help $name teach at the right level. (Optional)',
            style: AppTextStyles.body.copyWith(color: AppColors.text2),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'GRADE / YEAR LEVEL',
            style: AppTextStyles.label.copyWith(
              color: AppColors.text3,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: _gradeLevels.map((g) {
              final isActive = gradeLevel == g;
              return ActionChip(
                label: Text(g),
                onPressed: () => onGradeChanged(isActive ? null : g),
                backgroundColor: isActive ? accentColor : AppColors.surface,
                labelStyle: AppTextStyles.bodySmall.copyWith(
                  color: isActive ? Colors.white : AppColors.text2,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                ),
                side: BorderSide(
                  color: isActive ? accentColor : AppColors.outline,
                ),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'CURRICULUM',
            style: AppTextStyles.label.copyWith(
              color: AppColors.text3,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: _curriculums.map((c) {
              final isActive = curriculumType == c;
              return ActionChip(
                label: Text(c),
                onPressed: () => onCurriculumChanged(isActive ? null : c),
                backgroundColor: isActive ? accentColor : AppColors.surface,
                labelStyle: AppTextStyles.bodySmall.copyWith(
                  color: isActive ? Colors.white : AppColors.text2,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                ),
                side: BorderSide(
                  color: isActive ? accentColor : AppColors.outline,
                ),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              );
            }).toList(),
          ),
          const Spacer(),
          PallyButton(
            label: 'Create $name! 🎉',
            onPressed: onCreate,
            loading: isLoading,
            fullWidth: true,
          ),
        ],
      ),
    );
  }
}
