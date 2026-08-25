import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb, visibleForTesting;
import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:pally/core/utils/logger.dart';

/// Product identifiers, kept in code so enabling a tier is a store-side change.
///
/// PLAY STORE IS LIVE. The App Store identifiers below are deliberately
/// code-ready but NOT configured in App Store Connect: the 2.1 review response
/// is held, and IAP configuration must match what the reviewer eventually sees.
/// Creating them early would put products in front of a reviewer that the review
/// notes do not describe — the second-rejection risk.
class IapProducts {
  IapProducts._();

  /// Play Store — live and purchasable.
  static const String proMonthlyPlay = 'apalchi_pro_monthly';
  static const String proAnnualPlay = 'apalchi_pro_annual';

  /// App Store — identifiers reserved, NOT yet created in App Store Connect.
  static const String proMonthlyAppStore = 'apalchi_pro_monthly';
  static const String proAnnualAppStore = 'apalchi_pro_annual';

  /// The RevenueCat *entitlement* the backend grants on. One entitlement, many
  /// products: adding an annual SKU or a new tier is a dashboard change, not an
  /// app update.
  static const String proEntitlement = 'pro';
}

/// Thin wrapper over the RevenueCat SDK.
///
/// **Entitlement is NEVER read from this class.** The SDK tells us what the
/// STORE thinks; the backend tells us what we are willing to honour, learned
/// server-side from RevenueCat's webhook. The client never reports its
/// entitlement to the server — the same server-authoritative principle as quiz
/// grading (V97). This class exists to *start a purchase* and to identify the
/// user to RevenueCat, nothing more.
class RevenueCatService {
  RevenueCatService._();

  static bool _configured = false;

  @visibleForTesting
  static void debugResetForTest() => _configured = false;

  @visibleForTesting
  static bool get debugIsConfigured => _configured;

  /// Seam so tests can capture exactly what is handed to the SDK without a
  /// live RevenueCat connection.
  @visibleForTesting
  static Future<void> Function(PurchasesConfiguration)? debugConfigureOverride;

  /// Identifies the user to RevenueCat using the OPAQUE userId ONLY.
  ///
  /// No email, no display name, no avatar name. RevenueCat is a third-party
  /// data recipient and the app has a minors population, so it gets the same
  /// treatment as PostHog: an id that means nothing outside our database.
  ///
  /// Deliberately does NOT call `setEmail`, `setDisplayName`, or any other
  /// `setAttributes` call. A test asserts on the captured configuration rather
  /// than trusting this comment.
  static Future<void> configure({
    required String apiKey,
    required String opaqueUserId,
  }) async {
    if (_configured) return;
    if (kIsWeb) return;
    try {
      final config = PurchasesConfiguration(apiKey)
        // appUserID is the ONLY identifying value sent. Passing null here would
        // let RevenueCat mint its own anonymous id, which would then fail to
        // match the app_user_id our webhook keys entitlement on.
        ..appUserID = opaqueUserId;

      final configure = debugConfigureOverride ?? Purchases.configure;
      await configure(config);
      _configured = true;
      appLog.i('[RevenueCat] configured for opaque user id');
    } catch (e, st) {
      // Never fatal: a student must be able to open the app and study when the
      // billing SDK is unavailable. Entitlement still comes from the backend.
      appLog.w('[RevenueCat] configure failed (non-fatal)', error: e, stackTrace: st);
    }
  }

  /// Whether IAP is offered on this platform right now.
  ///
  /// Android only at launch. iOS returns false because the App Store products
  /// are not configured yet — showing a purchase button that cannot complete is
  /// worse than showing none.
  static bool get isPurchaseAvailable {
    if (kIsWeb) return false;
    return Platform.isAndroid;
  }

  /// Fetches the current offering. Returns null when unavailable — callers show
  /// no paywall rather than an empty one.
  ///
  /// Uses OFFERINGS rather than hardcoded product ids on purpose: it is what
  /// lets Family/Max be switched on server-side later with no app update.
  static Future<Offering?> currentOffering() async {
    if (!_configured) return null;
    try {
      final offerings = await Purchases.getOfferings();
      return offerings.current;
    } catch (e) {
      appLog.w('[RevenueCat] getOfferings failed: $e');
      return null;
    }
  }
}
