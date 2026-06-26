import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/error/pally_error.dart';

import 'package:pally/core/observability/observability_providers.dart';
import 'package:pally/core/utils/logger.dart';
import 'package:pally/features/progress/presentation/progress_view_model.dart';
import 'package:pally/shared/models/quiz_question.dart';

part 'quiz_view_model.g.dart';

enum Confidence { low, medium, high }

@immutable
class MasteryMatrix {
  const MasteryMatrix({
    this.mastered = const [],
    this.misconception = const [],
    this.luckyGuess = const [],
    this.knownGap = const [],
    this.priorityReview,
  });
  final List<String> mastered;
  final List<String> misconception;
  final List<String> luckyGuess;
  final List<String> knownGap;
  final String? priorityReview;

  bool get hasAny =>
      mastered.isNotEmpty ||
      misconception.isNotEmpty ||
      luckyGuess.isNotEmpty ||
      knownGap.isNotEmpty;
}

/// Per-question outcome returned POST-submit. For a teacher-graded (centre)
/// quiz this is the ONLY place [correctIndex] and [explanation] appear — they're
/// withheld from the served question by design, revealed here after submitting.
@immutable
class QuizFeedback {
  const QuizFeedback({
    required this.questionId,
    required this.wasCorrect,
    this.correctIndex,
    this.explanation,
  });
  final String questionId;
  final bool wasCorrect;
  final int? correctIndex;
  final String? explanation;
}

@immutable
class QuizState {
  const QuizState({
    this.questions = const [],
    this.currentIndex = 0,
    this.selectedAnswer,
    this.selectedConfidence,
    this.confidenceMode = true,
    this.isAnswered = false,
    this.score = 0,
    this.xpEarned = 0,
    this.isLoading = false,
    this.isSubmitting = false,
    this.isComplete = false,
    this.levelledUp = false,
    this.newLevel = 0,
    this.masteryMatrix,
    this.feedback = const [],
    this.error,
  });

  final List<QuizQuestion> questions;
  final int currentIndex;
  final int? selectedAnswer;
  final Confidence? selectedConfidence;
  final bool confidenceMode;
  final bool isAnswered;
  final int score;
  final int xpEarned;
  final bool isLoading;
  final bool isSubmitting;
  final bool isComplete;
  final bool levelledUp;
  final int newLevel;
  final MasteryMatrix? masteryMatrix;
  final List<QuizFeedback> feedback;
  final PallyError? error;

  /// True when the student can lock in their answer this turn — they must
  /// have picked an answer AND (if confidenceMode is on) a confidence rating.
  bool get canAnswer => confidenceMode ? selectedConfidence != null : true;

  QuizQuestion? get currentQuestion =>
      questions.isEmpty ? null : questions[currentIndex];

  int get totalQuestions => questions.length;
  bool get isLastQuestion => currentIndex >= totalQuestions - 1;

  QuizState copyWith({
    List<QuizQuestion>? questions,
    int? currentIndex,
    Object? selectedAnswer = _sentinel,
    Object? selectedConfidence = _sentinel,
    bool? confidenceMode,
    bool? isAnswered,
    int? score,
    int? xpEarned,
    bool? isLoading,
    bool? isSubmitting,
    bool? isComplete,
    bool? levelledUp,
    int? newLevel,
    Object? masteryMatrix = _sentinel,
    List<QuizFeedback>? feedback,
    Object? error = _sentinel,
  }) {
    return QuizState(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      selectedAnswer: selectedAnswer == _sentinel
          ? this.selectedAnswer
          : selectedAnswer as int?,
      selectedConfidence: selectedConfidence == _sentinel
          ? this.selectedConfidence
          : selectedConfidence as Confidence?,
      confidenceMode: confidenceMode ?? this.confidenceMode,
      isAnswered: isAnswered ?? this.isAnswered,
      score: score ?? this.score,
      xpEarned: xpEarned ?? this.xpEarned,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isComplete: isComplete ?? this.isComplete,
      levelledUp: levelledUp ?? this.levelledUp,
      newLevel: newLevel ?? this.newLevel,
      masteryMatrix: masteryMatrix == _sentinel
          ? this.masteryMatrix
          : masteryMatrix as MasteryMatrix?,
      feedback: feedback ?? this.feedback,
      error: error == _sentinel ? this.error : error as PallyError?,
    );
  }
}

const _sentinel = Object();

@riverpod
class QuizViewModel extends _$QuizViewModel {
  late String _avatarId;

  /// Wall-clock the child started working the quiz — set the moment questions
  /// render, read again at submit to report real active study time. Server
  /// also clamps, but we cap client-side too (see [_durationSeconds]).
  DateTime? _startedAt;

