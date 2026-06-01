// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_goal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DailyGoal _$DailyGoalFromJson(Map<String, dynamic> json) {
  return _DailyGoal.fromJson(json);
}

/// @nodoc
mixin _$DailyGoal {
  String get goalType => throw _privateConstructorUsedError;
  int get goalTarget => throw _privateConstructorUsedError;
  int get goalProgress => throw _privateConstructorUsedError;
  bool get met => throw _privateConstructorUsedError;

  /// Serializes this DailyGoal to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DailyGoal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DailyGoalCopyWith<DailyGoal> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyGoalCopyWith<$Res> {
  factory $DailyGoalCopyWith(DailyGoal value, $Res Function(DailyGoal) then) =
      _$DailyGoalCopyWithImpl<$Res, DailyGoal>;
  @useResult
  $Res call({String goalType, int goalTarget, int goalProgress, bool met});
}

/// @nodoc
class _$DailyGoalCopyWithImpl<$Res, $Val extends DailyGoal>
    implements $DailyGoalCopyWith<$Res> {
  _$DailyGoalCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailyGoal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? goalType = null,
    Object? goalTarget = null,
    Object? goalProgress = null,
    Object? met = null,
  }) {
    return _then(_value.copyWith(
      goalType: null == goalType
          ? _value.goalType
          : goalType // ignore: cast_nullable_to_non_nullable
              as String,
      goalTarget: null == goalTarget
          ? _value.goalTarget
          : goalTarget // ignore: cast_nullable_to_non_nullable
              as int,
      goalProgress: null == goalProgress
          ? _value.goalProgress
          : goalProgress // ignore: cast_nullable_to_non_nullable
              as int,
      met: null == met
          ? _value.met
          : met // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DailyGoalImplCopyWith<$Res>
    implements $DailyGoalCopyWith<$Res> {
  factory _$$DailyGoalImplCopyWith(
          _$DailyGoalImpl value, $Res Function(_$DailyGoalImpl) then) =
      __$$DailyGoalImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String goalType, int goalTarget, int goalProgress, bool met});
}

/// @nodoc
class __$$DailyGoalImplCopyWithImpl<$Res>
    extends _$DailyGoalCopyWithImpl<$Res, _$DailyGoalImpl>
    implements _$$DailyGoalImplCopyWith<$Res> {
  __$$DailyGoalImplCopyWithImpl(
      _$DailyGoalImpl _value, $Res Function(_$DailyGoalImpl) _then)
      : super(_value, _then);

  /// Create a copy of DailyGoal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? goalType = null,
    Object? goalTarget = null,
    Object? goalProgress = null,
    Object? met = null,
  }) {
    return _then(_$DailyGoalImpl(
      goalType: null == goalType
          ? _value.goalType
          : goalType // ignore: cast_nullable_to_non_nullable
              as String,
      goalTarget: null == goalTarget
          ? _value.goalTarget
          : goalTarget // ignore: cast_nullable_to_non_nullable
              as int,
      goalProgress: null == goalProgress
          ? _value.goalProgress
          : goalProgress // ignore: cast_nullable_to_non_nullable
              as int,
      met: null == met
          ? _value.met
          : met // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DailyGoalImpl implements _DailyGoal {
  const _$DailyGoalImpl(
      {this.goalType = 'QUIZ',
      this.goalTarget = 0,
      this.goalProgress = 0,
      this.met = false});

  factory _$DailyGoalImpl.fromJson(Map<String, dynamic> json) =>
      _$$DailyGoalImplFromJson(json);

  @override
  @JsonKey()
  final String goalType;
  @override
  @JsonKey()
  final int goalTarget;
  @override
  @JsonKey()
  final int goalProgress;
  @override
  @JsonKey()
  final bool met;

  @override
  String toString() {
    return 'DailyGoal(goalType: $goalType, goalTarget: $goalTarget, goalProgress: $goalProgress, met: $met)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyGoalImpl &&
            (identical(other.goalType, goalType) ||
                other.goalType == goalType) &&
            (identical(other.goalTarget, goalTarget) ||
                other.goalTarget == goalTarget) &&
            (identical(other.goalProgress, goalProgress) ||
                other.goalProgress == goalProgress) &&
            (identical(other.met, met) || other.met == met));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, goalType, goalTarget, goalProgress, met);

  /// Create a copy of DailyGoal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyGoalImplCopyWith<_$DailyGoalImpl> get copyWith =>
      __$$DailyGoalImplCopyWithImpl<_$DailyGoalImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DailyGoalImplToJson(
      this,
    );
  }
}

abstract class _DailyGoal implements DailyGoal {
  const factory _DailyGoal(
      {final String goalType,
      final int goalTarget,
      final int goalProgress,
      final bool met}) = _$DailyGoalImpl;

  factory _DailyGoal.fromJson(Map<String, dynamic> json) =
      _$DailyGoalImpl.fromJson;

  @override
  String get goalType;
  @override
  int get goalTarget;
  @override
  int get goalProgress;
  @override
  bool get met;

  /// Create a copy of DailyGoal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailyGoalImplCopyWith<_$DailyGoalImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
