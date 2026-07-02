import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/upload/presentation/widgets/upload_tips_banner.dart';

Future<void> _pump(WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(child: UploadTipsBanner()),
    ),
  ));
}

void main() {
  testWidgets('collapsed by default: one-liner + toggle, limits hidden', (tester) async {
    await _pump(tester);
    expect(find.text('Tip: clear, typed or printed pages read best.'), findsOneWidget);
    expect(find.text('What reads best?'), findsOneWidget);
    // Detailed guidance stays hidden until expanded.
    expect(find.text('Files must be under 25 MB.'), findsNothing);
  });

  testWidgets('expands to show the audited limits + reads-poorly guidance', (tester) async {
    await _pump(tester);
    await tester.tap(find.text('What reads best?'));
    await tester.pump();

    // Real, audited hard limit.
    expect(find.text('Files must be under 25 MB.'), findsOneWidget);
    // The honest large-doc guidance (compile timeout, not a fake page cap).
    expect(find.textContaining('chapter or topic at a time'), findsOneWidget);
    // Scanned-PDF failure mode.
    expect(find.textContaining('scanned, image-only PDF'), findsOneWidget);
    // A vision-OCR failure mode (type-instead guidance).
    expect(find.text('Cursive or messy handwriting.'), findsOneWidget);
    // The hallucination glance guard.
    expect(find.textContaining('glance at what Mochi read'), findsOneWidget);
    // Toggle flips to Hide.
    expect(find.text('Hide'), findsOneWidget);
  });
}
