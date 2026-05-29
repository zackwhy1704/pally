import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/collection/presentation/collection_view_model.dart';
import 'package:pally/shared/models/mochi_character.dart';

/// Locks the album math + null-character handling so the screen never
/// divides by zero or renders a 1.5× progress bar.
void main() {
  group('CollectionState', () {
    test('progress is 0 when empty (no /0 trap)', () {
      const s = CollectionState();
      expect(s.totalCount, 0);
      expect(s.ownedCount, 0);
      expect(s.progress, 0);
    });

    test('owned/total counts reflect entries', () {
      const s = CollectionState(entries: [
        CollectionEntry(
            id: 'MOCHI',
            character: MochiCharacter.mochi,
            rarity: 'COMMON',
            unlocked: true),
        CollectionEntry(
            id: 'PENCIL',
            character: MochiCharacter.pencil,
            rarity: 'COMMON',
            unlocked: true),
        CollectionEntry(
            id: 'GOLDSTAR',
            character: MochiCharacter.goldstar,
            rarity: 'SECRET',
            unlocked: false),
      ]);
      expect(s.totalCount, 3);
      expect(s.ownedCount, 2);
      expect(s.progress, closeTo(0.667, 0.01));
    });

    test('entries with unknown character (future seasonal) survive', () {
      const s = CollectionState(entries: [
        CollectionEntry(
            id: 'FUTURE_MOCHI',
            character: null,
            rarity: 'RARE',
            unlocked: false),
      ]);
      expect(s.totalCount, 1);
      expect(s.ownedCount, 0);
      // Album tile renders a "?" silhouette for these — see _AlbumTile.
    });

    test('copyWith preserves entries when only error toggles', () {
      const s = CollectionState(
        entries: [
          CollectionEntry(
              id: 'MOCHI',
              character: MochiCharacter.mochi,
              rarity: 'COMMON',
              unlocked: true),
        ],
      );
      final withError = s.copyWith(error: 'network');
      expect(withError.entries, hasLength(1));
      final cleared = withError.copyWith(error: null);
      expect(cleared.entries, hasLength(1));
      expect(cleared.error, isNull);
    });
  });
}
