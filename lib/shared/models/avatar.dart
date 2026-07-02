import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pally/shared/models/mochi_character.dart';
import 'package:pally/shared/models/mochi_config.dart';

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

/// The subject enum the backend accepts. The UI subject field is free-text
/// (and some quick-picks like "PE" differ from the enum), so any value outside
/// this set must be mapped or it triggers a 400 (e.g. "Accounting" → ACCOUNTING).
const _backendSubjects = {
  'PHYSICAL_EDUCATION', 'ART', 'SCIENCE', 'MUSIC', 'GENERAL', 'CODING',
  'MATHS', 'ENGLISH', 'LITERATURE', 'LANGUAGES', 'HISTORY', 'HEALTH',
  'GEOGRAPHY',
};

/// Common UI labels that don't match the backend enum spelling.
const _subjectAliases = {
  'PE': 'PHYSICAL_EDUCATION',
  'PHYS_ED': 'PHYSICAL_EDUCATION',
  'PHYSICAL_ED': 'PHYSICAL_EDUCATION',
  'MATH': 'MATHS',
  'MATHEMATICS': 'MATHS',
  'GEOG': 'GEOGRAPHY',
  'LIT': 'LITERATURE',
  'LANGUAGE': 'LANGUAGES',
};

String _subjectToJson(String s) {
  final norm = s.trim().toUpperCase().replaceAll(' ', '_');
  final mapped = _subjectAliases[norm] ?? norm;
  // Free-text subjects the backend can't model fall back to the GENERAL
  // catch-all so avatar creation never 400s on an unknown subject.
  return _backendSubjects.contains(mapped) ? mapped : 'GENERAL';
}

/// Public accessor for the canonical free-text → backend subject-enum mapping,
/// so callers (e.g. the weakness endpoint) send a value the backend accepts.
String toBackendSubject(String uiSubject) => _subjectToJson(uiSubject);

int _wikiPageCountFromJson(Object? count) => (count as int?) ?? 0;

// ── Pedagogy mode ─────────────────────────────────────────────────────────────

enum PedagogyMode { socratic }

PedagogyMode _pedagogyFromJson(Object? v) => PedagogyMode.socratic;

String _pedagogyToJson(PedagogyMode m) => 'SOCRATIC';

// ── Avatar kind ───────────────────────────────────────────────────────────────

/// Distinguishes a child's own collectible tutor (PERSONAL) from a
/// centre-provisioned class avatar (CENTRE_CLASS). Class avatars render as a
/// parameterised "uniform" Mochi and must never appear in the create-tutor
/// picker, shop, or collection.
enum AvatarKind { personal, centreClass }

/// Defensive parse: any unknown/missing value falls back to [personal] per the
/// network null-tolerance rules (CLAUDE.md PART 16).
AvatarKind _kindFromJson(Object? v) {
  final s = (v as String?)?.toUpperCase() ?? '';
  switch (s) {
    case 'CENTRE_CLASS':
    case 'CENTER_CLASS':
      return AvatarKind.centreClass;
    case 'PERSONAL':
    default:
      return AvatarKind.personal;
  }
}

String _kindToJson(AvatarKind k) =>
    k == AvatarKind.centreClass ? 'CENTRE_CLASS' : 'PERSONAL';

ClassAppearance? _appearanceFromJson(Object? v) {
  if (v is Map<String, dynamic>) return ClassAppearance.fromJson(v);
  if (v is Map) return ClassAppearance.fromJson(Map<String, dynamic>.from(v));
  return null;
}

Map<String, dynamic>? _appearanceToJson(ClassAppearance? a) => a?.toJson();

/// Parse the centre-designed Mochi look. Present only on CENTRE_CLASS
/// avatars; null/absent for PERSONAL avatars. Null-tolerant per PART 16.
MochiConfig? _mochiConfigFromJson(Object? v) {
  if (v is Map<String, dynamic>) return MochiConfig.fromJson(v);
  if (v is Map) return MochiConfig.fromJson(Map<String, dynamic>.from(v));
  return null;
}

