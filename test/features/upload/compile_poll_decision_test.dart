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

  group('compileStallGraceFor', () {
    // Pins the fix for "stuck on the loading screen": a normal-size compile
    // used to wait the full 4-minute stall grace with zero feedback, 3+
    // minutes past the "takes 30 to 60s" copy shown on screen, before the
    // user ever got a way to leave. Large files keep the old grace since
    // they already got the slower-expectations preflight dialog.
    test('normal-size file gets the SHORT grace, not the old 4 minutes', () {
      final grace = compileStallGraceFor(isLargeFile: false);
      expect(grace, const Duration(seconds: 90));
    });

    test('large file keeps the LONG grace', () {
      final grace = compileStallGraceFor(isLargeFile: true);
      expect(grace, const Duration(minutes: 4));
    });

    test('a real slow-but-healthy compile (CENTRE tier, ~90s/module, no '
        'progress signal from the poll) now gets the still-working screen '
        'well under the old 4-minute wait', () {
      // Matches the production log this fix was written against: brainState
      // stays COMPILING, wikiPageCount never advances past its starting
      // value (module generation isn't reflected by this field), so
      // sinceLastProgress is effectively just elapsed time.
      final grace = compileStallGraceFor(isLargeFile: false);
      final action = decideCompilePoll(
        brainState: 'COMPILING',
        wikiPageCount: 6,
        elapsed: const Duration(seconds: 95),
        sinceLastProgress: const Duration(seconds: 95),
        stallGrace: grace,
      );
      expect(action, CompilePollAction.stillWorkingBackground);
    });
  });
}
