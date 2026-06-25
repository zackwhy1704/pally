import 'package:flutter_test/flutter_test.dart';
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
}
