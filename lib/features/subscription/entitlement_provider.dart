import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/utils/logger.dart';
import 'package:pally/shared/models/entitlement.dart';

part 'entitlement_provider.g.dart';

/// Premium gate state. Refreshed on app resume + after returning from
/// Stripe checkout. Defensive unwrap mirrors the working view models.
@riverpod
class EntitlementVm extends _$EntitlementVm {
  @override
  Future<Entitlement> build() async => _fetch();

  /// Fetches entitlement, returning null on a transient network failure so
  /// callers can choose to keep the last-known value instead of downgrading.
  Future<Entitlement?> _fetchOrNull() async {
    try {
      final dio = ref.read(dioProvider);
      final res = await dio.get<dynamic>('/api/v1/subscription/entitlement');
      final data = res.data;
      final body = (data is Map && data['data'] is Map)
          ? Map<String, dynamic>.from(data['data'] as Map)
          : Map<String, dynamic>.from(data as Map);
      return Entitlement.fromJson(body);
    } on DioException catch (e) {
      appLog.w('[Entitlement] /entitlement failed: ${e.message}');
      return null;
    }
  }

  /// Always resolves to an Entitlement — a transient failure reads as free so a
  /// blip never shows the user a broken paywall.
  Future<Entitlement> _fetch() async =>
      await _fetchOrNull() ?? const Entitlement(isPremium: false, source: 'NONE');

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  /// Silent re-fetch for app-resume: updates [state] WITHOUT an AsyncLoading
  /// flash (so screens watching entitlement don't flicker), and IGNORES a
  /// transient failure (so a momentary network blip never downgrades a premium
  /// user to free). This is how a purchase completed on the web unlocks the app
  /// the next time it comes to the foreground.
  Future<void> reconcile() async {
    final ent = await _fetchOrNull();
    if (ent != null) state = AsyncData(ent);
  }

  /// Polls the backend entitlement until it flips to premium, or [timeout]
  /// elapses. Entitlement truth stays server-side: after a successful IAP the
  /// backend only flips once the RevenueCat webhook lands (async, seconds later),
  /// so a single re-fetch races ahead and shows the user "still free". This
  /// updates [state] each poll and returns whether premium was reached. Bounded —
  /// no infinite loop, no busy-wait.
  Future<bool> pollUntilPremium({
    Duration timeout = const Duration(seconds: 20),
    Duration interval = const Duration(seconds: 2),
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (true) {
      final ent = await _fetch();
      state = AsyncData(ent);
      if (ent.isPremium) return true;
      if (!DateTime.now().isBefore(deadline)) return false;
      await Future<void>.delayed(interval);
    }
  }
}
