import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/flashcards/presentation/flashcard_view_model.dart';

void main() {
  group('FlashCardState', () {
    test('default state has hasWikiPages null and isGenerating false', () {
      const s = FlashCardState();
      expect(s.hasWikiPages, isNull);
      expect(s.isGenerating, isFalse);
    });

    test('copyWith sets hasWikiPages via sentinel', () {
      const s = FlashCardState();
      final withPages = s.copyWith(hasWikiPages: true);
      expect(withPages.hasWikiPages, isTrue);

      final noPages = s.copyWith(hasWikiPages: false);
      expect(noPages.hasWikiPages, isFalse);
    });

    test('copyWith omitting hasWikiPages preserves previous value', () {
      const s = FlashCardState(hasWikiPages: true);
      final next = s.copyWith(isLoading: true);
      expect(next.hasWikiPages, isTrue);
    });

    test('copyWith clears hasWikiPages to null via sentinel', () {
      const s = FlashCardState(hasWikiPages: true);
      final cleared = s.copyWith(hasWikiPages: null);
      expect(cleared.hasWikiPages, isNull);
    });

    test('hasCards is false when filteredCards is empty', () {
      const s = FlashCardState(cards: []);
      expect(s.hasCards, isFalse);
    });

    test('isGenerating true blocks auto-backfill re-trigger via state', () {
      const generating = FlashCardState(isGenerating: true, isLoading: false);
      expect(generating.isGenerating, isTrue);
      expect(generating.isLoading, isFalse);
    });
  });
}
