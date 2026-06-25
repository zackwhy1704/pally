import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/join/presentation/join_screen.dart';
import 'package:pally/features/auth/screens/sign_up_screen.dart';

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
  });

  group('SignUpScreen — no overflow under narrow + large-text', () {
    testWidgets('320 dp @ 2.0× text scale', (tester) async {
      await _pumpScreen(tester, const SignUpScreen(), size: narrow, textScale: 2.0);
      expect(tester.takeException(), isNull);
    });
  });
}
