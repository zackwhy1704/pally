import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/features/subscription/entitlement_provider.dart';
import 'package:pally/features/subscription/presentation/subscription_plans_screen.dart';
import 'package:pally/features/subscription/trial_status_provider.dart';
import 'package:pally/shared/models/entitlement.dart';

// Tests run on the host (non-iOS), so the screen takes the default/Android
// billing-management path — the Stripe "Manage billing" affordance. (The iOS
// gating swaps this for an Apple-Settings hint; that branch is host-dependent
// and exercised manually per the Phase 3 sandbox checklist.)
final _router = GoRouter(
  routes: [GoRoute(path: '/', builder: (_, __) => const SubscriptionPlansScreen())],
);

Widget _wrap(List<Override> overrides) => ProviderScope(
      overrides: overrides,
      child: MaterialApp.router(routerConfig: _router),
    );

class _FakeEntitlementVm extends EntitlementVm {
  _FakeEntitlementVm(this._value);
  final Entitlement _value;
  @override
  Future<Entitlement> build() async => _value;
}

const _paidStatus = TrialStatus(
  isPremium: true,
  source: 'IAP',
  trialActive: false,
  trialStatus: 'NONE',
  trialDaysLeft: 0,
  trialHoursLeft: 0,
  subscriptionTier: 'MAX',
  mochiCap: -1,
  chatLimit: 100,
  chatUsed: 5,
  chatRemaining: 95,
);

const _paidEntitlement = Entitlement(isPremium: true, source: 'IAP', plan: 'MAX');

void main() {
  testWidgets(
      'premium (non-trial, non-centre) user sees the Stripe manage-billing affordance on the default platform',
      (tester) async {
    await tester.pumpWidget(_wrap([
      entitlementVmProvider.overrideWith(() => _FakeEntitlementVm(_paidEntitlement)),
      trialStatusProvider.overrideWith((_) async => _paidStatus),
    ]));
    await tester.pumpAndSettle();

    expect(find.textContaining('Manage billing'), findsOneWidget);
  });
}
