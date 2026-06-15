import 'package:flutter/material.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/shared/models/wiki_page.dart';

/// Maps a review state to its colour-only signal used on small cards.
Color reviewStateColor(WikiReviewState state) => switch (state) {
      WikiReviewState.verified => AppColors.green,
      WikiReviewState.flagged => AppColors.coral,
      WikiReviewState.lowConfidence => AppColors.amber,
      WikiReviewState.unverified => AppColors.text3,
    };

/// Tiny colour dot shown at card density — no text, just the status colour.
class ReviewStatusDot extends StatelessWidget {
  const ReviewStatusDot({super.key, required this.state});
  final WikiReviewState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: reviewStateColor(state),
        shape: BoxShape.circle,
      ),
    );
  }
}

/// The per-page review surface: a small chip for VERIFIED/UNVERIFIED, a full
/// banner for LOW_CONFIDENCE/FLAGGED. All variants are tappable to open the
/// "get it checked" sheet; banners also expose a "Fix my notes" action.
class ReviewStateSurface extends StatelessWidget {
  const ReviewStateSurface({
    super.key,
    required this.page,
    required this.onGetChecked,
    this.onFixNotes,
  });

  final WikiPage page;
  final VoidCallback onGetChecked;
  final VoidCallback? onFixNotes;

  @override
  Widget build(BuildContext context) {
    switch (page.reviewState) {
      case WikiReviewState.verified:
        return Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xs),
          child: _StatusChip(
            color: AppColors.green,
            bg: AppColors.greenL,
            icon: Icons.verified_rounded,
            label: 'Checked by ${page.verifiedBy ?? 'a reviewer'} ✓',
            onTap: onGetChecked,
          ),
        );
      case WikiReviewState.unverified:
        return Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xs),
          child: _StatusChip(
            color: AppColors.text2,
            bg: AppColors.surf2,
            icon: Icons.help_outline_rounded,
            label: 'Unverified',
            onTap: onGetChecked,
          ),
        );
      case WikiReviewState.lowConfidence:
        return _ReviewBanner(
          color: AppColors.amber,
          bg: AppColors.amberL,
          icon: Icons.lightbulb_outline_rounded,
          title:
              'This was made from limited notes — double-check key facts.',
          onGetChecked: onGetChecked,
          onFixNotes: onFixNotes,
        );
      case WikiReviewState.flagged:
        return _ReviewBanner(
          color: AppColors.coral,
          bg: AppColors.coralL,
          icon: Icons.flag_rounded,
          title: '${page.verifiedBy ?? 'A reviewer'} flagged something:',
          detail: page.flagNote,
          onGetChecked: onGetChecked,
          onFixNotes: onFixNotes,
        );
    }
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.color,
    required this.bg,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final Color color;
  final Color bg;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                label,
                style: AppTextStyles.caption
                    .copyWith(color: color, fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewBanner extends StatelessWidget {
  const _ReviewBanner({
    required this.color,
    required this.bg,
    required this.icon,
    required this.title,
    this.detail,
    required this.onGetChecked,
    this.onFixNotes,
  });

  final Color color;
  final Color bg;
  final IconData icon;
  final String title;
  final String? detail;
  final VoidCallback onGetChecked;
  final VoidCallback? onFixNotes;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.bodySmall.copyWith(
                      color: color, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          if (detail != null && detail!.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              detail!,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.text1),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          // Actions row — wraps so two buttons never overflow on narrow cards.
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              _BannerAction(
                color: color,
                icon: Icons.task_alt_rounded,
                label: 'Get it checked',
                onTap: onGetChecked,
              ),
              if (onFixNotes != null)
                _BannerAction(
                  color: color,
                  icon: Icons.edit_outlined,
                  label: 'Fix my notes',
                  onTap: onFixNotes!,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BannerAction extends StatelessWidget {
  const _BannerAction({
    required this.color,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final Color color;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: AppTextStyles.caption
                  .copyWith(color: color, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
