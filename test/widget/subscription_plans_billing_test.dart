import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/features/subscription/entitlement_provider.dart';
import 'package:pally/features/subscription/presentation/subscription_plans_screen.dart';
import 'package:pally/features/subscription/trial_status_provider.dart';
import 'package:pally/shared/models/entitlement.dart';

// Purchasing is web-only. Tests run on the host (Platform.isIOS == false), so
// the WebUpgradeCta renders its launch button — here the manage variant's
// "Manage on web". (On real iOS the launch button is hidden and only the
// copiable link shows; that dart:io branch is exercised manually.)
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
      'premium (non-trial, non-centre) user sees the web manage-subscription affordance on the default platform',
      (tester) async {
    await tester.pumpWidget(_wrap([
      entitlementVmProvider.overrideWith(() => _FakeEntitlementVm(_paidEntitlement)),
      trialStatusProvider.overrideWith((_) async => _paidStatus),
    ]));
    await tester.pumpAndSettle();

    expect(find.text('Manage on web'), findsOneWidget);
  });
}
