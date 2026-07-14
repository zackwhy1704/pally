import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/core/ui/adaptive_center.dart';

/// FIX 4 guard: AdaptiveCenter's doc promises it "centers [child] when there is
/// room". The old body only constrained minHeight, so inside the vertical
/// SingleChildScrollView narrow content shrink-wrapped and left-aligned (flashcard
/// "Loading…" squashed left). These pin: (a) narrow content centers both axes;
/// (b) tall content scrolls without overflow; (c) a full-width child still fills;
/// (d) with padding, no horizontal overflow.
void main() {
  Future<void> pumpAt(WidgetTester tester, Widget body,
      {Size size = const Size(600, 800), bool settle = true}) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = size;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: body)));
    // pumpAndSettle hangs on an endlessly-animating child (e.g. a spinner), so
    // callers with such content pass settle:false and a single pump lays out.
    settle ? await tester.pumpAndSettle() : await tester.pump();
  }

  testWidgets('(a) narrow child is centered horizontally AND vertically', (tester) async {
    await pumpAt(
      tester,
      const AdaptiveCenter(
        child: SizedBox(key: Key('box'), width: 100, height: 100),
      ),
    );
    final box = tester.getRect(find.byKey(const Key('box')));
    final screen = tester.getRect(find.byType(Scaffold));
    expect(box.center.dx, moreOrLessEquals(screen.center.dx, epsilon: 1.0),
        reason: 'narrow child must be horizontally centered, not left-squashed');
    expect(box.center.dy, moreOrLessEquals(screen.center.dy, epsilon: 1.0),
        reason: 'narrow child must be vertically centered');
    expect(tester.takeException(), isNull);
  });

  testWidgets('(b) child taller than the viewport scrolls, no overflow', (tester) async {
    await pumpAt(
      tester,
      const AdaptiveCenter(
        child: SizedBox(key: Key('tall'), width: 100, height: 4000),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    // Scrollable: dragging up reveals more of the tall child without error.
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('(c) a full-width child still fills the width', (tester) async {
    await pumpAt(
      tester,
      const AdaptiveCenter(
        child: SizedBox(key: Key('wide'), width: double.infinity, height: 100),
      ),
    );
    final wide = tester.getRect(find.byKey(const Key('wide')));
    expect(wide.width, moreOrLessEquals(600.0, epsilon: 1.0),
        reason: 'a width:infinity child must still expand edge-to-edge');
  });

  testWidgets('(d) with padding set, no horizontal overflow (full-width child)', (tester) async {
    await pumpAt(
      tester,
      const AdaptiveCenter(
        padding: EdgeInsets.all(24),
        child: SizedBox(key: Key('wide'), width: double.infinity, height: 100),
      ),
    );
    expect(tester.takeException(), isNull);
    final wide = tester.getRect(find.byKey(const Key('wide')));
    // Fills the padded content region exactly (600 - 24*2), never overflowing it.
    expect(wide.width, moreOrLessEquals(552.0, epsilon: 1.0));
  });

  testWidgets('loading-shape (spinner + "Loading...", the flashcard bug) centers', (tester) async {
    // Mirrors flashcards _GeneratingView: a narrow Column that used to squash left.
    // The spinner animates forever → pump once (settle:false) instead of settling.
    await pumpAt(
      tester,
      const AdaptiveCenter(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(key: Key('spinner')),
            SizedBox(height: 16),
            Text('Loading...'),
          ],
        ),
      ),
      settle: false,
    );
    final spinner = tester.getRect(find.byKey(const Key('spinner')));
    final screen = tester.getRect(find.byType(Scaffold));
    expect(spinner.center.dx, moreOrLessEquals(screen.center.dx, epsilon: 1.0),
        reason: 'the loading spinner must sit on the horizontal centre line');
    expect(tester.takeException(), isNull);
  });
}
