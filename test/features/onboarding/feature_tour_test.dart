import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/onboarding/presentation/feature_tour.dart';
import 'package:pally/features/subscription/presentation/trial_welcome_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // The tour anchors to GlobalKeys on the home/shell; none are mounted in this
  // harness, so every step falls back to a centered card (null-anchor path) —
  // which also pins that fallback (no crash, no highlight required).
  Widget harness() => MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () => FeatureTour.show(ctx),
              child: const Text('go'),
            ),
          ),
        ),
      );

  Future<void> openTour(WidgetTester tester) async {
    await tester.pumpWidget(harness());
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
  }

  testWidgets('renders 5 steps in order with the refreshed copy', (tester) async {
    await openTour(tester);

    // Step 1 (intro)
    expect(find.text("Hi, I'm Mochi!"), findsOneWidget);
    expect(find.textContaining('4 quick things'), findsOneWidget);
    await tester.tap(find.text('Show me!'));
    await tester.pumpAndSettle();

    // Step 2
    expect(find.text('A Mochi for every subject'), findsOneWidget);
    await tester.tap(find.text('Next →'));
    await tester.pumpAndSettle();

    // Step 3 — the NEW Modules step (replaces the dead Guide-Me step)
    expect(find.text('Learn it. Test it. Prove it.'), findsOneWidget);
    expect(find.textContaining('mini-mission'), findsOneWidget);
    expect(tester.takeException(), isNull); // centered fallback, anchor absent
    await tester.tap(find.text('Next →'));
    await tester.pumpAndSettle();

    // Step 4
    expect(find.text('I remember what you find hard'), findsOneWidget);
    await tester.tap(find.text('Next →'));
    await tester.pumpAndSettle();

    // Step 5 — closing line is a real sentence, not the duplicated title
    expect(find.text('Not a generic AI — a Mochi that knows yours.'),
        findsOneWidget);
    expect(find.textContaining('what YOUR teacher taught'), findsOneWidget);
    expect(find.text('A Mochi that knows yours.'), findsNothing); // old dup gone
    expect(find.text('Make my first Mochi'), findsOneWidget); // CTA unchanged
  });

  testWidgets('no step references the chat mode toggle (Guide Me removed)',
      (tester) async {
    await openTour(tester);
    // Walk every step and assert the mode-toggle copy never appears.
    for (var i = 0; i < 5; i++) {
      expect(find.text('Pick how I help'), findsNothing);
      expect(find.textContaining('Guide Me'), findsNothing);
      expect(find.textContaining('Just answer'), findsNothing);
      final next = find.text(i == 0 ? 'Show me!' : 'Next →');
      if (i < 4 && next.evaluate().isNotEmpty) {
        await tester.tap(next);
        await tester.pumpAndSettle();
      }
    }
  });

  Widget autoShowHarness(Future<void> Function(BuildContext) onReady) => MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () => onReady(ctx),
              child: const Text('go'),
            ),
          ),
        ),
      );

  testWidgets('maybeShow skips when v2 already seen (idempotent for v2-seers)',
      (tester) async {
    SharedPreferences.setMockInitialValues({'seen_feature_tour_v2': true});
    await tester.pumpWidget(autoShowHarness((ctx) => FeatureTour.maybeShow(ctx)));
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
    // Already saw v2 → no tour re-shown.
    expect(find.text("Hi, I'm Mochi!"), findsNothing);
  });

  testWidgets('maybeShow shows once for v1-only users (the one-time re-show)',
      (tester) async {
    // Saw the OLD v1 tour but not v2 → the corrected tour appears once.
    SharedPreferences.setMockInitialValues({'seen_feature_tour_v1': true});
    await tester.pumpWidget(autoShowHarness((ctx) => FeatureTour.maybeShow(ctx)));
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
    expect(find.text("Hi, I'm Mochi!"), findsOneWidget);
  });

  testWidgets('TrialWelcome.maybeShow returns false when already seen '
      '(so the tour proceeds, no stacked overlay)', (tester) async {
    SharedPreferences.setMockInitialValues({'trial_welcome_seen_v1': true});
    bool? result;
    await tester.pumpWidget(autoShowHarness((ctx) async {
      result = await TrialWelcomeScreen.maybeShow(ctx);
    }));
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
    // Seen → returns false (no sheet); home_screen then falls through to the tour.
    expect(result, isFalse);
  });
}
