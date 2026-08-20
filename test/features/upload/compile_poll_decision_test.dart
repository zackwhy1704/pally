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

  group('module-progress stall grace (real signal, supersedes the flat-elapsed attempt)', () {
    // SUPERSEDES an earlier version of this fix (flat 90s-since-compile-start).
    // That was proven wrong by real Railway production data: 37 module-completion
    // events across the full log retention window, clustered into 6 real CENTRE-
    // tier compile sessions. 4 of 6 ran 3.5-6 minutes total, so a flat elapsed-
    // since-start threshold fired mid-compile on a healthy job in the MAJORITY of
    // real cases. The real fix keys off "no module has completed recently" (see
    // upload_view_model.dart's _pollCompileStatus: modulesCompleted/modulesTotal
    // from the backend feed the SAME sinceLastProgress clock as page progress).
    // 180s (the production constant, mirrored here as a literal since it's
    // private) is a deliberately generous placeholder — ~2.1x the 86s max
    // inter-module gap actually observed in that sample — not a tuned final
    // number; 6 sessions is too small to lock one in.
    const moduleProgressStallGrace = Duration(seconds: 180);

    test('the real WORST observed production gap (86s) does NOT trip the new grace', () {
      // 8/19 kestrel-method-overview -> wind-reading session: this exact gap
      // nearly tripped the superseded 90s flat threshold (86s < 90s, a 4-second
      // margin). The real per-module signal has real headroom instead.
      final action = decideCompilePoll(
        brainState: 'COMPILING',
        wikiPageCount: 6,
        elapsed: const Duration(minutes: 5, seconds: 29),
        sinceLastProgress: const Duration(seconds: 86),
        stallGrace: moduleProgressStallGrace,
      );
      expect(action, CompilePollAction.keepPolling);
    });

    test('a genuine stall (no module progress for longer than the grace) still gives up', () {
      final action = decideCompilePoll(
        brainState: 'COMPILING',
        wikiPageCount: 6,
        elapsed: const Duration(minutes: 6),
        sinceLastProgress: const Duration(seconds: 181),
        stallGrace: moduleProgressStallGrace,
      );
      expect(action, CompilePollAction.stillWorkingBackground);
    });

    test('a real healthy 15-module session (8/15, max inter-module gap 51s) '
        'never trips the grace at any point across its full 6m05s run', () {
      // Every real gap observed in that session: 14,19,42,47,14,38,38,16,19,18,
      // 13,28,51,8 (seconds). All comfortably under 180s.
      const gaps = [14, 19, 42, 47, 14, 38, 38, 16, 19, 18, 13, 28, 51, 8];
      for (final gap in gaps) {
        final action = decideCompilePoll(
          brainState: 'COMPILING',
          wikiPageCount: 15,
          elapsed: const Duration(minutes: 6, seconds: 5),
          sinceLastProgress: Duration(seconds: gap),
          stallGrace: moduleProgressStallGrace,
        );
        expect(action, CompilePollAction.keepPolling, reason: 'gap=${gap}s must not trip 180s grace');
      }
    });
  });
}
