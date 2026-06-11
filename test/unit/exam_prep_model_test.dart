import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pally/shared/models/exam_prep.dart';

void main() {
  group('ExamPrep', () {
    test('fromJson parses all fields correctly', () {
      final json = {
        'testDate': '2026-07-15',
        'daysRemaining': 18,
        'concepts': [
          {
            'concept': 'Fractions',
            'mastery': 0.82,
            'moduleId': 'mod-1',
            'moduleTitle': 'Fractions Basics',
          },
          {
            'concept': 'Decimals',
            'mastery': 0.61,
            'moduleId': 'mod-2',
            'moduleTitle': 'Decimal Operations',
          },
        ],
        'recommendedOrder': ['mod-2', 'mod-1'],
        'dailyTarget': 3,
      };
      final examPrep = ExamPrep.fromJson(json);

      expect(examPrep.testDate, '2026-07-15');
      expect(examPrep.daysRemaining, 18);
      expect(examPrep.concepts, hasLength(2));
      expect(examPrep.concepts[0].concept, 'Fractions');
      expect(examPrep.concepts[0].mastery, 0.82);
      expect(examPrep.concepts[0].moduleId, 'mod-1');
      expect(examPrep.concepts[0].moduleTitle, 'Fractions Basics');
      expect(examPrep.concepts[1].mastery, 0.61);
      expect(examPrep.recommendedOrder, ['mod-2', 'mod-1']);
      expect(examPrep.dailyTarget, 3);
    });

    test('fromJson uses defaults for missing optional fields', () {
      final examPrep = ExamPrep.fromJson({});

      expect(examPrep.testDate, isNull);
      expect(examPrep.daysRemaining, isNull);
      expect(examPrep.concepts, isEmpty);
      expect(examPrep.recommendedOrder, isEmpty);
      expect(examPrep.dailyTarget, 2);
    });

    test('toJson round-trips correctly', () {
      const examPrep = ExamPrep(
        testDate: '2026-08-01',
        daysRemaining: 30,
        concepts: [
          ExamConceptMastery(
            concept: 'Geometry',
            mastery: 0.31,
            moduleId: 'mod-3',
            moduleTitle: 'Shapes and Angles',
          ),
        ],
        recommendedOrder: ['mod-3'],
        dailyTarget: 4,
      );
      // Encode to JSON string and decode back to simulate network round-trip
      final jsonString = jsonEncode(examPrep.toJson());
      final restored = ExamPrep.fromJson(
          jsonDecode(jsonString) as Map<String, dynamic>);

      expect(restored.testDate, examPrep.testDate);
      expect(restored.daysRemaining, examPrep.daysRemaining);
      expect(restored.concepts, hasLength(1));
      expect(restored.concepts[0].concept, 'Geometry');
      expect(restored.dailyTarget, 4);
    });
  });

  group('ExamConceptMastery', () {
    test('fromJson parses all fields', () {
      final json = {
        'concept': 'Photosynthesis',
        'mastery': 0.75,
        'moduleId': 'mod-bio-1',
        'moduleTitle': 'Plant Biology',
      };
      final concept = ExamConceptMastery.fromJson(json);

      expect(concept.concept, 'Photosynthesis');
      expect(concept.mastery, 0.75);
      expect(concept.moduleId, 'mod-bio-1');
      expect(concept.moduleTitle, 'Plant Biology');
    });

    test('fromJson defaults all fields gracefully', () {
      final concept = ExamConceptMastery.fromJson({});
      expect(concept.concept, '');
      expect(concept.mastery, 0);
      expect(concept.moduleId, isNull);
      expect(concept.moduleTitle, isNull);
    });

    test('toJson round-trips correctly', () {
      const concept = ExamConceptMastery(
        concept: 'Algebra',
        mastery: 0.5,
        moduleId: 'mod-math-2',
        moduleTitle: 'Equations',
      );
      final json = concept.toJson();
      final restored = ExamConceptMastery.fromJson(json);

      expect(restored.concept, concept.concept);
      expect(restored.mastery, concept.mastery);
      expect(restored.moduleId, concept.moduleId);
      expect(restored.moduleTitle, concept.moduleTitle);
    });
  });
}
