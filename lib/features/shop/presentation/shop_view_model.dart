import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/features/shop/providers/unlocked_characters_provider.dart';
import 'package:pally/shared/models/mochi_character.dart';

part 'shop_view_model.g.dart';

@immutable
class ShopState {
  const ShopState({
    this.stars = 0,
    this.isLoading = false,
    this.isOpening = false,
    this.lastUnlocked,
    this.wasDuplicate = false,
    this.error,
    this.collectionCount = 0,
  });

  final int stars;
  final bool isLoading;
  final bool isOpening;
  final MochiCharacter? lastUnlocked;
  final bool wasDuplicate;
  final String? error;
  final int collectionCount;

  ShopState copyWith({
    int? stars,
    bool? isLoading,
    bool? isOpening,
    Object? lastUnlocked = _sentinel,
    bool? wasDuplicate,
    Object? error = _sentinel,
    int? collectionCount,
  }) {
    return ShopState(
      stars: stars ?? this.stars,
      isLoading: isLoading ?? this.isLoading,
      isOpening: isOpening ?? this.isOpening,
      lastUnlocked: lastUnlocked == _sentinel
          ? this.lastUnlocked
          : lastUnlocked as MochiCharacter?,
      wasDuplicate: wasDuplicate ?? this.wasDuplicate,
      error: error == _sentinel ? this.error : error as String?,
      collectionCount: collectionCount ?? this.collectionCount,
    );
  }
}

const _sentinel = Object();

@riverpod
class ShopViewModel extends _$ShopViewModel {
  @override
  ShopState build() {
    _loadStars();
    return const ShopState(isLoading: true);
  }

  Future<void> _loadStars() async {
    try {
      final dio = ref.read(dioProvider);
      final response =
          await dio.get<Map<String, dynamic>>('/api/v1/shop/stars');
      final s = (response.data?['stars'] as int?) ?? 0;
      final c = (response.data?['collectionCount'] as int?) ?? 0;
      state = state.copyWith(stars: s, collectionCount: c, isLoading: false);
    } on DioException catch (_) {
      state = state.copyWith(stars: 1240, collectionCount: 3, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> openMysteryBox() async {
    if (state.stars < 600) return;
    state = state.copyWith(isOpening: true, lastUnlocked: null);
    try {
      final dio = ref.read(dioProvider);
      final response =
          await dio.post<Map<String, dynamic>>('/api/v1/shop/open-box');
      final charStr = (response.data?['character'] as String?) ?? 'PENCIL';
      final char = MochiCharacter.fromJson(charStr);
      await _handlePull(char);
    } on DioException catch (_) {
      const chars = MochiCharacter.values;
      final char = chars[DateTime.now().millisecondsSinceEpoch % chars.length];
      await _handlePull(char);
    } catch (e) {
      state = state.copyWith(isOpening: false, error: e.toString());
    }
  }

  Future<void> _handlePull(MochiCharacter char) async {
    final unlockedNotifier = ref.read(unlockedCharactersProvider.notifier);
    final alreadyUnlocked = unlockedNotifier.isUnlocked(char);

    if (!alreadyUnlocked) {
      await unlockedNotifier.unlock(char);
    }

    state = state.copyWith(
      stars: state.stars - 600,
      isOpening: false,
      lastUnlocked: char,
      wasDuplicate: alreadyUnlocked,
      collectionCount:
          alreadyUnlocked ? state.collectionCount : state.collectionCount + 1,
    );
  }

  void clearLastUnlocked() {
    state = state.copyWith(lastUnlocked: null);
  }
}
