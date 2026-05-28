import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/utils/logger.dart';
import 'package:pally/features/progress/presentation/progress_view_model.dart';
import 'package:pally/shared/models/quiz_question.dart';

part 'quiz_view_model.g.dart';

@immutable
class QuizState {
  const QuizState({
    this.questions = const [],
    this.currentIndex = 0,
    this.selectedAnswer,
    this.isAnswered = false,
    this.score = 0,
    this.xpEarned = 0,
    this.isLoading = false,
    this.isSubmitting = false,
    this.isComplete = false,
    this.levelledUp = false,
    this.newLevel = 0,
    this.error,
  });

  final List<QuizQuestion> questions;
  final int currentIndex;
  final int? selectedAnswer;
  final bool isAnswered;
  final int score;
  final int xpEarned;
  final bool isLoading;
  final bool isSubmitting;
  final bool isComplete;
  final bool levelledUp;
  final int newLevel;
  final String? error;

  QuizQuestion? get currentQuestion =>
      questions.isEmpty ? null : questions[currentIndex];

  int get totalQuestions => questions.length;
  bool get isLastQuestion => currentIndex >= totalQuestions - 1;

  QuizState copyWith({
    List<QuizQuestion>? questions,
    int? currentIndex,
    Object? selectedAnswer = _sentinel,
    bool? isAnswered,
    int? score,
    int? xpEarned,
    bool? isLoading,
    bool? isSubmitting,
    bool? isComplete,
    bool? levelledUp,
    int? newLevel,
    Object? error = _sentinel,
  }) {
    return QuizState(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      selectedAnswer: selectedAnswer == _sentinel
          ? this.selectedAnswer
          : selectedAnswer as int?,
      isAnswered: isAnswered ?? this.isAnswered,
      score: score ?? this.score,
      xpEarned: xpEarned ?? this.xpEarned,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isComplete: isComplete ?? this.isComplete,
      levelledUp: levelledUp ?? this.levelledUp,
      newLevel: newLevel ?? this.newLevel,
      error: error == _sentinel ? this.error : error as String?,
    );
  }
}

const _sentinel = Object();

@riverpod
class QuizViewModel extends _$QuizViewModel {
  late String _avatarId;

  @override
  QuizState build(String avatarId) {
    _avatarId = avatarId;
    _loadQuestions();
    return const QuizState(isLoading: true);
  }

  Future<void> _loadQuestions() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio
          .get<Map<String, dynamic>>('/api/v1/avatars/$_avatarId/quiz/daily');
      final list = (response.data?['questions'] as List<dynamic>?) ??
          (response.data is List ? response.data as List<dynamic> : []);
      final questions = list
          .map((e) => QuizQuestion.fromJson(e as Map<String, dynamic>))
          .toList();
      state = state.copyWith(questions: questions, isLoading: false);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404 || e.response?.statusCode == 500) {
        state = state.copyWith(questions: [], isLoading: false);
        return;
      }
      state = state.copyWith(questions: _stubQuestions, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Captures answers as questionId -> selectedIndex for the backend submission.
  final Map<String, int> _answers = {};
  // Captures questionId -> correctIndex so the backend can score authoritatively.
  final Map<String, int> _correctMap = {};
  // Captures questionId -> topic slug so the backend can group weak topics.
  final Map<String, String> _topicMap = {};

  void answerQuestion(int answerIndex) {
    if (state.isAnswered) return;
    final question = state.currentQuestion;
    if (question == null) return;

    _answers[question.id] = answerIndex;
    _correctMap[question.id] = question.correctIndex;
    if (question.sourcePage.isNotEmpty) {
      _topicMap[question.id] = question.sourcePage;
    }

    final isCorrect = answerIndex == question.correctIndex;
    state = state.copyWith(
      selectedAnswer: answerIndex,
      isAnswered: true,
      score: isCorrect ? state.score + 1 : state.score,
      xpEarned: isCorrect ? state.xpEarned + 20 : state.xpEarned,
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
      isAnswered: false,
    );
  }

  Future<void> _submitAnswers() async {
    state = state.copyWith(isSubmitting: true);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post<Map<String, dynamic>>(
        '/api/v1/avatars/$_avatarId/quiz/answers',
        data: {
          'answers': _answers,
          'correctMap': _correctMap,
          'topicMap': _topicMap,
        },
      );

      // Backend returns the authoritative XP/stars earned. Trust the backend
      // value over the local client estimate. Some wrappers nest under "data".
      final body = response.data ?? const <String, dynamic>{};
      final data = (body['data'] is Map ? body['data'] : body)
          as Map<String, dynamic>;
      final backendXp = (data['xpEarned'] as num?)?.toInt() ?? state.xpEarned;
      final levelledUp = data['levelledUp'] == true;
      final newLevel = (data['newLevel'] as num?)?.toInt() ?? 0;
      appLog.i('[Quiz] submitted answers=${_answers.length} correct=${state.score} '
          'backendXp=$backendXp levelledUp=$levelledUp newLevel=$newLevel');

      // Make the home/progress screen pick up the new XP on next view.
      ref.invalidate(progressViewModelProvider);

      state = state.copyWith(
        xpEarned: backendXp,
        levelledUp: levelledUp,
        newLevel: newLevel,
      );
    } catch (e, st) {
      appLog.w('[Quiz] submit failed — XP shown is local estimate only',
          error: e, stackTrace: st);
    }
    state = state.copyWith(isSubmitting: false, isComplete: true);
  }

  Future<void> restart() async {
    _answers.clear();
    _correctMap.clear();
    _topicMap.clear();
    state = const QuizState(isLoading: true);
    await _loadQuestions();
  }
}

const _stubQuestions = [
  QuizQuestion(
    id: 'q1',
    question: 'What process do plants use to make food from sunlight?',
    options: [
      'Respiration',
      'Photosynthesis',
      'Digestion',
      'Transpiration',
    ],
    correctIndex: 1,
    sourcePage: 'photosynthesis',
    explanation:
        'Photosynthesis is the process by which plants use sunlight, water and carbon dioxide to produce oxygen and energy in the form of sugar.',
  ),
  QuizQuestion(
    id: 'q2',
    question: 'What is the basic unit of life?',
    options: ['Atom', 'Molecule', 'Cell', 'Organ'],
    correctIndex: 2,
    sourcePage: 'cell-structure',
    explanation:
        'The cell is the basic structural and functional unit of all living organisms.',
  ),
  QuizQuestion(
    id: 'q3',
    question: 'Which gas do plants absorb during photosynthesis?',
    options: ['Oxygen', 'Nitrogen', 'Carbon Dioxide', 'Hydrogen'],
    correctIndex: 2,
    sourcePage: 'photosynthesis',
    explanation:
        'Plants absorb carbon dioxide (CO₂) from the air and convert it into glucose using energy from sunlight.',
  ),
];
