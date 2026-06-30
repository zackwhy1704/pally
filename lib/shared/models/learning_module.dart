import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'learning_module.freezed.dart';
part 'learning_module.g.dart';

/// The backend stores `content_json` / `answer_json` as serialized JSON *strings*
/// (entity columns are `String`). The `/start` and `/revision` endpoints emit
/// them as strings, while `/{moduleId}` (detail) does too — so the mobile model
/// must accept EITHER a decoded `Map` OR a JSON string and decode it. Without
/// this, the generated parser hard-casts a `String` to `Map` and throws, which
/// empties the item list and surfaces "Something went wrong loading this lesson".
/// We deliberately do NOT change the wire format (the web content-review panel
/// depends on the string form).
Map<String, dynamic> _contentJsonFromJson(Object? value) {
  final decoded = _decodeMapOrNull(value);
  return decoded ?? <String, dynamic>{};
}

Map<String, dynamic>? _answerJsonFromJson(Object? value) =>
    _decodeMapOrNull(value);

Map<String, dynamic>? _decodeMapOrNull(Object? value) {
  if (value == null) return null;
  if (value is Map) return Map<String, dynamic>.from(value);
  if (value is String) {
    if (value.trim().isEmpty) return null;
    try {
      final parsed = jsonDecode(value);
      if (parsed is Map) return Map<String, dynamic>.from(parsed);
    } catch (_) {
      // Not valid JSON — fall through to null so the item degrades gracefully
      // instead of throwing and dropping the whole lesson.
    }
  }
  return null;
}

@freezed
class LearningModule with _$LearningModule {
  const factory LearningModule({
    required String id,
    required String title,
    @Default('') String wikiSlug,
    @Default('LEARN') String stage,
    @Default(0) double masteryPct,
    @Default({}) Map<String, int> itemCounts,
    /// C3 — true when a teacher has reviewed/approved this centre content.
    @Default(false) bool teacherReviewed,
  }) = _LearningModule;

  factory LearningModule.fromJson(Map<String, dynamic> json) =>
      _$LearningModuleFromJson(json);
}

@freezed
class ModuleContentItem with _$ModuleContentItem {
  const factory ModuleContentItem({
    required String id,
    // The per-item stage is informational on mobile (rendering keys off the
    // response-level stage), so default it for resilience if a server omits it.
    @Default('LEARN') String stage,
    required String type,
    @JsonKey(fromJson: _contentJsonFromJson)
    required Map<String, dynamic> contentJson,
    @JsonKey(fromJson: _answerJsonFromJson) Map<String, dynamic>? answerJson,
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
