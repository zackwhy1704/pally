import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/quiz/presentation/quiz_screen.dart';
import 'package:pally/features/quiz/presentation/quiz_view_model.dart';
import 'package:pally/shared/models/quiz_question.dart';

/// Stub VM that hands the screen a fixed completed state so the results page
/// renders deterministically without any network/Claude call.
class _StubQuizVM extends QuizViewModel {
  _StubQuizVM(this._initial);
  final QuizState _initial;
  @override
  QuizState build(String avatarId) => _initial;
}

// A UUID-shaped question id, like the backend returns. If this leaks verbatim
// to the UI, the regex below catches it.
const _uuid = 'a1b2c3d4-e5f6-7890-abcd-ef0123456789';

final _completedState = QuizState(
  isComplete: true,
  score: 2,
  xpEarned: 40,
  questions: const [
    QuizQuestion(
      id: _uuid,
      question: 'Which gas do plants absorb during photosynthesis?',
      options: ['Oxygen', 'Carbon dioxide', 'Nitrogen', 'Hydrogen'],
      correctIndex: 1,
      sourcePage: 'photosynthesis-basics',
      explanation: 'Plants take in carbon dioxide.',
    ),
  ],
  // Mastery matrix carries the question ID, NOT a topic name — the UI must
  // resolve it to the question text before showing it.
  masteryMatrix: const MasteryMatrix(
    misconception: [_uuid],
    priorityReview: _uuid,
  ),
);

Widget _wrap(QuizState s) {
  return ProviderScope(
    overrides: [
      quizViewModelProvider('av-1').overrideWith(() => _StubQuizVM(s)),
    ],
    child: const MaterialApp(home: QuizScreen(avatarId: 'av-1')),
  );
}

void main() {
  group('humaniseSlug', () {
    test('turns a dashed slug into a title-cased name', () {
      expect(humaniseSlug('fractions-basics'), 'Fractions Basics');
      expect(humaniseSlug('photosynthesis_chapter_3'),
          'Photosynthesis Chapter 3');
    });
  });

  group('questionLabel', () {
    const qs = [
      QuizQuestion(id: 'q-1', question: 'What is 2 + 2?'),
    ];

    test('resolves a known id to its question text, not the id', () {
      expect(questionLabel('q-1', qs), 'What is 2 + 2?');
    });

    test('falls back to a humanised slug for an unknown id (never raw)', () {
      final label = questionLabel('mixed-fractions', qs);
      expect(label, 'Mixed Fractions');
      expect(label.contains('-'), isFalse);
    });

    test('a UUID id with no match never surfaces verbatim', () {
      final label = questionLabel(_uuid, qs);
      expect(label, isNot(equals(_uuid)));
      expect(label.contains('-'), isFalse);
    });
  });

  testWidgets(
      'completed results page names topics by question text, never a raw uuid',
      (tester) async {
    await tester.pumpWidget(_wrap(_completedState));
    await tester.pump();

    // The completion screen is up.
    expect(find.text('Quiz Complete!'), findsOneWidget);

    // The mastery + memory cards show the resolved question text…
    expect(find.textContaining('Which gas do plants absorb'),
        findsWidgets);

    // …and the raw UUID never appears anywhere on the page.
    final uuidPattern = RegExp(
        r'[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}');
    expect(find.byWidgetPredicate((w) {
      if (w is Text && w.data != null) return uuidPattern.hasMatch(w.data!);
      return false;
    }), findsNothing);
  });
}
