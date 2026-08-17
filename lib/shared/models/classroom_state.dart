import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pally/shared/models/quiz_question.dart';

part 'classroom_state.freezed.dart';
part 'classroom_state.g.dart';

/// Server-authoritative live classroom session state, mirrored 1:1 from the
/// backend's ClassroomStateResponse. No participant identity beyond a bare
/// count — nicknames arrive only via the live SSE "hit" events, ambient and
/// never listed/persisted client-side either.
@freezed
class ClassroomState with _$ClassroomState {
  const factory ClassroomState({
    required String sessionId,
    required String status, // CREATED | ACTIVE | ENDED
    required String topicSlug,
    required int hpRemaining,
    required int hpMax,
    @Default(false) bool defeated,
    @Default(0) int participantCount,
    QuizQuestion? currentQuestion,
  }) = _ClassroomState;

  factory ClassroomState.fromJson(Map<String, dynamic> json) =>
      _$ClassroomStateFromJson(json);
}
