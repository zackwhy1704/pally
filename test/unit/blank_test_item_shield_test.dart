import 'package:flutter_test/flutter_test.dart';
import 'package:pally/shared/models/learning_module.dart';
import 'package:pally/features/modules/presentation/module_player_view_model.dart';

/// The blank-item client shield — the TEST-path sibling of the PROVE blank-reference
/// guard. A slipped-through SPOT_MISTAKE with an empty reveal must be SKIPPED so the
/// student never sees a "The error:" / "Correct solution:" label with nothing under it.
void main() {
  ModuleContentItem item(String type, Map<String, dynamic>? answer) =>
      ModuleContentItem(id: '1', type: type, contentJson: const {'problem': 'p'},
          answerJson: answer);

  test('blank SPOT_MISTAKE reveal (empty/whitespace fields) → skipped', () {
    expect(isBlankTestItem(item('SPOT_MISTAKE',
        {'errorDescription': '  ', 'correctSolution': ''})), isTrue);
    expect(isBlankTestItem(item('SPOT_MISTAKE', null)), isTrue);
  });

  test('populated SPOT_MISTAKE → kept', () {
    expect(isBlankTestItem(item('SPOT_MISTAKE',
        {'errorDescription': 'sign flipped', 'correctSolution': 'x = 5'})), isFalse);
  });

  test('blank HOT_TAKE / CHALLENGE explanation → skipped; populated → kept', () {
    expect(isBlankTestItem(item('HOT_TAKE', {'explanation': ''})), isTrue);
    expect(isBlankTestItem(item('CHALLENGE', {'explanation': '   '})), isTrue);
    expect(isBlankTestItem(item('HOT_TAKE', {'explanation': 'because…'})), isFalse);
  });

  test('non-TEST types (LEARN micro-cards) are never skipped', () {
    expect(isBlankTestItem(item('MICRO_CARD', null)), isFalse);
    expect(isBlankTestItem(item('PROVE', null)), isFalse);
  });
}
