// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'progress_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

WeakTopic _$WeakTopicFromJson(Map<String, dynamic> json) {
  return _WeakTopic.fromJson(json);
}

/// @nodoc
mixin _$WeakTopic {
  String get topic => throw _privateConstructorUsedError;
  double get mastery => throw _privateConstructorUsedError;

  /// Serializes this WeakTopic to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WeakTopic
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WeakTopicCopyWith<WeakTopic> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeakTopicCopyWith<$Res> {
  factory $WeakTopicCopyWith(WeakTopic value, $Res Function(WeakTopic) then) =
      _$WeakTopicCopyWithImpl<$Res, WeakTopic>;
  @useResult
  $Res call({String topic, double mastery});
}

/// @nodoc
class _$WeakTopicCopyWithImpl<$Res, $Val extends WeakTopic>
    implements $WeakTopicCopyWith<$Res> {
  _$WeakTopicCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WeakTopic
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? topic = null,
    Object? mastery = null,
  }) {
    return _then(_value.copyWith(
      topic: null == topic
          ? _value.topic
          : topic // ignore: cast_nullable_to_non_nullable
              as String,
      mastery: null == mastery
          ? _value.mastery
          : mastery // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WeakTopicImplCopyWith<$Res>
    implements $WeakTopicCopyWith<$Res> {
  factory _$$WeakTopicImplCopyWith(
          _$WeakTopicImpl value, $Res Function(_$WeakTopicImpl) then) =
      __$$WeakTopicImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String topic, double mastery});
}

/// @nodoc
class __$$WeakTopicImplCopyWithImpl<$Res>
    extends _$WeakTopicCopyWithImpl<$Res, _$WeakTopicImpl>
    implements _$$WeakTopicImplCopyWith<$Res> {
  __$$WeakTopicImplCopyWithImpl(
      _$WeakTopicImpl _value, $Res Function(_$WeakTopicImpl) _then)
      : super(_value, _then);

  /// Create a copy of WeakTopic
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? topic = null,
    Object? mastery = null,
  }) {
    return _then(_$WeakTopicImpl(
      topic: null == topic
          ? _value.topic
          : topic // ignore: cast_nullable_to_non_nullable
              as String,
      mastery: null == mastery
          ? _value.mastery
          : mastery // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WeakTopicImpl implements _WeakTopic {
  const _$WeakTopicImpl({required this.topic, required this.mastery});

  factory _$WeakTopicImpl.fromJson(Map<String, dynamic> json) =>
      _$$WeakTopicImplFromJson(json);

  @override
  final String topic;
  @override
  final double mastery;

  @override
  String toString() {
    return 'WeakTopic(topic: $topic, mastery: $mastery)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeakTopicImpl &&
            (identical(other.topic, topic) || other.topic == topic) &&
            (identical(other.mastery, mastery) || other.mastery == mastery));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, topic, mastery);

  /// Create a copy of WeakTopic
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WeakTopicImplCopyWith<_$WeakTopicImpl> get copyWith =>
      __$$WeakTopicImplCopyWithImpl<_$WeakTopicImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WeakTopicImplToJson(
      this,
    );
  }
}

abstract class _WeakTopic implements WeakTopic {
  const factory _WeakTopic(
      {required final String topic,
      required final double mastery}) = _$WeakTopicImpl;

  factory _WeakTopic.fromJson(Map<String, dynamic> json) =
      _$WeakTopicImpl.fromJson;

  @override
  String get topic;
  @override
  double get mastery;

