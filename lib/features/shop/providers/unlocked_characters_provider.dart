import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/utils/logger.dart';
import 'package:pally/shared/models/mochi_character.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Source of truth for which characters the user has unlocked.
///
/// Backend is authoritative — every read goes to {@code GET /api/v1/shop/characters}
/// so the collection survives device changes / reinstalls. SharedPreferences is
/// only an offline cache: it's overwritten on every successful fetch and read
/// from when the network is unavailable.
class UnlockedCharactersNotifier extends AsyncNotifier<Set<MochiCharacter>> {
  static const _cacheKey = 'unlocked_mochi_characters_cache';

  @override
  Future<Set<MochiCharacter>> build() async => _fetchRemote();

  Future<Set<MochiCharacter>> _fetchRemote() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get<Map<String, dynamic>>(
        '/api/v1/shop/characters',
      );
      final data = (response.data?['data'] is Map
              ? response.data!['data']
              : response.data) as Map<String, dynamic>;
      final list = (data['characters'] as List?) ?? const [];
      final unlocked = list
          .whereType<Map<String, dynamic>>()
          .where((c) => c['unlocked'] == true)
          .map((c) => (c['character'] as String?) ?? '')
          .where((s) => s.isNotEmpty)
          .map((s) {
        try {
          return MochiCharacter.fromJson(s);
        } catch (_) {
          return null;
        }
      }).whereType<MochiCharacter>().toSet();

      await _saveCache(unlocked);
      return unlocked;
    } on DioException catch (e) {
      appLog.w('[Shop] /shop/characters fetch failed: ${e.message} '
          '— falling back to local cache');
      return _loadCache();
    }
  }

  Future<Set<MochiCharacter>> _loadCache() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    if (raw == null || raw.isEmpty) {
      // Conservative default: the standard characters that are always free.
      return MochiCharacter.values
          .where((c) => !c.isLockedByDefault)
          .toSet();
    }
    return raw
        .split(',')
        .where((s) => s.isNotEmpty)
        .map((s) {
      try {
        return MochiCharacter.fromJson(s);
      } catch (_) {
        return null;
      }
    }).whereType<MochiCharacter>().toSet();
  }

  Future<void> _saveCache(Set<MochiCharacter> chars) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _cacheKey, chars.map((c) => c.jsonValue).join(','));
  }

  /// Optimistic local update after {@code POST /shop/open-box} reports a new
  /// unlock; a background re-fetch then reconciles with the backend.
  Future<void> unlock(MochiCharacter character) async {
    final current = state.valueOrNull ?? {};
    final updated = {...current, character};
    state = AsyncData(updated);
    await _saveCache(updated);
    Future.microtask(() async {
      final fresh = await _fetchRemote();
      state = AsyncData(fresh);
    });
  }

  bool isUnlocked(MochiCharacter character) {
    if (!character.isLockedByDefault) return true;
    return state.valueOrNull?.contains(character) ?? false;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _fetchRemote());
  }
}

final unlockedCharactersProvider =
    AsyncNotifierProvider<UnlockedCharactersNotifier, Set<MochiCharacter>>(
        UnlockedCharactersNotifier.new);
