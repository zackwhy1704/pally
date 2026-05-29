import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/error/pally_error.dart';
import 'package:pally/features/shop/providers/unlocked_characters_provider.dart';
import 'package:pally/shared/models/mochi_character.dart';

part 'shop_view_model.g.dart';

@immutable
class ShopState {
  const ShopState({
    this.stars = 0,
    this.isLoading = false,
    this.isOpening = false,
    this.isBuyingFreeze = false,
    this.lastUnlocked,
    this.wasDuplicate = false,
    this.error,
    this.collectionCount = 0,
    this.lastFreezePurchase,
  });

  final int stars;
  final bool isLoading;
  final bool isOpening;
  final bool isBuyingFreeze;
  final MochiCharacter? lastUnlocked;
  final bool wasDuplicate;
  final String? error;
  final int collectionCount;

  /// Set after a successful freeze buy so the screen can show a confirmation
  /// snackbar without keeping a stale value around. Cleared by [clearFreezePurchase].
  final FreezePurchase? lastFreezePurchase;

  ShopState copyWith({
    int? stars,
    bool? isLoading,
    bool? isOpening,
    bool? isBuyingFreeze,
    Object? lastUnlocked = _sentinel,
    bool? wasDuplicate,
    Object? error = _sentinel,
    int? collectionCount,
    Object? lastFreezePurchase = _sentinel,
  }) {
    return ShopState(
      stars: stars ?? this.stars,
      isLoading: isLoading ?? this.isLoading,
      isOpening: isOpening ?? this.isOpening,
      isBuyingFreeze: isBuyingFreeze ?? this.isBuyingFreeze,
      lastUnlocked: lastUnlocked == _sentinel
          ? this.lastUnlocked
          : lastUnlocked as MochiCharacter?,
      wasDuplicate: wasDuplicate ?? this.wasDuplicate,
      error: error == _sentinel ? this.error : error as String?,
      collectionCount: collectionCount ?? this.collectionCount,
      lastFreezePurchase: lastFreezePurchase == _sentinel
          ? this.lastFreezePurchase
          : lastFreezePurchase as FreezePurchase?,
    );
  }
}

@immutable
class FreezePurchase {
  const FreezePurchase({required this.freezes, required this.freezeCap});
  final int freezes;
  final int freezeCap;
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
    } catch (e) {
      // Stars are a real currency. Never fabricate a balance — show a
      // real error + retry instead, so a kid can't think they have 1240
      // stars when the server says otherwise.
      state = state.copyWith(
          isLoading: false, error: PallyError.from(e).userMessage);
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
    } catch (e) {
      // Never fabricate a pull — picking a random character locally
      // means the user celebrates an unlock that doesn't exist on the
      // backend (and their stars weren't deducted). Surface the failure.
      state = state.copyWith(
          isOpening: false, error: PallyError.from(e).userMessage);
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

  /// Cost of one streak freeze. Mirrors backend constant — kept in sync via
  /// the API response (newStarBalance/freezes) on every purchase.
  static const int freezeCost = 150;

  Future<void> buyFreeze() async {
    if (state.isBuyingFreeze) return;
    state = state.copyWith(isBuyingFreeze: true, error: null);
    try {
      final dio = ref.read(dioProvider);
      final response =
          await dio.post<Map<String, dynamic>>('/api/v1/shop/buy-freeze');
      final stars = (response.data?['newStarBalance'] as int?) ?? state.stars;
      final freezes = (response.data?['freezes'] as int?) ?? 0;
      final cap = (response.data?['freezeCap'] as int?) ?? 3;
      state = state.copyWith(
        isBuyingFreeze: false,
        stars: stars,
        lastFreezePurchase: FreezePurchase(freezes: freezes, freezeCap: cap),
      );
    } catch (e) {
      // 400 from the backend means "not enough stars" or "freezes full" —
      // PallyError surfaces the kid-friendly message verbatim. Don't
      // mutate stars or freeze count on failure (server is authoritative).
      state = state.copyWith(
          isBuyingFreeze: false, error: PallyError.from(e).userMessage);
    }
  }

  void clearFreezePurchase() {
    state = state.copyWith(lastFreezePurchase: null);
  }
}
