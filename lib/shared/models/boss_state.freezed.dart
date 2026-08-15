// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'boss_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BossState _$BossStateFromJson(Map<String, dynamic> json) {
  return _BossState.fromJson(json);
}

/// @nodoc
mixin _$BossState {
  bool get active => throw _privateConstructorUsedError;
  String? get id => throw _privateConstructorUsedError;
  String? get topicSlug => throw _privateConstructorUsedError;
  int get hpRemaining => throw _privateConstructorUsedError;
  int get hpMax => throw _privateConstructorUsedError;
  bool get defeated => throw _privateConstructorUsedError;
  bool get rewardUnlocked => throw _privateConstructorUsedError;
  QuizQuestion? get currentQuestion => throw _privateConstructorUsedError;

  /// Serializes this BossState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BossState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BossStateCopyWith<BossState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BossStateCopyWith<$Res> {
  factory $BossStateCopyWith(BossState value, $Res Function(BossState) then) =
      _$BossStateCopyWithImpl<$Res, BossState>;
  @useResult
  $Res call(
      {bool active,
      String? id,
      String? topicSlug,
      int hpRemaining,
      int hpMax,
      bool defeated,
      bool rewardUnlocked,
      QuizQuestion? currentQuestion});

  $QuizQuestionCopyWith<$Res>? get currentQuestion;
}

/// @nodoc
class _$BossStateCopyWithImpl<$Res, $Val extends BossState>
    implements $BossStateCopyWith<$Res> {
  _$BossStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BossState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? active = null,
    Object? id = freezed,
    Object? topicSlug = freezed,
    Object? hpRemaining = null,
    Object? hpMax = null,
    Object? defeated = null,
    Object? rewardUnlocked = null,
    Object? currentQuestion = freezed,
  }) {
    return _then(_value.copyWith(
      active: null == active
          ? _value.active
          : active // ignore: cast_nullable_to_non_nullable
              as bool,
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      topicSlug: freezed == topicSlug
          ? _value.topicSlug
          : topicSlug // ignore: cast_nullable_to_non_nullable
              as String?,
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
      rewardUnlocked: null == rewardUnlocked
          ? _value.rewardUnlocked
          : rewardUnlocked // ignore: cast_nullable_to_non_nullable
              as bool,
      currentQuestion: freezed == currentQuestion
          ? _value.currentQuestion
          : currentQuestion // ignore: cast_nullable_to_non_nullable
              as QuizQuestion?,
    ) as $Val);
  }

  /// Create a copy of BossState
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
abstract class _$$BossStateImplCopyWith<$Res>
    implements $BossStateCopyWith<$Res> {
  factory _$$BossStateImplCopyWith(
          _$BossStateImpl value, $Res Function(_$BossStateImpl) then) =
      __$$BossStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool active,
      String? id,
      String? topicSlug,
      int hpRemaining,
      int hpMax,
      bool defeated,
      bool rewardUnlocked,
      QuizQuestion? currentQuestion});

  @override
  $QuizQuestionCopyWith<$Res>? get currentQuestion;
}

/// @nodoc
class __$$BossStateImplCopyWithImpl<$Res>
    extends _$BossStateCopyWithImpl<$Res, _$BossStateImpl>
    implements _$$BossStateImplCopyWith<$Res> {
  __$$BossStateImplCopyWithImpl(
      _$BossStateImpl _value, $Res Function(_$BossStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of BossState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? active = null,
    Object? id = freezed,
    Object? topicSlug = freezed,
    Object? hpRemaining = null,
    Object? hpMax = null,
    Object? defeated = null,
    Object? rewardUnlocked = null,
    Object? currentQuestion = freezed,
  }) {
    return _then(_$BossStateImpl(
      active: null == active
          ? _value.active
          : active // ignore: cast_nullable_to_non_nullable
              as bool,
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      topicSlug: freezed == topicSlug
          ? _value.topicSlug
          : topicSlug // ignore: cast_nullable_to_non_nullable
              as String?,
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
      rewardUnlocked: null == rewardUnlocked
          ? _value.rewardUnlocked
          : rewardUnlocked // ignore: cast_nullable_to_non_nullable
              as bool,
      currentQuestion: freezed == currentQuestion
          ? _value.currentQuestion
          : currentQuestion // ignore: cast_nullable_to_non_nullable
              as QuizQuestion?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BossStateImpl implements _BossState {
  const _$BossStateImpl(
      {this.active = false,
      this.id,
      this.topicSlug,
      this.hpRemaining = 0,
      this.hpMax = 0,
      this.defeated = false,
      this.rewardUnlocked = false,
      this.currentQuestion});

  factory _$BossStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$BossStateImplFromJson(json);

  @override
  @JsonKey()
  final bool active;
  @override
  final String? id;
  @override
  final String? topicSlug;
  @override
  @JsonKey()
  final int hpRemaining;
  @override
  @JsonKey()
  final int hpMax;
  @override
  @JsonKey()
  final bool defeated;
  @override
  @JsonKey()
  final bool rewardUnlocked;
  @override
  final QuizQuestion? currentQuestion;

  @override
  String toString() {
    return 'BossState(active: $active, id: $id, topicSlug: $topicSlug, hpRemaining: $hpRemaining, hpMax: $hpMax, defeated: $defeated, rewardUnlocked: $rewardUnlocked, currentQuestion: $currentQuestion)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BossStateImpl &&
            (identical(other.active, active) || other.active == active) &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.topicSlug, topicSlug) ||
                other.topicSlug == topicSlug) &&
            (identical(other.hpRemaining, hpRemaining) ||
                other.hpRemaining == hpRemaining) &&
            (identical(other.hpMax, hpMax) || other.hpMax == hpMax) &&
            (identical(other.defeated, defeated) ||
                other.defeated == defeated) &&
            (identical(other.rewardUnlocked, rewardUnlocked) ||
                other.rewardUnlocked == rewardUnlocked) &&
            (identical(other.currentQuestion, currentQuestion) ||
                other.currentQuestion == currentQuestion));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, active, id, topicSlug,
      hpRemaining, hpMax, defeated, rewardUnlocked, currentQuestion);

  /// Create a copy of BossState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BossStateImplCopyWith<_$BossStateImpl> get copyWith =>
      __$$BossStateImplCopyWithImpl<_$BossStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BossStateImplToJson(
      this,
    );
  }
}

