import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/features/auth/auth_state.dart';
import 'package:pally/features/auth/screens/sign_in_screen.dart';

/// The invariant: 'Create Account ✨' is the primary secondary-action of the
/// sign-in screen and must be reachable WITHOUT a scroll gesture at every common
/// device size. It now lives in a persistent footer (bottomNavigationBar), not
/// the scroll tail. Fail-without-fix: pre-change it was the last child of the
/// SingleChildScrollView and landed below the fold on short devices.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // In-memory flutter_secure_storage so AuthNotifier (singleton, used by the
  // screen's initState biometric check) resolves cleanly. local_auth self-
  // degrades to "unsupported" via its own try/catch, so no channel mock needed.
  const secureChannel =
      MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  final store = <String, String>{};

  setUp(() {
    store.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureChannel, (call) async {
      final args = (call.arguments as Map?) ?? {};
      switch (call.method) {
        case 'read':
          return store[args['key']];
        case 'write':
          store[args['key'] as String] = args['value'] as String;
          return null;
        case 'delete':
          store.remove(args['key']);
          return null;
        case 'readAll':
          return Map<String, String>.from(store);
        case 'containsKey':
          return store.containsKey(args['key']);
      }
      return null;
    });
  });

  tearDown(() async {
    await AuthNotifier.instance.signOut();
  });

  Widget app(GoRouter router) => ProviderScope(
        child: MaterialApp.router(routerConfig: router),
      );

  GoRouter router() => GoRouter(routes: [
        GoRoute(path: '/', builder: (_, __) => const SignInScreen()),
        GoRoute(
            path: '/onboarding/direct',
            builder: (_, __) =>
                const Scaffold(body: Center(child: Text('ONBOARD')))),
      ]);

  Future<void> pumpAt(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(app(router()));
    await tester.pump(); // let the initState biometric future settle
  }

  final cta = find.text('Create Account ✨');

  void assertOnScreenWithoutScroll(WidgetTester tester, double screenHeight) {
    expect(cta, findsOneWidget);
    final rect = tester.getRect(cta);
    // The whole CTA is within the viewport → reachable with NO scroll gesture.
    expect(rect.top, greaterThanOrEqualTo(0.0));
    expect(rect.bottom, lessThanOrEqualTo(screenHeight + 0.5),
        reason: 'Create Account must sit within the viewport (footer), not '
            'below the fold requiring a drag.');
    expect(tester.takeException(), isNull);
  }

  testWidgets('CTA is on-screen without scrolling at 360x640 (short device)',
      (tester) async {
    await pumpAt(tester, const Size(360, 640));
    assertOnScreenWithoutScroll(tester, 640);
  });

  testWidgets('CTA is on-screen without scrolling at 360x850 (tall device)',
      (tester) async {
    await pumpAt(tester, const Size(360, 850));
    assertOnScreenWithoutScroll(tester, 850);
  });

  testWidgets('tapping Create Account pushes /onboarding/direct (nav pin)',
      (tester) async {
    await pumpAt(tester, const Size(360, 640));
    await tester.tap(cta); // no scrollUntilVisible needed — it's pinned
    await tester.pumpAndSettle();
    expect(find.text('ONBOARD'), findsOneWidget);
  });

  testWidgets('form still scrolls with the keyboard up — no overflow',
      (tester) async {
    // Simulate the keyboard insetting the viewport; the scrollable body must
    // absorb it (fields reachable) with no RenderFlex overflow.
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(app(router()));
    await tester.pump();

    expect(tester.takeException(), isNull);
    // The email field is reachable within the scrollable body.
    expect(find.byType(TextField), findsWidgets);
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -120));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
