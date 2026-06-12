import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/error/pally_error.dart';
import 'package:pally/core/utils/logger.dart';

part 'challenge_view_model.g.dart';

/// A single option/count pair in a revealed challenge's answer distribution.
@immutable
class ChallengeDistribution {
  const ChallengeDistribution({required this.answer, required this.count});
  final String answer;
  final int count;

  static ChallengeDistribution fromJson(Map<String, dynamic> j) =>
      ChallengeDistribution(
        answer: (j['answer'] as String?) ?? '',
        count: (j['count'] as num?)?.toInt() ?? 0,
      );
}

/// A class daily challenge. Pre-reveal carries the question + options + a
/// `revealAt` timestamp; post-reveal adds the correct answer + distribution.
/// Every field is null-tolerant per CLAUDE.md PART 16.
@immutable
class Challenge {
  const Challenge({
    required this.id,
    required this.classId,
    required this.question,
    required this.options,
    required this.revealAt,
    required this.revealed,
    required this.answered,
    this.answer,
    this.correct,
    this.distribution = const [],
    this.myAnswer,
  });

  final String id;
  final String classId;
  final String question;

  /// Multiple-choice options. Empty for free-text/open challenges.
  final List<String> options;

  /// When the answer is revealed to students. Null when the server omits it
  /// (treated as "no scheduled reveal").
  final DateTime? revealAt;
  final bool revealed;
  final bool answered;

  /// Post-reveal only: the model answer string.
  final String? answer;

  /// Post-reveal only: which option is correct (may equal [answer]).
  final String? correct;

  /// Post-reveal only: per-answer vote counts.
  final List<ChallengeDistribution> distribution;

  /// The student's own submitted answer, tracked client-side so the revealed
  /// view can highlight "your answer". Null until they answer this session.
  final String? myAnswer;

  bool get isMcq => options.isNotEmpty;

  int get totalVotes =>
      distribution.fold<int>(0, (sum, d) => sum + d.count);

  Challenge copyWith({bool? answered, String? myAnswer}) => Challenge(
        id: id,
        classId: classId,
        question: question,
        options: options,
        revealAt: revealAt,
        revealed: revealed,
        answered: answered ?? this.answered,
        answer: answer,
        correct: correct,
        distribution: distribution,
        myAnswer: myAnswer ?? this.myAnswer,
      );

  static Challenge fromJson(Map<String, dynamic> j) {
    final options = ((j['options'] as List?) ?? const [])
        .map((e) => e?.toString() ?? '')
        .where((s) => s.isNotEmpty)
        .toList(growable: false);
    final distribution = ((j['distribution'] as List?) ?? const [])
        .whereType<Map>()
        .map((m) => ChallengeDistribution.fromJson(
            Map<String, dynamic>.from(m)))
        .toList(growable: false);
    return Challenge(
      id: (j['id'] as String?) ?? '',
      classId: (j['classId'] as String?) ?? '',
      question: (j['question'] as String?) ?? '',
      options: options,
      revealAt: j['revealAt'] != null
          ? DateTime.tryParse(j['revealAt'] as String)?.toLocal()
          : null,
      revealed: (j['revealed'] as bool?) ?? false,
      answered: (j['answered'] as bool?) ?? false,
      answer: j['answer'] as String?,
      correct: j['correct'] as String?,
      distribution: distribution,
    );
  }
}

/// Lists the open/recent challenges for a class. Returns an empty list on any
/// failure (e.g. a peer group with no class) so the feed degrades silently.
@riverpod
class ClassChallengesViewModel extends _$ClassChallengesViewModel {
  @override
  Future<List<Challenge>> build(String classId) async {
    if (classId.isEmpty) return const [];
    try {
      final dio = ref.read(dioProvider);
      final response =
          await dio.get<dynamic>('/api/v1/classes/$classId/challenges');
      final raw = response.data;
      final list = raw is List
          ? raw
          : (raw is Map && raw['challenges'] is List
              ? raw['challenges'] as List
              : (raw is Map && raw['data'] is List
                  ? raw['data'] as List
                  : const <dynamic>[]));
      final out = <Challenge>[];
      for (final e in list) {
        if (e is Map) {
          out.add(Challenge.fromJson(Map<String, dynamic>.from(e)));
        }
      }
      appLog.i('[Challenge] Listed ${out.length} for class $classId');
      return out;
    } on DioException catch (e, st) {
      appLog.w('[Challenge] list failed', error: e, stackTrace: st);
      return const [];
    }
  }
}

/// Loads + submits a single class challenge. Keyed by challengeId so the group
/// feed can host multiple cards independently.
@riverpod
class ChallengeViewModel extends _$ChallengeViewModel {
  late String _challengeId;

  @override
  Future<Challenge> build(String challengeId) async {
    _challengeId = challengeId;
    return _fetch();
  }

  Future<Challenge> _fetch() async {
    appLog.d('[Challenge] Fetching $_challengeId');
    final dio = ref.read(dioProvider);
    final response =
        await dio.get<dynamic>('/api/v1/challenges/$_challengeId');
    final raw = response.data;
    final data = raw is Map
        ? Map<String, dynamic>.from(
            raw['data'] is Map ? raw['data'] as Map : raw)
        : <String, dynamic>{};
    final challenge = Challenge.fromJson(data);
    appLog.i('[Challenge] Loaded $_challengeId revealed=${challenge.revealed} '
        'answered=${challenge.answered}');
    return challenge;
  }

  /// Submits the student's answer. A 409 means they already answered — we treat
  /// that as success (mark answered) rather than surfacing an error, then
  /// refresh so the card reflects server truth.
  Future<void> submitAnswer(String answer) async {
    final current = state.valueOrNull;
    appLog.i('[Challenge] Submitting answer for $_challengeId');
    // Optimistically flip to answered so the UI locks immediately.
    if (current != null) {
      state = AsyncData(current.copyWith(answered: true, myAnswer: answer));
    }
    try {
      final dio = ref.read(dioProvider);
      await dio.post<dynamic>(
        '/api/v1/challenges/$_challengeId/answer',
        data: {'answer': answer},
      );
    } on DioException catch (e, st) {
      if (e.response?.statusCode == 409) {
        // Already answered — benign, keep the locked state.
        appLog.d('[Challenge] $_challengeId already answered (409)');
      } else {
        appLog.e('[Challenge] Submit failed', error: e, stackTrace: st);
        // Roll back the optimistic lock so the child can retry.
        if (current != null) state = AsyncData(current);
        state = AsyncError(PallyError.from(e), st);
        return;
      }
    }
    // Re-sync with the server (picks up reveal/distribution when due).
    state = await AsyncValue.guard(_fetch);
  }

  /// Re-fetches the challenge (used when the countdown crosses revealAt so the
  /// distribution + correct answer appear).
  Future<void> refresh() async {
    state = await AsyncValue.guard(_fetch);
  }
}
