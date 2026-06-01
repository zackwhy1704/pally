import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';

const _kSeenTipKey = 'seen_mode_toggle_tip_v1';
const _kAnswerNudgeKey = 'answer_nudge_session_date';
const _kAnswerOnlyCountKey = 'answer_only_streak';

/// GM2 — One-time coach-mark bubble above the mode toggle.
/// Shows once; dismissed by tapping or switching mode.
class ModeCoachMark extends StatefulWidget {
  const ModeCoachMark({super.key, required this.child});
  final Widget child;

  @override
  State<ModeCoachMark> createState() => _ModeCoachMarkState();
}

class _ModeCoachMarkState extends State<ModeCoachMark> {
  bool _show = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool(_kSeenTipKey) ?? false;
    if (!seen && mounted) setState(() => _show = true);
  }

  Future<void> _dismiss() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kSeenTipKey, true);
    if (mounted) setState(() => _show = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!_show) return widget.child;
    // Coach mark is now positioned in the body Stack (not the AppBar Row),
    // so it can render at full height without causing a vertical overflow.
    // The bubble floats at the top of the chat body, directly below the AppBar.
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: _dismiss,
          child: Container(
            margin: const EdgeInsets.only(
                right: AppSpacing.sm, left: AppSpacing.md, top: AppSpacing.xs),
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.purple,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.purple.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('✨', style: TextStyle(fontSize: 16)),
                const SizedBox(width: AppSpacing.sm),
                Flexible(
                  child: Text(
                    'Tap the toggle to switch how Mochi helps you.',
                    style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                const Icon(Icons.close_rounded, size: 14, color: Colors.white70),
              ],
            ),
          ),
        ),
      ],
    );
  }
}


/// GM4 — Gentle once-per-session nudge when ANSWER mode is active.
/// Shows the first time ANSWER mode is used in a session; never again that session.
class AnswerModeNudge extends StatefulWidget {
  const AnswerModeNudge({super.key});

  @override
  State<AnswerModeNudge> createState() => _AnswerModeNudgeState();
}

class _AnswerModeNudgeState extends State<AnswerModeNudge> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final lastShown = prefs.getString(_kAnswerNudgeKey) ?? '';
    if (lastShown != today && mounted) {
      await prefs.setString(_kAnswerNudgeKey, today);
      setState(() => _visible = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.xs, AppSpacing.md, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.amberL,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: AppColors.amber.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            const Text('💡', style: TextStyle(fontSize: 14)),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Full answer coming up — try Guide Me sometimes, '
                'you\'ll remember more.',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.amber, fontWeight: FontWeight.w600),
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => _visible = false),
              child: const Icon(Icons.close_rounded, size: 14, color: AppColors.amber),
            ),
          ],
        ),
      ),
    );
  }
}

/// Records that the user sent a message in ANSWER mode.
/// After [threshold] consecutive ANSWER-only messages, returns true once
/// so the caller can show the gentle "try Guide Me" reminder.
Future<bool> shouldShowGuideMeReminder({int threshold = 5}) async {
  final prefs = await SharedPreferences.getInstance();
  final count = (prefs.getInt(_kAnswerOnlyCountKey) ?? 0) + 1;
  await prefs.setInt(_kAnswerOnlyCountKey, count);
  if (count == threshold) {
    await prefs.setInt(_kAnswerOnlyCountKey, 0); // reset after showing
    return true;
  }
  return false;
}

/// Call this when the user switches to Guide mode to reset the streak.
Future<void> resetAnswerOnlyStreak() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt(_kAnswerOnlyCountKey, 0);
}
