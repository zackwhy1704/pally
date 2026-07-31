import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/quiz/presentation/quiz_view_model.dart';

void main() {
  group('QuizState — rewardLabel (level-up wiring)', () {
    test('rewardLabel defaults to null', () {
      const state = QuizState();
      expect(state.rewardLabel, isNull);
    });

    test('copyWith sets rewardLabel alongside levelledUp/newLevel', () {
      const original = QuizState();
      final leveled = original.copyWith(
        levelledUp: true,
        newLevel: 5,
        rewardLabel: 'Extra free Mochi slot',
      );
      expect(leveled.levelledUp, isTrue);
      expect(leveled.newLevel, 5);
      expect(leveled.rewardLabel, 'Extra free Mochi slot');
    });

    test('copyWith can set rewardLabel to null explicitly '
        '(a crossing with no reward tier)', () {
      const original = QuizState(
          levelledUp: true, newLevel: 4, rewardLabel: 'Sparkle avatar effect');
      final cleared = original.copyWith(rewardLabel: null);
      expect(cleared.rewardLabel, isNull);
      // levelledUp/newLevel untouched by the explicit-null rewardLabel pass.
      expect(cleared.levelledUp, isTrue);
      expect(cleared.newLevel, 4);
    });

    test('copyWith preserves rewardLabel when not passed', () {
      const original =
          QuizState(levelledUp: true, newLevel: 2, rewardLabel: 'New Mochi colour');
      final copy = original.copyWith(score: 5);
      expect(copy.rewardLabel, 'New Mochi colour');
    });
  });
}
