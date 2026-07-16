import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/library/presentation/library_screen.dart';
import 'package:pally/features/modules/presentation/widgets/complete_body.dart';
import 'package:pally/shared/widgets/mochi_placeholder.dart';

Finder _anyMochiImage() => find.byWidgetPredicate(
      (w) =>
          w is Image &&
          w.image is AssetImage &&
          (w.image as AssetImage).assetName.contains('mochi'),
    );

void main() {
  // Surface #1 — module completion. Fail-without-fix: the pre-sweep build had
  // Icons.celebration_rounded and NO Image at all.
  testWidgets(
      'CompleteBody shows the Mochi success mascot with two poppers, not the celebration icon',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CompleteBody(results: null, onBack: () {}),
        ),
      ),
    );

    expect(find.byType(MochiPlaceholder), findsOneWidget);
    expect(_anyMochiImage(), findsOneWidget);
    expect(find.text('🎉'), findsNWidgets(2));
    // The old standalone hero placeholder is gone. Scoped to celebration_rounded
    // so the per-item MasteryRow check icons (a different IconData) never trip it.
    expect(find.byIcon(Icons.celebration_rounded), findsNothing);
    // Surrounding content untouched.
    expect(find.text('Module complete!'), findsOneWidget);
  });

  // Per-surface empty spot-check. Fail-without-fix: the pre-sweep build had
  // Icons.menu_book_outlined and no Image.
  testWidgets('EmptyLibraryView renders the Mochi empty mascot, not a book icon',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: EmptyLibraryView())),
    );

    expect(find.byType(MochiPlaceholder), findsOneWidget);
    expect(_anyMochiImage(), findsOneWidget);
    expect(find.byIcon(Icons.menu_book_outlined), findsNothing);
    expect(find.text('No Mochis yet'), findsOneWidget);
  });
}
