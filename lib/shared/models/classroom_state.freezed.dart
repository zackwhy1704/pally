// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'classroom_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ClassroomState _$ClassroomStateFromJson(Map<String, dynamic> json) {
  return _ClassroomState.fromJson(json);
}

/// @nodoc
mixin _$ClassroomState {
  String get sessionId => throw _privateConstructorUsedError;
  String get status =>
      throw _privateConstructorUsedError; // CREATED | ACTIVE | ENDED
  String get topicSlug => throw _privateConstructorUsedError;
  int get hpRemaining => throw _privateConstructorUsedError;
  int get hpMax => throw _privateConstructorUsedError;
  bool get defeated => throw _privateConstructorUsedError;
  int get participantCount => throw _privateConstructorUsedError;
  QuizQuestion? get currentQuestion => throw _privateConstructorUsedError;

  /// Serializes this ClassroomState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ClassroomState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ClassroomStateCopyWith<ClassroomState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClassroomStateCopyWith<$Res> {
  factory $ClassroomStateCopyWith(
          ClassroomState value, $Res Function(ClassroomState) then) =
      _$ClassroomStateCopyWithImpl<$Res, ClassroomState>;
  @useResult
  $Res call(
      {String sessionId,
      String status,
      String topicSlug,
      int hpRemaining,
      int hpMax,
      bool defeated,
      int participantCount,
      QuizQuestion? currentQuestion});

  $QuizQuestionCopyWith<$Res>? get currentQuestion;
}

