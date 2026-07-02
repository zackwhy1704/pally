import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/core/services/feature_flags.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/features/subscription/trial_status_provider.dart';

/// Escalating trial countdown banner shown on the home screen.
/// One banner, never stacked. Dismissible per-session; returns next launch.
/// Driven entirely by server-provided trial data (honest timers).
class TrialCountdownBanner extends ConsumerStatefulWidget {
  const TrialCountdownBanner({super.key});

  @override
  ConsumerState<TrialCountdownBanner> createState() =>
      _TrialCountdownBannerState();
}

class _TrialCountdownBannerState extends ConsumerState<TrialCountdownBanner> {
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();
    final trialAsync = ref.watch(trialStatusProvider);
    final trial = trialAsync.valueOrNull;
    if (trial == null || !trial.isOnTrial) return const SizedBox.shrink();

    final days  = trial.trialDaysLeft;
    final hours = trial.trialHoursLeft;
    final isUrgent  = days == 0;       // <24h
    final isWarning = days <= 2 && days > 0;
    final isCalm    = days >= 3;

    final bg     = isUrgent  ? AppColors.amberL
                 : isWarning ? AppColors.amberL
                             : AppColors.purpleL;
    final fg     = isUrgent || isWarning ? AppColors.amber : AppColors.purple;
    final border = fg.withValues(alpha: 0.35);

    final timeLabel = isUrgent
        ? '${hours}h left'
        : '$days day${days == 1 ? '' : 's'} left';

    final body = isUrgent
        ? 'Last day of Premium! ⏳ $timeLabel — keep your Mochis.'
        : isWarning
            ? '$timeLabel of Premium — subscribe to keep all your Mochis.'
            : '$timeLabel of Premium · Enjoying unlimited Mochis? Keep them after.';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => context.push('/subscription/plans'),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Text(isUrgent ? '⏰' : '⭐',
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        body,
                        style: AppTextStyles.bodySmall.copyWith(
                            color: fg, fontWeight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _dismissed = true),
                      child: Icon(Icons.close_rounded, size: 16, color: fg),
                    ),
                  ],
                ),
                if (isCalm) ...[
                  const SizedBox(height: 6),
                  _DotTrack(totalDays: 7, daysLeft: days, color: fg),
                ],
                if (isUrgent) ...[
                  const SizedBox(height: 8),
                  _WhatLocksCard(fgColor: fg),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => context.push('/subscription/plans'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.amber,
                        padding:
                            const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                          allowPriceDisplay(ref)
                              ? 'Keep Premium from US\$9.99/mo'
                              : 'Keep Premium',
                          style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w800,
                              color: Colors.white)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DotTrack extends StatelessWidget {
  const _DotTrack({
    required this.totalDays,
    required this.daysLeft,
    required this.color,
  });
  final int totalDays;
  final int daysLeft;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalDays, (i) {
        final filled = i < (totalDays - daysLeft);
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1.5),
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: filled
                    ? color.withValues(alpha: 0.35)
                    : color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _WhatLocksCard extends StatelessWidget {
  const _WhatLocksCard({required this.fgColor});
  final Color fgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('When your trial ends:',
              style: AppTextStyles.caption.copyWith(
                  color: fgColor, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          ...[
            '🔒 Extra Mochis locked (you keep 1 free)',
            '💬 Chat capped at 80/day (was unlimited)',
            '📊 Advanced quiz & study plan limited',
          ].map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(s,
                    style: AppTextStyles.caption.copyWith(
                        color: fgColor.withValues(alpha: 0.85))),
              )),
        ],
      ),
    );
  }
}
