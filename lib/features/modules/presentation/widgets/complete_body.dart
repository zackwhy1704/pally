import 'package:flutter/material.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_sizing.dart';
import 'package:pally/shared/models/learning_module.dart';

// ── COMPLETE stage ──────────────────────────────────────────────────────────

class CompleteBody extends StatelessWidget {
  const CompleteBody({super.key, required this.results, required this.onBack});
  final ModuleResults? results;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final concepts = results?.concepts ?? const [];
    final xpEarned = results?.xpEarned ?? 0;

    // Find the weakest concept for recommendation
    ConceptMastery? weakest;
    for (final c in concepts) {
      if (weakest == null || c.mastery < weakest.mastery) {
        weakest = c;
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.lg),
          // Celebration
          Container(
            width: MediaQuery.of(context).size.shortestSide * 0.3,
            height: MediaQuery.of(context).size.shortestSide * 0.3,
            decoration: const BoxDecoration(
              color: AppColors.greenL,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.celebration_rounded,
                  size: 48, color: AppColors.green),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Module complete!', style: AppTextStyles.heading1),
          if (xpEarned > 0) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.amberL,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '+$xpEarned XP',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.amber,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],

          // Mastery bars
          if (concepts.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xl),
            Text('Your mastery',
                style: AppTextStyles.title.copyWith(fontSize: 16)),
            const SizedBox(height: AppSpacing.md),
            ...concepts.map((c) => MasteryRow(concept: c)),
          ],

          // Weakest concept recommendation
          if (weakest != null && !weakest.passed) ...[
            const SizedBox(height: AppSpacing.lg),
            Container(
              width: double.infinity,
              padding: AppSpacing.card,
              decoration: BoxDecoration(
                color: AppColors.amberL,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppColors.amber.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Focus area',
                      style: AppTextStyles.label.copyWith(
                          color: AppColors.amber,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Review "${weakest.concept}" to improve your mastery.',
                    style: AppTextStyles.body,
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            height: AppSizing.buttonHeight,
            child: FilledButton(
              onPressed: onBack,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.purple,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Back to modules'),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + AppSpacing.md),
        ],
      ),
    );
  }
}

class MasteryRow extends StatelessWidget {
  const MasteryRow({super.key, required this.concept});
  final ConceptMastery concept;

  @override
  Widget build(BuildContext context) {
    final pct = (concept.mastery * 100).round();
    final color = concept.passed ? AppColors.green : AppColors.amber;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                concept.passed
                    ? Icons.check_circle_rounded
                    : Icons.circle_outlined,
                size: 16,
                color: color,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  concept.concept,
                  style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('$pct%',
                  style: AppTextStyles.label.copyWith(
                      color: color, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: concept.mastery.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: AppColors.outline,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          if (concept.feedback.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(concept.feedback,
                style: AppTextStyles.caption.copyWith(color: AppColors.text2)),
          ],
        ],
      ),
    );
  }
}

// ── Revision mode banner ───────────────────────────────────────────────────

class RevisionBanner extends StatelessWidget {
  const RevisionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      color: AppColors.purpleL,
      child: Row(
        children: [
          const Icon(Icons.replay_rounded, size: 18, color: AppColors.purple),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Revision mode — fresh questions to check your progress.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.purple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
