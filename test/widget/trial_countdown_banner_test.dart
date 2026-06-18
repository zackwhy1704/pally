import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/subscription/presentation/trial_countdown_banner.dart';
import 'package:pally/features/subscription/trial_status_provider.dart';

Widget _wrap(List<Override> overrides) => ProviderScope(
      overrides: overrides,
      child: const MaterialApp(
        home: Scaffold(body: TrialCountdownBanner()),
      ),
    );

const _trialStatus = TrialStatus(
  isPremium: true,
  source: 'TRIAL',
  trialActive: true,
  trialStatus: 'ACTIVE',
  trialDaysLeft: 3,
  trialHoursLeft: 72,
  subscriptionTier: 'MAX',
  mochiCap: -1,
  chatLimit: -1,
  chatUsed: 5,
  chatRemaining: -1,
);

const _freeStatus = TrialStatus(
  isPremium: false,
  source: 'NONE',
  trialActive: false,
  trialStatus: 'NONE',
  trialDaysLeft: 0,
  trialHoursLeft: 0,
  subscriptionTier: 'FREE',
  mochiCap: 1,
  chatLimit: 20,
  chatUsed: 0,
  chatRemaining: 20,
);

void main() {
  group('TrialCountdownBanner', () {
    testWidgets('shows countdown when user is on active trial', (tester) async {
      await tester.pumpWidget(_wrap([
        trialStatusProvider.overrideWith((_) async => _trialStatus),
      ]));
      await tester.pumpAndSettle();

      expect(find.textContaining('Premium'), findsWidgets);
      expect(find.textContaining('left'), findsWidgets);
    });

    testWidgets('renders nothing when user has no trial (source=NONE)',
        (tester) async {
      await tester.pumpWidget(_wrap([
        trialStatusProvider.overrideWith((_) async => _freeStatus),
      ]));
      await tester.pumpAndSettle();

      expect(find.textContaining('Premium'), findsNothing);
      expect(find.textContaining('left'), findsNothing);
    });

    testWidgets('shows urgent copy when less than 24 h remain',
        (tester) async {
      const urgent = TrialStatus(
        isPremium: true,
        source: 'TRIAL',
        trialActive: true,
        trialStatus: 'ACTIVE',
        trialDaysLeft: 0,
        trialHoursLeft: 5,
        subscriptionTier: 'MAX',
        mochiCap: -1,
        chatLimit: -1,
        chatUsed: 0,
        chatRemaining: -1,
      );
      await tester.pumpWidget(_wrap([
        trialStatusProvider.overrideWith((_) async => urgent),
      ]));
      await tester.pumpAndSettle();

      expect(find.textContaining('Last day'), findsWidgets);
    });
  });
}
