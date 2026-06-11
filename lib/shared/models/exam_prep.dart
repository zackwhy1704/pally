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
  }) = _ExamConceptMastery;

  factory ExamConceptMastery.fromJson(Map<String, dynamic> json) =>
      _$ExamConceptMasteryFromJson(json);
}
