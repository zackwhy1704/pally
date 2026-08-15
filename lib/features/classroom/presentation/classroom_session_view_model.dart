import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/error/pally_error.dart';
import 'package:pally/core/utils/logger.dart';
import 'package:pally/shared/models/classroom_state.dart';
import 'package:pally/shared/models/quiz_question.dart';

part 'classroom_session_view_model.g.dart';

@immutable
class RecentHit {
  const RecentHit({required this.nickname, required this.hitLanded});
  final String nickname;
  final bool hitLanded;
}

@immutable
class ClassroomSessionState {
  const ClassroomSessionState({
    this.isJoining = false,
    this.joined = false,
    this.nicknameRejectedMessage,
    this.participantToken,
    this.nickname,
    this.state,
    this.selectedIndex,
    this.isAttacking = false,
    this.recentHits = const [],
    this.error,
  });

  final bool isJoining;
  final bool joined;

  /// Set ONLY when the server rejected the nickname via moderation (422) —
  /// distinct from [error] so the join screen can show "try a different
  /// name" inline instead of a generic error card.
  final String? nicknameRejectedMessage;

  final String? participantToken;
  final String? nickname;
  final ClassroomState? state;
  final int? selectedIndex;
  final bool isAttacking;

  /// Most recent hits/misses from ANY participant, newest first — nicknames
  /// only, exactly what the live "hit" SSE events carry. Never a roster.
  final List<RecentHit> recentHits;
  final PallyError? error;

  ClassroomSessionState copyWith({
    bool? isJoining,
    bool? joined,
    Object? nicknameRejectedMessage = _sentinel,
    Object? participantToken = _sentinel,
    Object? nickname = _sentinel,
    Object? state = _sentinel,
    Object? selectedIndex = _sentinel,
    bool? isAttacking,
    List<RecentHit>? recentHits,
    Object? error = _sentinel,
  }) {
    return ClassroomSessionState(
      isJoining: isJoining ?? this.isJoining,
      joined: joined ?? this.joined,
      nicknameRejectedMessage: nicknameRejectedMessage == _sentinel
          ? this.nicknameRejectedMessage
          : nicknameRejectedMessage as String?,
      participantToken: participantToken == _sentinel
          ? this.participantToken
          : participantToken as String?,
      nickname: nickname == _sentinel ? this.nickname : nickname as String?,
      state: state == _sentinel ? this.state : state as ClassroomState?,
      selectedIndex:
          selectedIndex == _sentinel ? this.selectedIndex : selectedIndex as int?,
      isAttacking: isAttacking ?? this.isAttacking,
      recentHits: recentHits ?? this.recentHits,
      error: error == _sentinel ? this.error : error as PallyError?,
    );
  }
}

const _sentinel = Object();

/// Server-authoritative live classroom session. Every mutation either loads
/// or REPLACES [ClassroomSessionState.state] wholesale from a server
/// response/SSE event — never derived locally, same authority pattern as
/// the solo boss battle.
@riverpod
class ClassroomSessionViewModel extends _$ClassroomSessionViewModel {
  late String _avatarId;
  StreamSubscription<List<int>>? _streamSub;

  @override
  ClassroomSessionState build(String avatarId) {
    _avatarId = avatarId;
    ref.onDispose(() {
      _streamSub?.cancel();
    });
    return const ClassroomSessionState();
  }

