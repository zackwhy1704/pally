import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Known pilot flags. Add a new entry here when introducing a new gated module.
class FeatureFlags {
  static const groupsEnabled = 'groups_enabled';
}

/// Server-controlled per-user feature flags.
///
/// Fetched once on app launch from {@code GET /api/v1/me/flags}, cached in
/// SharedPreferences so the first frame on subsequent launches can render the
/// correct nav before the network round-trip completes. The cache is
/// overwritten on every successful fetch.
class FeatureFlagsNotifier extends AsyncNotifier<Map<String, bool>> {
  static const _cacheKey = 'feature_flags_cache_v1';

  @override
  Future<Map<String, bool>> build() async {
    // First paint uses the cache so the nav doesn't flicker between 4 and
    // 5 tabs while the network call is in flight.
    final cached = await _readCache();
    if (cached.isNotEmpty) {
      // Schedule a remote sync in the background.
      Future.microtask(_refreshFromRemote);
      return cached;
    }
    return _fetchRemote();
  }

  Future<Map<String, bool>> _fetchRemote() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get<Map<String, dynamic>>(
        '/api/v1/me/flags',
      );
      final data = (response.data?['data'] is Map
              ? response.data!['data']
              : response.data) as Map<String, dynamic>? ??
          const {};
      final flags = <String, bool>{
        for (final entry in data.entries)
          entry.key: entry.value == true,
      };
      await _writeCache(flags);
      return flags;
    } on DioException catch (e) {
      appLog.w('[Flags] fetch failed: ${e.message} — using cache/empty');
      return _readCache();
    }
  }

  Future<void> _refreshFromRemote() async {
    final fresh = await _fetchRemote();
    state = AsyncData(fresh);
  }

  Future<Map<String, bool>> _readCache() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_cacheKey) ?? const [];
    final result = <String, bool>{};
    for (final entry in raw) {
      final i = entry.indexOf('=');
      if (i <= 0) continue;
      result[entry.substring(0, i)] = entry.substring(i + 1) == 'true';
    }
    return result;
  }

  Future<void> _writeCache(Map<String, bool> flags) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_cacheKey,
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

/// Synchronous accessor that returns false while loading. Use this in build
/// methods where AsyncValue handling is overkill (e.g. nav-tab visibility).
bool isFlagEnabled(WidgetRef ref, String flag) =>
    ref.watch(featureFlagsProvider).valueOrNull?[flag] == true;
