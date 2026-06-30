import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/features/subscription/entitlement_provider.dart';
import 'package:pally/features/subscription/presentation/subscription_plans_screen.dart';
import 'package:pally/features/subscription/trial_status_provider.dart';
import 'package:pally/shared/models/entitlement.dart';

// Minimal GoRouter so GoRouter.of(context) resolves without crashing.
final _router = GoRouter(
  routes: [
    GoRoute(
      path: "/",
      builder: (_, __) => const SubscriptionPlansScreen(),
    ),
  ],
);

Widget _wrap(List<Override> overrides) => ProviderScope(
      overrides: overrides,
      child: MaterialApp.router(routerConfig: _router),
    );

// Stub notifier: returns a fixed Entitlement without hitting the network.
class _FakeEntitlementVm extends EntitlementVm {
  _FakeEntitlementVm(this._value);
  final Entitlement _value;
  @override
  Future<Entitlement> build() async => _value;
}

const _centreStatus = TrialStatus(
  isPremium: true,
  source: "CENTRE",
  trialActive: false,
  trialStatus: "NONE",
  trialDaysLeft: 0,
  trialHoursLeft: 0,
  subscriptionTier: "PRO",
  mochiCap: -1,
  chatLimit: 100,
  chatUsed: 5,
  chatRemaining: 95,
);

const _centreEntitlement = Entitlement(
  isPremium: true,
  source: "CENTRE",
  plan: "PRO",
);

const _freeStatus = TrialStatus(
  isPremium: false,
  source: "NONE",
  trialActive: false,
  trialStatus: "NONE",
  trialDaysLeft: 0,
  trialHoursLeft: 0,
  subscriptionTier: "FREE",
  mochiCap: 1,
  chatLimit: 20,
  chatUsed: 0,
  chatRemaining: 20,
);

const _freeEntitlement = Entitlement(isPremium: false, source: "NONE");

void main() {
  group("SubscriptionPlansScreen — CENTRE source guard", () {
    testWidgets(
        "shows centre premium badge and hides subscribe CTA for CENTRE-sourced student",
        (tester) async {
      await tester.pumpWidget(_wrap([
        entitlementVmProvider
            .overrideWith(() => _FakeEntitlementVm(_centreEntitlement)),
        trialStatusProvider.overrideWith((_) async => _centreStatus),
      ]));
      await tester.pumpAndSettle();

      // Centre badge is visible
      expect(find.textContaining("Premium via your centre"), findsWidgets);

      // Subscribe / trial CTAs are absent
      expect(find.text("Subscribe now"), findsNothing);
      expect(find.text("Start 7-day free trial"), findsNothing);

      // Manage billing link is absent (centre students have no Stripe sub)
      expect(find.textContaining("Manage billing"), findsNothing);
    });

    testWidgets("shows centre copy in header for CENTRE-sourced student",
        (tester) async {
      await tester.pumpWidget(_wrap([
        entitlementVmProvider
            .overrideWith(() => _FakeEntitlementVm(_centreEntitlement)),
        trialStatusProvider.overrideWith((_) async => _centreStatus),
      ]));
      await tester.pumpAndSettle();

      expect(
        find.textContaining("Your Premium comes from your centre"),
        findsWidgets,
      );
    });

    testWidgets(
        "shows web upgrade CTA for non-premium student (no CENTRE source)",
        (tester) async {
      await tester.pumpWidget(_wrap([
        entitlementVmProvider
            .overrideWith(() => _FakeEntitlementVm(_freeEntitlement)),
        trialStatusProvider.overrideWith((_) async => _freeStatus),
      ]));
      await tester.pumpAndSettle();

      // Free user sees the web-only upgrade CTA (purchasing happens on the web).
      expect(find.text("Continue on web"), findsOneWidget);
      // No centre badge
      expect(find.textContaining("Premium via your centre"), findsNothing);
    });
  });
}
