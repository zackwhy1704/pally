import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/quiz/presentation/quiz_screen.dart';
import 'package:pally/features/quiz/presentation/quiz_view_model.dart';

/// Regression for the "moving mochi" bug: while a quiz generates, the loading
/// view rotates a marketing tagline every 3s. Those taglines differ in length
/// (1 vs 2 rendered lines), so before the fix the reflow shifted the centred
/// column and the mochi visibly jumped each rotation. The mochi + spinner must
/// now stay pixel-still regardless of which tagline is showing.
class _LoadingQuizVM extends QuizViewModel {
  @override
  QuizState build(String avatarId) => const QuizState(isLoading: true);
}

Widget _wrap() => ProviderScope(
      overrides: [
        quizViewModelProvider('av-1').overrideWith(_LoadingQuizVM.new),
      ],
      child: const MaterialApp(home: QuizScreen(avatarId: 'av-1')),
    );

void main() {
  testWidgets('mochi stays put while the loading tagline rotates',
      (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pump();

    // We are on the loading view: mochi image + "Building your quiz…" label.
    expect(find.text('Building your quiz…'), findsOneWidget);
    final mochi = find.byType(Image);
    expect(mochi, findsOneWidget);

    final origin = tester.getTopLeft(mochi);
    // First tagline (index 0) is showing.
    expect(find.text('Learn it.'), findsOneWidget);

    // Advance past the 3s rotation + finish the 400ms cross-fade.
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 500));

    // The tagline actually rotated (proves the swap happened)…
    expect(find.text('Trained on your notes.'), findsOneWidget);
    // …yet the mochi did not move.
    expect(tester.getTopLeft(mochi), origin);

    // Rotate once more — still rock-still.
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.getTopLeft(mochi), origin);
  });
}
