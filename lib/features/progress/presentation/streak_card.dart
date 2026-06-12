import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/features/progress/presentation/streak_status_provider.dart';
import 'package:pally/shared/models/streak_status.dart';

/// Streak hero card. Replaces the bare day-count in the old `_StatsRow`.
class StreakCard extends ConsumerWidget {
  const StreakCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(streakStatusVmProvider);
    return async.when(
      loading: () => const _Skeleton(),
      error: (_, __) => const SizedBox.shrink(),
      data: (s) => _Body(status: s),
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 132,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.status});
  final StreakStatus status;

  @override
  Widget build(BuildContext context) {
    final goalText = status.daysToMilestone == 0
        ? 'Milestone reached — keep stacking!'
        : '${status.daysToMilestone} day${status.daysToMilestone == 1 ? '' : 's'} '
            'to ${_milestoneLabel(status.nextMilestone)}';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _StreakDetailSheet.show(context, status),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.coral, AppColors.amber],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: AppSpacing.card,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Number + unit group takes the remaining width and shrinks
                  // (label ellipsises) before the freeze pill is pushed off the
                  // right edge on small screens / large text scales.
                  Expanded(
                    child: Row(
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 36)),
                        const SizedBox(width: AppSpacing.sm),
                        _StreakNumber(value: status.streakDays),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              status.streakDays == 1 ? 'day' : 'days',
                              style: AppTextStyles.body.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _FreezePill(freezes: status.freezes),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              _WeekStrip(last7: status.last7),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  const Icon(Icons.flag_rounded,
                      color: Colors.white70, size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      goalText,
                      style:
                          AppTextStyles.bodySmall.copyWith(color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded,
                      color: Colors.white70, size: 12),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _milestoneLabel(int days) {
    if (days >= 365) return 'a full year';
    if (days >= 100) return '100 days';
    if (days >= 30) return '30-day badge';
    if (days >= 14) return '2-week badge';
    if (days >= 7) return '1-week badge';
    return '$days days';
  }
}

/// Odometer-style number — animates between digit changes when the
/// streak ticks. Big and unmissable; the whole point of the card.
class _StreakNumber extends StatelessWidget {
  const _StreakNumber({required this.value});
  final int value;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      transitionBuilder: (child, anim) => SlideTransition(
        position: Tween(begin: const Offset(0, -0.4), end: Offset.zero)
            .animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
        child: FadeTransition(opacity: anim, child: child),
      ),
      child: Text(
        '$value',
        key: ValueKey<int>(value),
        style: AppTextStyles.heading1
            .copyWith(color: Colors.white, fontSize: 40, height: 1.0),
      ),
    );
  }
}

class _FreezePill extends StatelessWidget {
  const _FreezePill({required this.freezes});
  final int freezes;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: const Duration(seconds: 3),
          content: Text(freezes > 0
              ? 'A freeze saves your streak if you miss one day.'
              : 'Earn a freeze by hitting a new 7-day milestone.'),
          backgroundColor: AppColors.text1,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('❄️', style: TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Text(
              '$freezes',
              style: AppTextStyles.label
                  .copyWith(color: Colors.white, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekStrip extends StatelessWidget {
  const _WeekStrip({required this.last7});
  final List<bool> last7;

  @override
  Widget build(BuildContext context) {
    // Take the last 7 values defensively in case backend ever sends more.
    final dots = last7.length > 7
        ? last7.sublist(last7.length - 7)
        : List<bool>.filled(7 - last7.length, false) + last7;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final active = dots[i];
        final isToday = i == 6;
        final size = isToday ? 18.0 : 14.0;
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? Colors.white : Colors.white.withValues(alpha: 0.18),
            border: isToday ? Border.all(color: Colors.white, width: 2) : null,
          ),
          child: active && isToday
              ? const Icon(Icons.check_rounded,
                  size: 12, color: AppColors.coral)
              : null,
        );
      }),
    );
  }
}

class _StreakDetailSheet extends StatelessWidget {
  const _StreakDetailSheet({required this.status});
  final StreakStatus status;

  static void show(BuildContext context, StreakStatus status) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _StreakDetailSheet(status: status),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reached = status.milestonesReached.toSet();
    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text('Streak ladder',
                        style: AppTextStyles.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text('Best: ${status.longestStreak} days',
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              for (final m in status.ladder) ...[
                _LadderRow(
                  milestone: m,
                  reached: reached.contains(m) || status.streakDays >= m,
                  current: status.nextMilestone == m,
                  streakDays: status.streakDays,
                ),
                const SizedBox(height: AppSpacing.xs),
              ],
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Freezes save your streak when you miss a day. Hit each new 7-day '
                'milestone to earn one back (up to 3).',
                style: AppTextStyles.caption.copyWith(color: AppColors.text2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LadderRow extends StatelessWidget {
  const _LadderRow({
    required this.milestone,
    required this.reached,
    required this.current,
    required this.streakDays,
  });

  final int milestone;
  final bool reached;
  final bool current;
  final int streakDays;

  @override
  Widget build(BuildContext context) {
    final color = reached
        ? AppColors.gold
        : current
            ? AppColors.amber
            : AppColors.text3;
    final bg = reached
        ? AppColors.goldL
        : current
            ? AppColors.amberL
            : AppColors.surf2;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: current ? Border.all(color: AppColors.amber, width: 1.5) : null,
      ),
      child: Row(
        children: [
          Icon(reached ? Icons.workspace_premium_rounded : Icons.flag_outlined,
              color: color, size: 22),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              '$milestone-day streak',
              style: AppTextStyles.body.copyWith(
                  color: reached ? AppColors.text1 : AppColors.text2,
                  fontWeight: FontWeight.w700),
            ),
          ),
          Text(
            reached
                ? 'Earned'
                : (current ? '$streakDays/$milestone' : 'Locked'),
            style: AppTextStyles.label.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
