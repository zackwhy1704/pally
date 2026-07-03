import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/consent/presentation/consent_approved_overlay.dart';

void main() {
  testWidgets('shows the Mochi celebration with kid-friendly copy + Let\'s go',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (ctx) => Center(
            child: ElevatedButton(
              onPressed: () => ConsentApprovedOverlay.show(ctx),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('open'));
    await tester.pump(); // start the dialog
    await tester.pump(const Duration(milliseconds: 600)); // past the entry anim

    expect(find.text("You're all set! 🎉"), findsOneWidget);
    expect(find.textContaining('grown-up said yes'), findsOneWidget);
    expect(find.text("Let's go!"), findsOneWidget);
    expect(find.byType(Image), findsOneWidget); // the Mochi mascot
    // No jargon leaks to a possibly-under-13 child.
    expect(find.textContaining('consent', findRichText: true), findsNothing);

    // "Let's go!" dismisses.
    await tester.tap(find.text("Let's go!"));
    await tester.pumpAndSettle();
    expect(find.text("You're all set! 🎉"), findsNothing);
  });
}
