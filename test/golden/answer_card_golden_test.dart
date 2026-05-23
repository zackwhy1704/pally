import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/features/chat/presentation/widgets/answer_card.dart';
import 'package:pally/shared/models/photo_question.dart';

const _answer = QuestionAnswer(
  questionId: 'q1',
  questionText: 'What is 2 + 2?',
  answer: '4',
  steps: ['Take the number 2', 'Add another 2', 'You get 4'],
  explanation: 'Simple addition — you got this! 🎉',
);

Widget _wrap(Widget child) => MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );

void main() {
  group('AnswerCard golden', () {
    testWidgets('collapsed state', (tester) async {
      await tester.pumpWidget(_wrap(
        AnswerCard(
          answer: _answer,
          questionNumber: 1,
          color: AppColors.teal,
          isExpanded: false,
          onToggle: () {},
        ),
      ));
      await expectLater(
        find.byType(AnswerCard),
        matchesGoldenFile('goldens/answer_card_collapsed.png'),
      );
    });

    testWidgets('expanded state', (tester) async {
      await tester.pumpWidget(_wrap(
        AnswerCard(
          answer: _answer,
          questionNumber: 1,
          color: AppColors.teal,
          isExpanded: true,
          onToggle: () {},
        ),
      ));
      await expectLater(
        find.byType(AnswerCard),
        matchesGoldenFile('goldens/answer_card_expanded.png'),
      );
    });
  });
}
