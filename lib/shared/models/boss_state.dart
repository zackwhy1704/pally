import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pally/shared/models/quiz_question.dart';

part 'boss_state.freezed.dart';
part 'boss_state.g.dart';

/// Server-authoritative boss battle state, mirrored 1:1 from the backend's
/// BossStateResponse. The client NEVER computes hp/defeated locally — this
/// record IS the truth, replaced wholesale on every server response.
/// [currentQuestion] reuses [QuizQuestion] — it's served through the SAME
/// answer-exposure chokepoint as the daily quiz (QuizService.serveGradable),
/// so it carries the identical withheld-for-centre-quizzes contract.
@freezed
class BossState with _$BossState {
  const factory BossState({
    @Default(false) bool active,
    String? id,
    String? topicSlug,
    @Default(0) int hpRemaining,
    @Default(0) int hpMax,
    @Default(false) bool defeated,
    @Default(false) bool rewardUnlocked,
    QuizQuestion? currentQuestion,
  }) = _BossState;

  factory BossState.fromJson(Map<String, dynamic> json) =>
      _$BossStateFromJson(json);
}

/// One attack's result. [hitLanded] is the ONLY thing the UI needs to decide
/// which animation to play — the HP/defeated truth lives in [state].
@freezed
class BossAttackResult with _$BossAttackResult {
  const factory BossAttackResult({
    required BossState state,
    @Default(false) bool hitLanded,
  }) = _BossAttackResult;

  factory BossAttackResult.fromJson(Map<String, dynamic> json) =>
      _$BossAttackResultFromJson(json);
}
