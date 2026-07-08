import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/auth/screens/complete_profile_screen.dart';
import 'package:pally/features/join/presentation/join_screen.dart';
import 'package:pally/features/onboarding/presentation/direct_onboarding_screen.dart';

/// Prevention harness for the recurring overflow class: render key entry screens
/// on a NARROW surface (320 dp) AND at a large accessibility text scale (2.0×) —
/// the two conditions that expose dynamic RenderFlex overflows the happy-path
/// (1.0× on a wide device) never hits. A layout overflow throws during pump and
/// surfaces via takeException(), naming the offending widget + file:line.
Future<void> _pumpScreen(
  WidgetTester tester,
  Widget screen, {
  required Size size,
  required double textScale,
}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: screen,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScale),
          ),
          child: child!,
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  const narrow = Size(320, 640); // iPhone SE / small Android, portrait

  group('JoinScreen — no overflow under narrow + large-text', () {
    testWidgets('320 dp @ 2.0× text scale', (tester) async {
      await _pumpScreen(tester, const JoinScreen(), size: narrow, textScale: 2.0);
      expect(tester.takeException(), isNull);
    });

    testWidgets('320 dp @ 1.0× text scale', (tester) async {
      await _pumpScreen(tester, const JoinScreen(), size: narrow, textScale: 1.0);
      expect(tester.takeException(), isNull);
    });

    testWidgets('content clamps (≤560 dp) on a wide iPad-class viewport', (tester) async {
      await _pumpScreen(tester, const JoinScreen(),
          size: const Size(1024, 768), textScale: 1.0);
      // The form must NOT stretch to 1024 — the content column is capped.
      final field = tester.getSize(find.byType(TextField).first);
      expect(field.width, lessThanOrEqualTo(560));
    });
  });

  group('DirectOnboardingScreen — no overflow under narrow + large-text', () {
    testWidgets('320 dp @ 2.0× text scale', (tester) async {
      await _pumpScreen(tester, const DirectOnboardingScreen(),
          size: narrow, textScale: 2.0);
      expect(tester.takeException(), isNull);
    });
  });

  group('CompleteProfileScreen — no overflow under narrow + large-text', () {
    testWidgets('320 dp @ 2.0× text scale — under-13 (parent email visible)',
        (tester) async {
      await _pumpScreen(tester, const CompleteProfileScreen(),
          size: narrow, textScale: 2.0);
      // Reveal the parent-email field (the tallest layout) then re-pump.
      await tester.tap(find.text('I am under 13'));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });
}