abstract class _BossState implements BossState {
  const factory _BossState(
      {final bool active,
      final String? id,
      final String? topicSlug,
      final int hpRemaining,
      final int hpMax,
      final bool defeated,
      final bool rewardUnlocked,
      final QuizQuestion? currentQuestion}) = _$BossStateImpl;

  factory _BossState.fromJson(Map<String, dynamic> json) =
      _$BossStateImpl.fromJson;

  @override
  bool get active;
  @override
  String? get id;
  @override
  String? get topicSlug;
  @override
  int get hpRemaining;
  @override
  int get hpMax;
  @override
  bool get defeated;
  @override
  bool get rewardUnlocked;
  @override
  QuizQuestion? get currentQuestion;

  /// Create a copy of BossState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BossStateImplCopyWith<_$BossStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BossAttackResult _$BossAttackResultFromJson(Map<String, dynamic> json) {
  return _BossAttackResult.fromJson(json);
}

/// @nodoc
mixin _$BossAttackResult {
  BossState get state => throw _privateConstructorUsedError;
  bool get hitLanded => throw _privateConstructorUsedError;

  /// Serializes this BossAttackResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BossAttackResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BossAttackResultCopyWith<BossAttackResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BossAttackResultCopyWith<$Res> {
  factory $BossAttackResultCopyWith(
          BossAttackResult value, $Res Function(BossAttackResult) then) =
      _$BossAttackResultCopyWithImpl<$Res, BossAttackResult>;
  @useResult
  $Res call({BossState state, bool hitLanded});

  $BossStateCopyWith<$Res> get state;
}

/// @nodoc
class _$BossAttackResultCopyWithImpl<$Res, $Val extends BossAttackResult>
    implements $BossAttackResultCopyWith<$Res> {
  _$BossAttackResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BossAttackResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? state = null,
    Object? hitLanded = null,
  }) {
    return _then(_value.copyWith(
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as BossState,
      hitLanded: null == hitLanded
          ? _value.hitLanded
          : hitLanded // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  /// Create a copy of BossAttackResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BossStateCopyWith<$Res> get state {
    return $BossStateCopyWith<$Res>(_value.state, (value) {
      return _then(_value.copyWith(state: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$BossAttackResultImplCopyWith<$Res>
    implements $BossAttackResultCopyWith<$Res> {
  factory _$$BossAttackResultImplCopyWith(_$BossAttackResultImpl value,
          $Res Function(_$BossAttackResultImpl) then) =
      __$$BossAttackResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({BossState state, bool hitLanded});

  @override
  $BossStateCopyWith<$Res> get state;
}

/// @nodoc
class __$$BossAttackResultImplCopyWithImpl<$Res>
    extends _$BossAttackResultCopyWithImpl<$Res, _$BossAttackResultImpl>
    implements _$$BossAttackResultImplCopyWith<$Res> {
  __$$BossAttackResultImplCopyWithImpl(_$BossAttackResultImpl _value,
      $Res Function(_$BossAttackResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of BossAttackResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? state = null,
    Object? hitLanded = null,
  }) {
    return _then(_$BossAttackResultImpl(
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as BossState,
      hitLanded: null == hitLanded
          ? _value.hitLanded
          : hitLanded // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BossAttackResultImpl implements _BossAttackResult {
  const _$BossAttackResultImpl({required this.state, this.hitLanded = false});

  factory _$BossAttackResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$BossAttackResultImplFromJson(json);

  @override
  final BossState state;
  @override
  @JsonKey()
  final bool hitLanded;

  @override
  String toString() {
    return 'BossAttackResult(state: $state, hitLanded: $hitLanded)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BossAttackResultImpl &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.hitLanded, hitLanded) ||
                other.hitLanded == hitLanded));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, state, hitLanded);

  /// Create a copy of BossAttackResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BossAttackResultImplCopyWith<_$BossAttackResultImpl> get copyWith =>
      __$$BossAttackResultImplCopyWithImpl<_$BossAttackResultImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BossAttackResultImplToJson(
      this,
    );
  }
}

abstract class _BossAttackResult implements BossAttackResult {
  const factory _BossAttackResult(
      {required final BossState state,
      final bool hitLanded}) = _$BossAttackResultImpl;

  factory _BossAttackResult.fromJson(Map<String, dynamic> json) =
      _$BossAttackResultImpl.fromJson;

  @override
  BossState get state;
  @override
  bool get hitLanded;

  /// Create a copy of BossAttackResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BossAttackResultImplCopyWith<_$BossAttackResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
