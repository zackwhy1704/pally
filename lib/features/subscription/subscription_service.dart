import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:url_launcher/url_launcher.dart';

part 'subscription_service.g.dart';

/// Opens the public web checkout in an EXTERNAL browser.
///
/// Purchasing happens entirely on the Apalchi website — the app never
/// runs in-app billing (no Stripe-in-webview, no store IAP). This keeps us
/// onside with App Store anti-steering (iOS shows a copiable link instead of
/// a launch button) and Google Play (an external-browser link-out is treated
/// far more leniently than an embedded payment WebView). After the user pays
/// on the web, the backend webhook grants premium and [EntitlementVm] unlocks
/// the app by polling — see entitlement_provider.dart.
@riverpod
SubscriptionService subscriptionService(Ref ref) => const SubscriptionService();

class SubscriptionService {
  const SubscriptionService();

  /// Launches [url] in the system browser (NOT an in-app WebView — an embedded
  /// payment page reads as in-app-purchase circumvention). Returns false when
  /// the platform refuses (e.g. emulator with no browser) so the caller can
  /// fall back to letting the user copy the URL.
  Future<bool> launchExternal(String url) {
    return launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }
}
