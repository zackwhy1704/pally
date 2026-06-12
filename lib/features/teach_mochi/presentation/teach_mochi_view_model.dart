import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/utils/logger.dart';
import 'package:pally/features/progress/presentation/progress_view_model.dart';
import 'package:pally/shared/models/wiki_page.dart';

part 'teach_mochi_view_model.g.dart';

@immutable
class TeachEvaluation {
  const TeachEvaluation({
    required this.score,
    required this.totalConcepts,
    required this.xpEarned,
    required this.coveredConcepts,
    required this.missedConcepts,
    required this.followUpQuestion,
    required this.feedback,
    this.levelledUp = false,
    this.newLevel = 0,
  });

  final int score;
  final int totalConcepts;
  final int xpEarned;
  final List<String> coveredConcepts;
  final List<String> missedConcepts;
  final String? followUpQuestion;
  final String feedback;
  final bool levelledUp;
  final int newLevel;

  bool get isPerfect => totalConcepts > 0 && score == totalConcepts;

  static TeachEvaluation fromJson(Map<String, dynamic> json) => TeachEvaluation(
        score: (json['score'] as num?)?.toInt() ?? 0,
        totalConcepts: (json['totalConcepts'] as num?)?.toInt() ?? 0,
        xpEarned: (json['xpEarned'] as num?)?.toInt() ?? 0,
        coveredConcepts: ((json['coveredConcepts'] as List?) ?? const [])
            .whereType<String>()
            .toList(),
        missedConcepts: ((json['missedConcepts'] as List?) ?? const [])
            .whereType<String>()
            .toList(),
        followUpQuestion: json['followUpQuestion'] as String?,
        feedback: (json['feedback'] as String?) ?? '',
        levelledUp: json['levelledUp'] == true,
        newLevel: (json['newLevel'] as num?)?.toInt() ?? 0,
      );
}

@immutable
class TeachState {
  const TeachState({
    this.topics = const [],
    this.selectedTopic,
    this.explanation = '',
    this.evaluation,
    this.isLoadingTopics = false,
    this.isSubmitting = false,
    this.error,
  });

  final List<WikiPage> topics;
  final WikiPage? selectedTopic;
  final String explanation;
  final TeachEvaluation? evaluation;
  final bool isLoadingTopics;
  final bool isSubmitting;
  final String? error;

  TeachState copyWith({
    List<WikiPage>? topics,
    Object? selectedTopic = _sentinel,
    String? explanation,
    Object? evaluation = _sentinel,
    bool? isLoadingTopics,
    bool? isSubmitting,
    Object? error = _sentinel,
  }) {
    return TeachState(
      topics: topics ?? this.topics,
      selectedTopic: selectedTopic == _sentinel
          ? this.selectedTopic
          : selectedTopic as WikiPage?,
      explanation: explanation ?? this.explanation,
      evaluation: evaluation == _sentinel
          ? this.evaluation
          : evaluation as TeachEvaluation?,
      isLoadingTopics: isLoadingTopics ?? this.isLoadingTopics,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error == _sentinel ? this.error : error as String?,
    );
  }
}

const _sentinel = Object();

@riverpod
class TeachMochiViewModel extends _$TeachMochiViewModel {
  late String _avatarId;

  // ITEM 6 — measures how long the student spent explaining. Started on the
  // first non-empty keystroke for a topic, stopped on submit. The backend
  // TeachController accepts + clamps `durationSeconds`; sending a real value
  // lets it reward genuine effort instead of defaulting to zero.
  final Stopwatch _explainStopwatch = Stopwatch();

  @override
  TeachState build(String avatarId) {
    _avatarId = avatarId;
    _loadTopics();
    return const TeachState(isLoadingTopics: true);
  }

  Future<void> _loadTopics() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get<Map<String, dynamic>>(
        '/api/v1/avatars/$_avatarId/wiki/pages',
      );
      final data = (response.data?['data'] is Map
          ? response.data!['data']
          : response.data) as Map<String, dynamic>;
      final list = (data['pages'] as List?) ?? const [];
      final topics = list
          .whereType<Map<String, dynamic>>()
          .map((e) => WikiPage.fromJson(e))
          .toList();
      state = state.copyWith(topics: topics, isLoadingTopics: false);
    } on DioException catch (e) {
      appLog.w('[Teach] topic load failed: ${e.message}');
      state = state.copyWith(topics: const [], isLoadingTopics: false);
    }
  }

  void selectTopic(WikiPage topic) {
    // New topic → fresh timing.
    _explainStopwatch
      ..reset()
      ..stop();
    state = state.copyWith(
      selectedTopic: topic,
      explanation: '',
      evaluation: null,
    );
  }

  void updateExplanation(String text) {
    // Start timing on the first real keystroke; keep running on edits.
    if (text.trim().isNotEmpty && !_explainStopwatch.isRunning) {
      _explainStopwatch.start();
    }
    state = state.copyWith(explanation: text);
  }

  void clearEvaluation() {
    state = state.copyWith(evaluation: null);
  }

  void back() {
    _explainStopwatch
      ..reset()
      ..stop();
    state = state.copyWith(
      selectedTopic: null,
      explanation: '',
      evaluation: null,
    );
  }

  Future<void> submit() async {
    final topic = state.selectedTopic;
    if (topic == null ||
        topic.slug == null ||
        state.explanation.trim().isEmpty) {
      return;
    }
    state = state.copyWith(isSubmitting: true, error: null);
    // Stop timing at submit; send the real elapsed seconds (backend clamps it).
    _explainStopwatch.stop();
    final durationSeconds = _explainStopwatch.elapsed.inSeconds;
    try {
      final dio = ref.read(dioProvider);
      // Teach evaluates the student explanation via Claude — allow 90s.
      final response = await dio.post<Map<String, dynamic>>(
        '/api/v1/avatars/$_avatarId/teach',
        data: {
          'topicSlug': topic.slug,
          'explanation': state.explanation,
          'durationSeconds': durationSeconds,
        },
        options: Options(receiveTimeout: const Duration(seconds: 90)),
      );
      final data = (response.data?['data'] is Map
          ? response.data!['data']
          : response.data) as Map<String, dynamic>;
      final evaluation = TeachEvaluation.fromJson(data);
      appLog.i('[Teach] score=${evaluation.score}/${evaluation.totalConcepts} '
          'xp=${evaluation.xpEarned}');
      // New XP should reflect on progress screens.
      ref.invalidate(progressViewModelProvider);
      state = state.copyWith(
        evaluation: evaluation,
        isSubmitting: false,
      );
    } on DioException catch (e) {
      appLog.w('[Teach] submit failed: ${e.message}');
      state = state.copyWith(
        isSubmitting: false,
        error: 'Could not reach Mochi. Try again.',
      );
    }
  }
}
