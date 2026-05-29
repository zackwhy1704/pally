import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pally/features/progress/presentation/streak_milestone_overlay.dart';

/// Fires the streak-milestone overlay for each milestone that's newly in
/// the user's "reached" list since the last check. Persists the seen set
/// in SharedPreferences so the celebration is one-shot per device.
class StreakMilestoneController {
  StreakMilestoneController._();

  static const _prefsKey = 'streak_milestones_seen';

  static Future<void> maybeCelebrate(
    BuildContext context, {
    required List<int> milestonesReached,
  }) async {
    if (milestonesReached.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getStringList(_prefsKey)?.toSet() ?? <String>{};
    final newly = milestonesReached
        .map((m) => m.toString())
        .where((m) => !seen.contains(m))
        .toList();
    if (newly.isEmpty) return;
    // Persist immediately so a fast tab switch doesn't trigger twice.
    await prefs.setStringList(_prefsKey, {...seen, ...newly}.toList());
    for (final m in newly) {
      if (!context.mounted) return;
      await StreakMilestoneOverlay.show(context, int.parse(m));
    }
  }
}
