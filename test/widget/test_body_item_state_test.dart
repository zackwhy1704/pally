import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/modules/presentation/widgets/test_body.dart';
import 'package:pally/shared/models/learning_module.dart';

/// FIX A: per-item widget State must NOT bleed across TEST-item advances. Without a
/// per-item key, Flutter reuses the same State for a same-type card at the same tree
/// position, so ChallengeCard's TextEditingController carried the previous item's text
/// (visible in the screen recording: answer prefilled on the next question).
void main() {
  Widget host(ModuleContentItem item) => MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 800,
            height: 1200,
            child: TestBody(
              item: item,
              currentIndex: 0,
              totalItems: 2,
              isRevealed: false,
              answer: null, // fresh item has no accumulated answer
              onAnswer: (_, __) {},
              onNext: () {},
              isLast: false,
              isSubmitting: false,
            ),
          ),
        ),
      );

  const challengeA = ModuleContentItem(
    id: 'ch-A',
    type: 'CHALLENGE',
    contentJson: {'question': 'Question A'},
  );
  const challengeB = ModuleContentItem(
    id: 'ch-B',
    type: 'CHALLENGE',
    contentJson: {'question': 'Question B'},
  );

  testWidgets('advancing to a second Challenge clears the field and disables Submit',
      (tester) async {
    await tester.pumpWidget(host(challengeA));
    await tester.enterText(find.byType(TextField), 'my answer to A');
    await tester.pump();
    expect(find.text('my answer to A'), findsOneWidget);

    // Advance to a different Challenge at the SAME tree position.
    await tester.pumpWidget(host(challengeB));
    await tester.pump();

    // The field must be EMPTY (no bleed) and Submit disabled.
    expect(find.text('my answer to A'), findsNothing);
    expect(find.text('Question B'), findsOneWidget);
    final submit = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Submit'));
    expect(submit.onPressed, isNull, reason: 'empty field → Submit disabled');
  });

  testWidgets('advancing between two HotTakes shows the new statement, no stale reveal',
      (tester) async {
    const hotA = ModuleContentItem(
        id: 'ht-A', type: 'HOT_TAKE', contentJson: {'statement': 'Statement A'});
    const hotB = ModuleContentItem(
        id: 'ht-B', type: 'HOT_TAKE', contentJson: {'statement': 'Statement B'});

    await tester.pumpWidget(host(hotA));
    expect(find.text('Statement A'), findsOneWidget);
    await tester.pumpWidget(host(hotB));
    await tester.pump();
    expect(find.text('Statement A'), findsNothing);
    expect(find.text('Statement B'), findsOneWidget);
    // Fresh item → answer buttons present, no carried verdict banner.
    expect(find.text('Agree'), findsOneWidget);
    expect(find.text('Correct!'), findsNothing);
    expect(find.text('Not quite'), findsNothing);
  });
}
