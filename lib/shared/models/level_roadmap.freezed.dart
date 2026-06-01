// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'level_roadmap.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LevelReward _$LevelRewardFromJson(Map<String, dynamic> json) {
  return _LevelReward.fromJson(json);
}

/// @nodoc
mixin _$LevelReward {
  int get level => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;
  String get kind =>
      throw _privateConstructorUsedError; // COSMETIC | FUNCTIONAL | BADGE | MYSTERY
  bool get unlocked => throw _privateConstructorUsedError;

  /// Serializes this LevelReward to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LevelReward
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LevelRewardCopyWith<LevelReward> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LevelRewardCopyWith<$Res> {
  factory $LevelRewardCopyWith(
          LevelReward value, $Res Function(LevelReward) then) =
      _$LevelRewardCopyWithImpl<$Res, LevelReward>;
  @useResult
  $Res call({int level, String label, String kind, bool unlocked});
}

/// @nodoc
class _$LevelRewardCopyWithImpl<$Res, $Val extends LevelReward>
    implements $LevelRewardCopyWith<$Res> {
  _$LevelRewardCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LevelReward
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? level = null,
    Object? label = null,
    Object? kind = null,
    Object? unlocked = null,
  }) {
    return _then(_value.copyWith(
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as int,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      kind: null == kind
          ? _value.kind
          : kind // ignore: cast_nullable_to_non_nullable
              as String,
      unlocked: null == unlocked
          ? _value.unlocked
          : unlocked // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LevelRewardImplCopyWith<$Res>
    implements $LevelRewardCopyWith<$Res> {
  factory _$$LevelRewardImplCopyWith(
          _$LevelRewardImpl value, $Res Function(_$LevelRewardImpl) then) =
      __$$LevelRewardImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int level, String label, String kind, bool unlocked});
}

/// @nodoc
class __$$LevelRewardImplCopyWithImpl<$Res>
    extends _$LevelRewardCopyWithImpl<$Res, _$LevelRewardImpl>
    implements _$$LevelRewardImplCopyWith<$Res> {
  __$$LevelRewardImplCopyWithImpl(
      _$LevelRewardImpl _value, $Res Function(_$LevelRewardImpl) _then)
      : super(_value, _then);

  /// Create a copy of LevelReward
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? level = null,
    Object? label = null,
    Object? kind = null,
    Object? unlocked = null,
  }) {
    return _then(_$LevelRewardImpl(
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as int,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      kind: null == kind
          ? _value.kind
          : kind // ignore: cast_nullable_to_non_nullable
              as String,
      unlocked: null == unlocked
          ? _value.unlocked
          : unlocked // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LevelRewardImpl implements _LevelReward {
  const _$LevelRewardImpl(
      {this.level = 0,
      this.label = '',
      this.kind = 'COSMETIC',
      this.unlocked = false});

  factory _$LevelRewardImpl.fromJson(Map<String, dynamic> json) =>
      _$$LevelRewardImplFromJson(json);

  @override
  @JsonKey()
  final int level;
  @override
  @JsonKey()
  final String label;
  @override
  @JsonKey()
  final String kind;
// COSMETIC | FUNCTIONAL | BADGE | MYSTERY
  @override
  @JsonKey()
  final bool unlocked;

  @override
  String toString() {
    return 'LevelReward(level: $level, label: $label, kind: $kind, unlocked: $unlocked)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LevelRewardImpl &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.kind, kind) || other.kind == kind) &&
            (identical(other.unlocked, unlocked) ||
                other.unlocked == unlocked));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, level, label, kind, unlocked);

  /// Create a copy of LevelReward
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LevelRewardImplCopyWith<_$LevelRewardImpl> get copyWith =>
      __$$LevelRewardImplCopyWithImpl<_$LevelRewardImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LevelRewardImplToJson(
      this,
    );
  }
}

abstract class _LevelReward implements LevelReward {
  const factory _LevelReward(
      {final int level,
      final String label,
      final String kind,
      final bool unlocked}) = _$LevelRewardImpl;

  factory _LevelReward.fromJson(Map<String, dynamic> json) =
      _$LevelRewardImpl.fromJson;

  @override
  int get level;
  @override
  String get label;
  @override
  String get kind; // COSMETIC | FUNCTIONAL | BADGE | MYSTERY
  @override
  bool get unlocked;

