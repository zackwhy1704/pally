import 'package:freezed_annotation/freezed_annotation.dart';

part 'photo_question.freezed.dart';
part 'photo_question.g.dart';

enum HomeworkScanStatus {
  pending,
  ocrProcessing,
  claudeProcessing,
  complete,
  error
}

@freezed
class PhotoQuestion with _$PhotoQuestion {
  const factory PhotoQuestion({
    @Default('') String id,
    @Default('') String rawText,
    @Default(0) int questionIndex,
    @Default(true) bool isSelected,
  }) = _PhotoQuestion;

  factory PhotoQuestion.fromJson(Map<String, dynamic> json) =>
      _$PhotoQuestionFromJson(json);
}

@freezed
class QuestionAnswer with _$QuestionAnswer {
  const factory QuestionAnswer({
    @Default('') String questionId,
    @Default('') String questionText,
    @Default('') String answer,
    @Default([]) List<String> steps,
    @Default('') String explanation,
    // Tier 0/2 fields from the backend visual classifier
    @Default('NONE') String visualType,
    @Default(false) bool calculatorVerified,
  }) = _QuestionAnswer;

  factory QuestionAnswer.fromJson(Map<String, dynamic> json) =>
      _$QuestionAnswerFromJson(json);
}

@freezed
class HomeworkScanResult with _$HomeworkScanResult {
  const factory HomeworkScanResult({
    @Default('') String messageId,
    @Default('') String imageLocalPath,
    @Default([]) List<PhotoQuestion> questions,
    @Default([]) List<QuestionAnswer> answers,
    @Default(5) int xpEarned,
    String? sourceWikiPage,
    @Default(HomeworkScanStatus.complete) HomeworkScanStatus status,
  }) = _HomeworkScanResult;

  factory HomeworkScanResult.fromJson(Map<String, dynamic> json) =>
      _$HomeworkScanResultFromJson(json);
}
