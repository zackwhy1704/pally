import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/groups/presentation/groups_view_model.dart';

void main() {
  group('ShareResult', () {
    test('earnedReward is true when xpGranted > 0', () {
      const r = ShareResult(
        id: 'n1',
        relevanceStatus: 'OK',
        xpGranted: 10,
        starsGranted: 5,
      );
      expect(r.earnedReward, isTrue);
    });

    test('earnedReward is false when xpGranted is 0 (re-share dedup)', () {
      const r = ShareResult(
        id: 'n2',
        relevanceStatus: 'OK',
        xpGranted: 0,
        starsGranted: 0,
      );
      expect(r.earnedReward, isFalse);
    });

    test('wasBlocked is true for BLOCKED status', () {
      const r = ShareResult(
        id: 'n3',
        relevanceStatus: 'BLOCKED',
        xpGranted: 0,
        starsGranted: 0,
      );
      expect(r.wasBlocked, isTrue);
      expect(r.earnedReward, isFalse);
    });

    test('wasBlocked is false for OK and WARNING', () {
      expect(
        const ShareResult(
                id: 'a', relevanceStatus: 'OK', xpGranted: 10, starsGranted: 5)
            .wasBlocked,
        isFalse,
      );
      expect(
        const ShareResult(
                id: 'b',
                relevanceStatus: 'WARNING',
                xpGranted: 10,
                starsGranted: 5)
            .wasBlocked,
        isFalse,
      );
    });
  });

  group('SharedNote', () {
    test('defaults relevanceStatus to OK', () {
      final n = SharedNote(
        id: 'n1',
        wikiPageId: 'wp1',
        avatarId: 'av1',
        title: 'Photosynthesis',
        sharedBy: 'Alex',
        sharedAt: DateTime(2025),
      );
      expect(n.relevanceStatus, 'OK');
    });

    test('preserves provided relevanceStatus', () {
      final n = SharedNote(
        id: 'n2',
        wikiPageId: 'wp2',
        avatarId: 'av1',
        title: 'Random',
        sharedBy: 'Bob',
        sharedAt: DateTime(2025),
        relevanceStatus: 'WARNING',
      );
      expect(n.relevanceStatus, 'WARNING');
    });
  });

  group('StudyGroup.fromJson', () {
    test('parses a complete response correctly', () {
      final g = StudyGroup.fromJson({
        'id': 'g1',
        'name': 'Science Squad',
        'subject': 'Science',
        'inviteCode': 'AB12CD',
        'memberCount': 3,
      });
      expect(g.id, 'g1');
      expect(g.name, 'Science Squad');
      expect(g.subject, 'Science');
      expect(g.inviteCode, 'AB12CD');
      expect(g.memberCount, 3);
    });

    test('handles null subject gracefully', () {
      final g = StudyGroup.fromJson({
        'id': 'g2',
        'name': 'Fun Group',
        'inviteCode': 'XY99ZZ',
        'memberCount': 1,
      });
      expect(g.subject, isNull);
    });

    test('defaults memberCount to 0 on missing field', () {
      final g = StudyGroup.fromJson({
        'id': 'g3',
        'name': 'Solo',
        'inviteCode': 'QQ0000',
      });
      expect(g.memberCount, 0);
    });
  });
}
