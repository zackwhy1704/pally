import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/utils/logger.dart';

part 'subscription_service.g.dart';

/// Thin client for /api/v1/subscription/{checkout,portal}. Returns the URL
/// the backend's Stripe layer hands us; opening the URL is the caller's
/// job so the UI can push the return-route first to avoid a race where
/// the webhook lands before the screen is ready to poll.
@riverpod
SubscriptionService subscriptionService(Ref ref) =>
    SubscriptionService(ref.read(dioProvider));

class SubscriptionService {
  SubscriptionService(this._dio);
  final Dio _dio;

  Future<String> startCheckout(String plan) async {
    try {
      final res = await _dio.post<dynamic>(
        '/api/v1/subscription/checkout',
        data: {'plan': plan},
      );
      final body = _unwrap(res.data);
      final url = body['checkoutUrl'] as String?;
      if (url == null || url.isEmpty) {
        throw const SubscriptionError(
            'Checkout URL missing from server response');
      }
      return url;
    } on DioException catch (e) {
      appLog.e('[Subscription] checkout failed', error: e);
      throw SubscriptionError(_friendly(e));
    }
  }

  Future<String> openPortal() async {
    try {
      final res = await _dio.post<dynamic>('/api/v1/subscription/portal');
      final body = _unwrap(res.data);
      final url = body['url'] as String?;
      if (url == null || url.isEmpty) {
        throw const SubscriptionError(
            'Portal URL missing from server response');
      }
      return url;
    } on DioException catch (e) {
      appLog.e('[Subscription] portal failed', error: e);
      throw SubscriptionError(_friendly(e));
    }
  }

  /// Launches an external browser/Chrome custom tab. Returns false when the
  /// platform refuses (e.g. emulator without a browser) so the caller can
  /// fall back to copying the URL.
  Future<bool> launchExternal(String url) async {
    final uri = Uri.parse(url);
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Map<String, dynamic> _unwrap(dynamic data) =>
      (data is Map && data['data'] is Map)
          ? Map<String, dynamic>.from(data['data'] as Map)
          : Map<String, dynamic>.from(data as Map);

  String _friendly(DioException e) {
    final status = e.response?.statusCode;
    if (status == 503) return 'Payments are unavailable right now.';
    if (status == 409) return 'You need to subscribe first.';
    if (status == 502) return 'Could not reach the payment provider.';
    return 'Something went wrong. Please try again.';
  }
}

class SubscriptionError implements Exception {
  const SubscriptionError(this.message);
  final String message;
  @override
  String toString() => message;
}
