import 'package:freezed_annotation/freezed_annotation.dart';

part 'study_plan_item.freezed.dart';
part 'study_plan_item.g.dart';

enum StudyPlanItemType { quiz, flashcard, reading, practice }

StudyPlanItemType _typeFromJson(Object? json) {
  final s = (json as String? ?? '').toUpperCase();
  return StudyPlanItemType.values.firstWhere(
    (e) => e.name.toUpperCase() == s,
    orElse: () => StudyPlanItemType.practice,
  );
}

String _typeToJson(StudyPlanItemType t) => t.name.toUpperCase();

@freezed
class StudyPlanItem with _$StudyPlanItem {
  const factory StudyPlanItem({
    required String id,
    required String title,
    @JsonKey(fromJson: _typeFromJson, toJson: _typeToJson)
    required StudyPlanItemType type,
    @Default(false) bool isDone,
    @Default('') String avatarId,
    DateTime? scheduledDate,
  }) = _StudyPlanItem;

  factory StudyPlanItem.fromJson(Map<String, dynamic> json) =>
      _$StudyPlanItemFromJson(json);
}
