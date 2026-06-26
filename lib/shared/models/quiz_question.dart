import 'package:freezed_annotation/freezed_annotation.dart';

part 'quiz_question.freezed.dart';
part 'quiz_question.g.dart';

@freezed
class QuizQuestion with _$QuizQuestion {
  const factory QuizQuestion({
    @Default('') String id,
    @Default('') String question,
    @Default([]) List<String> options,
    // Nullable BY CONTRACT: the backend WITHHOLDS the answer key for
    // teacher-graded (centre) quizzes — `correctIndex` is null then, and the
    // correct answer is revealed only post-submit (QuizResult.feedback). A
    // `@Default(0)` here would collapse "withheld" into "index 0" and make the
    // UI confidently highlight option A as correct — the exact bug this
    // nullability prevents. Non-null = B2C daily quiz (instant feedback OK).
    int? correctIndex,
    @Default('') String sourcePage,
    @Default('') String explanation,
  }) = _QuizQuestion;

  factory QuizQuestion.fromJson(Map<String, dynamic> json) =>
      _$QuizQuestionFromJson(json);
}
