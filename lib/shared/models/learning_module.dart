import 'package:freezed_annotation/freezed_annotation.dart';

part 'learning_module.freezed.dart';
part 'learning_module.g.dart';

@freezed
class LearningModule with _$LearningModule {
  const factory LearningModule({
    required String id,
    required String title,
    @Default('') String wikiSlug,
    @Default('LEARN') String stage,
    @Default(0) double masteryPct,
    @Default({}) Map<String, int> itemCounts,
  }) = _LearningModule;

  factory LearningModule.fromJson(Map<String, dynamic> json) =>
      _$LearningModuleFromJson(json);
}

@freezed
class ModuleContentItem with _$ModuleContentItem {
  const factory ModuleContentItem({
    required String id,
    required String stage,
    required String type,
    required Map<String, dynamic> contentJson,
    Map<String, dynamic>? answerJson,
    @Default(0) int sortOrder,
  }) = _ModuleContentItem;

  factory ModuleContentItem.fromJson(Map<String, dynamic> json) =>
      _$ModuleContentItemFromJson(json);
}

@freezed
class ModuleResults with _$ModuleResults {
  const factory ModuleResults({
    @Default([]) List<ConceptMastery> concepts,
    @Default(0) int xpEarned,
  }) = _ModuleResults;

  factory ModuleResults.fromJson(Map<String, dynamic> json) =>
      _$ModuleResultsFromJson(json);
}

@freezed
class ConceptMastery with _$ConceptMastery {
  const factory ConceptMastery({
    @Default('') String concept,
    @Default(0) double mastery,
    @Default('') String feedback,
    @Default(false) bool passed,
  }) = _ConceptMastery;

  factory ConceptMastery.fromJson(Map<String, dynamic> json) =>
      _$ConceptMasteryFromJson(json);
}
