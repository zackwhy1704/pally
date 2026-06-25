import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pally/app/router.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';

/// Contextual "invite a friend" nudge surfaced AT a moment of delight (a streak
/// milestone) — never an interruptive pop-up. Shows at most once per milestone
/// (persisted), is dismissible, and renders nothing off-milestone or once seen.
class MilestoneInviteNudge extends StatefulWidget {
  const MilestoneInviteNudge({super.key, required this.streakDays});

  final int streakDays;

  /// Streak lengths worth celebrating with an invite ask.
  static const List<int> milestones = [3, 7, 14, 30, 60, 100];

  static int milestoneFor(int streakDays) {
    int reached = 0;
    for (final m in milestones) {
      if (streakDays >= m) reached = m;
    }
    return reached;
  }

  @override
  State<MilestoneInviteNudge> createState() => _MilestoneInviteNudgeState();
}

class _MilestoneInviteNudgeState extends State<MilestoneInviteNudge> {
  int _milestone = 0;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _evaluate();
  }

  Future<void> _evaluate() async {
    final milestone = MilestoneInviteNudge.milestoneFor(widget.streakDays);
    if (milestone == 0) return;
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool(_key(milestone)) ?? false;
    if (!seen && mounted) {
      setState(() {
        _milestone = milestone;
        _visible = true;
      });
    }
  }

  String _key(int milestone) => 'invite_nudge_streak_$milestone';

  Future<void> _markSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key(_milestone), true);
    if (mounted) setState(() => _visible = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.purpleL,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.purple.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 24)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$_milestone-day streak — nice!',
                    style: AppTextStyles.body
                        .copyWith(fontWeight: FontWeight.w800, color: AppColors.text1)),
                Text('Invite a friend — you both get bonus stars.',
                    style: AppTextStyles.caption.copyWith(color: AppColors.text2)),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          TextButton(
            onPressed: () {
              _markSeen();
              const InviteRoute().push(context);
            },
            child: Text('Invite',
                style: AppTextStyles.body
                    .copyWith(fontWeight: FontWeight.w700, color: AppColors.purple)),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: _markSeen,
            icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.text3),
            tooltip: 'Dismiss',
          ),
        ],
      ),
    );
  }
}