  /// Upper bound on a single quiz session's reported duration. A 1-hour cap
  /// stops a backgrounded/forgotten quiz from inflating study minutes.
  static const int _maxQuizSeconds = 3600;

  int get _durationSeconds {
    final started = _startedAt;
    if (started == null) return 0;
    final elapsed = DateTime.now().difference(started).inSeconds;
    return elapsed.clamp(0, _maxQuizSeconds);
  }

  @override
  QuizState build(String avatarId) {
    _avatarId = avatarId;
    _loadQuestions();
    return const QuizState(isLoading: true);
  }

  Future<void> _loadQuestions() async {
    final span = ref.read(perfMonitorProvider).startSpan('ai.quiz.daily',
        operation: 'ai', description: 'GET /quiz/daily');
    span.setTag('route', 'quiz.daily');
    try {
      final dio = ref.read(dioProvider);
      // /quiz/daily returns ApiResponse<List<QuizQuestionResponse>> — after
      // _ApiResponseInterceptor strips the envelope, response.data is a bare
      // List. Typing the call <Map> would crash at Dio's transport layer
      // before parsing. Use <dynamic> and branch on the runtime shape.
      // Quiz generation (Haiku + 1200 tokens) typically takes 3-8s but can
      // spike to 30s under Anthropic load. The global 90s Dio receiveTimeout
      // covers this, but we document it explicitly here so it's obvious why
      // this call tolerates a longer wait than normal CRUD endpoints.
      final response = await dio.get<dynamic>(
        '/api/v1/avatars/$_avatarId/quiz/daily',
        options: Options(receiveTimeout: const Duration(seconds: 90)),
      );
      final data = response.data;
      final List<dynamic> list = data is List
          ? data
          : (data is Map && data['questions'] is List
              ? data['questions'] as List<dynamic>
              : const <dynamic>[]);
      final questions = list
          .map(
              (e) => QuizQuestion.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      state = state.copyWith(questions: questions, isLoading: false);
      // Start the active-time clock once the child can actually see questions.
      if (questions.isNotEmpty) _startedAt = DateTime.now();
      span.setData('questions_count', questions.length);
      span.finish(statusCode: 200);
    } on DioException catch (e) {
      // 404 = "no quiz yet" (genuinely empty); everything else routes
      // through PallyError so the UI gets a uniform message + retry.
      if (e.response?.statusCode == 404) {
        state = state.copyWith(questions: const [], isLoading: false);
        span.finish(statusCode: 404);
        return;
      }
      state = state.copyWith(isLoading: false, error: PallyError.from(e));
      span.finish(statusCode: e.response?.statusCode ?? 500);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: PallyError.from(e));
      span.finish(statusCode: 500);
    }
  }

  // Captures answers as questionId -> selectedIndex for the backend submission.
  final Map<String, int> _answers = {};
  // Captures questionId -> correctIndex so the backend can score authoritatively.
  final Map<String, int> _correctMap = {};
  // Captures questionId -> topic slug so the backend can group weak topics.
  final Map<String, String> _topicMap = {};
  // Captures questionId -> LOW/MEDIUM/HIGH for the mastery matrix.
  final Map<String, String> _confidenceMap = {};

  void setConfidence(Confidence c) {
    if (state.isAnswered) return;
    state = state.copyWith(selectedConfidence: c);
  }

  void toggleConfidenceMode(bool enabled) {
    state = state.copyWith(
      confidenceMode: enabled,
      selectedConfidence: null,
    );
  }

  void answerQuestion(int answerIndex) {
    if (state.isAnswered) return;
    final question = state.currentQuestion;
    if (question == null) return;
    // Confidence mode forces the student to pick a rating before locking in
    // their answer — that's the whole point of the metacognitive check.
    if (state.confidenceMode && state.selectedConfidence == null) return;

    final correctIndex = question.correctIndex; // null = key withheld (centre)
    _answers[question.id] = answerIndex;
    // Only send a client key when we have one. The server now grades from its
    // own persisted key and ignores this map, but keep it for B2C/legacy. Never
    // fabricate a 0 for a withheld key.
    if (correctIndex != null) {
      _correctMap[question.id] = correctIndex;
    }
    if (question.sourcePage.isNotEmpty) {
      _topicMap[question.id] = question.sourcePage;
    }
    if (state.confidenceMode && state.selectedConfidence != null) {
      _confidenceMap[question.id] =
          state.selectedConfidence!.name.toUpperCase();
    }

    // Local instant scoring ONLY when the key is known (B2C daily quiz). For a
    // teacher-graded quiz the key is withheld, so we can't know correctness
    // here — the server is authoritative and fills score/XP in post-submit.
    final knownCorrect =
        correctIndex == null ? null : answerIndex == correctIndex;
    state = state.copyWith(
      selectedAnswer: answerIndex,
      isAnswered: true,
      score: knownCorrect == true ? state.score + 1 : state.score,
      xpEarned: knownCorrect == true ? state.xpEarned + 20 : state.xpEarned,
    );
  }

