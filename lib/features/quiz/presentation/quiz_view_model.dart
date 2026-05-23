import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/app/api_client.dart';
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
    } on DioException catch (_) {
      state = state.copyWith(questions: _stubQuestions, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void answerQuestion(int answerIndex) {
    if (state.isAnswered) return;
    final question = state.currentQuestion;
    if (question == null) return;

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
      await dio.post(
        '/api/v1/avatars/$_avatarId/quiz/answers',
        data: {
          'score': state.score,
          'total': state.totalQuestions,
          'xpEarned': state.xpEarned,
        },
      );
    } catch (_) {
      // Ignore submission errors — still show completion
    }
    state = state.copyWith(isSubmitting: false, isComplete: true);
  }

  Future<void> restart() async {
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
