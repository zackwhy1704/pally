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
      String brainState});
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
    ) as $Val);
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
      String brainState});
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
      this.brainState = 'READY'});

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

  @override
  String toString() {
    return 'Avatar(id: $id, name: $name, character: $character, subject: $subject, wikiPageCount: $wikiPageCount, fileCount: $fileCount, createdAt: $createdAt, updatedAt: $updatedAt, pedagogyMode: $pedagogyMode, gradeLevel: $gradeLevel, curriculumType: $curriculumType, testDate: $testDate, brainState: $brainState)';
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
                other.brainState == brainState));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
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
      brainState);

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
      final String brainState}) = _$AvatarImpl;

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
