// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'avatar.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ClassAppearance _$ClassAppearanceFromJson(Map<String, dynamic> json) {
  return _ClassAppearance.fromJson(json);
}

/// @nodoc
mixin _$ClassAppearance {
  /// Hex band colour, e.g. "#7042ED". Empty string when omitted.
  @JsonKey(name: 'bandColorHex')
  String get bandColorHex => throw _privateConstructorUsedError;

  /// Subject glyph key, e.g. "math". Drives the badge icon; unknown keys
  /// map to a neutral book icon at render time.
  @JsonKey(name: 'subjectGlyph')
  String get subjectGlyph => throw _privateConstructorUsedError;

  /// 1-2 uppercase letters shown on/beneath the badge.
  String get initials => throw _privateConstructorUsedError;

  /// Serializes this ClassAppearance to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ClassAppearance
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ClassAppearanceCopyWith<ClassAppearance> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClassAppearanceCopyWith<$Res> {
  factory $ClassAppearanceCopyWith(
          ClassAppearance value, $Res Function(ClassAppearance) then) =
      _$ClassAppearanceCopyWithImpl<$Res, ClassAppearance>;
  @useResult
  $Res call(
      {@JsonKey(name: 'bandColorHex') String bandColorHex,
      @JsonKey(name: 'subjectGlyph') String subjectGlyph,
      String initials});
}

/// @nodoc
class _$ClassAppearanceCopyWithImpl<$Res, $Val extends ClassAppearance>
    implements $ClassAppearanceCopyWith<$Res> {
  _$ClassAppearanceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ClassAppearance
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bandColorHex = null,
    Object? subjectGlyph = null,
    Object? initials = null,
  }) {
    return _then(_value.copyWith(
      bandColorHex: null == bandColorHex
          ? _value.bandColorHex
          : bandColorHex // ignore: cast_nullable_to_non_nullable
              as String,
      subjectGlyph: null == subjectGlyph
          ? _value.subjectGlyph
          : subjectGlyph // ignore: cast_nullable_to_non_nullable
              as String,
      initials: null == initials
          ? _value.initials
          : initials // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ClassAppearanceImplCopyWith<$Res>
    implements $ClassAppearanceCopyWith<$Res> {
  factory _$$ClassAppearanceImplCopyWith(_$ClassAppearanceImpl value,
          $Res Function(_$ClassAppearanceImpl) then) =
      __$$ClassAppearanceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'bandColorHex') String bandColorHex,
      @JsonKey(name: 'subjectGlyph') String subjectGlyph,
      String initials});
}

/// @nodoc
class __$$ClassAppearanceImplCopyWithImpl<$Res>
    extends _$ClassAppearanceCopyWithImpl<$Res, _$ClassAppearanceImpl>
    implements _$$ClassAppearanceImplCopyWith<$Res> {
  __$$ClassAppearanceImplCopyWithImpl(
      _$ClassAppearanceImpl _value, $Res Function(_$ClassAppearanceImpl) _then)
      : super(_value, _then);

  /// Create a copy of ClassAppearance
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bandColorHex = null,
    Object? subjectGlyph = null,
    Object? initials = null,
  }) {
    return _then(_$ClassAppearanceImpl(
      bandColorHex: null == bandColorHex
          ? _value.bandColorHex
          : bandColorHex // ignore: cast_nullable_to_non_nullable
              as String,
      subjectGlyph: null == subjectGlyph
          ? _value.subjectGlyph
          : subjectGlyph // ignore: cast_nullable_to_non_nullable
              as String,
      initials: null == initials
          ? _value.initials
          : initials // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ClassAppearanceImpl implements _ClassAppearance {
  const _$ClassAppearanceImpl(
      {@JsonKey(name: 'bandColorHex') this.bandColorHex = '',
      @JsonKey(name: 'subjectGlyph') this.subjectGlyph = '',
      this.initials = ''});

  factory _$ClassAppearanceImpl.fromJson(Map<String, dynamic> json) =>
      _$$ClassAppearanceImplFromJson(json);

  /// Hex band colour, e.g. "#7042ED". Empty string when omitted.
  @override
  @JsonKey(name: 'bandColorHex')
  final String bandColorHex;

  /// Subject glyph key, e.g. "math". Drives the badge icon; unknown keys
  /// map to a neutral book icon at render time.
  @override
  @JsonKey(name: 'subjectGlyph')
  final String subjectGlyph;

  /// 1-2 uppercase letters shown on/beneath the badge.
  @override
  @JsonKey()
  final String initials;

  @override
  String toString() {
    return 'ClassAppearance(bandColorHex: $bandColorHex, subjectGlyph: $subjectGlyph, initials: $initials)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClassAppearanceImpl &&
            (identical(other.bandColorHex, bandColorHex) ||
                other.bandColorHex == bandColorHex) &&
            (identical(other.subjectGlyph, subjectGlyph) ||
                other.subjectGlyph == subjectGlyph) &&
            (identical(other.initials, initials) ||
                other.initials == initials));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, bandColorHex, subjectGlyph, initials);

  /// Create a copy of ClassAppearance
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ClassAppearanceImplCopyWith<_$ClassAppearanceImpl> get copyWith =>
      __$$ClassAppearanceImplCopyWithImpl<_$ClassAppearanceImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ClassAppearanceImplToJson(
      this,
    );
  }
}

