import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/progress/presentation/daily_goal_provider.dart';
import 'package:pally/features/progress/presentation/daily_goal_ring.dart';
import 'package:pally/shared/models/daily_goal.dart';

/// FIX A: the goal-picker ChoiceChips had no explicit selectedColor/labelStyle, so the
/// selected state inherited a theme combo that rendered the label near-invisible
/// (purple-on-purple). This pins that a SELECTED chip's label colour differs from its
/// fill — fails on the old widget (both null → equal).
class _FakeGoalVm extends DailyGoalVm {
  @override
  Future<DailyGoal> build() async =>
      const DailyGoal(goalType: 'QUIZ', goalTarget: 2, goalProgress: 0);
}

void main() {
  testWidgets('selected goal chip label colour differs from its fill (readable)',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [dailyGoalVmProvider.overrideWith(_FakeGoalVm.new)],
        child: const MaterialApp(home: Scaffold(body: DailyGoalRing())),
      ),
    );
    await tester.pumpAndSettle();

    // Open the goal sheet, where the chips live.
    await tester.tap(find.text('Set my goal'));
    await tester.pumpAndSettle();

    final chips = tester
        .widgetList<ChoiceChip>(find.byType(ChoiceChip))
        .where((c) => c.selected)
        .toList();
    expect(chips, isNotEmpty, reason: 'goalTarget 2 must select a chip');
    final selected = chips.first;

    expect(selected.selectedColor, isNotNull,
        reason: 'selected fill must be explicit, not theme-inherited');
    expect(selected.labelStyle?.color, isNotNull,
        reason: 'selected label colour must be explicit');
    expect(selected.labelStyle!.color, isNot(selected.selectedColor),
        reason: 'label must be readable ON the selected fill, not the same colour');
  });
}