  Future<void> join(String joinCode, String nickname) async {
    if (state.isJoining) return; // re-entry guard
    state = state.copyWith(isJoining: true, nicknameRejectedMessage: null, error: null);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post<dynamic>(
        '/api/v1/avatars/$_avatarId/classroom-sessions/join',
        data: {'joinCode': joinCode, 'nickname': nickname},
      );
      final data = _asMap(response.data);
      final participantToken = data['participantToken'] as String?;
      final resolvedNickname = data['nickname'] as String? ?? nickname;
      final classroomState =
          ClassroomState.fromJson(_asMap(data['state']));

      state = state.copyWith(
        isJoining: false,
        joined: true,
        participantToken: participantToken,
        nickname: resolvedNickname,
        state: classroomState,
      );
      _connectStream();
    } catch (e) {
      // A rejected nickname (422) gets its own state field so the join
      // screen can show "try a different name" inline instead of a generic
      // error card. Checked via `e is DioException` inside the general catch
      // (not a typed catch clause) so every other error still falls through
      // to the same handling every other view model in this app uses.
      if (e is DioException && e.response?.statusCode == 422) {
        final responseData = e.response?.data;
        final msg = responseData is Map ? responseData['error'] as String? : null;
        state = state.copyWith(
          isJoining: false,
          nicknameRejectedMessage:
              msg ?? "That name isn't allowed — try a different name.",
        );
        return;
      }
      appLog.w('[Classroom] join failed', error: e);
      state = state.copyWith(isJoining: false, error: PallyError.from(e));
    }
  }

  void selectAnswer(int index) {
    final classroomState = state.state;
    if (state.isAttacking || classroomState == null || classroomState.defeated) return;
    state = state.copyWith(selectedIndex: index);
  }

  Future<void> attack() async {
    if (state.isAttacking) return; // re-entry guard
    final classroomState = state.state;
    final question = classroomState?.currentQuestion;
    final selected = state.selectedIndex;
    final token = state.participantToken;
    if (classroomState == null || question == null || selected == null || token == null) {
      return;
    }

    state = state.copyWith(isAttacking: true, error: null);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post<dynamic>(
        '/api/v1/avatars/$_avatarId/classroom-sessions/${classroomState.sessionId}/attack',
        data: {
          'participantToken': token,
          'questionId': question.id,
          'selectedIndex': selected,
        },
      );
      final data = _asMap(response.data);
      // SERVER-AUTHORITATIVE: replace state wholesale — the SSE stream will
      // also push the same shared-HP update to every OTHER participant; this
      // just avoids waiting on our own event round-trip for our own attack.
      state = state.copyWith(
        state: ClassroomState.fromJson(_asMap(data['state'])),
        isAttacking: false,
        selectedIndex: null,
      );
    } catch (e) {
      appLog.w('[Classroom] attack failed', error: e);
      state = state.copyWith(isAttacking: false, error: PallyError.from(e));
    }
  }

  /// Live question/HP/hit updates from every participant, including other
  /// students — same SSE wire format chat already uses (event:/data:
  /// framing), consumed with the identical line-parsing chat's stream uses.
  /// Long-lived: runs for the whole session, not one turn.
  Future<void> _connectStream() async {
    final classroomState = state.state;
    final token = state.participantToken;
    if (classroomState == null || token == null) return;

    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get<ResponseBody>(
        '/api/v1/avatars/$_avatarId/classroom-sessions/${classroomState.sessionId}/stream',
        queryParameters: {'participantToken': token},
        options: Options(
          responseType: ResponseType.stream,
          headers: {'Accept': 'text/event-stream'},
          receiveTimeout: const Duration(minutes: 30),
        ),
      );

      String currentEvent = '';
      final dataLines = <String>[];

      // .listen (not await-for) so ref.onDispose can actually cancel this —
      // a long-lived session stream must not outlive the notifier.
      _streamSub = response.data!.stream.listen(
        (chunk) {
          final raw = utf8.decode(chunk);
          for (final line in raw.split('\n')) {
            if (line.startsWith(':')) continue; // SSE comment
            if (line.startsWith('event: ')) {
              currentEvent = line.substring(7).trim();
            } else if (line.startsWith('data: ') || line.startsWith('data:')) {
              dataLines.add(
                  line.startsWith('data: ') ? line.substring(6) : line.substring(5));
            } else if (line.trim().isEmpty && dataLines.isNotEmpty) {
              final fullData = dataLines.join('\n');
              dataLines.clear();
              _handleStreamEvent(currentEvent, fullData);
              currentEvent = '';
            }
          }
        },
        onError: (Object e) => appLog.w('[Classroom] live stream error', error: e),
        cancelOnError: true,
      );
    } catch (e) {
      appLog.w('[Classroom] live stream failed to connect', error: e);
      // Best-effort: the student can still attack via the request/response
      // path above even if the live push connection never connects.
    }
  }

  void _handleStreamEvent(String type, String data) {
    if (data.isEmpty) return;
    switch (type) {
      case 'hit':
        final json = jsonDecode(data) as Map<String, dynamic>;
        final nickname = json['nickname'] as String? ?? '?';
        final hitLanded = json['hitLanded'] == true;
        final hpRemaining = (json['hpRemaining'] as num?)?.toInt();
        final hpMax = (json['hpMax'] as num?)?.toInt();
        final current = state.state;
        state = state.copyWith(
          recentHits: [RecentHit(nickname: nickname, hitLanded: hitLanded),
              ...state.recentHits.take(9)],
          state: (current == null || hpRemaining == null || hpMax == null)
              ? current
              : current.copyWith(hpRemaining: hpRemaining, hpMax: hpMax),
        );
        break;
      case 'question':
        final current = state.state;
        if (current == null) return;
        try {
          final json = jsonDecode(data) as Map<String, dynamic>;
          state = state.copyWith(
              state: current.copyWith(currentQuestion: QuizQuestion.fromJson(json)));
        } catch (e) {
          appLog.w('[Classroom] malformed question event', error: e);
        }
        break;
      case 'defeated':
        final current = state.state;
        if (current == null) return;
        state = state.copyWith(
            state: current.copyWith(defeated: true, currentQuestion: null));
        break;
      case 'ended':
        final current = state.state;
        if (current == null) return;
        state = state.copyWith(state: current.copyWith(status: 'ENDED'));
        break;
      default:
        break; // e.g. "started" — no client state change needed
    }
  }

  Map<String, dynamic> _asMap(dynamic body) {
    if (body is Map) return Map<String, dynamic>.from(body);
    return const <String, dynamic>{};
  }
}
