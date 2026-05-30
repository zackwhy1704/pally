import 'package:flutter_test/flutter_test.dart';
import 'package:pally/shared/models/study_plan_item.dart';

void main() {
  group('StudyPlanItem', () {
    test('fromJson parses id, title, type, reason correctly', () {
      final item = StudyPlanItem.fromJson({
        'id': 'abc:quiz:2025-01-15',
        'title': 'Daily quiz — Zap',
        'type': 'QUIZ',
        'avatarId': 'abc',
        'done': false,
        'reason': 'Keep your daily streak going',
      });
      expect(item.id, 'abc:quiz:2025-01-15');
      expect(item.title, 'Daily quiz — Zap');
      expect(item.type, StudyPlanItemType.quiz);
      expect(item.reason, 'Keep your daily streak going');
      expect(item.isDone, isFalse);
    });

    test('fromJson defaults reason to empty string', () {
      final item = StudyPlanItem.fromJson({
        'id': 'abc:flashcard:2025-01-15',
        'title': 'Review 3 flashcards',
        'type': 'FLASHCARD',
        'avatarId': 'abc',
        'done': false,
      });
      expect(item.reason, '');
    });

    test('copyWith isDone preserves id and reason', () {
      final item = StudyPlanItem.fromJson({
        'id': 'abc:quiz:2025-01-15',
        'title': 'Quiz',
        'type': 'QUIZ',
        'avatarId': 'abc',
        'done': false,
        'reason': 'streak',
      });
      final done = item.copyWith(isDone: true);
      expect(done.isDone, isTrue);
      expect(done.id, 'abc:quiz:2025-01-15');
      expect(done.reason, 'streak');
    });

    test('unknown type falls back to practice', () {
      final item = StudyPlanItem.fromJson({
        'id': 'x',
        'title': 'Something',
        'type': 'UNKNOWN_TYPE',
        'avatarId': '',
        'done': false,
      });
      expect(item.type, StudyPlanItemType.practice);
    });
  });
}