  /// Create a copy of WeakTopic
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WeakTopicImplCopyWith<_$WeakTopicImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ProgressSummary _$ProgressSummaryFromJson(Map<String, dynamic> json) {
  return _ProgressSummary.fromJson(json);
}

/// @nodoc
mixin _$ProgressSummary {
  int get level => throw _privateConstructorUsedError;
  int get xp => throw _privateConstructorUsedError;
  int get xpToNextLevel => throw _privateConstructorUsedError;
  int get streakDays => throw _privateConstructorUsedError;
  List<int> get weekMinutes => throw _privateConstructorUsedError;
  List<WeakTopic> get weakTopics => throw _privateConstructorUsedError;
  List<String> get badges => throw _privateConstructorUsedError;

  /// Serializes this ProgressSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProgressSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProgressSummaryCopyWith<ProgressSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProgressSummaryCopyWith<$Res> {
  factory $ProgressSummaryCopyWith(
          ProgressSummary value, $Res Function(ProgressSummary) then) =
      _$ProgressSummaryCopyWithImpl<$Res, ProgressSummary>;
  @useResult
  $Res call(
      {int level,
      int xp,
      int xpToNextLevel,
      int streakDays,
      List<int> weekMinutes,
      List<WeakTopic> weakTopics,
      List<String> badges});
}

/// @nodoc
class _$ProgressSummaryCopyWithImpl<$Res, $Val extends ProgressSummary>
    implements $ProgressSummaryCopyWith<$Res> {
  _$ProgressSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProgressSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? level = null,
    Object? xp = null,
    Object? xpToNextLevel = null,
    Object? streakDays = null,
    Object? weekMinutes = null,
    Object? weakTopics = null,
    Object? badges = null,
  }) {
    return _then(_value.copyWith(
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as int,
      xp: null == xp
          ? _value.xp
          : xp // ignore: cast_nullable_to_non_nullable
              as int,
      xpToNextLevel: null == xpToNextLevel
          ? _value.xpToNextLevel
          : xpToNextLevel // ignore: cast_nullable_to_non_nullable
              as int,
      streakDays: null == streakDays
          ? _value.streakDays
          : streakDays // ignore: cast_nullable_to_non_nullable
              as int,
      weekMinutes: null == weekMinutes
          ? _value.weekMinutes
          : weekMinutes // ignore: cast_nullable_to_non_nullable
              as List<int>,
      weakTopics: null == weakTopics
          ? _value.weakTopics
          : weakTopics // ignore: cast_nullable_to_non_nullable
              as List<WeakTopic>,
      badges: null == badges
          ? _value.badges
          : badges // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProgressSummaryImplCopyWith<$Res>
    implements $ProgressSummaryCopyWith<$Res> {
  factory _$$ProgressSummaryImplCopyWith(_$ProgressSummaryImpl value,
          $Res Function(_$ProgressSummaryImpl) then) =
      __$$ProgressSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int level,
      int xp,
      int xpToNextLevel,
      int streakDays,
      List<int> weekMinutes,
      List<WeakTopic> weakTopics,
      List<String> badges});
}

/// @nodoc
class __$$ProgressSummaryImplCopyWithImpl<$Res>
    extends _$ProgressSummaryCopyWithImpl<$Res, _$ProgressSummaryImpl>
    implements _$$ProgressSummaryImplCopyWith<$Res> {
  __$$ProgressSummaryImplCopyWithImpl(
      _$ProgressSummaryImpl _value, $Res Function(_$ProgressSummaryImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProgressSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? level = null,
    Object? xp = null,
    Object? xpToNextLevel = null,
    Object? streakDays = null,
    Object? weekMinutes = null,
    Object? weakTopics = null,
    Object? badges = null,
  }) {
    return _then(_$ProgressSummaryImpl(
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as int,
      xp: null == xp
          ? _value.xp
          : xp // ignore: cast_nullable_to_non_nullable
              as int,
      xpToNextLevel: null == xpToNextLevel
          ? _value.xpToNextLevel
          : xpToNextLevel // ignore: cast_nullable_to_non_nullable
              as int,
      streakDays: null == streakDays
          ? _value.streakDays
          : streakDays // ignore: cast_nullable_to_non_nullable
              as int,
      weekMinutes: null == weekMinutes
          ? _value._weekMinutes
          : weekMinutes // ignore: cast_nullable_to_non_nullable
              as List<int>,
      weakTopics: null == weakTopics
          ? _value._weakTopics
          : weakTopics // ignore: cast_nullable_to_non_nullable
              as List<WeakTopic>,
      badges: null == badges
          ? _value._badges
          : badges // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProgressSummaryImpl implements _ProgressSummary {
  const _$ProgressSummaryImpl(
      {required this.level,
      required this.xp,
      required this.xpToNextLevel,
      this.streakDays = 0,
      final List<int> weekMinutes = const [],
      final List<WeakTopic> weakTopics = const [],
      final List<String> badges = const []})
      : _weekMinutes = weekMinutes,
        _weakTopics = weakTopics,
        _badges = badges;

  factory _$ProgressSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProgressSummaryImplFromJson(json);

  @override
  final int level;
  @override
  final int xp;
  @override
  final int xpToNextLevel;
  @override
  @JsonKey()
  final int streakDays;
  final List<int> _weekMinutes;
  @override
  @JsonKey()
  List<int> get weekMinutes {
    if (_weekMinutes is EqualUnmodifiableListView) return _weekMinutes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_weekMinutes);
  }

  final List<WeakTopic> _weakTopics;
  @override
  @JsonKey()
  List<WeakTopic> get weakTopics {
    if (_weakTopics is EqualUnmodifiableListView) return _weakTopics;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_weakTopics);
  }

  final List<String> _badges;
  @override
  @JsonKey()
  List<String> get badges {
    if (_badges is EqualUnmodifiableListView) return _badges;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_badges);
  }

  @override
  String toString() {
    return 'ProgressSummary(level: $level, xp: $xp, xpToNextLevel: $xpToNextLevel, streakDays: $streakDays, weekMinutes: $weekMinutes, weakTopics: $weakTopics, badges: $badges)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProgressSummaryImpl &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.xp, xp) || other.xp == xp) &&
            (identical(other.xpToNextLevel, xpToNextLevel) ||
                other.xpToNextLevel == xpToNextLevel) &&
            (identical(other.streakDays, streakDays) ||
                other.streakDays == streakDays) &&
            const DeepCollectionEquality()
                .equals(other._weekMinutes, _weekMinutes) &&
            const DeepCollectionEquality()
                .equals(other._weakTopics, _weakTopics) &&
            const DeepCollectionEquality().equals(other._badges, _badges));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      level,
      xp,
      xpToNextLevel,
      streakDays,
      const DeepCollectionEquality().hash(_weekMinutes),
      const DeepCollectionEquality().hash(_weakTopics),
      const DeepCollectionEquality().hash(_badges));

  /// Create a copy of ProgressSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProgressSummaryImplCopyWith<_$ProgressSummaryImpl> get copyWith =>
      __$$ProgressSummaryImplCopyWithImpl<_$ProgressSummaryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProgressSummaryImplToJson(
      this,
    );
  }
}

abstract class _ProgressSummary implements ProgressSummary {
  const factory _ProgressSummary(
      {required final int level,
      required final int xp,
      required final int xpToNextLevel,
      final int streakDays,
      final List<int> weekMinutes,
      final List<WeakTopic> weakTopics,
      final List<String> badges}) = _$ProgressSummaryImpl;

  factory _ProgressSummary.fromJson(Map<String, dynamic> json) =
      _$ProgressSummaryImpl.fromJson;

  @override
  int get level;
  @override
  int get xp;
  @override
  int get xpToNextLevel;
  @override
  int get streakDays;
  @override
  List<int> get weekMinutes;
  @override
  List<WeakTopic> get weakTopics;
  @override
  List<String> get badges;

  /// Create a copy of ProgressSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProgressSummaryImplCopyWith<_$ProgressSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