/// @nodoc
class _$ClassroomStateCopyWithImpl<$Res, $Val extends ClassroomState>
    implements $ClassroomStateCopyWith<$Res> {
  _$ClassroomStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ClassroomState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
    Object? status = null,
    Object? topicSlug = null,
    Object? hpRemaining = null,
    Object? hpMax = null,
    Object? defeated = null,
    Object? participantCount = null,
    Object? currentQuestion = freezed,
  }) {
    return _then(_value.copyWith(
      sessionId: null == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      topicSlug: null == topicSlug
          ? _value.topicSlug
          : topicSlug // ignore: cast_nullable_to_non_nullable
              as String,
      hpRemaining: null == hpRemaining
          ? _value.hpRemaining
          : hpRemaining // ignore: cast_nullable_to_non_nullable
              as int,
      hpMax: null == hpMax
          ? _value.hpMax
          : hpMax // ignore: cast_nullable_to_non_nullable
              as int,
      defeated: null == defeated
          ? _value.defeated
          : defeated // ignore: cast_nullable_to_non_nullable
              as bool,
      participantCount: null == participantCount
          ? _value.participantCount
          : participantCount // ignore: cast_nullable_to_non_nullable
              as int,
      currentQuestion: freezed == currentQuestion
          ? _value.currentQuestion
          : currentQuestion // ignore: cast_nullable_to_non_nullable
              as QuizQuestion?,
    ) as $Val);
  }

  /// Create a copy of ClassroomState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $QuizQuestionCopyWith<$Res>? get currentQuestion {
    if (_value.currentQuestion == null) {
      return null;
    }

    return $QuizQuestionCopyWith<$Res>(_value.currentQuestion!, (value) {
      return _then(_value.copyWith(currentQuestion: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ClassroomStateImplCopyWith<$Res>
    implements $ClassroomStateCopyWith<$Res> {
  factory _$$ClassroomStateImplCopyWith(_$ClassroomStateImpl value,
          $Res Function(_$ClassroomStateImpl) then) =
      __$$ClassroomStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String sessionId,
      String status,
      String topicSlug,
      int hpRemaining,
      int hpMax,
      bool defeated,
      int participantCount,
      QuizQuestion? currentQuestion});

  @override
  $QuizQuestionCopyWith<$Res>? get currentQuestion;
}

/// @nodoc
class __$$ClassroomStateImplCopyWithImpl<$Res>
    extends _$ClassroomStateCopyWithImpl<$Res, _$ClassroomStateImpl>
    implements _$$ClassroomStateImplCopyWith<$Res> {
  __$$ClassroomStateImplCopyWithImpl(
      _$ClassroomStateImpl _value, $Res Function(_$ClassroomStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of ClassroomState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
    Object? status = null,
    Object? topicSlug = null,
    Object? hpRemaining = null,
    Object? hpMax = null,
    Object? defeated = null,
    Object? participantCount = null,
    Object? currentQuestion = freezed,
  }) {
    return _then(_$ClassroomStateImpl(
      sessionId: null == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      topicSlug: null == topicSlug
          ? _value.topicSlug
          : topicSlug // ignore: cast_nullable_to_non_nullable
              as String,
      hpRemaining: null == hpRemaining
          ? _value.hpRemaining
          : hpRemaining // ignore: cast_nullable_to_non_nullable
              as int,
      hpMax: null == hpMax
          ? _value.hpMax
          : hpMax // ignore: cast_nullable_to_non_nullable
              as int,
      defeated: null == defeated
          ? _value.defeated
          : defeated // ignore: cast_nullable_to_non_nullable
              as bool,
      participantCount: null == participantCount
          ? _value.participantCount
          : participantCount // ignore: cast_nullable_to_non_nullable
              as int,
      currentQuestion: freezed == currentQuestion
          ? _value.currentQuestion
          : currentQuestion // ignore: cast_nullable_to_non_nullable
              as QuizQuestion?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ClassroomStateImpl implements _ClassroomState {
  const _$ClassroomStateImpl(
      {required this.sessionId,
      required this.status,
      required this.topicSlug,
      required this.hpRemaining,
      required this.hpMax,
      this.defeated = false,
      this.participantCount = 0,
      this.currentQuestion});

  factory _$ClassroomStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$ClassroomStateImplFromJson(json);

  @override
  final String sessionId;
  @override
  final String status;
// CREATED | ACTIVE | ENDED
  @override
  final String topicSlug;
  @override
  final int hpRemaining;
  @override
  final int hpMax;
  @override
  @JsonKey()
  final bool defeated;
  @override
  @JsonKey()
  final int participantCount;
  @override
  final QuizQuestion? currentQuestion;

  @override
  String toString() {
    return 'ClassroomState(sessionId: $sessionId, status: $status, topicSlug: $topicSlug, hpRemaining: $hpRemaining, hpMax: $hpMax, defeated: $defeated, participantCount: $participantCount, currentQuestion: $currentQuestion)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClassroomStateImpl &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.topicSlug, topicSlug) ||
                other.topicSlug == topicSlug) &&
            (identical(other.hpRemaining, hpRemaining) ||
                other.hpRemaining == hpRemaining) &&
            (identical(other.hpMax, hpMax) || other.hpMax == hpMax) &&
            (identical(other.defeated, defeated) ||
                other.defeated == defeated) &&
            (identical(other.participantCount, participantCount) ||
                other.participantCount == participantCount) &&
            (identical(other.currentQuestion, currentQuestion) ||
                other.currentQuestion == currentQuestion));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, sessionId, status, topicSlug,
      hpRemaining, hpMax, defeated, participantCount, currentQuestion);

  /// Create a copy of ClassroomState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ClassroomStateImplCopyWith<_$ClassroomStateImpl> get copyWith =>
      __$$ClassroomStateImplCopyWithImpl<_$ClassroomStateImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ClassroomStateImplToJson(
      this,
    );
  }
}

abstract class _ClassroomState implements ClassroomState {
  const factory _ClassroomState(
      {required final String sessionId,
      required final String status,
      required final String topicSlug,
      required final int hpRemaining,
      required final int hpMax,
      final bool defeated,
      final int participantCount,
      final QuizQuestion? currentQuestion}) = _$ClassroomStateImpl;

  factory _ClassroomState.fromJson(Map<String, dynamic> json) =
      _$ClassroomStateImpl.fromJson;

  @override
  String get sessionId;
  @override
  String get status; // CREATED | ACTIVE | ENDED
  @override
  String get topicSlug;
  @override
  int get hpRemaining;
  @override
  int get hpMax;
  @override
  bool get defeated;
  @override
  int get participantCount;
  @override
  QuizQuestion? get currentQuestion;

  /// Create a copy of ClassroomState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ClassroomStateImplCopyWith<_$ClassroomStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
