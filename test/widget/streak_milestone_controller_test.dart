import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pally/features/progress/presentation/streak_milestone_controller.dart';

/// Pumps a host app and hands back a BuildContext usable for showing the
/// milestone overlay.
Future<BuildContext> _pumpHost(WidgetTester tester) async {
  late BuildContext ctx;
  await tester.pumpWidget(MaterialApp(
    home: Builder(builder: (c) {
      ctx = c;
      return const Scaffold(body: SizedBox.shrink());
    }),
  ));
  return ctx;
}

/// Dismisses any open overlay and drains the 4s auto-dismiss timer so the test
/// ends with no pending timers.
Future<void> _drain(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 5));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    StreakMilestoneController.resetInFlightForTest();
  });

  testWidgets('celebrates a newly-reached milestone exactly once', (tester) async {
    final ctx = await _pumpHost(tester);

    StreakMilestoneController.maybeCelebrate(ctx,
        milestonesReached: [3], userId: 'u1');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('3-DAY STREAK!'), findsOneWidget);
    await _drain(tester);
  });

  testWidgets('concurrent emissions for the same milestone fire only once',
      (tester) async {
    final ctx = await _pumpHost(tester);

    // Two rapid emissions (tab focus + refresh) before either awaited write
    // completes — the synchronous in-flight guard must let only one through.
    StreakMilestoneController.maybeCelebrate(ctx,
        milestonesReached: [7], userId: 'u1');
    StreakMilestoneController.maybeCelebrate(ctx,
        milestonesReached: [7], userId: 'u1');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('7-DAY STREAK!'), findsOneWidget);
    await _drain(tester);
  });

  testWidgets('a milestone already seen by THIS user is not re-celebrated',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'streak_milestones_seen_u1': ['3'],
    });
    final ctx = await _pumpHost(tester);

    StreakMilestoneController.maybeCelebrate(ctx,
        milestonesReached: [3], userId: 'u1');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('3-DAY STREAK!'), findsNothing);
  });

  testWidgets('seen set is per-user: a different account still celebrates',
      (tester) async {
    // u1 has already seen milestone 3; u2 is a fresh account on the same device.
    SharedPreferences.setMockInitialValues({
      'streak_milestones_seen_u1': ['3'],
    });
    final ctx = await _pumpHost(tester);

    StreakMilestoneController.maybeCelebrate(ctx,
        milestonesReached: [3], userId: 'u2');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('3-DAY STREAK!'), findsOneWidget);
    await _drain(tester);
  });
}
