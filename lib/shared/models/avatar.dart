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
    // Title-case the remaining backend enums so they don't leak as raw
    // SHOUTING_CASE strings (the "PHYSICAL EDUCATION" bug).
    case 'PHYSICAL_EDUCATION':
      return 'Physical Education';
    case 'HEALTH':
      return 'Health';
    case 'LITERATURE':
      return 'Literature';
    case 'GENERAL':
      return 'General';
    default:
      // Defensive fallback for any future enum: lower-case then capitalise
      // each word so the UI never shows raw SHOUTING_CASE.
      return s
          .toLowerCase()
          .replaceAll('_', ' ')
          .split(' ')
          .where((w) => w.isNotEmpty)
          .map((w) => w[0].toUpperCase() + w.substring(1))
          .join(' ');
  }
}

String _subjectToJson(String s) => s.toUpperCase().replaceAll(' ', '_');

int _wikiPageCountFromJson(Object? count) => (count as int?) ?? 0;

// ── Pedagogy mode ─────────────────────────────────────────────────────────────

enum PedagogyMode { socratic }

PedagogyMode _pedagogyFromJson(Object? v) => PedagogyMode.socratic;

String _pedagogyToJson(PedagogyMode m) => 'SOCRATIC';

// ── Models ───────────────────────────────────────────────────────────────────

DateTime? _testDateFromJson(Object? v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  if (v is String && v.isNotEmpty) {
    try {
      return DateTime.parse(v);
    } catch (_) {
      return null;
    }
  }
  return null;
}

String? _testDateToJson(DateTime? d) =>
    d == null ? null : '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';

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
    @JsonKey(name: 'wikiPageCount', fromJson: _wikiPageCountFromJson)
    @Default(0)
    int wikiPageCount,
    @Default(0) int fileCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    @JsonKey(fromJson: _pedagogyFromJson, toJson: _pedagogyToJson)
    @Default(PedagogyMode.socratic)
    PedagogyMode pedagogyMode,
    String? gradeLevel,
    String? curriculumType,
    @JsonKey(fromJson: _testDateFromJson, toJson: _testDateToJson)
    DateTime? testDate,
    /// Brain compilation state: READY | PENDING_RECOMPILE | COMPILING
    @Default('READY') String brainState,
    /// False when this avatar is outside the user's active slot cap.
    /// Inactive avatars are visible but chat/quiz are blocked.
    @Default(true) bool isActive,
  }) = _Avatar;

  factory Avatar.fromJson(Map<String, dynamic> json) => _$AvatarFromJson(json);
}

extension AvatarKnowledge on Avatar {
  bool get hasKnowledge => wikiPageCount > 0;
  /// True while the brain is being compiled (debounced or in-flight).
  bool get isBrainCompiling => brainState != 'READY';
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
