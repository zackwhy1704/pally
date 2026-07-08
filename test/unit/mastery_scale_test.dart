import 'package:flutter_test/flutter_test.dart';
import 'package:pally/shared/models/learning_module.dart';

/// The 2600% regression pin: masteryPct is 0–100, so the display must NOT ×100.
/// Before the fix, module_list_screen did `(masteryPct * 100).round()` → 26 → 2600%
/// and the bar clamped 26 to 1.0 (always full). These pin the sanctioned conversions.
void main() {
  test('masteryPct 26 → "26%" label + ~quarter-full bar (NOT 2600%)', () {
    const m = LearningModule(id: '1', title: 't', masteryPct: 26);
    expect(m.masteryDisplayPct, 26); // the label — was 2600
    expect(m.masteryFraction, closeTo(0.26, 0.001)); // the bar — was clamped to 1.0
  });

  test('legacy/miswritten >100 clamps to 100% and a full bar', () {
    const m = LearningModule(id: '1', title: 't', masteryPct: 2600);
    expect(m.masteryDisplayPct, 100);
    expect(m.masteryFraction, 1.0);
  });

  test('zero renders 0% / empty bar', () {
    const m = LearningModule(id: '1', title: 't', masteryPct: 0);
    expect(m.masteryDisplayPct, 0);
    expect(m.masteryFraction, 0.0);
  });
}
