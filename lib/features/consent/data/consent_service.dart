import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/utils/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'consent_service.g.dart';

/// Thin wrapper over the backend consent endpoints used by the AI-disclosure
/// gate:
///   GET  /api/v1/consent/status            -> reports consent flags
///   POST /api/v1/consent/ai-data-transfer  -> records AI data-transfer consent
@riverpod
ConsentService consentService(Ref ref) =>
    ConsentService(ref.read(dioProvider));

class ConsentService {
  const ConsentService(this._dio);
  final Dio _dio;

  /// Returns true when the user has already granted consent for their data to
  /// be processed by overseas AI providers.
  ///
  /// The backend may name this field a few different ways. We parse
  /// defensively across the known candidates and unwrap the ApiResponse<T>
  /// envelope (the Dio interceptor usually does this, but we guard for the
  /// raw shape too so this stays safe to call directly in tests).
  Future<bool> isAiConsentGranted() async {
    final res = await _dio.get<dynamic>('/api/v1/consent/status');
    final granted = parseAiConsentGranted(res.data);
    appLog.d('[Consent] AI consent status -> granted=$granted');
    return granted;
  }

  /// Records the user's consent to overseas AI data transfer.
  Future<void> grantAiConsent() async {
    appLog.i('[Consent] Granting AI data-transfer consent');
    await _dio.post<void>('/api/v1/consent/ai-data-transfer');
  }

  /// Defensive parse of the consent-status payload. Handles:
  ///   - the unwrapped object `{...}`
  ///   - the still-wrapped envelope `{"data": {...}}`
  ///   - several plausible field names the backend might use
  ///
  /// Public + static so it can be unit-tested without a live Dio.
  static bool parseAiConsentGranted(dynamic body) {
    Map<String, dynamic>? map;
    if (body is Map<String, dynamic>) {
      // Unwrap an ApiResponse envelope if it is still present.
      final inner = body['data'];
      map = inner is Map<String, dynamic> ? inner : body;
    }
    if (map == null) return false;

    const candidateKeys = [
      'aiDataTransfer',
      'aiDataTransferConsent',
      'aiConsent',
      'aiConsentGranted',
      'aiDataTransferGranted',
    ];
    for (final key in candidateKeys) {
      final parsed = _asBool(map[key]);
      if (parsed != null) return parsed;
    }
    return false;
  }

  static bool? _asBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) {
      final v = value.toLowerCase();
      if (v == 'true' || v == 'granted' || v == 'yes') return true;
      if (v == 'false' || v == 'pending' || v == 'no' || v == 'none') {
        return false;
      }
    }
    return null;
  }
}
