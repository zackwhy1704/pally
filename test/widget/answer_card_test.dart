import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/features/chat/presentation/widgets/answer_card.dart';
import 'package:pally/shared/models/photo_question.dart';

const _testAnswer = QuestionAnswer(
  questionId: 'q1',
  questionText: 'What is 2 + 2?',
  answer: '4',
  steps: ['Start with 2', 'Add 2 more', 'Total is 4'],
  explanation: 'Simple addition!',
);

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('AnswerCard', () {
    testWidgets('renders question text in header', (tester) async {
      await tester.pumpWidget(_wrap(
        AnswerCard(
          answer: _testAnswer,
          questionNumber: 1,
          color: AppColors.teal,
          isExpanded: false,
          onToggle: () {},
        ),
      ));
      expect(find.text('What is 2 + 2?'), findsOneWidget);
    });

    testWidgets('shows Show arrow when collapsed', (tester) async {
      await tester.pumpWidget(_wrap(
        AnswerCard(
          answer: _testAnswer,
          questionNumber: 1,
          color: AppColors.teal,
          isExpanded: false,
          onToggle: () {},
        ),
      ));
      expect(find.text('Show →'), findsOneWidget);
    });

    testWidgets('shows answer when expanded', (tester) async {
      await tester.pumpWidget(_wrap(
        AnswerCard(
          answer: _testAnswer,
          questionNumber: 1,
          color: AppColors.green,
          isExpanded: true,
          onToggle: () {},
        ),
      ));
      expect(find.text('= 4'), findsOneWidget);
      expect(find.text('Simple addition!'), findsOneWidget);
    });

    testWidgets('shows step-by-step when expanded', (tester) async {
      await tester.pumpWidget(_wrap(
        AnswerCard(
          answer: _testAnswer,
          questionNumber: 1,
          color: AppColors.purple,
          isExpanded: true,
          onToggle: () {},
        ),
      ));
      expect(find.text('Start with 2'), findsOneWidget);
      expect(find.text('Add 2 more'), findsOneWidget);
      expect(find.text('Total is 4'), findsOneWidget);
    });

    testWidgets('does not show steps when collapsed', (tester) async {
      await tester.pumpWidget(_wrap(
        AnswerCard(
          answer: _testAnswer,
          questionNumber: 1,
          color: AppColors.amber,
          isExpanded: false,
          onToggle: () {},
        ),
      ));
      expect(find.text('Start with 2'), findsNothing);
    });

    testWidgets('calls onToggle when tapped', (tester) async {
      var toggled = false;
      await tester.pumpWidget(_wrap(
        AnswerCard(
          answer: _testAnswer,
          questionNumber: 1,
          color: AppColors.teal,
          isExpanded: false,
          onToggle: () => toggled = true,
        ),
      ));
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pump();
      expect(toggled, isTrue);
    });

    testWidgets('displays question number badge', (tester) async {
      await tester.pumpWidget(_wrap(
        AnswerCard(
          answer: _testAnswer,
          questionNumber: 3,
          color: AppColors.teal,
          isExpanded: false,
          onToggle: () {},
        ),
      ));
      expect(find.text('3'), findsOneWidget);
    });
  });
}
