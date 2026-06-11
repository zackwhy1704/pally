import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/modules/presentation/module_player_view_model.dart';
import 'package:pally/shared/models/learning_module.dart';

void main() {
  group('ModulePlayerState', () {
    test('default state has isLoading false and no items', () {
      const s = ModulePlayerState();
      expect(s.isLoading, isFalse);
      expect(s.isSubmitting, isFalse);
      expect(s.isComplete, isFalse);
      expect(s.items, isEmpty);
      expect(s.currentIndex, 0);
      expect(s.stage, 'LEARN');
      expect(s.module, isNull);
      expect(s.results, isNull);
      expect(s.error, isNull);
      expect(s.answers, isEmpty);
      expect(s.revealedItems, isEmpty);
    });

    test('currentItem returns null when items is empty', () {
      const s = ModulePlayerState();
      expect(s.currentItem, isNull);
    });

    test('currentItem returns the item at currentIndex', () {
      const item1 = ModuleContentItem(
        id: 'i1',
        stage: 'LEARN',
        type: 'MICRO_CARD',
        contentJson: {'title': 'Card 1'},
      );
      const item2 = ModuleContentItem(
        id: 'i2',
        stage: 'LEARN',
        type: 'MICRO_CARD',
        contentJson: {'title': 'Card 2'},
      );
      const s = ModulePlayerState(items: [item1, item2], currentIndex: 1);
      expect(s.currentItem?.id, 'i2');
    });

    test('isLastItem is true when on the last item', () {
      const item = ModuleContentItem(
        id: 'i1',
        stage: 'LEARN',
        type: 'MICRO_CARD',
        contentJson: {},
      );
      const s = ModulePlayerState(items: [item], currentIndex: 0);
      expect(s.isLastItem, isTrue);
    });

    test('isLastItem is false when not on the last item', () {
      const item1 = ModuleContentItem(
        id: 'i1',
        stage: 'LEARN',
        type: 'MICRO_CARD',
        contentJson: {},
      );
      const item2 = ModuleContentItem(
        id: 'i2',
        stage: 'LEARN',
        type: 'MICRO_CARD',
        contentJson: {},
      );
      const s = ModulePlayerState(items: [item1, item2], currentIndex: 0);
      expect(s.isLastItem, isFalse);
    });

    test('totalItems returns the length of items', () {
      const item = ModuleContentItem(
        id: 'i1',
        stage: 'TEST',
        type: 'HOT_TAKE',
        contentJson: {},
      );
      const s = ModulePlayerState(items: [item, item, item]);
      expect(s.totalItems, 3);
    });

    test('copyWith preserves values via sentinel for nullable fields', () {
      const s = ModulePlayerState(
        stage: 'TEST',
        currentIndex: 2,
        isLoading: true,
      );
      final next = s.copyWith(isLoading: false);
      expect(next.stage, 'TEST');
      expect(next.currentIndex, 2);
      expect(next.isLoading, isFalse);
    });

    test('copyWith can set results to null', () {
      final s = ModulePlayerState(
        results: const ModuleResults(xpEarned: 10),
      );
      final cleared = s.copyWith(results: null);
      expect(cleared.results, isNull);
    });

    test('answers map tracks item responses', () {
      const s = ModulePlayerState(
        answers: {'item-1': 'AGREE', 'item-2': 'my answer'},
      );
      expect(s.answers['item-1'], 'AGREE');
      expect(s.answers['item-2'], 'my answer');
    });

    test('revealedItems set tracks revealed items', () {
      const s = ModulePlayerState(
        revealedItems: {'item-1', 'item-3'},
      );
      expect(s.revealedItems.contains('item-1'), isTrue);
      expect(s.revealedItems.contains('item-2'), isFalse);
      expect(s.revealedItems.contains('item-3'), isTrue);
    });
  });
}
