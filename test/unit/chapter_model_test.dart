import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/chapters/domain/chapter.dart';

void main() {
  group('Chapter.fromJson', () {
    test('maps state strings and page range', () {
      final c = Chapter.fromJson({
        'chunkId': 'c1',
        'parentFileId': 'p1',
        'title': 'Chapter 1',
        'pageFrom': 1,
        'pageTo': 25,
        'pageCount': 25,
        'state': 'LOCKED',
      });
      expect(c.chunkId, 'c1');
      expect(c.title, 'Chapter 1');
      expect(c.pageFrom, 1);
      expect(c.pageTo, 25);
      expect(c.state, ChapterState.locked);
      expect(c.isLocked, isTrue);
    });

    test('unknown/blank state falls back to locked; blank title defaults', () {
      final c = Chapter.fromJson({'chunkId': 'c', 'title': '  ', 'state': null});
      expect(c.state, ChapterState.locked);
      expect(c.title, 'Chapter');
    });
  });

  group('ChaptersResult', () {
    test('remaining + locked + unlimited derive correctly', () {
      final r = ChaptersResult.fromJson({
        'allowanceUsed': 3,
        'allowanceLimit': 5,
        'chapters': [
          {'chunkId': 'a', 'state': 'LOCKED'},
          {'chunkId': 'b', 'state': 'COMPILED'},
          {'chunkId': 'c', 'state': 'COMPILING'},
        ],
      });
      expect(r.unlimited, isFalse);
      expect(r.remaining, 2); // 5 - 3
      expect(r.locked.map((c) => c.chunkId), ['a']);
    });

    test('limit -1 is unlimited', () {
      final r = ChaptersResult.fromJson({'allowanceUsed': 9, 'allowanceLimit': -1, 'chapters': []});
      expect(r.unlimited, isTrue);
    });

    test('remaining never goes negative', () {
      final r = ChaptersResult.fromJson({'allowanceUsed': 7, 'allowanceLimit': 5, 'chapters': []});
      expect(r.remaining, 0);
    });
  });
}
