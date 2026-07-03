import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/modules/presentation/widgets/test_body.dart';
import 'package:pally/shared/models/learning_module.dart';

/// TEST-stage reveal must read the answer from answerJson, not contentJson. The
/// generators keep answers out of contentJson (leak-safe + a student sees
/// contentJson before revealing), so reading reveal fields from contentJson made
/// SPOT_MISTAKE / HOT_TAKE / CHALLENGE reveals render EMPTY. This pins the fix.
void main() {
  Widget host(ModuleContentItem item) => MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 800,
            height: 1200,
            child: TestBody(
              item: item,
              currentIndex: 0,
              totalItems: 1,
              isRevealed: true,
              answer: null,
              onAnswer: (_, __) {},
              onNext: () {},
              isLast: true,
              isSubmitting: false,
            ),
          ),
        ),
      );

  testWidgets('SPOT_MISTAKE reveal shows errorDescription + correctSolution from answerJson', (tester) async {
    const item = ModuleContentItem(
      id: 'i1',
      type: 'SPOT_MISTAKE',
      // The prompt is in contentJson; the answer is ONLY in answerJson (as generated).
      contentJson: {'problem': 'Solve 2+2', 'wrongSolution': '5'},
      answerJson: {'errorDescription': 'They added wrong', 'correctSolution': 'The answer is 4'},
    );

    await tester.pumpWidget(host(item));

    // Both would be empty (never found) if the reveal still read contentJson.
    expect(find.text('The answer is 4'), findsOneWidget);
    expect(find.text('They added wrong'), findsOneWidget);
  });
}
