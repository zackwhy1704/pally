import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/utils/logger.dart';
import 'package:pally/features/auth/auth_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Known feature flags. Add a new entry here when introducing a new gated module.
class FeatureFlags {
  /// Groups tab — open to all users (server always returns true).
  static const groupsEnabled = 'groups_enabled';

  /// Admin-only flag (admin demo mode, admin settings).
  /// Set server-side from ADMIN_EMAILS env var only. Never set client-side.
  static const isAdmin = 'is_admin';

  /// iOS external-purchase link allowed. Defaults absent → false, so iOS shows
  /// a copy-only billing link (App Store anti-steering compliant). Flip this on
  /// server-side ONLY after Apple grants the External Link Account Entitlement;
  /// then the web upgrade CTA reveals a tappable "Continue on web" button on iOS.
  static const iosExternalLinkEnabled = 'ios_external_link_enabled';
}

/// Server-controlled per-user feature flags.
///
/// Cache is scoped per userId so an admin logging in on a shared device
/// cannot leak their flags (including is_admin=true) to the next user.
///
/// Security guarantee for is_admin:
/// - Cache key includes userId → different users never share a cache.
/// - First-frame value always comes from the user's own cache (or empty).
/// - is_admin is NEVER set client-side; it comes only from the server
///   which checks ADMIN_EMAILS env var at request time.
class FeatureFlagsNotifier extends AsyncNotifier<Map<String, bool>> {
  static String _cacheKey(String userId) => 'feature_flags_v2_$userId';

  @override
  Future<Map<String, bool>> build() async {
    final userId = ref.watch(authStateProvider).userId;
    if (userId == null) {
      // Not signed in — no flags, no cache read
      return const {};
    }

    // First frame from this user's own cache (never another user's cache)
    final cached = await _readCache(userId);
    if (cached.isNotEmpty) {
      Future.microtask(_refreshFromRemote);
      return cached;
    }
    return _fetchRemote(userId);
  }

  Future<Map<String, bool>> _fetchRemote([String? uid]) async {
    final userId = uid ?? ref.read(authStateProvider).userId;
    if (userId == null) return const {};
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get<Map<String, dynamic>>('/api/v1/me/flags');
      final data = (response.data?['data'] is Map
              ? response.data!['data']
              : response.data) as Map<String, dynamic>? ??
          const {};
      final flags = <String, bool>{
        for (final entry in data.entries) entry.key: entry.value == true,
      };
      // is_admin must come from the server — never cache a true value that
      // was set locally. The server already enforces ADMIN_EMAILS, so if
      // the server says is_admin=false, we store false (not absent).
      await _writeCache(userId, flags);
      return flags;
    } on DioException catch (e) {
      appLog.w('[Flags] fetch failed: ${e.message} — using cache/empty');
      return await _readCache(userId);
    }
  }

  Future<void> _refreshFromRemote() async {
    final fresh = await _fetchRemote();
    state = AsyncData(fresh);
  }

  Future<Map<String, bool>> _readCache(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_cacheKey(userId)) ?? const [];
    final result = <String, bool>{};
    for (final entry in raw) {
      final i = entry.indexOf('=');
      if (i <= 0) continue;
      result[entry.substring(0, i)] = entry.substring(i + 1) == 'true';
    }
    return result;
  }

  Future<void> _writeCache(String userId, Map<String, bool> flags) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_cacheKey(userId),
        [for (final e in flags.entries) '${e.key}=${e.value}']);
  }

  bool isEnabled(String name) => state.valueOrNull?[name] == true;

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _fetchRemote());
  }
}

final featureFlagsProvider =
    AsyncNotifierProvider<FeatureFlagsNotifier, Map<String, bool>>(
        FeatureFlagsNotifier.new);

/// Synchronous accessor — returns false while loading or when the flag is absent.
///
/// For is_admin specifically: returns false until the server confirms it,
/// which means the Tuition tab is NEVER shown on the first frame unless
/// the server has already confirmed admin status for this userId.
bool isFlagEnabled(WidgetRef ref, String flag) =>
    ref.watch(featureFlagsProvider).valueOrNull?[flag] == true;

/// Whether subscription PRICES may be displayed in-app. iOS anti-steering
/// forbids showing subscription prices without the external-link entitlement
/// (the same rule that gates the buy URL); Android is always allowed. Use this
/// to hide every price string on gated iOS, mirroring WebUpgradeCta's launch gate.
bool allowPriceDisplay(WidgetRef ref) =>
    !Platform.isIOS || isFlagEnabled(ref, FeatureFlags.iosExternalLinkEnabled);
