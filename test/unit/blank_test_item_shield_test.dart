import 'package:flutter_test/flutter_test.dart';
import 'package:pally/shared/models/learning_module.dart';
import 'package:pally/features/modules/presentation/module_player_view_model.dart';

/// The blank-item client shield — the TEST-path sibling of the PROVE blank-reference
/// guard. It judges the PROMPT the client renders at serve time (contentJson), NOT the
/// reveal (answerJson), because the serve contract omits answerJson for every TEST item.
/// An answerJson-based check saw null on all served items and skipped the whole stage →
/// "Mochi is refreshing this lesson" on every TEST. These tests pin the corrected contract.
void main() {
  ModuleContentItem item(String type, Map<String, dynamic> content,
          {Map<String, dynamic>? answer}) =>
      ModuleContentItem(
          id: '1', type: type, contentJson: content, answerJson: answer);

  test('REGRESSION: TEST item with NULL answerJson + real content → NOT blank', () {
    // The serve contract: answerJson is always null for TEST items. The old shield
    // read answerJson and skipped every one. These must all be KEPT.
    expect(isBlankTestItem(item('HOT_TAKE', {'statement': 'The sky is green'})),
        isFalse);
    expect(
        isBlankTestItem(item('SPOT_MISTAKE',
            {'problem': 'Solve 2x=4', 'wrongSolution': 'x=3'})),
        isFalse);
    expect(isBlankTestItem(item('CHALLENGE', {'question': 'Explain osmosis'})),
        isFalse);
  });

  test('blank prompt content per type → blank/skipped', () {
    expect(isBlankTestItem(item('HOT_TAKE', {'statement': '  '})), isTrue);
    expect(isBlankTestItem(item('HOT_TAKE', const {})), isTrue);
    expect(isBlankTestItem(item('CHALLENGE', {'question': ''})), isTrue);
    // SPOT_MISTAKE is blank only when BOTH prompt fields are empty (dead card).
    expect(
        isBlankTestItem(
            item('SPOT_MISTAKE', {'problem': '', 'wrongSolution': '   '})),
        isTrue);
    expect(isBlankTestItem(item('SPOT_MISTAKE', const {})), isTrue);
  });

  test('SPOT_MISTAKE with either prompt field present → kept (conservative)', () {
    expect(
        isBlankTestItem(item('SPOT_MISTAKE', {'problem': 'Solve it', 'wrongSolution': ''})),
        isFalse);
    expect(
        isBlankTestItem(item('SPOT_MISTAKE', {'problem': '', 'wrongSolution': 'x=3'})),
        isFalse);
  });

  test('answerJson is IGNORED — a populated reveal never rescues blank content', () {
    // Even with a full reveal, empty prompt content is still a dead card.
    expect(
        isBlankTestItem(item('HOT_TAKE', {'statement': ''},
            answer: {'explanation': 'because…', 'isTrue': true})),
        isTrue);
    // And an absent reveal never marks good content as blank.
    expect(isBlankTestItem(item('CHALLENGE', {'question': 'Why?'}, answer: null)),
        isFalse);
  });

  test('non-TEST types (LEARN micro-cards / PROVE) are never skipped', () {
    expect(isBlankTestItem(item('MICRO_CARD', const {})), isFalse);
    expect(isBlankTestItem(item('PROVE', const {})), isFalse);
  });
}