abstract class _ClassAppearance implements ClassAppearance {
  const factory _ClassAppearance(
      {@JsonKey(name: 'bandColorHex') final String bandColorHex,
      @JsonKey(name: 'subjectGlyph') final String subjectGlyph,
      final String initials}) = _$ClassAppearanceImpl;

  factory _ClassAppearance.fromJson(Map<String, dynamic> json) =
      _$ClassAppearanceImpl.fromJson;

  /// Hex band colour, e.g. "#7042ED". Empty string when omitted.
  @override
  @JsonKey(name: 'bandColorHex')
  String get bandColorHex;

  /// Subject glyph key, e.g. "math". Drives the badge icon; unknown keys
  /// map to a neutral book icon at render time.
  @override
  @JsonKey(name: 'subjectGlyph')
  String get subjectGlyph;

  /// 1-2 uppercase letters shown on/beneath the badge.
  @override
  String get initials;

  /// Create a copy of ClassAppearance
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ClassAppearanceImplCopyWith<_$ClassAppearanceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Avatar _$AvatarFromJson(Map<String, dynamic> json) {
  return _Avatar.fromJson(json);
}

/// @nodoc
mixin _$Avatar {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  @JsonKey(
      name: 'characterType',
      fromJson: _characterFromJson,
      toJson: _characterToJson)
  MochiCharacter get character => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _subjectFromJson, toJson: _subjectToJson)
  String get subject => throw _privateConstructorUsedError;
  @JsonKey(name: 'wikiPageCount', fromJson: _wikiPageCountFromJson)
  int get wikiPageCount => throw _privateConstructorUsedError;
  int get fileCount => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _pedagogyFromJson, toJson: _pedagogyToJson)
  PedagogyMode get pedagogyMode => throw _privateConstructorUsedError;
  String? get gradeLevel => throw _privateConstructorUsedError;
  String? get curriculumType => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _testDateFromJson, toJson: _testDateToJson)
  DateTime? get testDate => throw _privateConstructorUsedError;

  /// Brain compilation state: READY | PENDING_RECOMPILE | COMPILING
  String get brainState => throw _privateConstructorUsedError;

  /// False when this avatar is outside the user's active slot cap.
  /// Inactive avatars are visible but chat/quiz are blocked.
  bool get isActive => throw _privateConstructorUsedError;

  /// Optional teacher-specified method preferences injected into Block 2.
  String? get teacherPreferences =>
      throw _privateConstructorUsedError; // ── Centre-mode fields (null/false for all personal avatars) ──────────
  /// True when this avatar is provisioned by a tuition centre.
  /// Disables uploads, teach, and delete; enforces closed-book chat.
  bool get centreManaged => throw _privateConstructorUsedError;
  String? get centreId => throw _privateConstructorUsedError;

  /// Display name override, e.g. "ABC Mochi". Falls back to avatar.name.
  String? get centreBrandName => throw _privateConstructorUsedError;

  /// Hex accent colour for the centre's card/appbar accent.
  String? get centreAccentColor => throw _privateConstructorUsedError;

  /// True when the centre has paused student access to this avatar
  /// (e.g. removed from a class). Chat shows a canned "ask your centre".
  bool get avatarLocked =>
      throw _privateConstructorUsedError; // ── Cosmetic accessory slots (centre-admin customization) ─────────────
  /// Accessory slot ids set by the centre. Inert until layered art exists;
  /// resolved to optional overlay assets by [MochiCosmetics].
  String? get cosmeticEyewear => throw _privateConstructorUsedError;
  String? get cosmeticClothes => throw _privateConstructorUsedError;
  String? get cosmeticShoes =>
      throw _privateConstructorUsedError; // ── Centre-class kind + uniform appearance ────────────────────────────
  /// PERSONAL (collectible tutor) or CENTRE_CLASS (class uniform). Defaults
  /// to PERSONAL when the backend omits the field.
  @JsonKey(fromJson: _kindFromJson, toJson: _kindToJson)
  AvatarKind get kind => throw _privateConstructorUsedError;

  /// Uniform render params; present only for CENTRE_CLASS avatars.
  @JsonKey(fromJson: _appearanceFromJson, toJson: _appearanceToJson)
  ClassAppearance? get appearance => throw _privateConstructorUsedError;

  /// Serializes this Avatar to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Avatar
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AvatarCopyWith<Avatar> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AvatarCopyWith<$Res> {
  factory $AvatarCopyWith(Avatar value, $Res Function(Avatar) then) =
      _$AvatarCopyWithImpl<$Res, Avatar>;
  @useResult
  $Res call(
      {String id,
      String name,
      @JsonKey(
          name: 'characterType',
          fromJson: _characterFromJson,
          toJson: _characterToJson)
      MochiCharacter character,
      @JsonKey(fromJson: _subjectFromJson, toJson: _subjectToJson)
      String subject,
      @JsonKey(name: 'wikiPageCount', fromJson: _wikiPageCountFromJson)
      int wikiPageCount,
      int fileCount,
      DateTime? createdAt,
      DateTime? updatedAt,
      @JsonKey(fromJson: _pedagogyFromJson, toJson: _pedagogyToJson)
      PedagogyMode pedagogyMode,
      String? gradeLevel,
      String? curriculumType,
      @JsonKey(fromJson: _testDateFromJson, toJson: _testDateToJson)
      DateTime? testDate,
      String brainState,
      bool isActive,
      String? teacherPreferences,
      bool centreManaged,
      String? centreId,
      String? centreBrandName,
      String? centreAccentColor,
      bool avatarLocked,
      String? cosmeticEyewear,
      String? cosmeticClothes,
      String? cosmeticShoes,
      @JsonKey(fromJson: _kindFromJson, toJson: _kindToJson) AvatarKind kind,
      @JsonKey(fromJson: _appearanceFromJson, toJson: _appearanceToJson)
      ClassAppearance? appearance});

  $ClassAppearanceCopyWith<$Res>? get appearance;
}

