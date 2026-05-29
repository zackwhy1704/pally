import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/shop/presentation/shop_view_model.dart';
import 'package:pally/shared/models/mochi_character.dart';

/// Pure-state tests for ShopState.copyWith. The new fields (isBuyingFreeze,
/// lastFreezePurchase) participate in the same sentinel-pattern dance the
/// rest of the state uses; a regression in copyWith silently breaks UX
/// reactions (snackbars firing twice, spinners stuck on).
void main() {
  group('ShopState copyWith — new freeze fields', () {
    test('isBuyingFreeze toggles independently', () {
      const s = ShopState(stars: 200);
      final updated = s.copyWith(isBuyingFreeze: true);
      expect(updated.isBuyingFreeze, isTrue);
      expect(updated.stars, 200);
    });

    test('lastFreezePurchase can be set then cleared via null', () {
      const s = ShopState();
      final bought = s.copyWith(
          lastFreezePurchase: const FreezePurchase(freezes: 2, freezeCap: 3));
      expect(bought.lastFreezePurchase, isNotNull);
      expect(bought.lastFreezePurchase!.freezes, 2);
      expect(bought.lastFreezePurchase!.freezeCap, 3);

      final cleared = bought.copyWith(lastFreezePurchase: null);
      expect(cleared.lastFreezePurchase, isNull);
    });

    test('not passing lastFreezePurchase preserves previous value', () {
      final s = const ShopState()
          .copyWith(lastFreezePurchase: const FreezePurchase(
              freezes: 1, freezeCap: 3));
      // Touch an unrelated field; the freeze purchase should survive.
      final touched = s.copyWith(isOpening: true);
      expect(touched.lastFreezePurchase, isNotNull);
      expect(touched.lastFreezePurchase!.freezes, 1);
    });

    test('lastUnlocked sentinel still works alongside new fields', () {
      const s = ShopState();
      final withChar = s.copyWith(lastUnlocked: MochiCharacter.pencil);
      expect(withChar.lastUnlocked, MochiCharacter.pencil);
      // Not passing lastUnlocked: preserves.
      final touched = withChar.copyWith(isBuyingFreeze: true);
      expect(touched.lastUnlocked, MochiCharacter.pencil);
      // Passing null explicitly: clears.
      final cleared = touched.copyWith(lastUnlocked: null);
      expect(cleared.lastUnlocked, isNull);
    });

    test('error clears via null but preserves on bare copy', () {
      const s = ShopState(error: 'Not enough stars');
      expect(s.copyWith(stars: 50).error, 'Not enough stars');
      expect(s.copyWith(error: null).error, isNull);
    });

    test('FreezePurchase value semantics', () {
      const a = FreezePurchase(freezes: 2, freezeCap: 3);
      const b = FreezePurchase(freezes: 2, freezeCap: 3);
      // Not @immutable equality-overridden, but kid-facing UI only inspects
      // fields. Locking the shape so a refactor toward freezed maintains
      // these accessors.
      expect(a.freezes, b.freezes);
      expect(a.freezeCap, b.freezeCap);
    });
  });
}
