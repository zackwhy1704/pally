import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:shared_preferences/shared_preferences.dart';
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

  /// BOUNDED FAIL-OPEN (24h).
  ///
  /// On a successful fetch the entitlement is cached with a timestamp. When the
  /// backend is unreachable we honour that cache for 24 hours from
  /// `lastVerifiedAt`, then fail CLOSED to free.
  ///
  /// Why bounded rather than either extreme: failing closed immediately would cut
  /// off a paying student mid-session over a tunnel or a flaky lift, which is the
  /// worst moment to do it. Failing open indefinitely would let a cancelled
  /// subscriber keep access forever simply by staying offline — the cache would
  /// become the product. Twenty-four hours caps that exposure at one day while
  /// covering every realistic connectivity gap.
  ///
  /// The boundary is INCLUSIVE: at exactly 24h the cache is stale and we fail
  /// closed, matching the server-side staleness rule so the two cannot disagree
  /// about the same instant.
  Future<Entitlement> _fetch() async {
    final fresh = await _fetchOrNull();
    if (fresh != null) {
      await _cache(fresh);
      return fresh;
    }
    final cached = await _readCache();
    if (cached != null) {
      appLog.i('[Entitlement] backend unreachable — honouring cache within 24h');
      return cached;
    }
    return const Entitlement(isPremium: false, source: 'NONE');
  }

  static const String _kCacheJson = 'entitlement_cache_json';
  static const String _kCacheAt = 'entitlement_cache_verified_at';

  /// Cache window. Must stay equal to the server's staleness bound.
  @visibleForTesting
  static const Duration cacheWindow = Duration(hours: 24);

  Future<void> _cache(Entitlement e) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kCacheJson, jsonEncode(e.toJson()));
      await prefs.setInt(_kCacheAt, DateTime.now().toUtc().millisecondsSinceEpoch);
    } catch (err) {
      appLog.w('[Entitlement] cache write failed: $err');
    }
  }

  /// Returns the cached entitlement only if it is INSIDE the window.
  /// Anything at or beyond 24h reads as absent, so the caller falls to free.
  Future<Entitlement?> _readCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kCacheJson);
      final at = prefs.getInt(_kCacheAt);
      if (raw == null || at == null) return null;
      final age = DateTime.now().toUtc().difference(
          DateTime.fromMillisecondsSinceEpoch(at, isUtc: true));
      if (age >= cacheWindow) {
        appLog.i('[Entitlement] cache is ${age.inHours}h old — beyond the '
            '24h bound, failing CLOSED');
        return null;
      }
      return Entitlement.fromJson(
          Map<String, dynamic>.from(jsonDecode(raw) as Map));
    } catch (err) {
      appLog.w('[Entitlement] cache read failed: $err');
      return null;
    }
  }

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