/// @nodoc
class _$AvatarCopyWithImpl<$Res, $Val extends Avatar>
    implements $AvatarCopyWith<$Res> {
  _$AvatarCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Avatar
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? character = null,
    Object? subject = null,
    Object? wikiPageCount = null,
    Object? fileCount = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? pedagogyMode = null,
    Object? gradeLevel = freezed,
    Object? curriculumType = freezed,
    Object? testDate = freezed,
    Object? brainState = null,
    Object? isActive = null,
    Object? teacherPreferences = freezed,
    Object? centreManaged = null,
    Object? centreId = freezed,
    Object? centreBrandName = freezed,
    Object? centreAccentColor = freezed,
    Object? avatarLocked = null,
    Object? cosmeticEyewear = freezed,
    Object? cosmeticClothes = freezed,
    Object? cosmeticShoes = freezed,
    Object? kind = null,
    Object? appearance = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      character: null == character
          ? _value.character
          : character // ignore: cast_nullable_to_non_nullable
              as MochiCharacter,
      subject: null == subject
          ? _value.subject
          : subject // ignore: cast_nullable_to_non_nullable
              as String,
      wikiPageCount: null == wikiPageCount
          ? _value.wikiPageCount
          : wikiPageCount // ignore: cast_nullable_to_non_nullable
              as int,
      fileCount: null == fileCount
          ? _value.fileCount
          : fileCount // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      pedagogyMode: null == pedagogyMode
          ? _value.pedagogyMode
          : pedagogyMode // ignore: cast_nullable_to_non_nullable
              as PedagogyMode,
      gradeLevel: freezed == gradeLevel
          ? _value.gradeLevel
          : gradeLevel // ignore: cast_nullable_to_non_nullable
              as String?,
      curriculumType: freezed == curriculumType
          ? _value.curriculumType
          : curriculumType // ignore: cast_nullable_to_non_nullable
              as String?,
      testDate: freezed == testDate
          ? _value.testDate
          : testDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      brainState: null == brainState
          ? _value.brainState
          : brainState // ignore: cast_nullable_to_non_nullable
              as String,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      teacherPreferences: freezed == teacherPreferences
          ? _value.teacherPreferences
          : teacherPreferences // ignore: cast_nullable_to_non_nullable
              as String?,
      centreManaged: null == centreManaged
          ? _value.centreManaged
          : centreManaged // ignore: cast_nullable_to_non_nullable
              as bool,
      centreId: freezed == centreId
          ? _value.centreId
          : centreId // ignore: cast_nullable_to_non_nullable
              as String?,
      centreBrandName: freezed == centreBrandName
          ? _value.centreBrandName
          : centreBrandName // ignore: cast_nullable_to_non_nullable
              as String?,
      centreAccentColor: freezed == centreAccentColor
          ? _value.centreAccentColor
          : centreAccentColor // ignore: cast_nullable_to_non_nullable
              as String?,
      avatarLocked: null == avatarLocked
          ? _value.avatarLocked
          : avatarLocked // ignore: cast_nullable_to_non_nullable
              as bool,
      cosmeticEyewear: freezed == cosmeticEyewear
          ? _value.cosmeticEyewear
          : cosmeticEyewear // ignore: cast_nullable_to_non_nullable
              as String?,
      cosmeticClothes: freezed == cosmeticClothes
          ? _value.cosmeticClothes
          : cosmeticClothes // ignore: cast_nullable_to_non_nullable
              as String?,
      cosmeticShoes: freezed == cosmeticShoes
          ? _value.cosmeticShoes
          : cosmeticShoes // ignore: cast_nullable_to_non_nullable
              as String?,
      kind: null == kind
          ? _value.kind
          : kind // ignore: cast_nullable_to_non_nullable
              as AvatarKind,
      appearance: freezed == appearance
          ? _value.appearance
          : appearance // ignore: cast_nullable_to_non_nullable
              as ClassAppearance?,
    ) as $Val);
  }

  /// Create a copy of Avatar
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ClassAppearanceCopyWith<$Res>? get appearance {
    if (_value.appearance == null) {
      return null;
    }

    return $ClassAppearanceCopyWith<$Res>(_value.appearance!, (value) {
      return _then(_value.copyWith(appearance: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AvatarImplCopyWith<$Res> implements $AvatarCopyWith<$Res> {
  factory _$$AvatarImplCopyWith(
          _$AvatarImpl value, $Res Function(_$AvatarImpl) then) =
      __$$AvatarImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      @JsonKey(
          name: 'characterType',
          fromJson: _characterFromJson,
          toJson: _characterToJson)
      MochiCharacter character,
      @JsonKey(fromJson: _subjectFromJson, toJson: _subjectToJson)
      String subject,
      @JsonKey(name: 'wikiPageCount', fromJson: _wikiPageCountFromJson)
      int wikiPageCount,
      int fileCount,
      DateTime? createdAt,
      DateTime? updatedAt,
      @JsonKey(fromJson: _pedagogyFromJson, toJson: _pedagogyToJson)
      PedagogyMode pedagogyMode,
      String? gradeLevel,
      String? curriculumType,
      @JsonKey(fromJson: _testDateFromJson, toJson: _testDateToJson)
      DateTime? testDate,
      String brainState,
      bool isActive,
      String? teacherPreferences,
      bool centreManaged,
      String? centreId,
      String? centreBrandName,
      String? centreAccentColor,
      bool avatarLocked,
      String? cosmeticEyewear,
      String? cosmeticClothes,
      String? cosmeticShoes,
      @JsonKey(fromJson: _kindFromJson, toJson: _kindToJson) AvatarKind kind,
      @JsonKey(fromJson: _appearanceFromJson, toJson: _appearanceToJson)
      ClassAppearance? appearance});

  @override
  $ClassAppearanceCopyWith<$Res>? get appearance;
}

/// @nodoc
class __$$AvatarImplCopyWithImpl<$Res>
    extends _$AvatarCopyWithImpl<$Res, _$AvatarImpl>
    implements _$$AvatarImplCopyWith<$Res> {
  __$$AvatarImplCopyWithImpl(
      _$AvatarImpl _value, $Res Function(_$AvatarImpl) _then)
      : super(_value, _then);

  /// Create a copy of Avatar
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? character = null,
    Object? subject = null,
    Object? wikiPageCount = null,
    Object? fileCount = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? pedagogyMode = null,
    Object? gradeLevel = freezed,
    Object? curriculumType = freezed,
    Object? testDate = freezed,
    Object? brainState = null,
    Object? isActive = null,
    Object? teacherPreferences = freezed,
    Object? centreManaged = null,
    Object? centreId = freezed,
    Object? centreBrandName = freezed,
    Object? centreAccentColor = freezed,
    Object? avatarLocked = null,
    Object? cosmeticEyewear = freezed,
    Object? cosmeticClothes = freezed,
    Object? cosmeticShoes = freezed,
    Object? kind = null,
    Object? appearance = freezed,
  }) {
    return _then(_$AvatarImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      character: null == character
          ? _value.character
          : character // ignore: cast_nullable_to_non_nullable
              as MochiCharacter,
      subject: null == subject
          ? _value.subject
          : subject // ignore: cast_nullable_to_non_nullable
              as String,
      wikiPageCount: null == wikiPageCount
          ? _value.wikiPageCount
          : wikiPageCount // ignore: cast_nullable_to_non_nullable
              as int,
      fileCount: null == fileCount
          ? _value.fileCount
          : fileCount // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      pedagogyMode: null == pedagogyMode
          ? _value.pedagogyMode
          : pedagogyMode // ignore: cast_nullable_to_non_nullable
              as PedagogyMode,
      gradeLevel: freezed == gradeLevel
          ? _value.gradeLevel
          : gradeLevel // ignore: cast_nullable_to_non_nullable
              as String?,
      curriculumType: freezed == curriculumType
          ? _value.curriculumType
          : curriculumType // ignore: cast_nullable_to_non_nullable
              as String?,
      testDate: freezed == testDate
          ? _value.testDate
          : testDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      brainState: null == brainState
          ? _value.brainState
          : brainState // ignore: cast_nullable_to_non_nullable
              as String,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      teacherPreferences: freezed == teacherPreferences
          ? _value.teacherPreferences
          : teacherPreferences // ignore: cast_nullable_to_non_nullable
              as String?,
      centreManaged: null == centreManaged
          ? _value.centreManaged
          : centreManaged // ignore: cast_nullable_to_non_nullable
              as bool,
      centreId: freezed == centreId
          ? _value.centreId
          : centreId // ignore: cast_nullable_to_non_nullable
              as String?,
      centreBrandName: freezed == centreBrandName
          ? _value.centreBrandName
          : centreBrandName // ignore: cast_nullable_to_non_nullable
              as String?,
      centreAccentColor: freezed == centreAccentColor
          ? _value.centreAccentColor
          : centreAccentColor // ignore: cast_nullable_to_non_nullable
              as String?,
      avatarLocked: null == avatarLocked
          ? _value.avatarLocked
          : avatarLocked // ignore: cast_nullable_to_non_nullable
              as bool,
      cosmeticEyewear: freezed == cosmeticEyewear
          ? _value.cosmeticEyewear
          : cosmeticEyewear // ignore: cast_nullable_to_non_nullable
              as String?,
      cosmeticClothes: freezed == cosmeticClothes
          ? _value.cosmeticClothes
          : cosmeticClothes // ignore: cast_nullable_to_non_nullable
              as String?,
      cosmeticShoes: freezed == cosmeticShoes
          ? _value.cosmeticShoes
          : cosmeticShoes // ignore: cast_nullable_to_non_nullable
              as String?,
      kind: null == kind
          ? _value.kind
          : kind // ignore: cast_nullable_to_non_nullable
              as AvatarKind,
      appearance: freezed == appearance
          ? _value.appearance
          : appearance // ignore: cast_nullable_to_non_nullable
              as ClassAppearance?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AvatarImpl implements _Avatar {
  const _$AvatarImpl(
      {required this.id,
      required this.name,
      @JsonKey(
          name: 'characterType',
          fromJson: _characterFromJson,
          toJson: _characterToJson)
      required this.character,
      @JsonKey(fromJson: _subjectFromJson, toJson: _subjectToJson)
      required this.subject,
      @JsonKey(name: 'wikiPageCount', fromJson: _wikiPageCountFromJson)
      this.wikiPageCount = 0,
      this.fileCount = 0,
      this.createdAt,
      this.updatedAt,
      @JsonKey(fromJson: _pedagogyFromJson, toJson: _pedagogyToJson)
      this.pedagogyMode = PedagogyMode.socratic,
      this.gradeLevel,
      this.curriculumType,
      @JsonKey(fromJson: _testDateFromJson, toJson: _testDateToJson)
      this.testDate,
      this.brainState = 'READY',
      this.isActive = true,
      this.teacherPreferences,
      this.centreManaged = false,
      this.centreId,
      this.centreBrandName,
      this.centreAccentColor,
      this.avatarLocked = false,
      this.cosmeticEyewear,
      this.cosmeticClothes,
      this.cosmeticShoes,
      @JsonKey(fromJson: _kindFromJson, toJson: _kindToJson)
      this.kind = AvatarKind.personal,
      @JsonKey(fromJson: _appearanceFromJson, toJson: _appearanceToJson)
      this.appearance});

  factory _$AvatarImpl.fromJson(Map<String, dynamic> json) =>
      _$$AvatarImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  @JsonKey(
      name: 'characterType',
      fromJson: _characterFromJson,
      toJson: _characterToJson)
  final MochiCharacter character;
  @override
  @JsonKey(fromJson: _subjectFromJson, toJson: _subjectToJson)
  final String subject;
  @override
  @JsonKey(name: 'wikiPageCount', fromJson: _wikiPageCountFromJson)
  final int wikiPageCount;
  @override
  @JsonKey()
  final int fileCount;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  @override
  @JsonKey(fromJson: _pedagogyFromJson, toJson: _pedagogyToJson)
  final PedagogyMode pedagogyMode;
  @override
  final String? gradeLevel;
  @override
  final String? curriculumType;
  @override
  @JsonKey(fromJson: _testDateFromJson, toJson: _testDateToJson)
  final DateTime? testDate;

  /// Brain compilation state: READY | PENDING_RECOMPILE | COMPILING
  @override
  @JsonKey()
  final String brainState;

  /// False when this avatar is outside the user's active slot cap.
  /// Inactive avatars are visible but chat/quiz are blocked.
  @override
  @JsonKey()
  final bool isActive;

  /// Optional teacher-specified method preferences injected into Block 2.
  @override
  final String? teacherPreferences;
// ── Centre-mode fields (null/false for all personal avatars) ──────────
  /// True when this avatar is provisioned by a tuition centre.
  /// Disables uploads, teach, and delete; enforces closed-book chat.
  @override
  @JsonKey()
  final bool centreManaged;
  @override
  final String? centreId;

  /// Display name override, e.g. "ABC Mochi". Falls back to avatar.name.
  @override
  final String? centreBrandName;

  /// Hex accent colour for the centre's card/appbar accent.
  @override
  final String? centreAccentColor;

  /// True when the centre has paused student access to this avatar
  /// (e.g. removed from a class). Chat shows a canned "ask your centre".
  @override
  @JsonKey()
  final bool avatarLocked;
// ── Cosmetic accessory slots (centre-admin customization) ─────────────
  /// Accessory slot ids set by the centre. Inert until layered art exists;
  /// resolved to optional overlay assets by [MochiCosmetics].
  @override
  final String? cosmeticEyewear;
  @override
  final String? cosmeticClothes;
  @override
  final String? cosmeticShoes;
// ── Centre-class kind + uniform appearance ────────────────────────────
  /// PERSONAL (collectible tutor) or CENTRE_CLASS (class uniform). Defaults
  /// to PERSONAL when the backend omits the field.
  @override
  @JsonKey(fromJson: _kindFromJson, toJson: _kindToJson)
  final AvatarKind kind;

  /// Uniform render params; present only for CENTRE_CLASS avatars.
  @override
  @JsonKey(fromJson: _appearanceFromJson, toJson: _appearanceToJson)
  final ClassAppearance? appearance;

  @override
  String toString() {
    return 'Avatar(id: $id, name: $name, character: $character, subject: $subject, wikiPageCount: $wikiPageCount, fileCount: $fileCount, createdAt: $createdAt, updatedAt: $updatedAt, pedagogyMode: $pedagogyMode, gradeLevel: $gradeLevel, curriculumType: $curriculumType, testDate: $testDate, brainState: $brainState, isActive: $isActive, teacherPreferences: $teacherPreferences, centreManaged: $centreManaged, centreId: $centreId, centreBrandName: $centreBrandName, centreAccentColor: $centreAccentColor, avatarLocked: $avatarLocked, cosmeticEyewear: $cosmeticEyewear, cosmeticClothes: $cosmeticClothes, cosmeticShoes: $cosmeticShoes, kind: $kind, appearance: $appearance)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AvatarImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.character, character) ||
                other.character == character) &&
            (identical(other.subject, subject) || other.subject == subject) &&
            (identical(other.wikiPageCount, wikiPageCount) ||
                other.wikiPageCount == wikiPageCount) &&
            (identical(other.fileCount, fileCount) ||
                other.fileCount == fileCount) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.pedagogyMode, pedagogyMode) ||
                other.pedagogyMode == pedagogyMode) &&
            (identical(other.gradeLevel, gradeLevel) ||
                other.gradeLevel == gradeLevel) &&
            (identical(other.curriculumType, curriculumType) ||
                other.curriculumType == curriculumType) &&
            (identical(other.testDate, testDate) ||
                other.testDate == testDate) &&
            (identical(other.brainState, brainState) ||
                other.brainState == brainState) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.teacherPreferences, teacherPreferences) ||
                other.teacherPreferences == teacherPreferences) &&
            (identical(other.centreManaged, centreManaged) ||
                other.centreManaged == centreManaged) &&
            (identical(other.centreId, centreId) ||
                other.centreId == centreId) &&
            (identical(other.centreBrandName, centreBrandName) ||
                other.centreBrandName == centreBrandName) &&
            (identical(other.centreAccentColor, centreAccentColor) ||
                other.centreAccentColor == centreAccentColor) &&
            (identical(other.avatarLocked, avatarLocked) ||
                other.avatarLocked == avatarLocked) &&
            (identical(other.cosmeticEyewear, cosmeticEyewear) ||
                other.cosmeticEyewear == cosmeticEyewear) &&
            (identical(other.cosmeticClothes, cosmeticClothes) ||
                other.cosmeticClothes == cosmeticClothes) &&
            (identical(other.cosmeticShoes, cosmeticShoes) ||
                other.cosmeticShoes == cosmeticShoes) &&
            (identical(other.kind, kind) || other.kind == kind) &&
            (identical(other.appearance, appearance) ||
                other.appearance == appearance));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        name,
        character,
        subject,
        wikiPageCount,
        fileCount,
        createdAt,
        updatedAt,
        pedagogyMode,
        gradeLevel,
        curriculumType,
        testDate,
        brainState,
        isActive,
        teacherPreferences,
        centreManaged,
        centreId,
        centreBrandName,
        centreAccentColor,
        avatarLocked,
        cosmeticEyewear,
        cosmeticClothes,
        cosmeticShoes,
        kind,
        appearance
      ]);

  /// Create a copy of Avatar
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AvatarImplCopyWith<_$AvatarImpl> get copyWith =>
      __$$AvatarImplCopyWithImpl<_$AvatarImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AvatarImplToJson(
      this,
    );
  }
}