Map<String, dynamic>? _mochiConfigToJson(MochiConfig? c) => c?.toJson();

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

/// Render parameters for a CENTRE_CLASS avatar's "uniform" Mochi.
/// All fields are network-sourced, so every scalar is null-tolerant with a
/// safe default (CLAUDE.md PART 16).
@freezed
class ClassAppearance with _$ClassAppearance {
  const factory ClassAppearance({
    /// Hex band colour, e.g. "#7042ED". Empty string when omitted.
    @JsonKey(name: 'bandColorHex') @Default('') String bandColorHex,

    /// Subject glyph key, e.g. "math". Drives the badge icon; unknown keys
    /// map to a neutral book icon at render time.
    @JsonKey(name: 'subjectGlyph') @Default('') String subjectGlyph,

    /// 1-2 uppercase letters shown on/beneath the badge.
    @Default('') String initials,
  }) = _ClassAppearance;

  factory ClassAppearance.fromJson(Map<String, dynamic> json) =>
      _$ClassAppearanceFromJson(json);
}

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
    /// Optional teacher-specified method preferences injected into Block 2.
    String? teacherPreferences,
    // ── Centre-mode fields (null/false for all personal avatars) ──────────
    /// True when this avatar is provisioned by a tuition centre.
    /// Disables uploads, teach, and delete; enforces closed-book chat.
    @Default(false) bool centreManaged,
    String? centreId,
    /// Display name override, e.g. "ABC Mochi". Falls back to avatar.name.
    String? centreBrandName,
    /// Hex accent colour for the centre's card/appbar accent.
    String? centreAccentColor,
    /// True when the centre has paused student access to this avatar
    /// (e.g. removed from a class). Chat shows a canned "ask your centre".
    @Default(false) bool avatarLocked,
    // ── Cosmetic accessory slots (centre-admin customization) ─────────────
    /// Accessory slot ids set by the centre. Inert until layered art exists;
    /// resolved to optional overlay assets by [MochiCosmetics].
    String? cosmeticEyewear,
    String? cosmeticClothes,
    String? cosmeticShoes,
    // ── Centre-class kind + uniform appearance ────────────────────────────
    /// PERSONAL (collectible tutor) or CENTRE_CLASS (class uniform). Defaults
    /// to PERSONAL when the backend omits the field.
    @JsonKey(fromJson: _kindFromJson, toJson: _kindToJson)
    @Default(AvatarKind.personal)
    AvatarKind kind,
    /// Uniform render params; present only for CENTRE_CLASS avatars.
    @JsonKey(fromJson: _appearanceFromJson, toJson: _appearanceToJson)
    ClassAppearance? appearance,
    /// Centre-designed class Mochi look (body colour + accessory + aura).
    /// Present only for CENTRE_CLASS avatars; null for PERSONAL avatars.
    @JsonKey(name: 'mochiConfig', fromJson: _mochiConfigFromJson, toJson: _mochiConfigToJson)
    MochiConfig? mochiConfig,
    /// The class this avatar belongs to. Present only for a student's class-bound
    /// CENTRE_CLASS avatar; null for PERSONAL and the hidden corpus. Used by the
    /// leave-class action.
    @JsonKey(name: 'classId')
    String? classId,
  }) = _Avatar;

  factory Avatar.fromJson(Map<String, dynamic> json) => _$AvatarFromJson(json);
}

extension AvatarKnowledge on Avatar {
  bool get hasKnowledge => wikiPageCount > 0;
  /// True while the brain is being compiled (debounced or in-flight).
  bool get isBrainCompiling => brainState != 'READY';

  /// True when this avatar is a centre-provisioned class that should render as
  /// a uniform Mochi instead of collectible character art.
  bool get isCentreClass =>
      kind == AvatarKind.centreClass && appearance != null;
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
