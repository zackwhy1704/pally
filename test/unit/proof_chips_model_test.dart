import 'package:flutter_test/flutter_test.dart';
import 'package:pally/shared/models/learning_module.dart';
import 'package:pally/shared/models/quiz_question.dart';

/// Pins the serve→model contract for the adaptive-provenance fields: the client
/// parses exactly the keys the backend serves. Absent keys → null/empty (silent degrade).
void main() {
  test('ModuleContentItem.fromJson parses provenance + PROVE targeting fields', () {
    final it = ModuleContentItem.fromJson({
      'id': 'pv1',
      'type': 'PROVE_QUESTION',
      'contentJson': {'question': 'Q'},
      'sourcePageTitle': 'Sales Game',
      'sourcePageSlug': 'sales-game',
      'targetConcept': 'Closing',
      'priorScore': 0.0,
    });
    expect(it.sourcePageTitle, 'Sales Game');
    expect(it.sourcePageSlug, 'sales-game');
    expect(it.targetConcept, 'Closing');
    expect(it.priorScore, 0.0);
  });

  test('ModuleContentItem.fromJson: absent provenance keys → null (old content)', () {
    final it = ModuleContentItem.fromJson({
      'id': 'x',
      'type': 'MICRO_CARD',
      'contentJson': {'title': 'T'},
    });
    expect(it.sourcePageTitle, isNull);
    expect(it.targetConcept, isNull);
    expect(it.priorScore, isNull);
  });

  test('QuizQuestion.fromJson parses pageTitle + selectionReason', () {
    final q = QuizQuestion.fromJson({
      'id': '1',
      'question': 'Q',
      'options': ['a', 'b'],
      'pageTitle': 'Sales Game',
      'selectionReason': 'WEAK_TOPIC:Closing',
    });
    expect(q.pageTitle, 'Sales Game');
    expect(q.selectionReason, 'WEAK_TOPIC:Closing');
  });

  test('QuizQuestion.fromJson: absent keys → empty/null (old content)', () {
    final q = QuizQuestion.fromJson({'id': '1', 'question': 'Q', 'options': <String>[]});
    expect(q.pageTitle, '');
    expect(q.selectionReason, isNull);
  });
}