abstract class _Avatar implements Avatar {
  const factory _Avatar(
      {required final String id,
      required final String name,
      @JsonKey(
          name: 'characterType',
          fromJson: _characterFromJson,
          toJson: _characterToJson)
      required final MochiCharacter character,
      @JsonKey(fromJson: _subjectFromJson, toJson: _subjectToJson)
      required final String subject,
      @JsonKey(name: 'wikiPageCount', fromJson: _wikiPageCountFromJson)
      final int wikiPageCount,
      final int fileCount,
      final DateTime? createdAt,
      final DateTime? updatedAt,
      @JsonKey(fromJson: _pedagogyFromJson, toJson: _pedagogyToJson)
      final PedagogyMode pedagogyMode,
      final String? gradeLevel,
      final String? curriculumType,
      @JsonKey(fromJson: _testDateFromJson, toJson: _testDateToJson)
      final DateTime? testDate,
      final String brainState,
      final bool isActive,
      final String? teacherPreferences,
      final bool centreManaged,
      final String? centreId,
      final String? centreBrandName,
      final String? centreAccentColor,
      final bool avatarLocked,
      final String? cosmeticEyewear,
      final String? cosmeticClothes,
      final String? cosmeticShoes,
      @JsonKey(fromJson: _kindFromJson, toJson: _kindToJson)
      final AvatarKind kind,
      @JsonKey(fromJson: _appearanceFromJson, toJson: _appearanceToJson)
      final ClassAppearance? appearance}) = _$AvatarImpl;

