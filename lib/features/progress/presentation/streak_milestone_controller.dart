import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pally/features/progress/presentation/streak_milestone_overlay.dart';

/// Fires the streak-milestone overlay exactly once per newly-reached milestone.
///
/// The server returns the CUMULATIVE set of reached milestones (e.g. [3, 7]) on
/// every `/progress/streak` poll, so the client is the only thing that prevents
/// re-celebrating. Two hazards this guards against:
///  1. **Lost / cross-account prefs** — the "seen" set is keyed by userId, so a
///     reinstall, logout→login, or a different account on the same device does
///     not inherit (or leak) another state's celebrations.
///  2. **Concurrent emissions** — `ref.listen(streakStatusVmProvider)` fires on
///     every emission (tab focus, pull-refresh, invalidate). The prefs read→write
///     is async, so two rapid emissions could both pass the dedup before either
///     persists. We claim each (user, milestone) pair SYNCHRONOUSLY in-memory so
///     only the first emission proceeds.
class StreakMilestoneController {
  StreakMilestoneController._();

  static const _prefsKeyBase = 'streak_milestones_seen';

  /// Synchronous in-session guard: a (userId|milestone) is claimed before the
  /// first `await`, so a racing emission sees it already claimed and bails.
  static final Set<String> _inFlight = <String>{};

  static String _prefsKey(String? userId) => '${_prefsKeyBase}_${userId ?? 'anon'}';

  /// Test-only hook to reset the in-memory guard between cases.
  @visibleForTesting
  static void resetInFlightForTest() => _inFlight.clear();

  static Future<void> maybeCelebrate(
    BuildContext context, {
    required List<int> milestonesReached,
    String? userId,
  }) async {
    if (milestonesReached.isEmpty) return;

    // Synchronously claim each milestone for this session, BEFORE any await, so
    // a second emission racing this one cannot also pass the dedup.
    final claimed = <String>[];
    for (final m in milestonesReached) {
      if (_inFlight.add('${userId ?? 'anon'}|$m')) {
        claimed.add(m.toString());
      }
    }
    if (claimed.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final key = _prefsKey(userId);
    final seen = prefs.getStringList(key)?.toSet() ?? <String>{};
    final newly = claimed.where((m) => !seen.contains(m)).toList();
    if (newly.isEmpty) return;

    // Persist immediately so a cold start / next session doesn't re-fire.
    await prefs.setStringList(key, {...seen, ...newly}.toList());
    for (final m in newly) {
      if (!context.mounted) return;
      await StreakMilestoneOverlay.show(context, int.parse(m));
    }
  }
}
