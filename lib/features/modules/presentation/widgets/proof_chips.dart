import 'package:flutter/material.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';

/// The "one-to-one, for everyone" feature made visible on every card:
///  · [ProvenanceChip] — "From your notes: {title}", the trust marker (tap → wiki).
///  · [TargetingBadge] — pre-answer, dynamic: why THIS item is here (your weak spot).
///  · [ComebackLine] — post-answer payoff: you beat a concept that beat you before.
///
/// All degrade silently: fed null/empty (old content), the callers render nothing.

/// The concept inside a "WEAK_TOPIC:{concept}" quiz selectionReason, or null.
String? weakTopicConcept(String? selectionReason) {
  const prefix = 'WEAK_TOPIC:';
  if (selectionReason != null && selectionReason.startsWith(prefix)) {
    final c = selectionReason.substring(prefix.length).trim();
    return c.isEmpty ? null : c;
  }
  return null;
}

/// A PROVE priorScore below 0.5 means the student got this concept wrong in the Test.
bool isWeaknessScore(double? priorScore) =>
    priorScore != null && priorScore < 0.5;

/// "From your notes: {pageTitle}" — the provenance trust marker. Tappable to the wiki.
class ProvenanceChip extends StatelessWidget {
  const ProvenanceChip({super.key, required this.pageTitle, this.onTap});

  final String pageTitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surf2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.outline),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.menu_book_rounded, size: 12, color: AppColors.text2),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                'From your notes: $pageTitle',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(color: AppColors.text2),
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 2),
              const Icon(Icons.chevron_right_rounded,
                  size: 12, color: AppColors.text3),
            ],
          ],
        ),
      ),
    );
  }
}

/// Pre-answer targeting badge: why this item is being shown right now.
class TargetingBadge extends StatelessWidget {
  const TargetingBadge({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.amber.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.amber.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.my_location_rounded, size: 13, color: AppColors.amber),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              text,
              maxLines: 2,
              style: AppTextStyles.label.copyWith(
                  color: AppColors.text1, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

/// Post-answer payoff shown when the student beats a concept that beat them before.
class ComebackLine extends StatelessWidget {
  const ComebackLine({super.key, required this.concept});

  final String concept;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('🎉', style: TextStyle(fontSize: 14)),
        const SizedBox(width: AppSpacing.xs),
        Flexible(
          child: Text(
            "That's a comeback — $concept got you last time.",
            maxLines: 2,
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.green, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