  factory _Avatar.fromJson(Map<String, dynamic> json) = _$AvatarImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  @JsonKey(
      name: 'characterType',
      fromJson: _characterFromJson,
      toJson: _characterToJson)
  MochiCharacter get character;
  @override
  @JsonKey(fromJson: _subjectFromJson, toJson: _subjectToJson)
  String get subject;
  @override
  @JsonKey(name: 'wikiPageCount', fromJson: _wikiPageCountFromJson)
  int get wikiPageCount;
  @override
  int get fileCount;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  @JsonKey(fromJson: _pedagogyFromJson, toJson: _pedagogyToJson)
  PedagogyMode get pedagogyMode;
  @override
  String? get gradeLevel;
  @override
  String? get curriculumType;
  @override
  @JsonKey(fromJson: _testDateFromJson, toJson: _testDateToJson)
  DateTime? get testDate;

  /// Brain compilation state: READY | PENDING_RECOMPILE | COMPILING
  @override
  String get brainState;

  /// False when this avatar is outside the user's active slot cap.
  /// Inactive avatars are visible but chat/quiz are blocked.
  @override
  bool get isActive;

  /// Optional teacher-specified method preferences injected into Block 2.
  @override
  String?
      get teacherPreferences; // ── Centre-mode fields (null/false for all personal avatars) ──────────
  /// True when this avatar is provisioned by a tuition centre.
  /// Disables uploads, teach, and delete; enforces closed-book chat.
  @override
  bool get centreManaged;
  @override
  String? get centreId;

