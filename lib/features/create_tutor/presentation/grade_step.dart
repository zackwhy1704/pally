import 'package:flutter/material.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/ui/pally_button.dart';

const _grades = [
  'K', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12',
];

const _curricula = [
  'Common Core', 'IB', 'Cambridge', 'National', 'Montessori', 'Other',
];

class GradeStep extends StatelessWidget {
  const GradeStep({
    super.key,
    required this.gradeLevel,
    required this.curriculumType,
    required this.onGradeChanged,
    required this.onCurriculumChanged,
    required this.onCreate,
    required this.isLoading,
  });

  final String? gradeLevel;
  final String? curriculumType;
  final ValueChanged<String?> onGradeChanged;
  final ValueChanged<String?> onCurriculumChanged;
  final VoidCallback onCreate;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Almost done!', style: AppTextStyles.heading1),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Help your tutor teach at the right level (optional).',
            style: AppTextStyles.body.copyWith(color: AppColors.text2),
          ),
          const SizedBox(height: AppSpacing.lg),

          Text('Grade level', style: AppTextStyles.label),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: _grades.map((g) {
              final selected = gradeLevel == g;
              return GestureDetector(
                onTap: () => onGradeChanged(selected ? null : g),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.purple : AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          selected ? AppColors.purple : AppColors.outline,
                    ),
                  ),
                  child: Text(
                    g,
                    style: AppTextStyles.label.copyWith(
                      color: selected ? Colors.white : AppColors.text2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: AppSpacing.lg),

          Text('Curriculum', style: AppTextStyles.label),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: _curricula.map((c) {
              final selected = curriculumType == c;
              return GestureDetector(
                onTap: () => onCurriculumChanged(selected ? null : c),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.teal : AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected ? AppColors.teal : AppColors.outline,
                    ),
                  ),
                  child: Text(
                    c,
                    style: AppTextStyles.label.copyWith(
                      color: selected ? Colors.white : AppColors.text2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const Spacer(),

          PallyButton(
            label: 'Create Tutor!',
            onPressed: isLoading ? null : onCreate,
            loading: isLoading,
          ),
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: TextButton(
              onPressed: onCreate,
              child: Text(
                'Skip for now',
                style: AppTextStyles.body.copyWith(color: AppColors.text3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