  void nextQuestion() {
    if (state.isLastQuestion) {
      _submitAnswers();
      return;
    }
    state = state.copyWith(
      currentIndex: state.currentIndex + 1,
      selectedAnswer: null,
      selectedConfidence: null,
      isAnswered: false,
    );
  }

  Future<void> _submitAnswers() async {
    state = state.copyWith(isSubmitting: true);
    final span = ref.read(perfMonitorProvider).startSpan('ai.quiz.submit',
        operation: 'ai', description: 'POST /quiz/answers');
    span.setTag('route', 'quiz.submit');
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post<Map<String, dynamic>>(
        '/api/v1/avatars/$_avatarId/quiz/answers',
        data: {
          'answers': _answers,
          'correctMap': _correctMap,
          'topicMap': _topicMap,
          if (_confidenceMap.isNotEmpty) 'confidenceMap': _confidenceMap,
          // Real active time spent on the quiz (clamped client-side; backend
          // clamps again). Feeds the daily-minutes study metric.
          'durationSeconds': _durationSeconds,
        },
      );

      // Backend returns the authoritative XP/stars earned. Trust the backend
      // value over the local client estimate. Some wrappers nest under "data".
      final body = response.data ?? const <String, dynamic>{};
      final data =
          (body['data'] is Map ? body['data'] : body) as Map<String, dynamic>;
      final backendXp = (data['xpEarned'] as num?)?.toInt() ?? state.xpEarned;
      // Server score is authoritative — and the ONLY score we have for a
      // teacher-graded quiz, whose key was withheld so we couldn't grade
      // locally. Falls back to the local estimate for legacy responses.
      final backendScore = (data['score'] as num?)?.toInt() ?? state.score;
      final levelledUp = data['levelledUp'] == true;
      final newLevel = (data['newLevel'] as num?)?.toInt() ?? 0;
      final matrixJson = data['masteryMatrix'] as Map<String, dynamic>?;
      final matrix = matrixJson == null
          ? null
          : MasteryMatrix(
              mastered: _asStringList(matrixJson['mastered']),
              misconception: _asStringList(matrixJson['misconception']),
              luckyGuess: _asStringList(matrixJson['luckyGuess']),
              knownGap: _asStringList(matrixJson['knownGap']),
              priorityReview: matrixJson['priorityReview'] as String?,
            );

      // Post-submit feedback — the ONLY place a teacher-graded quiz reveals the
      // correct answer + explanation (both withheld from the served question).
      final feedback = (data['feedback'] as List?)
              ?.whereType<Map>()
              .map((f) => QuizFeedback(
                    questionId: (f['questionId'] ?? '').toString(),
                    wasCorrect: f['wasCorrect'] == true,
                    correctIndex: (f['correctIndex'] as num?)?.toInt(),
                    explanation: f['explanation'] as String?,
                  ))
              .toList() ??
          const <QuizFeedback>[];

      appLog.i(
          '[Quiz] submitted answers=${_answers.length} correct=${state.score} '
          'backendXp=$backendXp levelledUp=$levelledUp newLevel=$newLevel '
          'matrix=${matrix?.hasAny ?? false}');

      // Make the home/progress screen pick up the new XP on next view.
      ref.invalidate(progressViewModelProvider);

      state = state.copyWith(
        score: backendScore,
        xpEarned: backendXp,
        levelledUp: levelledUp,
        newLevel: newLevel,
        masteryMatrix: matrix,
        feedback: feedback,
      );
      span.setData('xp_earned', backendXp);
      span.finish(statusCode: 200);
    } catch (e, st) {
      span.finish(statusCode: 500);
      appLog.w('[Quiz] submit failed — XP shown is local estimate only',
          error: e, stackTrace: st);
    }
    state = state.copyWith(isSubmitting: false, isComplete: true);
  }

  Future<void> restart() async {
    _answers.clear();
    _correctMap.clear();
    _topicMap.clear();
    _confidenceMap.clear();
    state = const QuizState(isLoading: true);
    await _loadQuestions();
  }

  List<String> _asStringList(Object? v) =>
      v is List ? v.whereType<String>().toList() : const <String>[];
}
