import 'package:flutter_test/flutter_test.dart';
import 'package:pally/shared/models/mochi_cosmetics.dart';

void main() {
  group('MochiCosmetics — empty-catalog gating', () {
    test('hasAnyCosmetics is false while catalogs are empty (no art shipped)',
        () {
      // Guard contract: any cosmetic-picker surface must render nothing while
      // this is false. Until layered art is commissioned, it stays false.
      expect(MochiCosmetics.hasAnyCosmetics, isFalse);
    });

    test('every slot resolver returns null for any id while catalogs are empty',
        () {
      expect(MochiCosmetics.eyewearAsset('round_glasses'), isNull);
      expect(MochiCosmetics.clothesAsset('lab_coat'), isNull);
      expect(MochiCosmetics.shoesAsset('sneakers'), isNull);
    });

    test('null / empty slot ids resolve to null', () {
      expect(MochiCosmetics.eyewearAsset(null), isNull);
      expect(MochiCosmetics.clothesAsset(''), isNull);
      expect(MochiCosmetics.shoesAsset(null), isNull);
    });
  });
}
