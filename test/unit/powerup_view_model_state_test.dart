import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/shop/presentation/powerup_view_model.dart';

/// Pure state tests for PowerupState.copyWith. The sentinel pattern on
/// `error` and `lastPurchase` is load-bearing — a regression breaks the
/// snackbar reactions (firing twice / never firing).
void main() {
  group('PowerupState', () {
    test('defaults: empty counts + empty catalog + not loading', () {
      const s = PowerupState();
      expect(s.isLoading, isFalse);
      expect(s.isBuying, isFalse);
      expect(s.counts, isEmpty);
      expect(s.catalog, isEmpty);
      expect(s.lastPurchase, isNull);
      expect(s.error, isNull);
    });

    test('copyWith updates counts independently of catalog', () {
      const s = PowerupState(
        counts: {'HINT_TOKEN': 3},
        catalog: {
          'HINT_TOKEN': PowerupCatalogEntry(cost: 50, label: 'hint'),
        },
      );
      final updated = s.copyWith(counts: {'HINT_TOKEN': 4});
      expect(updated.counts['HINT_TOKEN'], 4);
      expect(updated.catalog['HINT_TOKEN']?.cost, 50);
    });

    test('error clears via null but preserves on bare copy', () {
      const s = PowerupState(error: 'Not enough stars');
      expect(s.copyWith(isBuying: true).error, 'Not enough stars');
      expect(s.copyWith(error: null).error, isNull);
    });

    test('lastPurchase clears via null sentinel', () {
      const s = PowerupState(
        lastPurchase: PowerupPurchase(
            type: 'HINT_TOKEN', count: 1, newStarBalance: 50),
      );
      expect(s.lastPurchase, isNotNull);
      final cleared = s.copyWith(lastPurchase: null);
      expect(cleared.lastPurchase, isNull);
    });

    test('lastPurchase preserved when not passed (no sentinel collision)', () {
      const s = PowerupState(
        lastPurchase: PowerupPurchase(
            type: 'DOUBLE_XP', count: 2, newStarBalance: 100),
      );
      final touched = s.copyWith(isBuying: true);
      expect(touched.lastPurchase?.type, 'DOUBLE_XP');
      expect(touched.lastPurchase?.count, 2);
    });
  });
}
