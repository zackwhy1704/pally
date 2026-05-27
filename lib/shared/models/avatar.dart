import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pally/shared/models/mochi_character.dart';

part 'avatar.freezed.dart';
part 'avatar.g.dart';

// ── JSON converters ──────────────────────────────────────────────────────────

MochiCharacter _characterFromJson(Object? json) =>
    MochiCharacter.fromJson(json as String? ?? 'PENCIL');

String _characterToJson(MochiCharacter c) => c.jsonValue;

String _subjectFromJson(Object? json) {
  final s = (json as String?) ?? '';
  switch (s.toUpperCase()) {
    case 'MATHS':
      return 'Maths';
    case 'SCIENCE':
      return 'Science';
    case 'ENGLISH':
      return 'English';
    case 'HISTORY':
      return 'History';
    case 'CODING':
      return 'Coding';
    case 'ART':
      return 'Art';
    case 'GEOGRAPHY':
      return 'Geography';
    case 'LANGUAGES':
      return 'Languages';
    case 'MUSIC':
      return 'Music';
    default:
      return s;
  }
}

String _subjectToJson(String s) => s.toUpperCase().replaceAll(' ', '_');

bool _hasKnowledgeFromJson(Object? count) => ((count as int?) ?? 0) > 0;

// ── Pedagogy mode ─────────────────────────────────────────────────────────────

enum PedagogyMode { socratic }

PedagogyMode _pedagogyFromJson(Object? v) => PedagogyMode.socratic;

String _pedagogyToJson(PedagogyMode m) => 'SOCRATIC';

// ── Models ───────────────────────────────────────────────────────────────────

@freezed
class Avatar with _$Avatar {
  const factory Avatar({
    required String id,
    required String name,
    @JsonKey(
        name: 'characterType',
        fromJson: _characterFromJson,
        toJson: _characterToJson)
    required MochiCharacter character,
    @JsonKey(fromJson: _subjectFromJson, toJson: _subjectToJson)
    required String subject,
    @JsonKey(name: 'wikiPageCount', fromJson: _hasKnowledgeFromJson)
    @Default(false)
    bool hasKnowledge,
    @Default(0) int fileCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    @JsonKey(fromJson: _pedagogyFromJson, toJson: _pedagogyToJson)
    @Default(PedagogyMode.socratic)
    PedagogyMode pedagogyMode,
    String? gradeLevel,
    String? curriculumType,
  }) = _Avatar;

  factory Avatar.fromJson(Map<String, dynamic> json) => _$AvatarFromJson(json);
}

@freezed
class CreateAvatarRequest with _$CreateAvatarRequest {
  const factory CreateAvatarRequest({
    required String name,
    @JsonKey(
        name: 'characterType',
        fromJson: _characterFromJson,
        toJson: _characterToJson)
    required MochiCharacter character,
    @JsonKey(toJson: _subjectToJson, fromJson: _subjectFromJson)
    required String subject,
    String? gradeLevel,
    String? curriculumType,
  }) = _CreateAvatarRequest;

  factory CreateAvatarRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateAvatarRequestFromJson(json);
}
