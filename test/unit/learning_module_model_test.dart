import 'package:flutter_test/flutter_test.dart';
import 'package:pally/shared/models/learning_module.dart';

void main() {
  group('LearningModule', () {
    test('fromJson parses all fields correctly', () {
      final json = {
        'id': 'mod-1',
        'title': 'Fractions',
        'wikiSlug': 'fractions',
        'stage': 'TEST',
        'masteryPct': 0.65,
        'itemCounts': {'learn': 4, 'test': 3, 'prove': 0},
      };
      final module = LearningModule.fromJson(json);

      expect(module.id, 'mod-1');
      expect(module.title, 'Fractions');
      expect(module.wikiSlug, 'fractions');
      expect(module.stage, 'TEST');
      expect(module.masteryPct, 0.65);
      expect(module.itemCounts['learn'], 4);
      expect(module.itemCounts['test'], 3);
    });

    test('fromJson uses defaults for missing optional fields', () {
      final json = {'id': 'mod-2', 'title': 'Decimals'};
      final module = LearningModule.fromJson(json);

      expect(module.wikiSlug, '');
      expect(module.stage, 'LEARN');
      expect(module.masteryPct, 0);
      expect(module.itemCounts, isEmpty);
    });

    test('toJson round-trips correctly', () {
      const module = LearningModule(
        id: 'mod-3',
        title: 'Algebra',
        stage: 'PROVE',
        masteryPct: 0.8,
      );
      final json = module.toJson();
      final restored = LearningModule.fromJson(json);

      expect(restored.id, module.id);
      expect(restored.title, module.title);
      expect(restored.stage, module.stage);
      expect(restored.masteryPct, module.masteryPct);
    });
  });

  group('ModuleContentItem', () {
    test('fromJson parses content and answer fields', () {
      final json = {
        'id': 'item-1',
        'stage': 'LEARN',
        'type': 'MICRO_CARD',
        'contentJson': {'title': 'Intro', 'body': 'Hello'},
        'answerJson': {'correct': true},
        'sortOrder': 2,
      };
      final item = ModuleContentItem.fromJson(json);

      expect(item.id, 'item-1');
      expect(item.stage, 'LEARN');
      expect(item.type, 'MICRO_CARD');
      expect(item.contentJson['title'], 'Intro');
      expect(item.answerJson?['correct'], true);
      expect(item.sortOrder, 2);
    });

    test('fromJson defaults sortOrder to 0 when missing', () {
      final json = {
        'id': 'item-2',
        'stage': 'TEST',
        'type': 'HOT_TAKE',
        'contentJson': {'statement': 'Water is wet'},
      };
      final item = ModuleContentItem.fromJson(json);

      expect(item.sortOrder, 0);
      expect(item.answerJson, isNull);
    });

    // Regression: the backend stores content_json/answer_json as serialized
    // JSON *strings*, and the /start endpoint emits them as strings. The parser
    // must decode a string into a Map instead of hard-casting (which threw and
    // emptied the lesson → "Something went wrong loading this lesson").
    test('fromJson decodes contentJson/answerJson when sent as JSON strings', () {
      final json = {
        'id': 'item-3',
        'stage': 'LEARN',
        'type': 'MICRO_CARD',
        'contentJson': '{"title":"Intro","body":"Hello"}',
        'answerJson': '{"correct":true}',
        'sortOrder': 1,
      };
      final item = ModuleContentItem.fromJson(json);

      expect(item.contentJson['title'], 'Intro');
      expect(item.contentJson['body'], 'Hello');
      expect(item.answerJson?['correct'], true);
    });

    // Regression: the /start path historically omitted `stage`. A missing or
    // null stage must default rather than throw, since rendering keys off the
    // response-level stage, not the per-item one.
    test('fromJson defaults stage to LEARN when missing', () {
      final json = {
        'id': 'item-4',
        'type': 'MICRO_CARD',
        'contentJson': {'title': 'No stage here'},
      };
      final item = ModuleContentItem.fromJson(json);

      expect(item.stage, 'LEARN');
      expect(item.contentJson['title'], 'No stage here');
    });

    test('fromJson degrades a malformed contentJson string to empty map '
        'instead of throwing', () {
      final json = {
        'id': 'item-5',
        'type': 'MICRO_CARD',
        'contentJson': 'not-json-at-all',
      };
      final item = ModuleContentItem.fromJson(json);

      expect(item.contentJson, isEmpty);
    });
  });

  group('ModuleResults', () {
    test('fromJson parses concepts and xpEarned', () {
      final json = {
        'concepts': [
          {
            'concept': 'Adding fractions',
            'mastery': 0.9,
            'feedback': 'Great job!',
            'passed': true,
          },
          {
            'concept': 'Mixed numbers',
            'mastery': 0.4,
            'feedback': 'Needs review',
            'passed': false,
          },
        ],
        'xpEarned': 30,
      };
      final results = ModuleResults.fromJson(json);

      expect(results.concepts, hasLength(2));
      expect(results.concepts[0].concept, 'Adding fractions');
      expect(results.concepts[0].passed, isTrue);
      expect(results.concepts[1].mastery, 0.4);
      expect(results.xpEarned, 30);
    });

    test('fromJson defaults to empty concepts and 0 xp', () {
      final results = ModuleResults.fromJson({});
      expect(results.concepts, isEmpty);
      expect(results.xpEarned, 0);
    });
  });

  group('ConceptMastery', () {
    test('fromJson with all fields', () {
      final json = {
        'concept': 'Photosynthesis',
        'mastery': 0.75,
        'feedback': 'Good understanding',
        'passed': true,
      };
      final concept = ConceptMastery.fromJson(json);

      expect(concept.concept, 'Photosynthesis');
      expect(concept.mastery, 0.75);
      expect(concept.feedback, 'Good understanding');
      expect(concept.passed, isTrue);
    });

    test('fromJson defaults all fields gracefully', () {
      final concept = ConceptMastery.fromJson({});
      expect(concept.concept, '');
      expect(concept.mastery, 0);
      expect(concept.feedback, '');
      expect(concept.passed, isFalse);
    });
  });
}
