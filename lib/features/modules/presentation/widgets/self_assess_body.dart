import 'package:flutter/material.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/ui/adaptive_content_width.dart';
import 'package:pally/features/modules/presentation/module_player_view_model.dart';

/// Post-PROVE self-assessment (Tier 2). For each open-ended answer the student
/// compares theirs to the reference and reports Yes / Partly / No. The system
/// never asserts correctness here — the student does. Optional + non-blocking:
/// "Continue" is always enabled.
class SelfAssessBody extends StatelessWidget {
  const SelfAssessBody({
    super.key,
    required this.items,
    required this.reports,
    required this.onReport,
    required this.onDone,
  });

  final List<SelfAssessItem> items;

  /// itemId -> YES/PARTLY/NO already chosen.
  final Map<String, String> reports;
  final void Function(String itemId, String report) onReport;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return AdaptiveContentWidth(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Mark your own answers', style: AppTextStyles.heading1),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Compare what you wrote to the reference. Be honest — this just '
              'helps Mochi learn what to revisit.',
              style: AppTextStyles.body.copyWith(color: AppColors.text2),
            ),
            const SizedBox(height: AppSpacing.lg),
            for (final item in items) ...[
              _SelfAssessCard(
                item: item,
                selected: reports[item.itemId],
                onReport: (r) => onReport(item.itemId, r),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            const SizedBox(height: AppSpacing.sm),
            FilledButton(
              onPressed: onDone,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.purple,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              ),
              child: const Text('Continue'),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _SelfAssessCard extends StatelessWidget {
  const _SelfAssessCard({
    required this.item,
    required this.selected,
    required this.onReport,
  });

  final SelfAssessItem item;
  final String? selected;
  final void Function(String report) onReport;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.question, style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.sm),
          _labelled('Your answer', item.yourAnswer.isEmpty ? '—' : item.yourAnswer,
              AppColors.surf2),
          const SizedBox(height: AppSpacing.sm),
          _labelled('Reference', item.reference.isEmpty ? '—' : item.reference,
              AppColors.tealL),
          const SizedBox(height: AppSpacing.md),
          Text('Did you get it?',
              style: AppTextStyles.label.copyWith(color: AppColors.text2)),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              _choice('Yes', 'YES', AppColors.green),
              const SizedBox(width: AppSpacing.sm),
              _choice('Partly', 'PARTLY', AppColors.amber),
              const SizedBox(width: AppSpacing.sm),
              _choice('No', 'NO', AppColors.coral),
            ],
          ),
        ],
      ),
    );
  }

  Widget _labelled(String label, String value, Color bg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTextStyles.label.copyWith(color: AppColors.text2)),
          const SizedBox(height: 2),
          Text(value, style: AppTextStyles.body.copyWith(color: AppColors.text1)),
        ],
      ),
    );
  }

  Widget _choice(String label, String value, Color color) {
    final isSelected = selected == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => onReport(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: isSelected ? color : AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.sm),
            border: Border.all(
                color: isSelected ? color : AppColors.outline, width: 1.5),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.label.copyWith(
              color: isSelected ? AppColors.surface : AppColors.text1,
            ),
          ),
        ),
      ),
    );
  }
}
