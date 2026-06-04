import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/subscription/trial_status_provider.dart';

void main() {
  group('TrialStatus', () {
    test('defaults to FREE tier with 20-message cap', () {
      const s = TrialStatus.empty;
      expect(s.subscriptionTier, 'FREE');
      expect(s.chatLimit, 20);
      expect(s.chatRemaining, 20);
      expect(s.chatUsed, 0);
      expect(s.mochiCap, 1);
      expect(s.hasUnlimitedChat, isFalse);
      expect(s.isLowOnMessages, isFalse);
    });

    test('hasUnlimitedChat true when chatLimit is -1', () {
      const s = TrialStatus(
        isPremium: true,
        source: 'SELF',
        trialActive: false,
        trialStatus: 'NONE',
        trialDaysLeft: 0,
        trialHoursLeft: 0,
        subscriptionTier: 'MAX',
        mochiCap: -1,
        chatLimit: -1,
        chatUsed: 50,
        chatRemaining: -1,
      );
      expect(s.hasUnlimitedChat, isTrue);
      expect(s.isLowOnMessages, isFalse);
    });

    test('isLowOnMessages true when chatRemaining <= 5 and not unlimited', () {
      const s = TrialStatus(
        isPremium: false,
        source: 'NONE',
        trialActive: false,
        trialStatus: 'NONE',
        trialDaysLeft: 0,
        trialHoursLeft: 0,
        subscriptionTier: 'FREE',
        chatLimit: 20,
        chatUsed: 15,
        chatRemaining: 5,
        mochiCap: 1,
      );
      expect(s.isLowOnMessages, isTrue);
    });

    test('isLowOnMessages false when chatRemaining > 5', () {
      const s = TrialStatus(
        isPremium: false,
        source: 'NONE',
        trialActive: false,
        trialStatus: 'NONE',
        trialDaysLeft: 0,
        trialHoursLeft: 0,
        subscriptionTier: 'FREE',
        chatLimit: 20,
        chatUsed: 10,
        chatRemaining: 10,
        mochiCap: 1,
      );
      expect(s.isLowOnMessages, isFalse);
    });

    test('isLowOnMessages false for unlimited tier even if chatRemaining is -1', () {
      const s = TrialStatus(
        isPremium: true,
        source: 'SELF',
        trialActive: false,
        trialStatus: 'NONE',
        trialDaysLeft: 0,
        trialHoursLeft: 0,
        subscriptionTier: 'PRO',
        chatLimit: -1,
        chatUsed: 0,
        chatRemaining: -1,
        mochiCap: 5,
      );
      expect(s.hasUnlimitedChat, isTrue);
      expect(s.isLowOnMessages, isFalse);
    });

    test('mochiCap -1 means unlimited', () {
      const s = TrialStatus(
        isPremium: true,
        source: 'SELF',
        trialActive: false,
        trialStatus: 'NONE',
        trialDaysLeft: 0,
        trialHoursLeft: 0,
        subscriptionTier: 'FAMILY',
        chatLimit: -1,
        chatUsed: 0,
        chatRemaining: -1,
        mochiCap: -1,
      );
      expect(s.mochiCap, -1);
    });

    test('isOnTrial false for SELF source even when trialActive', () {
      const s = TrialStatus(
        isPremium: true,
        source: 'SELF',
        trialActive: true,
        trialStatus: 'CONVERTED',
        trialDaysLeft: 0,
        trialHoursLeft: 0,
      );
      expect(s.isOnTrial, isFalse);
    });

    test('isTrialExpired true for EXPIRED status', () {
      const s = TrialStatus(
        isPremium: false,
        source: 'TRIAL',
        trialActive: false,
        trialStatus: 'EXPIRED',
        trialDaysLeft: 0,
        trialHoursLeft: 0,
      );
      expect(s.isTrialExpired, isTrue);
    });
  });
}
