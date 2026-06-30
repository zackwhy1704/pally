import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pally/features/invite/presentation/milestone_invite_nudge.dart';

void main() {
  group('MilestoneInviteNudge.milestoneFor', () {
    test('no milestone below the first threshold', () {
      expect(MilestoneInviteNudge.milestoneFor(0), 0);
      expect(MilestoneInviteNudge.milestoneFor(2), 0);
    });

    test('returns the highest reached threshold', () {
      expect(MilestoneInviteNudge.milestoneFor(3), 3);
      expect(MilestoneInviteNudge.milestoneFor(6), 3);
      expect(MilestoneInviteNudge.milestoneFor(7), 7);
      expect(MilestoneInviteNudge.milestoneFor(13), 7);
      expect(MilestoneInviteNudge.milestoneFor(14), 14);
      expect(MilestoneInviteNudge.milestoneFor(30), 30);
      expect(MilestoneInviteNudge.milestoneFor(999), 100);
    });
  });

  group('MilestoneInviteNudge persistence', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    Future<void> pump(WidgetTester tester, {String? userId}) async {
      // Unmount anything first so a re-pump runs initState again (a fresh
      // "visit"), instead of Flutter reusing the existing State in place.
      await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: MilestoneInviteNudge(streakDays: 7, userId: userId),
        ),
      ));
      await tester.pump();
    }

    testWidgets('persists "seen" the moment it is shown (not only on dismiss)',
        (tester) async {
      await pump(tester, userId: 'u1');
      expect(find.text('7-day streak — nice!'), findsOneWidget);

      // Without ever tapping Invite/✕, the seen flag is already written, so a
      // fresh mount (next visit) renders nothing.
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('invite_nudge_streak_u1_7'), isTrue);

      await pump(tester, userId: 'u1');
      expect(find.text('7-day streak — nice!'), findsNothing);
    });

    testWidgets('seen flag is per-user: another account still sees the nudge',
        (tester) async {
      SharedPreferences.setMockInitialValues({
        'invite_nudge_streak_u1_7': true,
      });
      await pump(tester, userId: 'u2');
      expect(find.text('7-day streak — nice!'), findsOneWidget);
    });
  });
}
