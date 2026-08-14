import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/error/pally_error.dart';
import 'package:pally/core/utils/logger.dart';
import 'package:pally/shared/models/boss_state.dart';

part 'boss_battle_view_model.g.dart';

@immutable
class BossBattleState {
  const BossBattleState({
    this.isLoading = true,
    this.isAttacking = false,
    this.boss,
    this.selectedIndex,
    this.lastHitLanded,
    this.error,
  });

  final bool isLoading;
  final bool isAttacking;
  final BossState? boss;
  final int? selectedIndex;

  /// Result of the MOST RECENT attack (null before any attack this session) —
  /// purely a cosmetic animation trigger for the Flame view; the authoritative
  /// hp/defeated truth is always [boss].
  final bool? lastHitLanded;
  final PallyError? error;

  bool get hasActiveBoss => boss != null && boss!.active;

  BossBattleState copyWith({
    bool? isLoading,
    bool? isAttacking,
    Object? boss = _sentinel,
    Object? selectedIndex = _sentinel,
    Object? lastHitLanded = _sentinel,
    Object? error = _sentinel,
  }) {
    return BossBattleState(
      isLoading: isLoading ?? this.isLoading,
      isAttacking: isAttacking ?? this.isAttacking,
      boss: boss == _sentinel ? this.boss : boss as BossState?,
      selectedIndex:
          selectedIndex == _sentinel ? this.selectedIndex : selectedIndex as int?,
      lastHitLanded:
          lastHitLanded == _sentinel ? this.lastHitLanded : lastHitLanded as bool?,
      error: error == _sentinel ? this.error : error as PallyError?,
    );
  }
}

const _sentinel = Object();

/// Server-authoritative boss battle. Every mutation here either loads or
/// REPLACES [BossBattleState.boss] wholesale from a server response — this
/// view model never derives hp/defeated locally (same authority pattern as
/// the server-graded quiz submit).
@riverpod
class BossBattleViewModel extends _$BossBattleViewModel {
  late String _avatarId;

  @override
  BossBattleState build(String avatarId) {
    _avatarId = avatarId;
    _loadActive();
    return const BossBattleState();
  }

  Future<void> _loadActive() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get<dynamic>(
        '/api/v1/avatars/$_avatarId/boss/active',
        options: Options(receiveTimeout: const Duration(seconds: 60)),
      );
      final boss = BossState.fromJson(_asMap(response.data));
      state = state.copyWith(boss: boss, isLoading: false);
    } catch (e) {
      appLog.w('[BossBattle] load active failed', error: e);
      state = state.copyWith(isLoading: false, error: PallyError.from(e));
    }
  }

  /// Local UI selection only — never scores/decides correctness client-side.
  void selectAnswer(int index) {
    final boss = state.boss;
    if (state.isAttacking || boss == null || boss.defeated) return;
    state = state.copyWith(selectedIndex: index);
  }

  Future<void> attack() async {
    // Re-entry guard: a double-tap must fire exactly one attack.
    if (state.isAttacking) return;
    final boss = state.boss;
    final question = boss?.currentQuestion;
    final selected = state.selectedIndex;
    if (boss == null || boss.id == null || question == null || selected == null) {
      return;
    }

    state = state.copyWith(isAttacking: true, error: null);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post<dynamic>(
        '/api/v1/avatars/$_avatarId/boss/${boss.id}/attack',
        data: {'questionId': question.id, 'selectedIndex': selected},
        options: Options(
          sendTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 20),
        ),
      );
      final result = BossAttackResult.fromJson(_asMap(response.data));
      // SERVER-AUTHORITATIVE: the new boss state REPLACES the old one wholesale.
      // No local hp-- / defeated=true anywhere in this class.
      state = state.copyWith(
        boss: result.state,
        isAttacking: false,
        lastHitLanded: result.hitLanded,
        selectedIndex: null,
      );
    } catch (e) {
      appLog.w('[BossBattle] attack failed', error: e);
      state = state.copyWith(isAttacking: false, error: PallyError.from(e));
    }
  }

  Future<void> retry() async {
    state = state.copyWith(isLoading: true, error: null);
    await _loadActive();
  }

  Map<String, dynamic> _asMap(dynamic body) {
    if (body is Map) {
      final map = Map<String, dynamic>.from(body);
      // Defensive double-check, matching the daily-quiz submit path: some
      // wrappers nest under "data" even after the envelope interceptor.
      if (map['data'] is Map) return Map<String, dynamic>.from(map['data'] as Map);
      return map;
    }
    return const <String, dynamic>{};
  }
}
