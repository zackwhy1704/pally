import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pally/app/api_client.dart';

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

/// Asks the backend to send the web billing link to the signed-in user by
/// email AND push notification, so they can finish checkout in their phone's
/// browser. The primary affordance on iOS, where we can't show a launch button.
@riverpod
UpgradeLinkSender upgradeLinkSender(Ref ref) =>
    UpgradeLinkSender(ref.read(dioProvider));

class UpgradeLinkSender {
  UpgradeLinkSender(this._dio);
  final Dio _dio;

  /// POSTs the request (no body → backend sends BOTH channels). Returns which
  /// channels were actually dispatched. Throws [DioException] on failure so the
  /// caller can surface a persistent inline error (incl. 429 rate-limit).
  Future<UpgradeLinkResult> send() async {
    final res = await _dio.post<dynamic>(
      '/api/v1/subscription/upgrade-link',
      // Email + push dispatch can be slow; never hang the button forever.
      options: Options(
        sendTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );
    final data = res.data;
    final body = (data is Map && data['data'] is Map)
        ? Map<String, dynamic>.from(data['data'] as Map)
        : Map<String, dynamic>.from(data as Map);
    final sent = (body['sent'] as Map?) ?? const {};
    return UpgradeLinkResult(
      emailSent: sent['email'] == true,
      pushSent: sent['push'] == true,
    );
  }
}

class UpgradeLinkResult {
  const UpgradeLinkResult({required this.emailSent, required this.pushSent});
  final bool emailSent;
  final bool pushSent;

  /// True when at least one channel was dispatched.
  bool get anySent => emailSent || pushSent;
}
