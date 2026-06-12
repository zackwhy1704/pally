import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/ui/pally_toast.dart';
import 'package:pally/features/progress/presentation/daily_goal_provider.dart';
import 'package:pally/shared/models/daily_goal.dart';

/// Apple-Fitness style ring for today's goal. Replaces the dead
/// weekMinutes bar chart — a glanceable purpose for the page.
class DailyGoalRing extends ConsumerWidget {
  const DailyGoalRing({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(dailyGoalVmProvider);
    return async.when(
      loading: () => const _Skeleton(),
      error: (_, __) => const SizedBox.shrink(),
      data: (g) => _Body(goal: g),
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();
  @override
  Widget build(BuildContext context) => Container(
        height: 168,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.outline),
        ),
      );
}

class _Body extends ConsumerWidget {
  const _Body({required this.goal});
  final DailyGoal goal;

  String get _unit => switch (goal.goalType) {
        'XP' => 'XP',
        'MINUTES' => 'min',
        _ => goal.goalTarget == 1 ? 'quiz' : 'quizzes',
      };

  String get _verb => switch (goal.goalType) {
        'XP' => 'XP earned today',
        'MINUTES' => 'minutes today',
        _ => goal.goalTarget == 1 ? 'daily quiz' : 'quizzes today',
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress =
        (goal.goalProgress / math.max(1, goal.goalTarget)).clamp(0.0, 1.0);
    final pct = (progress * 100).round();

    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 116,
            height: 116,
            child: CustomPaint(
              painter: _RingPainter(progress: progress, met: goal.met),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      goal.met ? '✓' : '${goal.goalProgress}',
                      style: AppTextStyles.heading1.copyWith(
                          color: goal.met
                              ? AppColors.green
                              : AppColors.purple,
                          fontSize: goal.met ? 36 : 28),
                    ),
                    Text(
                      goal.met
                          ? 'Goal'
                          : '/ ${goal.goalTarget} $_unit',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Today's goal", style: AppTextStyles.title),
                const SizedBox(height: 2),
                Text(
                  goal.met
                      ? 'Goal complete! Streak safe 🔥'
                      : '$pct% of your $_verb',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.text2),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: () => _GoalSheet.show(context, ref, goal),
                    icon: const Icon(Icons.tune_rounded, size: 16),
                    label: const Text('Set my goal'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.purple,
                      side: const BorderSide(color: AppColors.purpleL),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress, required this.met});
  final double progress;
  final bool met;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 8;
    final rect = Rect.fromCircle(center: centre, radius: radius);

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..color = AppColors.surf2;
    canvas.drawCircle(centre, radius, track);

    if (progress <= 0) return;

    final fill = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 12
      ..shader = LinearGradient(
        colors: met
            ? const [AppColors.green, AppColors.teal]
            : const [AppColors.purple, AppColors.pink],
      ).createShader(rect);
    const start = -math.pi / 2;
    canvas.drawArc(rect, start, 2 * math.pi * progress, false, fill);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress || old.met != met;
}

class _GoalSheet extends StatefulWidget {
  const _GoalSheet({required this.current});
  final DailyGoal current;

  static void show(BuildContext context, WidgetRef ref, DailyGoal current) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _GoalSheet(current: current),
    );
  }

  @override
  State<_GoalSheet> createState() => _GoalSheetState();
}

class _GoalSheetState extends State<_GoalSheet> {
  late String _type = widget.current.goalType;
  late int _target = widget.current.goalTarget;

  static const _options = <String, List<int>>{
    'QUIZ': [1, 2, 3],
    'XP': [20, 50, 100],
    'MINUTES': [10, 20, 30],
  };

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Consumer(builder: (context, ref, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.lg),
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
              Text('Pick your daily goal', style: AppTextStyles.title),
              const SizedBox(height: 4),
              Text('Close this ring every day to keep your streak safe.',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.text2)),
              const SizedBox(height: AppSpacing.md),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'QUIZ', label: Text('Quizzes')),
                  ButtonSegment(value: 'XP', label: Text('XP')),
                  ButtonSegment(value: 'MINUTES', label: Text('Minutes')),
                ],
                selected: {_type},
                onSelectionChanged: (s) => setState(() {
                  _type = s.first;
                  _target = _options[_type]!.first;
                }),
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                children: _options[_type]!.map((v) {
                  final selected = v == _target;
                  return ChoiceChip(
                    label: Text('$v ${_unitOf(_type, v)}'),
                    selected: selected,
                    onSelected: (_) => setState(() => _target = v),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    HapticFeedback.lightImpact();
                    try {
                      await ref
                          .read(dailyGoalVmProvider.notifier)
                          .setGoal(_type, _target);
                      if (!context.mounted) return;
                      Navigator.of(context).pop();
                    } catch (_) {
                      if (!context.mounted) return;
                      PallyToast.error(
                          context, 'Could not save goal. Try again.');
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.purple,
                    padding:
                        const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Commit to my goal'),
                ),
              ),
            ],
            ),
          );
        }),
      ),
    );
  }

  static String _unitOf(String type, int v) => switch (type) {
        'XP' => 'XP',
        'MINUTES' => 'min',
        _ => v == 1 ? 'quiz' : 'quizzes',
      };
}
