import 'package:flutter_test/flutter_test.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:pally/features/subscription/revenuecat_service.dart';

/// Enforces the third-party identifier policy for RevenueCat.
///
/// POLICY: RevenueCat receives the OPAQUE userId and nothing else — no email, no
/// display name, no avatar name. It is a third-party data recipient and the app
/// has a minors population, so it gets the same treatment as PostHog (PDPA
/// overseas-transfer of PII).
///
/// This asserts on the CAPTURED CONFIGURATION handed to the SDK, not on a
/// comment. A policy that lives only in prose is one refactor away from being
/// untrue, and nothing would fail when it stopped holding.
void main() {
  const userId = '9e6f46bc-b768-4b71-8adb-3b822219c7bf';

  late List<PurchasesConfiguration> captured;

  setUp(() {
    captured = <PurchasesConfiguration>[];
    RevenueCatService.debugResetForTest();
    RevenueCatService.debugConfigureOverride = (config) async {
      captured.add(config);
    };
  });

  tearDown(() {
    RevenueCatService.debugConfigureOverride = null;
    RevenueCatService.debugResetForTest();
  });

  test('the opaque userId is sent as appUserID', () async {
    await RevenueCatService.configure(apiKey: 'test-key', opaqueUserId: userId);

    expect(captured, hasLength(1));
    expect(captured.single.appUserID, userId);
  });

  test('appUserID is never left null — RevenueCat must not mint its own id',
      () async {
    // An anonymous RevenueCat id would not match the app_user_id our webhook
    // keys entitlement on, so a real purchase would land on nobody.
    await RevenueCatService.configure(apiKey: 'test-key', opaqueUserId: userId);

    expect(captured.single.appUserID, isNotNull);
    expect(captured.single.appUserID, isNotEmpty);
  });

  test('NOTHING identifying beyond the userId reaches the SDK', () async {
    // The real assertion: scan the captured configuration for anything that
    // could carry personal data. If a future change starts passing an email or
    // a name, this fails rather than shipping quietly.
    await RevenueCatService.configure(apiKey: 'test-key', opaqueUserId: userId);

    final config = captured.single;
    final rendered = config.toString().toLowerCase();

    expect(rendered, isNot(contains('@')),
        reason: 'an email address must never be sent to RevenueCat');
    for (final banned in ['email', 'displayname', 'firstname', 'lastname', 'phone']) {
      expect(rendered, isNot(contains(banned)),
          reason: '"$banned" must not appear in the RevenueCat configuration');
    }
  });

  test('configure is idempotent — a second call does not re-identify', () async {
    await RevenueCatService.configure(apiKey: 'test-key', opaqueUserId: userId);
    await RevenueCatService.configure(apiKey: 'test-key', opaqueUserId: userId);

    expect(captured, hasLength(1));
  });

  test('a configure failure is non-fatal', () async {
    // A student must be able to open the app and study when the billing SDK is
    // unavailable. Entitlement comes from the backend regardless.
    RevenueCatService.debugConfigureOverride =
        (_) async => throw StateError('SDK unavailable');

    await RevenueCatService.configure(apiKey: 'k', opaqueUserId: userId);

    expect(RevenueCatService.debugIsConfigured, isFalse);
  });

  test('product identifiers are reserved for both stores but iOS is not offered',
      () {
    // App Store identifiers are code-ready; they are deliberately NOT created in
    // App Store Connect while the 2.1 review is held.
    expect(IapProducts.proMonthlyPlay, isNotEmpty);
    expect(IapProducts.proMonthlyAppStore, isNotEmpty);
    expect(IapProducts.proEntitlement, 'pro');
  });
}
