import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/create_tutor/presentation/create_tutor_view_model.dart';
import 'package:pally/shared/models/mochi_character.dart';

void main() {
  group('CreateTutorState.copyWith — selectedCharacter sentinel', () {
    test('passing a character sets it', () {
      const s = CreateTutorState();
      final next = s.copyWith(selectedCharacter: MochiCharacter.mochi);
      expect(next.selectedCharacter, MochiCharacter.mochi);
    });

    test('passing null clears the selection', () {
      final s = const CreateTutorState().copyWith(
        selectedCharacter: MochiCharacter.mochi,
      );
      final cleared = s.copyWith(selectedCharacter: null);
      expect(cleared.selectedCharacter, isNull);
    });

    test('omitting selectedCharacter preserves previous value', () {
      final s = const CreateTutorState().copyWith(
        selectedCharacter: MochiCharacter.mochi,
      );
      final preserved = s.copyWith(name: 'New name');
      expect(preserved.selectedCharacter, MochiCharacter.mochi);
    });
  });

  group('MochiRarity — COMMON label', () {
    test('standard rarity label is COMMON', () {
      expect(MochiRarity.standard.label, 'COMMON');
    });

    test('rare and secret labels unchanged', () {
      expect(MochiRarity.rare.label, 'RARE');
      expect(MochiRarity.secret.label, 'SECRET');
    });

    test('standard badge color is non-transparent (visible badge)', () {
      expect(
        MochiRarity.standard.badgeColor.a,
        greaterThan(0),
      );
    });
  });
}
