import 'package:freezed_annotation/freezed_annotation.dart';

part 'exam_prep.freezed.dart';
part 'exam_prep.g.dart';

@freezed
class ExamPrep with _$ExamPrep {
  const factory ExamPrep({
    String? testDate,
    int? daysRemaining,
    @Default([]) List<ExamConceptMastery> concepts,
    @Default([]) List<String> recommendedOrder,
    @Default(2) int dailyTarget,
  }) = _ExamPrep;

  factory ExamPrep.fromJson(Map<String, dynamic> json) =>
      _$ExamPrepFromJson(json);
}

@freezed
class ExamConceptMastery with _$ExamConceptMastery {
  const factory ExamConceptMastery({
    @Default('') String concept,
    @Default(0) double mastery,
    String? moduleId,
    String? moduleTitle,
    // Trust class of the mastery signal (backend GradingSignal.name()): only
    // 'SELF_REPORT' concepts carry a self-assessed (trust-weighted) %, so the UI
    // labels them "self-assessed" instead of implying a graded score.
    String? signalType,
  }) = _ExamConceptMastery;

  factory ExamConceptMastery.fromJson(Map<String, dynamic> json) =>
      _$ExamConceptMasteryFromJson(json);
}
