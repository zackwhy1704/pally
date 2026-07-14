import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/modules/presentation/module_player_view_model.dart';
import 'package:pally/features/modules/presentation/widgets/test_body.dart';
import 'package:pally/shared/models/learning_module.dart';

/// TEST-stage reveal contract (option B):
///  · SPOT_MISTAKE / CHALLENGE render their reveal from the SERVED `revealJson`
///    (field-filtered, non-secret) — never from serve-time answerJson (which is null).
///  · HOT_TAKE renders the authoritative SERVER verdict passed in; with no verdict it
///    shows NO Correct!/Not quite banner (the old `isTrue ?? true` fabrication is gone).
void main() {
  Widget host(ModuleContentItem item,
          {HotTakeVerdict? verdict, bool verdictPending = false}) =>
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 800,
            height: 1200,
            child: TestBody(
              item: item,
              currentIndex: 0,
              totalItems: 1,
              isRevealed: true,
              answer: 'AGREE',
              onAnswer: (_, __) {},
              onNext: () {},
              isLast: true,
              isSubmitting: false,
              verdict: verdict,
              verdictPending: verdictPending,
            ),
          ),
        ),
      );

  testWidgets('SPOT_MISTAKE reveal renders errorDescription + correctSolution from revealJson',
      (tester) async {
    const item = ModuleContentItem(
      id: 'i1',
      type: 'SPOT_MISTAKE',
      contentJson: {'problem': 'Solve 2+2', 'wrongSolution': '5'},
      revealJson: {'errorDescription': 'They added wrong', 'correctSolution': 'The answer is 4'},
    );
    await tester.pumpWidget(host(item));
    expect(find.text('The answer is 4'), findsOneWidget);
    expect(find.text('They added wrong'), findsOneWidget);
  });

  testWidgets('CHALLENGE reveal renders explanation from revealJson', (tester) async {
    const item = ModuleContentItem(
      id: 'c1',
      type: 'CHALLENGE',
      contentJson: {'question': 'Why is the sky blue?'},
      revealJson: {'explanation': 'Rayleigh scattering'},
    );
    await tester.pumpWidget(host(item, verdict: null));
    expect(find.text('Rayleigh scattering'), findsOneWidget);
  });

  testWidgets('HOT_TAKE with a WRONG server verdict shows "Not quite" + the real explanation',
      (tester) async {
    const item = ModuleContentItem(
      id: 'h1',
      type: 'HOT_TAKE',
      contentJson: {'statement': 'Plants eat soil'},
    );
    await tester.pumpWidget(host(item,
        verdict: const HotTakeVerdict(correct: false, explanation: 'They photosynthesise')));
    expect(find.text('Not quite'), findsOneWidget);
    expect(find.text('Correct!'), findsNothing);
    expect(find.text('They photosynthesise'), findsOneWidget);
  });

  testWidgets('HOT_TAKE with a CORRECT server verdict shows "Correct!"', (tester) async {
    const item = ModuleContentItem(
      id: 'h2',
      type: 'HOT_TAKE',
      contentJson: {'statement': 'Water is H2O'},
    );
    await tester.pumpWidget(host(item,
        verdict: const HotTakeVerdict(correct: true, explanation: 'Indeed')));
    expect(find.text('Correct!'), findsOneWidget);
    expect(find.text('Not quite'), findsNothing);
  });

  testWidgets('HOT_TAKE with NO verdict (fetch failed) shows no banner — never a fabricated Correct!',
      (tester) async {
    const item = ModuleContentItem(
      id: 'h3',
      type: 'HOT_TAKE',
      contentJson: {'statement': 'Ambiguous claim'},
    );
    await tester.pumpWidget(host(item, verdict: null));
    // The old bug defaulted isCorrect=true → "Correct!" for anyone who tapped Agree.
    expect(find.text('Correct!'), findsNothing);
    expect(find.text('Not quite'), findsNothing);
    expect(find.textContaining('Answer recorded'), findsOneWidget);
  });

  testWidgets('HOT_TAKE while verdict is pending shows a checking state, no banner',
      (tester) async {
    const item = ModuleContentItem(
      id: 'h4',
      type: 'HOT_TAKE',
      contentJson: {'statement': 'Loading claim'},
    );
    await tester.pumpWidget(host(item, verdict: null, verdictPending: true));
    expect(find.textContaining('Checking'), findsOneWidget);
    expect(find.text('Correct!'), findsNothing);
    expect(find.text('Not quite'), findsNothing);
  });
}
