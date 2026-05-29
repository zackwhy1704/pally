import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/error/pally_error.dart';
import 'package:pally/shared/models/mochi_character.dart';

part 'collection_view_model.g.dart';

/// One slot in the album. [character] is null for catalog entries the
/// client doesn't have a local enum mapping for (a future seasonal Mochi
/// shipped server-side ahead of the app release).
@immutable
class CollectionEntry {
  const CollectionEntry({
    required this.id,
    required this.character,
    required this.rarity,
    required this.unlocked,
  });

  final String id;
  final MochiCharacter? character;
  final String rarity; // COMMON | RARE | SECRET | STANDARD
  final bool unlocked;
}

/// Aggregate state for the album screen.
@immutable
class CollectionState {
  const CollectionState({
    this.isLoading = false,
    this.error,
    this.entries = const [],
  });

  final bool isLoading;
  final String? error;
  final List<CollectionEntry> entries;

  int get ownedCount => entries.where((e) => e.unlocked).length;
  int get totalCount => entries.length;
  double get progress => totalCount == 0 ? 0 : ownedCount / totalCount;

  CollectionState copyWith({
    bool? isLoading,
    Object? error = _sentinel,
    List<CollectionEntry>? entries,
  }) {
    return CollectionState(
      isLoading: isLoading ?? this.isLoading,
      error: error == _sentinel ? this.error : error as String?,
      entries: entries ?? this.entries,
    );
  }
}

const _sentinel = Object();

@riverpod
class CollectionViewModel extends _$CollectionViewModel {
  @override
  CollectionState build() {
    _load();
    return const CollectionState(isLoading: true);
  }

  Future<void> _load() async {
    try {
      final dio = ref.read(dioProvider);
      final res = await dio
          .get<Map<String, dynamic>>('/api/v1/shop/characters');
      final list = (res.data?['characters'] as List?) ?? const [];
      final entries = list
          .whereType<Map<String, dynamic>>()
          .map((m) {
            final id = (m['character'] as String?) ?? '';
            MochiCharacter? char;
            try {
              char = MochiCharacter.fromJson(id);
            } catch (_) {
              char = null;
            }
            return CollectionEntry(
              id: id,
              character: char,
              rarity: (m['rarity'] as String?) ?? 'COMMON',
              unlocked: (m['unlocked'] as bool?) ?? false,
            );
          })
          .where((e) => e.id.isNotEmpty)
          .toList();
      state = state.copyWith(
          isLoading: false, error: null, entries: entries);
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: PallyError.from(e).userMessage);
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    await _load();
  }
}
