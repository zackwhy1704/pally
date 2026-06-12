import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/brain_map/presentation/brain_map_screen.dart';
import 'package:pally/features/brain_map/presentation/brain_map_view_model.dart';
import 'package:pally/shared/models/wiki_page.dart';

void main() {
  group('WikiPage knowledge-graph fields (null-tolerant)', () {
    test('absent graph fields fall back to safe defaults', () {
      // An older backend that omits the new fields must not crash and must
      // produce a renderable root node (no prereqs, 0 confidence/usage).
      final p = WikiPage.fromJson({
        'id': 'p1',
        'avatarId': 'a1',
        'title': 'Cells',
        'content': 'body',
      });
      expect(p.prerequisiteSlugs, isEmpty);
      expect(p.certaintyScore, 0.0);
      expect(p.quizUseCount, 0);
      expect(p.conflictNote, isNull);
    });

    test('present graph fields parse through', () {
      final p = WikiPage.fromJson({
        'id': 'p2',
        'avatarId': 'a1',
        'title': 'Photosynthesis',
        'content': 'body',
        'prerequisiteSlugs': ['cells', 'sunlight'],
        'certaintyScore': 0.75,
        'quizUseCount': 5,
        'hasConflict': true,
        'conflictNote': 'leaves are blue vs green',
      });
      expect(p.prerequisiteSlugs, ['cells', 'sunlight']);
      expect(p.certaintyScore, 0.75);
      expect(p.quizUseCount, 5);
      expect(p.hasConflict, isTrue);
      expect(p.conflictNote, 'leaves are blue vs green');
    });
  });

  group('TopicNode graph geometry', () {
    test('node diameter scales 40..72 with quizUseCount', () {
      const a = TopicNode(slug: 'a', title: 'A', mastery: 0, attempts: 0);
      expect(a.nodeDiameter, 40.0);
      const b = TopicNode(
          slug: 'b', title: 'B', mastery: 0, attempts: 0, quizUseCount: 4);
      expect(b.nodeDiameter, 40.0 + 4 * 4.0);
      const c = TopicNode(
          slug: 'c', title: 'C', mastery: 0, attempts: 0, quizUseCount: 100);
      // Capped at 8 uses → 40 + 32 = 72.
      expect(c.nodeDiameter, 72.0);
    });

    test('border weight is 1..4 from certaintyScore', () {
      const lo = TopicNode(slug: 'a', title: 'A', mastery: 0, attempts: 0);
      expect(lo.borderWeight, 1.0);
      const hi = TopicNode(
          slug: 'b', title: 'B', mastery: 0, attempts: 0, certaintyScore: 1.0);
      expect(hi.borderWeight, 4.0);
    });
  });

  group('certaintyColor mapping', () {
    test('verified → green, inferred → purple, uncertain → coral', () {
      // Compare by value; exact AppColors are asserted indirectly via distinct
      // results so a future palette tweak still keeps the three distinct.
      final verified = certaintyColor('VERIFIED');
      final inferred = certaintyColor('INFERRED');
      final uncertain = certaintyColor('UNCERTAIN');
      expect(verified, isNot(inferred));
      expect(inferred, isNot(uncertain));
      // Unknown values fall back to the inferred (purple) colour.
      expect(certaintyColor('whatever'), inferred);
    });
  });

  group('BrainMapState.isNew', () {
    test('matches on slug or title', () {
      const state = BrainMapState(
        isLoading: false,
        newSlugs: {'cells'},
        newTitles: {'Photosynthesis'},
      );
      expect(
          state.isNew(const TopicNode(
              slug: 'cells', title: 'X', mastery: 0, attempts: 0)),
          isTrue);
      expect(
          state.isNew(const TopicNode(
              slug: 'y', title: 'Photosynthesis', mastery: 0, attempts: 0)),
          isTrue);
      expect(
          state.isNew(
              const TopicNode(slug: 'z', title: 'Z', mastery: 0, attempts: 0)),
          isFalse);
    });
  });
}
