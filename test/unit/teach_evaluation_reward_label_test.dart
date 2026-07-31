import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/teach_mochi/presentation/teach_mochi_view_model.dart';

void main() {
  group('TeachEvaluation.fromJson — rewardLabel (level-up wiring)', () {
    test('parses rewardLabel when present', () {
      final e = TeachEvaluation.fromJson({
        'score': 8,
        'totalConcepts': 10,
        'xpEarned': 15,
        'coveredConcepts': ['a'],
        'missedConcepts': [],
        'feedback': 'Nice work!',
        'levelledUp': true,
        'newLevel': 5,
        'rewardLabel': 'Extra free Mochi slot',
        'status': 'OK',
      });

      expect(e.levelledUp, isTrue);
      expect(e.newLevel, 5);
      expect(e.rewardLabel, 'Extra free Mochi slot');
    });

    test('rewardLabel defaults to null when absent (no level crossed)', () {
      final e = TeachEvaluation.fromJson({
        'score': 8,
        'totalConcepts': 10,
        'xpEarned': 15,
        'coveredConcepts': ['a'],
        'missedConcepts': [],
        'feedback': 'Nice work!',
      });

      expect(e.levelledUp, isFalse);
      expect(e.rewardLabel, isNull);
    });
  });
}