  /// Display name override, e.g. "ABC Mochi". Falls back to avatar.name.
  @override
  String? get centreBrandName;

  /// Hex accent colour for the centre's card/appbar accent.
  @override
  String? get centreAccentColor;

  /// True when the centre has paused student access to this avatar
  /// (e.g. removed from a class). Chat shows a canned "ask your centre".
  @override
  bool
      get avatarLocked; // ── Cosmetic accessory slots (centre-admin customization) ─────────────
  /// Accessory slot ids set by the centre. Inert until layered art exists;
  /// resolved to optional overlay assets by [MochiCosmetics].
  @override
  String? get cosmeticEyewear;
  @override
  String? get cosmeticClothes;
  @override
  String?
      get cosmeticShoes; // ── Centre-class kind + uniform appearance ────────────────────────────
  /// PERSONAL (collectible tutor) or CENTRE_CLASS (class uniform). Defaults
  /// to PERSONAL when the backend omits the field.
  @override
  @JsonKey(fromJson: _kindFromJson, toJson: _kindToJson)
  AvatarKind get kind;

  /// Uniform render params; present only for CENTRE_CLASS avatars.
  @override
  @JsonKey(fromJson: _appearanceFromJson, toJson: _appearanceToJson)
  ClassAppearance? get appearance;

