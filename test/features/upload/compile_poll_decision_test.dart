import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/upload/presentation/upload_view_model.dart';

/// Pins the compile-poll give-up policy. Before the fix the poller gave up on a
/// fixed 5-minute wall-clock, false-failing large files that legitimately take
/// 5-7 minutes in the background. Now it keeps polling while pages are still being
/// added and only gives up on a genuine stall, an absolute ceiling, or backend done.
void main() {
  group('decideCompilePoll', () {
    test('KEEPS polling past 5 min while pages are still advancing (the fix)', () {
      // 6 minutes elapsed — the OLD code would have given up at 5:00. Progress
      // advanced 10s ago, so the backend is clearly still working.
      final action = decideCompilePoll(
        brainState: 'COMPILING',
        wikiPageCount: 40,
        elapsed: const Duration(minutes: 6),
        sinceLastProgress: const Duration(seconds: 10),
      );
      expect(action, CompilePollAction.keepPolling);
    });

    test('gives up (still-working) when progress has STALLED for the grace window', () {
      final action = decideCompilePoll(
        brainState: 'COMPILING',
        wikiPageCount: 40,
        elapsed: const Duration(minutes: 6),
        sinceLastProgress: const Duration(minutes: 4), // no new pages for 4 min
      );
      expect(action, CompilePollAction.stillWorkingBackground);
    });

    test('gives up (still-working) at the absolute hard ceiling even if advancing', () {
      final action = decideCompilePoll(
        brainState: 'COMPILING',
        wikiPageCount: 120,
        elapsed: const Duration(minutes: 15), // ceiling
        sinceLastProgress: const Duration(seconds: 5),
      );
      expect(action, CompilePollAction.stillWorkingBackground);
    });

    test('still polling just under the stall grace + ceiling', () {
      final action = decideCompilePoll(
        brainState: 'COMPILING',
        wikiPageCount: 40,
        elapsed: const Duration(minutes: 6),
        sinceLastProgress: const Duration(minutes: 3, seconds: 59),
      );
      expect(action, CompilePollAction.keepPolling);
    });

    test('READY with pages -> success', () {
      final action = decideCompilePoll(
        brainState: 'READY',
        wikiPageCount: 88,
        elapsed: const Duration(minutes: 2),
        sinceLastProgress: const Duration(seconds: 5),
      );
      expect(action, CompilePollAction.success);
    });

    test('READY with zero pages -> emptyFailed', () {
      final action = decideCompilePoll(
        brainState: 'READY',
        wikiPageCount: 0,
        elapsed: const Duration(minutes: 2),
        sinceLastProgress: const Duration(minutes: 2),
      );
      expect(action, CompilePollAction.emptyFailed);
    });
  });
}
