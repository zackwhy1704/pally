import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/modules/presentation/widgets/test_body.dart';

/// feat/sm-diagnosis-ui: Spot-the-Mistake becomes an honest interaction —
/// read → TYPE the mistake (non-empty required) → reveal → self-check.
void main() {
  // SpotMistakeCard's field now carries a VoiceInputButton (voice-input
  // feature), which reads a Riverpod provider — every render needs a
  // ProviderScope ancestor now, even though this widget itself has no other
  // Riverpod dependency.
  Widget wrap(Widget child) =>
      ProviderScope(child: MaterialApp(home: Scaffold(body: child)));

  testWidgets('Reveal is disabled until the student types a diagnosis',
      (tester) async {
    await tester.pumpWidget(wrap(SpotMistakeCard(
      problem: '2 + 2 = ?',
      wrongSolution: '2 + 2 = 5',
      errorDescription: 'the sum is wrong',
      correctSolution: '2 + 2 = 4',
      isRevealed: false,
      diagnosis: '',
      selfCheck: null,
      onReveal: (_) {},
      onSelfCheck: (_) {},
    )));

    OutlinedButton revealBtn() => tester.widget<OutlinedButton>(
        find.widgetWithText(OutlinedButton, 'Reveal the error'));

    // Fail-without-fix: the OLD card had an always-enabled "I found it!" button
    // and no input — there was nothing to require.
    expect(revealBtn().onPressed, isNull); // empty → disabled

    await tester.enterText(find.byType(TextField), 'the second step is wrong');
    await tester.pump();
    expect(revealBtn().onPressed, isNotNull); // typing enables it
  });

  testWidgets('Reveal fires with the typed diagnosis, then shows answer + self-check',
      (tester) async {
    String? revealed;
    await tester.pumpWidget(wrap(SpotMistakeCard(
      problem: '2 + 2 = ?',
      wrongSolution: '2 + 2 = 5',
      errorDescription: 'the sum is wrong',
      correctSolution: '2 + 2 = 4',
      isRevealed: false,
      diagnosis: '',
      selfCheck: null,
      onReveal: (d) => revealed = d,
      onSelfCheck: (_) {},
    )));

    await tester.enterText(find.byType(TextField), 'the addition is off by one');
    await tester.pump();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Reveal the error'));
    await tester.pump();
    expect(revealed, 'the addition is off by one');
  });

  testWidgets('Revealed state shows the answer and the Yes/Not quite self-check',
      (tester) async {
    String? checked;
    await tester.pumpWidget(wrap(SpotMistakeCard(
      problem: '2 + 2 = ?',
      wrongSolution: '2 + 2 = 5',
      errorDescription: 'the sum is wrong',
      correctSolution: '2 + 2 = 4',
      isRevealed: true,
      diagnosis: 'my earlier diagnosis',
      selfCheck: null,
      onReveal: (_) {},
      onSelfCheck: (v) => checked = v,
    )));

    expect(find.text('the sum is wrong'), findsOneWidget);   // errorDescription
    expect(find.text('2 + 2 = 4'), findsOneWidget);          // correctSolution
    expect(find.text('Were you right?'), findsOneWidget);
    expect(find.text('Yes'), findsOneWidget);
    expect(find.text('Not quite'), findsOneWidget);
    // No input in the revealed state.
    expect(find.byType(TextField), findsNothing);

    await tester.tap(find.text('Not quite'));
    await tester.pump();
    expect(checked, 'NOT_QUITE');
  });
}