  /// Create a copy of Avatar
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AvatarImplCopyWith<_$AvatarImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CreateAvatarRequest _$CreateAvatarRequestFromJson(Map<String, dynamic> json) {
  return _CreateAvatarRequest.fromJson(json);
}

/// @nodoc
mixin _$CreateAvatarRequest {
  String get name => throw _privateConstructorUsedError;
  @JsonKey(
      name: 'characterType',
      fromJson: _characterFromJson,
      toJson: _characterToJson)
  MochiCharacter get character => throw _privateConstructorUsedError;
  @JsonKey(toJson: _subjectToJson, fromJson: _subjectFromJson)
  String get subject => throw _privateConstructorUsedError;
  String? get gradeLevel => throw _privateConstructorUsedError;
  String? get curriculumType => throw _privateConstructorUsedError;

  /// Serializes this CreateAvatarRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateAvatarRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateAvatarRequestCopyWith<CreateAvatarRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateAvatarRequestCopyWith<$Res> {
  factory $CreateAvatarRequestCopyWith(
          CreateAvatarRequest value, $Res Function(CreateAvatarRequest) then) =
      _$CreateAvatarRequestCopyWithImpl<$Res, CreateAvatarRequest>;
  @useResult
  $Res call(
      {String name,
      @JsonKey(
          name: 'characterType',
          fromJson: _characterFromJson,
          toJson: _characterToJson)
      MochiCharacter character,
      @JsonKey(toJson: _subjectToJson, fromJson: _subjectFromJson)
      String subject,
      String? gradeLevel,
      String? curriculumType});
}

/// @nodoc
class _$CreateAvatarRequestCopyWithImpl<$Res, $Val extends CreateAvatarRequest>
    implements $CreateAvatarRequestCopyWith<$Res> {
  _$CreateAvatarRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateAvatarRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? character = null,
    Object? subject = null,
    Object? gradeLevel = freezed,
    Object? curriculumType = freezed,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      character: null == character
          ? _value.character
          : character // ignore: cast_nullable_to_non_nullable
              as MochiCharacter,
      subject: null == subject
          ? _value.subject
          : subject // ignore: cast_nullable_to_non_nullable
              as String,
      gradeLevel: freezed == gradeLevel
          ? _value.gradeLevel
          : gradeLevel // ignore: cast_nullable_to_non_nullable
              as String?,
      curriculumType: freezed == curriculumType
          ? _value.curriculumType
          : curriculumType // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CreateAvatarRequestImplCopyWith<$Res>
    implements $CreateAvatarRequestCopyWith<$Res> {
  factory _$$CreateAvatarRequestImplCopyWith(_$CreateAvatarRequestImpl value,
          $Res Function(_$CreateAvatarRequestImpl) then) =
      __$$CreateAvatarRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      @JsonKey(
          name: 'characterType',
          fromJson: _characterFromJson,
          toJson: _characterToJson)
      MochiCharacter character,
      @JsonKey(toJson: _subjectToJson, fromJson: _subjectFromJson)
      String subject,
      String? gradeLevel,
      String? curriculumType});
}

