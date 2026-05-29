import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/error/pally_error.dart';

part 'powerup_view_model.g.dart';

/// Single source of truth for "how much does X cost" + "what does the
/// user currently own." Loads /shop/powerups/catalog (price + label)
/// + /shop/powerups (current counts) on construction. Buy / consume
/// re-read from the response so the UI never drifts from the server.
@immutable
class PowerupState {
  const PowerupState({
    this.isLoading = false,
    this.isBuying = false,
    this.error,
    this.counts = const {},
    this.catalog = const {},
    this.lastPurchase,
  });

  final bool isLoading;
  final bool isBuying;
  final String? error;

  /// type name → owned count (HINT_TOKEN / DOUBLE_XP / BONUS_QUIZ)
  final Map<String, int> counts;

  /// type name → {cost, label}
  final Map<String, PowerupCatalogEntry> catalog;

  final PowerupPurchase? lastPurchase;

  PowerupState copyWith({
    bool? isLoading,
    bool? isBuying,
    Object? error = _sentinel,
    Map<String, int>? counts,
    Map<String, PowerupCatalogEntry>? catalog,
    Object? lastPurchase = _sentinel,
  }) {
    return PowerupState(
      isLoading: isLoading ?? this.isLoading,
      isBuying: isBuying ?? this.isBuying,
      error: error == _sentinel ? this.error : error as String?,
      counts: counts ?? this.counts,
      catalog: catalog ?? this.catalog,
      lastPurchase: lastPurchase == _sentinel
          ? this.lastPurchase
          : lastPurchase as PowerupPurchase?,
    );
  }
}

const _sentinel = Object();

@immutable
class PowerupCatalogEntry {
  const PowerupCatalogEntry({required this.cost, required this.label});
  final int cost;
  final String label;
}

@immutable
class PowerupPurchase {
  const PowerupPurchase({
    required this.type,
    required this.count,
    required this.newStarBalance,
  });
  final String type;
  final int count;
  final int newStarBalance;
}

@riverpod
class PowerupViewModel extends _$PowerupViewModel {
  @override
  PowerupState build() {
    _load();
    return const PowerupState(isLoading: true);
  }

  Future<void> _load() async {
    try {
      final dio = ref.read(dioProvider);
      final catalogRes = await dio
          .get<Map<String, dynamic>>('/api/v1/shop/powerups/catalog');
      final countsRes =
          await dio.get<Map<String, dynamic>>('/api/v1/shop/powerups');

      final catalogRaw =
          (catalogRes.data?['powerups'] as Map?) ?? const {};
      final catalog = <String, PowerupCatalogEntry>{};
      catalogRaw.forEach((k, v) {
        if (v is Map) {
          catalog[k as String] = PowerupCatalogEntry(
            cost: (v['cost'] as num?)?.toInt() ?? 0,
            label: (v['label'] as String?) ?? k,
          );
        }
      });

      final counts = <String, int>{};
      (countsRes.data ?? const {}).forEach((k, v) {
        counts[k] = (v as num?)?.toInt() ?? 0;
      });

      state = state.copyWith(
          isLoading: false,
          catalog: catalog,
          counts: counts,
          error: null);
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: PallyError.from(e).userMessage);
    }
  }

  /// Purchase one of [type]. Backend returns the new count + balance so
  /// we don't need a follow-up read. The shop view model bumps its star
  /// balance via the lastPurchase listener.
  Future<void> buy(String type) async {
    if (state.isBuying) return;
    state = state.copyWith(isBuying: true, error: null);
    try {
      final dio = ref.read(dioProvider);
      final res = await dio
          .post<Map<String, dynamic>>('/api/v1/shop/powerups/$type');
      final data = res.data ?? const {};
      final count = (data['count'] as num?)?.toInt() ?? 0;
      final stars = (data['newStarBalance'] as num?)?.toInt() ?? 0;
      final updatedCounts = Map<String, int>.from(state.counts);
      updatedCounts[type] = count;
      state = state.copyWith(
        isBuying: false,
        counts: updatedCounts,
        lastPurchase: PowerupPurchase(
            type: type, count: count, newStarBalance: stars),
      );
    } catch (e) {
      state = state.copyWith(
          isBuying: false, error: PallyError.from(e).userMessage);
    }
  }

  void clearPurchase() {
    state = state.copyWith(lastPurchase: null);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
