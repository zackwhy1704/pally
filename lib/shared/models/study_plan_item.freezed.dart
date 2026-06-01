// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'study_plan_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

StudyPlanItem _$StudyPlanItemFromJson(Map<String, dynamic> json) {
  return _StudyPlanItem.fromJson(json);
}

/// @nodoc
mixin _$StudyPlanItem {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _typeFromJson, toJson: _typeToJson)
  StudyPlanItemType get type => throw _privateConstructorUsedError;
  bool get isDone => throw _privateConstructorUsedError;
  String get avatarId => throw _privateConstructorUsedError;
  String get reason => throw _privateConstructorUsedError;
  DateTime? get scheduledDate => throw _privateConstructorUsedError;

  /// Serializes this StudyPlanItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StudyPlanItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StudyPlanItemCopyWith<StudyPlanItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StudyPlanItemCopyWith<$Res> {
  factory $StudyPlanItemCopyWith(
          StudyPlanItem value, $Res Function(StudyPlanItem) then) =
      _$StudyPlanItemCopyWithImpl<$Res, StudyPlanItem>;
  @useResult
  $Res call(
      {String id,
      String title,
      @JsonKey(fromJson: _typeFromJson, toJson: _typeToJson)
      StudyPlanItemType type,
      bool isDone,
      String avatarId,
      String reason,
      DateTime? scheduledDate});
}

/// @nodoc
class _$StudyPlanItemCopyWithImpl<$Res, $Val extends StudyPlanItem>
    implements $StudyPlanItemCopyWith<$Res> {
  _$StudyPlanItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StudyPlanItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? type = null,
    Object? isDone = null,
    Object? avatarId = null,
    Object? reason = null,
    Object? scheduledDate = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as StudyPlanItemType,
      isDone: null == isDone
          ? _value.isDone
          : isDone // ignore: cast_nullable_to_non_nullable
              as bool,
      avatarId: null == avatarId
          ? _value.avatarId
          : avatarId // ignore: cast_nullable_to_non_nullable
              as String,
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
      scheduledDate: freezed == scheduledDate
          ? _value.scheduledDate
          : scheduledDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StudyPlanItemImplCopyWith<$Res>
    implements $StudyPlanItemCopyWith<$Res> {
  factory _$$StudyPlanItemImplCopyWith(
          _$StudyPlanItemImpl value, $Res Function(_$StudyPlanItemImpl) then) =
      __$$StudyPlanItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      @JsonKey(fromJson: _typeFromJson, toJson: _typeToJson)
      StudyPlanItemType type,
      bool isDone,
      String avatarId,
      String reason,
      DateTime? scheduledDate});
}

/// @nodoc
class __$$StudyPlanItemImplCopyWithImpl<$Res>
    extends _$StudyPlanItemCopyWithImpl<$Res, _$StudyPlanItemImpl>
    implements _$$StudyPlanItemImplCopyWith<$Res> {
  __$$StudyPlanItemImplCopyWithImpl(
      _$StudyPlanItemImpl _value, $Res Function(_$StudyPlanItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of StudyPlanItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? type = null,
    Object? isDone = null,
    Object? avatarId = null,
    Object? reason = null,
    Object? scheduledDate = freezed,
  }) {
    return _then(_$StudyPlanItemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as StudyPlanItemType,
      isDone: null == isDone
          ? _value.isDone
          : isDone // ignore: cast_nullable_to_non_nullable
              as bool,
      avatarId: null == avatarId
          ? _value.avatarId
          : avatarId // ignore: cast_nullable_to_non_nullable
              as String,
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
      scheduledDate: freezed == scheduledDate
          ? _value.scheduledDate
          : scheduledDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StudyPlanItemImpl implements _StudyPlanItem {
  const _$StudyPlanItemImpl(
      {this.id = '',
      this.title = '',
      @JsonKey(fromJson: _typeFromJson, toJson: _typeToJson) required this.type,
      this.isDone = false,
      this.avatarId = '',
      this.reason = '',
      this.scheduledDate});

  factory _$StudyPlanItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$StudyPlanItemImplFromJson(json);

  @override
  @JsonKey()
  final String id;
  @override
  @JsonKey()
  final String title;
  @override
  @JsonKey(fromJson: _typeFromJson, toJson: _typeToJson)
  final StudyPlanItemType type;
  @override
  @JsonKey()
  final bool isDone;
  @override
  @JsonKey()
  final String avatarId;
  @override
  @JsonKey()
  final String reason;
  @override
  final DateTime? scheduledDate;

  @override
  String toString() {
    return 'StudyPlanItem(id: $id, title: $title, type: $type, isDone: $isDone, avatarId: $avatarId, reason: $reason, scheduledDate: $scheduledDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StudyPlanItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.isDone, isDone) || other.isDone == isDone) &&
            (identical(other.avatarId, avatarId) ||
                other.avatarId == avatarId) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.scheduledDate, scheduledDate) ||
                other.scheduledDate == scheduledDate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, title, type, isDone, avatarId, reason, scheduledDate);

  /// Create a copy of StudyPlanItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StudyPlanItemImplCopyWith<_$StudyPlanItemImpl> get copyWith =>
      __$$StudyPlanItemImplCopyWithImpl<_$StudyPlanItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StudyPlanItemImplToJson(
      this,
    );
  }
}

abstract class _StudyPlanItem implements StudyPlanItem {
  const factory _StudyPlanItem(
      {final String id,
      final String title,
      @JsonKey(fromJson: _typeFromJson, toJson: _typeToJson)
      required final StudyPlanItemType type,
      final bool isDone,
      final String avatarId,
      final String reason,
      final DateTime? scheduledDate}) = _$StudyPlanItemImpl;

  factory _StudyPlanItem.fromJson(Map<String, dynamic> json) =
      _$StudyPlanItemImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  @JsonKey(fromJson: _typeFromJson, toJson: _typeToJson)
  StudyPlanItemType get type;
  @override
  bool get isDone;
  @override
  String get avatarId;
  @override
  String get reason;
  @override
  DateTime? get scheduledDate;

  /// Create a copy of StudyPlanItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StudyPlanItemImplCopyWith<_$StudyPlanItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
