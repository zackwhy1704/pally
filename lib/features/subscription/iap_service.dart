import 'dart:io' show Platform;

import 'package:flutter/services.dart' show PlatformException;
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:pally/core/utils/logger.dart';

// RevenueCat public SDK keys, injected at build time:
//   flutter build … --dart-define=REVENUECAT_IOS_KEY=appl_xxx --dart-define=REVENUECAT_ANDROID_KEY=goog_xxx
const _iosKey = String.fromEnvironment('REVENUECAT_IOS_KEY', defaultValue: '');
const _androidKey = String.fromEnvironment('REVENUECAT_ANDROID_KEY', defaultValue: '');

/// Thin wrapper over RevenueCat (Apple StoreKit + Google Play Billing). Entitlement
/// truth stays server-side: a successful purchase fires a RevenueCat webhook keyed on
/// our userId (set via [configure]) that flips the backend `entitlement` record.
///
/// Until the RevenueCat keys are provided, [isConfigured] is false and every call is
/// a graceful no-op, so the app keeps working before IAP is provisioned.
class IapService {
  IapService._();
  static final IapService instance = IapService._();

  bool _configured = false;
  bool get isConfigured => _configured;

  String get _apiKey => Platform.isIOS ? _iosKey : _androidKey;

  /// Configure RevenueCat and bind purchases to [userId] so the backend webhook's
  /// `app_user_id` matches our user. Safe to call on every launch — configures once,
  /// then [Purchases.logIn]s on subsequent calls. No-op when no key is set.
  Future<void> configure(String userId) async {
    if (_apiKey.isEmpty || userId.isEmpty) return;
    try {
      if (!_configured) {
        await Purchases.configure(PurchasesConfiguration(_apiKey)..appUserID = userId);
        _configured = true;
        appLog.i('[IAP] RevenueCat configured');
      } else {
        await Purchases.logIn(userId);
      }
    } catch (e) {
      appLog.w('[IAP] configure failed: $e');
    }
  }

  /// Purchases the package matching [planId] from the current offering. Returns true
  /// only when the purchase grants an active entitlement. False on cancel/error.
  Future<bool> purchasePlan(String planId) async {
    if (!_configured) return false;
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      if (current == null || current.availablePackages.isEmpty) return false;

      final lower = planId.toLowerCase();
      final pkg = current.availablePackages.firstWhere(
        (p) =>
            p.identifier == planId ||
            p.storeProduct.identifier.toLowerCase().contains(lower),
        orElse: () => current.availablePackages.first,
      );

      final info = await Purchases.purchasePackage(pkg);
      return info.entitlements.active.isNotEmpty;
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      if (code == PurchasesErrorCode.purchaseCancelledError) {
        appLog.i('[IAP] purchase cancelled by user');
      } else {
        appLog.w('[IAP] purchase failed: ${e.message}');
      }
      return false;
    } catch (e) {
      appLog.w('[IAP] purchase error: $e');
      return false;
    }
  }

  /// Restores prior purchases (Apple requires a restore affordance). Returns true
  /// when any active entitlement is found.
  Future<bool> restore() async {
    if (!_configured) return false;
    try {
      final info = await Purchases.restorePurchases();
      return info.entitlements.active.isNotEmpty;
    } catch (e) {
      appLog.w('[IAP] restore failed: $e');
      return false;
    }
  }
}
