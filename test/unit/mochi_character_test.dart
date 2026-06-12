import 'package:flutter_test/flutter_test.dart';
import 'package:pally/shared/models/mochi_character.dart';

/// Locks the F1 reset of the Mochi roster:
///  - the new `mochi` enum value exists and uses base.png,
///  - it is the ONLY default-unlocked character,
///  - all 8 school Mochis are locked by default (they live in the
///    mystery box now),
///  - jsonValue round-trip still works for every value.
void main() {
  group('MochiCharacter — F1 reset', () {
    test('mochi enum value exists with base.png asset', () {
      expect(MochiCharacter.mochi.assetPath, 'assets/images/base.png');
      expect(MochiCharacter.mochi.displayName, 'Mochi');
    });

    test('mochi is the only default-unlocked character', () {
      final unlocked = MochiCharacter.values
          .where((c) => !c.isLockedByDefault)
          .toList();
      expect(unlocked, [MochiCharacter.mochi]);
    });

    test('every school Mochi is locked by default', () {
      const schoolMochis = [
        MochiCharacter.pencil,
        MochiCharacter.science,
        MochiCharacter.pe,
        MochiCharacter.art,
        MochiCharacter.lunchbox,
        MochiCharacter.library,
        MochiCharacter.headmaster,
        MochiCharacter.goldstar,
      ];
      for (final c in schoolMochis) {
        expect(c.isLockedByDefault, isTrue,
            reason: '${c.name} must be locked by default after F1');
      }
    });

    test('roster has exactly 9 characters (starter + 8 school Mochis)', () {
      // The 8 unreleased aroundTheWorld characters were removed product-wide,
      // so the enum is now exactly the starter Mochi plus the 8 school Mochis.
      // Catches an accidental add/remove that would knock the box odds off
      // the spec (6×15 + 8 + 2 = 100).
      expect(MochiCharacter.values.length, 9);
    });

    test('jsonValue round-trip preserves identity', () {
      for (final c in MochiCharacter.values) {
        final json = c.jsonValue;
        final back = MochiCharacter.fromJson(json);
        expect(back, c, reason: '$c failed round-trip via $json');
      }
    });

    test('fromJson unknown returns pencil fallback (back-compat)', () {
      // The catalog can ship Mochis the app doesn't know about yet (a
      // future seasonal theme). The picker uses the fallback as a safe
      // default so older clients don't crash.
      expect(
          MochiCharacter.fromJson('NOT_A_REAL_MOCHI'), MochiCharacter.pencil);
    });
  });
}