  /// Create a copy of LevelReward
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LevelRewardImplCopyWith<_$LevelRewardImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LevelRoadmap _$LevelRoadmapFromJson(Map<String, dynamic> json) {
  return _LevelRoadmap.fromJson(json);
}

/// @nodoc
mixin _$LevelRoadmap {
  int get currentLevel => throw _privateConstructorUsedError;
  int get maxLevel => throw _privateConstructorUsedError;
  List<LevelReward> get rewards => throw _privateConstructorUsedError;

  /// Serializes this LevelRoadmap to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LevelRoadmap
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LevelRoadmapCopyWith<LevelRoadmap> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LevelRoadmapCopyWith<$Res> {
  factory $LevelRoadmapCopyWith(
          LevelRoadmap value, $Res Function(LevelRoadmap) then) =
      _$LevelRoadmapCopyWithImpl<$Res, LevelRoadmap>;
  @useResult
  $Res call({int currentLevel, int maxLevel, List<LevelReward> rewards});
}

/// @nodoc
class _$LevelRoadmapCopyWithImpl<$Res, $Val extends LevelRoadmap>
    implements $LevelRoadmapCopyWith<$Res> {
  _$LevelRoadmapCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LevelRoadmap
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentLevel = null,
    Object? maxLevel = null,
    Object? rewards = null,
  }) {
    return _then(_value.copyWith(
      currentLevel: null == currentLevel
          ? _value.currentLevel
          : currentLevel // ignore: cast_nullable_to_non_nullable
              as int,
      maxLevel: null == maxLevel
          ? _value.maxLevel
          : maxLevel // ignore: cast_nullable_to_non_nullable
              as int,
      rewards: null == rewards
          ? _value.rewards
          : rewards // ignore: cast_nullable_to_non_nullable
              as List<LevelReward>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LevelRoadmapImplCopyWith<$Res>
    implements $LevelRoadmapCopyWith<$Res> {
  factory _$$LevelRoadmapImplCopyWith(
          _$LevelRoadmapImpl value, $Res Function(_$LevelRoadmapImpl) then) =
      __$$LevelRoadmapImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int currentLevel, int maxLevel, List<LevelReward> rewards});
}

/// @nodoc
class __$$LevelRoadmapImplCopyWithImpl<$Res>
    extends _$LevelRoadmapCopyWithImpl<$Res, _$LevelRoadmapImpl>
    implements _$$LevelRoadmapImplCopyWith<$Res> {
  __$$LevelRoadmapImplCopyWithImpl(
      _$LevelRoadmapImpl _value, $Res Function(_$LevelRoadmapImpl) _then)
      : super(_value, _then);

  /// Create a copy of LevelRoadmap
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentLevel = null,
    Object? maxLevel = null,
    Object? rewards = null,
  }) {
    return _then(_$LevelRoadmapImpl(
      currentLevel: null == currentLevel
          ? _value.currentLevel
          : currentLevel // ignore: cast_nullable_to_non_nullable
              as int,
      maxLevel: null == maxLevel
          ? _value.maxLevel
          : maxLevel // ignore: cast_nullable_to_non_nullable
              as int,
      rewards: null == rewards
          ? _value._rewards
          : rewards // ignore: cast_nullable_to_non_nullable
              as List<LevelReward>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LevelRoadmapImpl implements _LevelRoadmap {
  const _$LevelRoadmapImpl(
      {this.currentLevel = 1,
      this.maxLevel = 30,
      final List<LevelReward> rewards = const []})
      : _rewards = rewards;

  factory _$LevelRoadmapImpl.fromJson(Map<String, dynamic> json) =>
      _$$LevelRoadmapImplFromJson(json);

  @override
  @JsonKey()
  final int currentLevel;
  @override
  @JsonKey()
  final int maxLevel;
  final List<LevelReward> _rewards;
  @override
  @JsonKey()
  List<LevelReward> get rewards {
    if (_rewards is EqualUnmodifiableListView) return _rewards;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_rewards);
  }

  @override
  String toString() {
    return 'LevelRoadmap(currentLevel: $currentLevel, maxLevel: $maxLevel, rewards: $rewards)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LevelRoadmapImpl &&
            (identical(other.currentLevel, currentLevel) ||
                other.currentLevel == currentLevel) &&
            (identical(other.maxLevel, maxLevel) ||
                other.maxLevel == maxLevel) &&
            const DeepCollectionEquality().equals(other._rewards, _rewards));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, currentLevel, maxLevel,
      const DeepCollectionEquality().hash(_rewards));

  /// Create a copy of LevelRoadmap
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LevelRoadmapImplCopyWith<_$LevelRoadmapImpl> get copyWith =>
      __$$LevelRoadmapImplCopyWithImpl<_$LevelRoadmapImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LevelRoadmapImplToJson(
      this,
    );
  }
}

abstract class _LevelRoadmap implements LevelRoadmap {
  const factory _LevelRoadmap(
      {final int currentLevel,
      final int maxLevel,
      final List<LevelReward> rewards}) = _$LevelRoadmapImpl;

  factory _LevelRoadmap.fromJson(Map<String, dynamic> json) =
      _$LevelRoadmapImpl.fromJson;

  @override
  int get currentLevel;
  @override
  int get maxLevel;
  @override
  List<LevelReward> get rewards;

  /// Create a copy of LevelRoadmap
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LevelRoadmapImplCopyWith<_$LevelRoadmapImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
