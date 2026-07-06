import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/modules/presentation/widgets/test_body.dart';

/// Launch-blocker regression: a Challenge is stage 5/5 of a module. If its Submit
/// button never enables, the student can type a full answer and still not submit —
/// so the module can never be completed. The button gates on the text controller;
/// without a rebuild on keystroke it is evaluated once (empty → disabled) and stays
/// disabled forever. This pins that typing re-enables Submit.
void main() {
  testWidgets('ChallengeCard Submit enables once the student types', (tester) async {
    String? submitted;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ChallengeCard(
          question: 'Explain the idea in your own words.',
          explanation: 'a model answer',
          isRevealed: false,
          answer: '',
          onSubmit: (v) => submitted = v,
        ),
      ),
    ));

    FilledButton submitButton() =>
        tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Submit'));

    // Empty → disabled (correct: no blank submissions).
    expect(submitButton().onPressed, isNull);

    await tester.enterText(find.byType(TextField), 'My real answer');
    await tester.pump();

    // The regression: without the keystroke rebuild this stays null forever.
    expect(
      submitButton().onPressed,
      isNotNull,
      reason: 'Submit must enable as the student types, or a Challenge can never be '
          'submitted and the module can never be completed.',
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Submit'));
    await tester.pump();
    expect(submitted, 'My real answer');
  });
}
