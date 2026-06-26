import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/quiz/presentation/quiz_screen.dart';
import 'package:pally/features/quiz/presentation/quiz_view_model.dart';
import 'package:pally/shared/models/quiz_question.dart';

/// The phone-render half of the answer-key exposure fix — the half the Python
/// smoke harness CANNOT see. A teacher-graded (centre) quiz withholds the key
/// (`correctIndex == null`); the in-quiz UI must show NO correct/incorrect
/// verdict for it (otherwise a `?? 0` default would confidently highlight
/// option A as correct on every question). B2C quizzes (key known) keep their
/// instant feedback.
class _StubQuizVM extends QuizViewModel {
  _StubQuizVM(this._initial);
  final QuizState _initial;
  @override
  QuizState build(String avatarId) => _initial;
}

QuizState _answered({required int? correctIndex}) => QuizState(
      confidenceMode: false,
      isAnswered: true,
      selectedAnswer: 0,
      questions: [
        QuizQuestion(
          id: 'q-1',
          question: 'Which gas do plants absorb?',
          options: const ['Oxygen', 'Carbon dioxide', 'Nitrogen'],
          correctIndex: correctIndex, // null = teacher-graded (key withheld)
          sourcePage: 'photosynthesis',
          explanation: 'Plants take in carbon dioxide.',
        ),
      ],
    );

Widget _wrap(QuizState s) => ProviderScope(
      overrides: [
        quizViewModelProvider('av-1').overrideWith(() => _StubQuizVM(s)),
      ],
      child: const MaterialApp(home: QuizScreen(avatarId: 'av-1')),
    );

void main() {
  testWidgets('withheld key (centre quiz) shows NO verdict — only a locked note',
      (tester) async {
    await tester.pumpWidget(_wrap(_answered(correctIndex: null)));
    await tester.pump();

    // Neutral "answer recorded" note instead of a verdict.
    expect(find.textContaining('Answer locked in'), findsOneWidget);
    // No correct/incorrect colouring or icons — the key is secret by design.
    expect(find.byIcon(Icons.check_circle_rounded), findsNothing);
    expect(find.byIcon(Icons.cancel_rounded), findsNothing);
    // The explanation (which can reveal the answer) is not shown pre-submit.
    expect(find.textContaining('Plants take in carbon dioxide'), findsNothing);
  });

  testWidgets('known key (B2C quiz) STILL shows instant verdict — not regressed',
      (tester) async {
    // correctIndex 0 == selectedAnswer 0 → correct → instant feedback shown.
    await tester.pumpWidget(_wrap(_answered(correctIndex: 0)));
    await tester.pump();

    // Verdict IS shown (correct-option check + explanation header) — contrast
    // with the withheld case which shows none.
    expect(find.byIcon(Icons.check_circle_rounded), findsWidgets);
    expect(find.textContaining('Answer locked in'), findsNothing);
  });
}
