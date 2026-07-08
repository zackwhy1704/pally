import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/onboarding/presentation/feature_tour.dart';
import 'package:pally/features/subscription/presentation/trial_welcome_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // The tour adds looping motion (spotlight pulse, illustrations). Those would keep
  // pumpAndSettle spinning forever, so content/nav tests run with disableAnimations
  // (reduced motion) — which is ALSO the reduced-motion static path under test. A
  // separate test exercises the animated path with pump() (not settle).
  // disableAnimations must reach the PUSHED tour route, so inject it via
  // MaterialApp.builder (wraps the Navigator) — a MediaQuery around the button only
  // would not be inherited by the route FeatureTour.show pushes.
  Widget harness({bool reduceMotion = true}) => MaterialApp(
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(disableAnimations: reduceMotion),
          child: child!,
        ),
        home: Scaffold(
          body: Builder(
            builder: (inner) => ElevatedButton(
              onPressed: () => FeatureTour.show(inner),
              child: const Text('go'),
            ),
          ),
        ),
      );

  Future<void> openTour(WidgetTester tester, {bool reduceMotion = true}) async {
    await tester.pumpWidget(harness(reduceMotion: reduceMotion));
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
  }

  testWidgets('renders 5 steps in order with the refreshed copy', (tester) async {
    await openTour(tester);

    expect(find.text("Hi, I'm Mochi!"), findsOneWidget);
    expect(find.textContaining('4 quick things'), findsOneWidget);
    await tester.tap(find.text('Show me!'));
    await tester.pumpAndSettle();

    expect(find.text('A Mochi for every subject'), findsOneWidget);
    await tester.tap(find.text('Next →'));
    await tester.pumpAndSettle();

    expect(find.text('Learn it. Test it. Prove it.'), findsOneWidget);
    expect(find.textContaining('mini-mission'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Next →'));
    await tester.pumpAndSettle();

    expect(find.text('I remember what you find hard'), findsOneWidget);
    await tester.tap(find.text('Next →'));
    await tester.pumpAndSettle();

    expect(find.text('Not a generic AI — a Mochi that knows yours.'), findsOneWidget);
    expect(find.text('Make my first Mochi'), findsOneWidget);
  });

  // ── Back navigation (the v3 gap) ─────────────────────────────────────────────

  testWidgets('Back button appears on step ≥2 and returns to the previous step',
      (tester) async {
    await openTour(tester);
    expect(find.text('← Back'), findsNothing); // step 1: no Back
    await tester.tap(find.text('Show me!'));
    await tester.pumpAndSettle();

    expect(find.text('A Mochi for every subject'), findsOneWidget);
    expect(find.text('← Back'), findsOneWidget);
    await tester.tap(find.text('← Back'));
    await tester.pumpAndSettle();
    expect(find.text("Hi, I'm Mochi!"), findsOneWidget); // back on step 1
  });

  testWidgets('tapping a progress dot jumps to that step', (tester) async {
    await openTour(tester);
    expect(find.text("Hi, I'm Mochi!"), findsOneWidget);
    // 5 dots are AnimatedContainers; tap the last to jump straight to the closing step.
    final dots = find.byType(AnimatedContainer);
    expect(dots, findsNWidgets(5));
    await tester.tap(dots.at(4));
    await tester.pumpAndSettle();
    expect(find.text('Not a generic AI — a Mochi that knows yours.'), findsOneWidget);
  });

  testWidgets('swipe left advances, swipe right goes back', (tester) async {
    await openTour(tester);
    // fling (not drag) so onHorizontalDragEnd sees a real velocity.
    await tester.fling(find.byKey(const Key('tour_card')), const Offset(-400, 0), 1000);
    await tester.pumpAndSettle();
    expect(find.text('A Mochi for every subject'), findsOneWidget); // advanced

    await tester.fling(find.byKey(const Key('tour_card')), const Offset(400, 0), 1000);
    await tester.pumpAndSettle();
    expect(find.text("Hi, I'm Mochi!"), findsOneWidget); // went back
  });

  testWidgets('system back goes to the previous step on step ≥2, dismisses on step 1',
      (tester) async {
    await openTour(tester);
    await tester.tap(find.text('Show me!'));
    await tester.pumpAndSettle();
    expect(find.text('A Mochi for every subject'), findsOneWidget);

    // System back on step 2 → back to step 1 (tour stays open).
    final popped1 = await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(popped1, isTrue); // handled (did not pop the route)
    expect(find.text("Hi, I'm Mochi!"), findsOneWidget);

    // System back on step 1 → dismiss the whole tour.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text("Hi, I'm Mochi!"), findsNothing);
  });

  // ── Motion / reduced-motion ──────────────────────────────────────────────────

  testWidgets('reduced-motion path renders static and complete (no hang)',
      (tester) async {
    await openTour(tester); // disableAnimations: true
    // Full content present, no exception, pumpAndSettle returned (didn't time out).
    expect(find.text("Hi, I'm Mochi!"), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets); // spotlight painter present
    expect(tester.takeException(), isNull);
  });

  testWidgets('animated path renders without crashing (pump, not settle)',
      (tester) async {
    await tester.pumpWidget(harness(reduceMotion: false));
    await tester.tap(find.text('go'));
    await tester.pump(); // entrance
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.text("Hi, I'm Mochi!"), findsOneWidget);
    expect(tester.takeException(), isNull);
    // Don't pumpAndSettle — the loop never settles by design.
  });

  // ── Seen-key v3 ──────────────────────────────────────────────────────────────

  Widget autoShowHarness(Future<void> Function(BuildContext) onReady) => MaterialApp(
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
          child: child!,
        ),
        home: Scaffold(
          body: Builder(
            builder: (inner) => ElevatedButton(
              onPressed: () => onReady(inner),
              child: const Text('go'),
            ),
          ),
        ),
      );

  testWidgets('maybeShow skips when v3 already seen', (tester) async {
    SharedPreferences.setMockInitialValues({'seen_feature_tour_v3': true});
    await tester.pumpWidget(autoShowHarness((ctx) => FeatureTour.maybeShow(ctx)));
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
    expect(find.text("Hi, I'm Mochi!"), findsNothing);
  });

  testWidgets('maybeShow shows once for v2-seen users (the v3 one-time re-show)',
      (tester) async {
    SharedPreferences.setMockInitialValues({'seen_feature_tour_v2': true});
    await tester.pumpWidget(autoShowHarness((ctx) => FeatureTour.maybeShow(ctx)));
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
    expect(find.text("Hi, I'm Mochi!"), findsOneWidget); // v3 not seen → appears
  });

  testWidgets('TrialWelcome.maybeShow returns false when already seen', (tester) async {
    SharedPreferences.setMockInitialValues({'trial_welcome_seen_v1': true});
    bool? result;
    await tester.pumpWidget(autoShowHarness((ctx) async {
      result = await TrialWelcomeScreen.maybeShow(ctx);
    }));
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
    expect(result, isFalse);
  });

  // ── Positioning (the v2 squeeze regression) ──────────────────────────────────

  testWidgets('bottom-nav-anchored step places the card clear of the bottom strip',
      (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(360, 640);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Mount the library-tab anchor at the very bottom (like the bottom nav).
    await tester.pumpWidget(MaterialApp(
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
        child: child!,
      ),
      home: Scaffold(
        body: Stack(
          children: [
            Positioned(
              left: 0, right: 0, bottom: 0,
              child: SizedBox(
                key: featureTourLibraryTabKey, height: 56,
                child: const ColoredBox(color: Colors.blue),
              ),
            ),
            Center(
              child: Builder(
                builder: (inner) => ElevatedButton(
                  onPressed: () => FeatureTour.show(inner),
                  child: const Text('go'),
                ),
              ),
            ),
          ],
        ),
      ),
    ));
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
    // Advance to step 3 (anchored to the bottom library tab).
    await tester.tap(find.text('Show me!'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next →'));
    await tester.pumpAndSettle();
    expect(find.text('Learn it. Test it. Prove it.'), findsOneWidget);

    final cardRect = tester.getRect(find.byKey(const Key('tour_card')));
    // Regression pin: card bottom ≥ 200dp above the 640 screen bottom (v2 landed it
    // ~20dp above → buttons on the gesture bar).
    expect(cardRect.bottom, lessThanOrEqualTo(640 - 200));
    // And ≥ 24dp from the top edge.
    expect(cardRect.top, greaterThanOrEqualTo(24));
    // ≥24dp horizontal margins.
    expect(cardRect.left, greaterThanOrEqualTo(24));
    expect(cardRect.right, lessThanOrEqualTo(360 - 24));
  });

  testWidgets('top-anchored step places the card below the anchor', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(360, 800);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MaterialApp(
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
        child: child!,
      ),
      home: Scaffold(
        body: Stack(
          children: [
            Positioned(
              left: 0, right: 0, top: 0,
              child: SizedBox(
                key: featureTourCreateMochiKey, height: 56,
                child: const ColoredBox(color: Colors.green),
              ),
            ),
            Center(
              child: Builder(
                builder: (inner) => ElevatedButton(
                  onPressed: () => FeatureTour.show(inner),
                  child: const Text('go'),
                ),
              ),
            ),
          ],
        ),
      ),
    ));
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Show me!')); // → step 2, anchored to the top "+"
    await tester.pumpAndSettle();
    expect(find.text('A Mochi for every subject'), findsOneWidget);

    final anchor = tester.getRect(find.byKey(featureTourCreateMochiKey));
    final card = tester.getRect(find.byKey(const Key('tour_card')));
    expect(card.top, greaterThanOrEqualTo(anchor.bottom)); // card BELOW the anchor
  });

  testWidgets('no overflow at 320dp width + 2.0x text scale', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(320, 640);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MaterialApp(
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(
            disableAnimations: true, textScaler: const TextScaler.linear(2.0)),
        child: child!,
      ),
      home: Scaffold(
        body: Builder(
          builder: (inner) => ElevatedButton(
            onPressed: () => FeatureTour.show(inner),
            child: const Text('go'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull); // card scrolls internally, no overflow
  });
}
