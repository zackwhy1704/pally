import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/shared/widgets/mochi_placeholder.dart';

/// Asserts a Mochi PNG is actually rendered (the whole point of the sweep —
/// the old placeholders were Material `Icon`s with no `Image` at all).
Finder _mochiImage(String assetName) => find.byWidgetPredicate(
      (w) =>
          w is Image &&
          w.image is AssetImage &&
          (w.image as AssetImage).assetName == assetName,
    );

void main() {
  Future<void> pump(WidgetTester tester, Widget child) => tester.pumpWidget(
        MaterialApp(home: Scaffold(body: Center(child: child))),
      );

  testWidgets(
      'empty variant renders the Mochi mascot image and no party poppers',
      (tester) async {
    await pump(
      tester,
      const MochiPlaceholder(
        variant: MochiVariant.empty,
        title: 'No Mochis yet',
        subtitle: 'Create one from Home.',
      ),
    );

    expect(_mochiImage('assets/images/mochi.png'), findsOneWidget);
    expect(find.text('🎉'), findsNothing);
    expect(find.text('No Mochis yet'), findsOneWidget);
    expect(find.text('Create one from Home.'), findsOneWidget);
  });

  testWidgets(
      'success variant renders the Mochi image flanked by exactly two party poppers',
      (tester) async {
    await pump(tester, const MochiPlaceholder(variant: MochiVariant.success));

    expect(_mochiImage('assets/images/mochi.png'), findsOneWidget);
    // Exactly two 🎉 marks — one each side of Mochi.
    expect(find.text('🎉'), findsNWidgets(2));
  });

  testWidgets(
      'error variant renders the neutral (transparent) Mochi and never a party popper',
      (tester) async {
    await pump(
      tester,
      const MochiPlaceholder(
        variant: MochiVariant.error,
        title: 'Something went wrong',
      ),
    );

    // Never a celebrating mascot on a failure.
    expect(_mochiImage('assets/images/mochi_base_transparent.png'),
        findsOneWidget);
    expect(find.text('🎉'), findsNothing);
  });

  testWidgets('renders an optional action below the copy', (tester) async {
    await pump(
      tester,
      const MochiPlaceholder(
        variant: MochiVariant.empty,
        title: 'No topics',
        action: Text('CTA-MARKER'),
      ),
    );

    expect(find.text('CTA-MARKER'), findsOneWidget);
  });

  testWidgets(
      'success poppers do not overflow at 320dp width and 2.0x text scale',
      (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(2.0)),
        child: MaterialApp(
          home: Scaffold(
            body: Center(
              child: MochiPlaceholder(variant: MochiVariant.success),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
