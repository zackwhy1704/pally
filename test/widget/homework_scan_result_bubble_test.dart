import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/chat/presentation/widgets/homework_scan_result_bubble.dart';
import 'package:pally/shared/models/photo_question.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

const _q1 = PhotoQuestion(id: 'q1', rawText: 'Q1', questionIndex: 1);
const _q2 = PhotoQuestion(id: 'q2', rawText: 'Q2', questionIndex: 2);

const _result = HomeworkScanResult(
  messageId: 'msg1',
  imageLocalPath: '/img.jpg',
  questions: [_q1, _q2],
  answers: [
    QuestionAnswer(
      questionId: 'q1',
      questionText: 'What is 2+2?',
      answer: '4',
      steps: ['Add 2 and 2'],
      explanation: 'Basic addition.',
    ),
    QuestionAnswer(
      questionId: 'q2',
      questionText: 'What is 3×3?',
      answer: '9',
      steps: ['Multiply 3 by 3'],
      explanation: 'Basic multiplication.',
    ),
  ],
  xpEarned: 10,
  status: HomeworkScanStatus.complete,
);

void main() {
  group('HomeworkScanResultBubble', () {
    testWidgets('renders solved count header', (tester) async {
      await tester.pumpWidget(_wrap(
        const HomeworkScanResultBubble(result: _result),
      ));
      expect(find.text('Solved 2 questions!'), findsOneWidget);
    });

    testWidgets('renders XP badge', (tester) async {
      await tester.pumpWidget(_wrap(
        const HomeworkScanResultBubble(result: _result),
      ));
      expect(find.textContaining('+10 XP'), findsOneWidget);
    });

    testWidgets('renders first answer card expanded by default', (tester) async {
      await tester.pumpWidget(_wrap(
        const HomeworkScanResultBubble(result: _result),
      ));
      // First answer pill shows "= 4" when expanded
      expect(find.text('= 4'), findsOneWidget);
    });

    testWidgets('renders question texts', (tester) async {
      await tester.pumpWidget(_wrap(
        const HomeworkScanResultBubble(result: _result),
      ));
      expect(find.text('What is 2+2?'), findsOneWidget);
    });

    testWidgets('renders follow-up chips', (tester) async {
      await tester.pumpWidget(_wrap(
        const HomeworkScanResultBubble(result: _result),
      ));
      expect(find.textContaining('Show full working'), findsOneWidget);
      expect(find.textContaining('Another example'), findsOneWidget);
    });

    testWidgets('renders source badge when wiki page present', (tester) async {
      const resultWithSource = HomeworkScanResult(
        messageId: 'msg2',
        imageLocalPath: '/img.jpg',
        questions: [_q1],
        answers: [
          QuestionAnswer(
            questionId: 'q1',
            questionText: 'Q?',
            answer: 'A',
          ),
        ],
        sourceWikiPage: 'algebra-basics',
        status: HomeworkScanStatus.complete,
      );
      await tester.pumpWidget(_wrap(
        const HomeworkScanResultBubble(result: resultWithSource),
      ));
      expect(find.textContaining('algebra-basics'), findsOneWidget);
    });

    testWidgets('singular "question" when count is 1', (tester) async {
      const singleResult = HomeworkScanResult(
        messageId: 'msg3',
        imageLocalPath: '/img.jpg',
        questions: [_q1],
        answers: [
          QuestionAnswer(
            questionId: 'q1',
            questionText: 'Q?',
            answer: 'A',
          ),
        ],
        status: HomeworkScanStatus.complete,
      );
      await tester.pumpWidget(_wrap(
        const HomeworkScanResultBubble(result: singleResult),
      ));
      expect(find.text('Solved 1 question!'), findsOneWidget);
    });
  });
}