/// @nodoc
class __$$CreateAvatarRequestImplCopyWithImpl<$Res>
    extends _$CreateAvatarRequestCopyWithImpl<$Res, _$CreateAvatarRequestImpl>
    implements _$$CreateAvatarRequestImplCopyWith<$Res> {
  __$$CreateAvatarRequestImplCopyWithImpl(_$CreateAvatarRequestImpl _value,
      $Res Function(_$CreateAvatarRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of CreateAvatarRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? character = null,
    Object? subject = null,
    Object? gradeLevel = freezed,
    Object? curriculumType = freezed,
  }) {
    return _then(_$CreateAvatarRequestImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      character: null == character
          ? _value.character
          : character // ignore: cast_nullable_to_non_nullable
              as MochiCharacter,
      subject: null == subject
          ? _value.subject
          : subject // ignore: cast_nullable_to_non_nullable
              as String,
      gradeLevel: freezed == gradeLevel
          ? _value.gradeLevel
          : gradeLevel // ignore: cast_nullable_to_non_nullable
              as String?,
      curriculumType: freezed == curriculumType
          ? _value.curriculumType
          : curriculumType // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateAvatarRequestImpl implements _CreateAvatarRequest {
  const _$CreateAvatarRequestImpl(
      {required this.name,
      @JsonKey(
          name: 'characterType',
          fromJson: _characterFromJson,
          toJson: _characterToJson)
      required this.character,
      @JsonKey(toJson: _subjectToJson, fromJson: _subjectFromJson)
      required this.subject,
      this.gradeLevel,
      this.curriculumType});

  factory _$CreateAvatarRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateAvatarRequestImplFromJson(json);

  @override
  final String name;
  @override
  @JsonKey(
      name: 'characterType',
      fromJson: _characterFromJson,
      toJson: _characterToJson)
  final MochiCharacter character;
  @override
  @JsonKey(toJson: _subjectToJson, fromJson: _subjectFromJson)
  final String subject;
  @override
  final String? gradeLevel;
  @override
  final String? curriculumType;

  @override
  String toString() {
    return 'CreateAvatarRequest(name: $name, character: $character, subject: $subject, gradeLevel: $gradeLevel, curriculumType: $curriculumType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateAvatarRequestImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.character, character) ||
                other.character == character) &&
            (identical(other.subject, subject) || other.subject == subject) &&
            (identical(other.gradeLevel, gradeLevel) ||
                other.gradeLevel == gradeLevel) &&
            (identical(other.curriculumType, curriculumType) ||
                other.curriculumType == curriculumType));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, name, character, subject, gradeLevel, curriculumType);

  /// Create a copy of CreateAvatarRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateAvatarRequestImplCopyWith<_$CreateAvatarRequestImpl> get copyWith =>
      __$$CreateAvatarRequestImplCopyWithImpl<_$CreateAvatarRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateAvatarRequestImplToJson(
      this,
    );
  }
}

abstract class _CreateAvatarRequest implements CreateAvatarRequest {
  const factory _CreateAvatarRequest(
      {required final String name,
      @JsonKey(
          name: 'characterType',
          fromJson: _characterFromJson,
          toJson: _characterToJson)
      required final MochiCharacter character,
      @JsonKey(toJson: _subjectToJson, fromJson: _subjectFromJson)
      required final String subject,
      final String? gradeLevel,
      final String? curriculumType}) = _$CreateAvatarRequestImpl;

  factory _CreateAvatarRequest.fromJson(Map<String, dynamic> json) =
      _$CreateAvatarRequestImpl.fromJson;

  @override
  String get name;
  @override
  @JsonKey(
      name: 'characterType',
      fromJson: _characterFromJson,
      toJson: _characterToJson)
  MochiCharacter get character;
  @override
  @JsonKey(toJson: _subjectToJson, fromJson: _subjectFromJson)
  String get subject;
  @override
  String? get gradeLevel;
  @override
  String? get curriculumType;

  /// Create a copy of CreateAvatarRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateAvatarRequestImplCopyWith<_$CreateAvatarRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
