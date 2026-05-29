// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'achievement.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Achievement _$AchievementFromJson(Map<String, dynamic> json) {
  return _Achievement.fromJson(json);
}

/// @nodoc
mixin _$Achievement {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get category =>
      throw _privateConstructorUsedError; // STREAK | MASTERY | CURIOSITY | MILESTONE
  String get rarity =>
      throw _privateConstructorUsedError; // COMMON | RARE | EPIC | LEGENDARY
  int get target => throw _privateConstructorUsedError;
  int get progress => throw _privateConstructorUsedError;
  bool get earned => throw _privateConstructorUsedError;
  String? get earnedAt => throw _privateConstructorUsedError;

  /// Serializes this Achievement to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Achievement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AchievementCopyWith<Achievement> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AchievementCopyWith<$Res> {
  factory $AchievementCopyWith(
          Achievement value, $Res Function(Achievement) then) =
      _$AchievementCopyWithImpl<$Res, Achievement>;
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      String category,
      String rarity,
      int target,
      int progress,
      bool earned,
      String? earnedAt});
}

/// @nodoc
class _$AchievementCopyWithImpl<$Res, $Val extends Achievement>
    implements $AchievementCopyWith<$Res> {
  _$AchievementCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Achievement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? category = null,
    Object? rarity = null,
    Object? target = null,
    Object? progress = null,
    Object? earned = null,
    Object? earnedAt = freezed,
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
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      rarity: null == rarity
          ? _value.rarity
          : rarity // ignore: cast_nullable_to_non_nullable
              as String,
      target: null == target
          ? _value.target
          : target // ignore: cast_nullable_to_non_nullable
              as int,
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as int,
      earned: null == earned
          ? _value.earned
          : earned // ignore: cast_nullable_to_non_nullable
              as bool,
      earnedAt: freezed == earnedAt
          ? _value.earnedAt
          : earnedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AchievementImplCopyWith<$Res>
    implements $AchievementCopyWith<$Res> {
  factory _$$AchievementImplCopyWith(
          _$AchievementImpl value, $Res Function(_$AchievementImpl) then) =
      __$$AchievementImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      String category,
      String rarity,
      int target,
      int progress,
      bool earned,
      String? earnedAt});
}

/// @nodoc
class __$$AchievementImplCopyWithImpl<$Res>
    extends _$AchievementCopyWithImpl<$Res, _$AchievementImpl>
    implements _$$AchievementImplCopyWith<$Res> {
  __$$AchievementImplCopyWithImpl(
      _$AchievementImpl _value, $Res Function(_$AchievementImpl) _then)
      : super(_value, _then);

  /// Create a copy of Achievement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? category = null,
    Object? rarity = null,
    Object? target = null,
    Object? progress = null,
    Object? earned = null,
    Object? earnedAt = freezed,
  }) {
    return _then(_$AchievementImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      rarity: null == rarity
          ? _value.rarity
          : rarity // ignore: cast_nullable_to_non_nullable
              as String,
      target: null == target
          ? _value.target
          : target // ignore: cast_nullable_to_non_nullable
              as int,
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as int,
      earned: null == earned
          ? _value.earned
          : earned // ignore: cast_nullable_to_non_nullable
              as bool,
      earnedAt: freezed == earnedAt
          ? _value.earnedAt
          : earnedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AchievementImpl implements _Achievement {
  const _$AchievementImpl(
      {required this.id,
      required this.name,
      required this.description,
      required this.category,
      required this.rarity,
      required this.target,
      required this.progress,
      required this.earned,
      this.earnedAt});

  factory _$AchievementImpl.fromJson(Map<String, dynamic> json) =>
      _$$AchievementImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String description;
  @override
  final String category;
// STREAK | MASTERY | CURIOSITY | MILESTONE
  @override
  final String rarity;
// COMMON | RARE | EPIC | LEGENDARY
  @override
  final int target;
  @override
  final int progress;
  @override
  final bool earned;
  @override
  final String? earnedAt;

  @override
  String toString() {
    return 'Achievement(id: $id, name: $name, description: $description, category: $category, rarity: $rarity, target: $target, progress: $progress, earned: $earned, earnedAt: $earnedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AchievementImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.rarity, rarity) || other.rarity == rarity) &&
            (identical(other.target, target) || other.target == target) &&
            (identical(other.progress, progress) ||
                other.progress == progress) &&
            (identical(other.earned, earned) || other.earned == earned) &&
            (identical(other.earnedAt, earnedAt) ||
                other.earnedAt == earnedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, description, category,
      rarity, target, progress, earned, earnedAt);

  /// Create a copy of Achievement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AchievementImplCopyWith<_$AchievementImpl> get copyWith =>
      __$$AchievementImplCopyWithImpl<_$AchievementImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AchievementImplToJson(
      this,
    );
  }
}

abstract class _Achievement implements Achievement {
  const factory _Achievement(
      {required final String id,
      required final String name,
      required final String description,
      required final String category,
      required final String rarity,
      required final int target,
      required final int progress,
      required final bool earned,
      final String? earnedAt}) = _$AchievementImpl;

  factory _Achievement.fromJson(Map<String, dynamic> json) =
      _$AchievementImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get description;
  @override
  String get category; // STREAK | MASTERY | CURIOSITY | MILESTONE
  @override
  String get rarity; // COMMON | RARE | EPIC | LEGENDARY
  @override
  int get target;
  @override
  int get progress;
  @override
  bool get earned;
  @override
  String? get earnedAt;

  /// Create a copy of Achievement
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AchievementImplCopyWith<_$AchievementImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AchievementList _$AchievementListFromJson(Map<String, dynamic> json) {
  return _AchievementList.fromJson(json);
}

/// @nodoc
mixin _$AchievementList {
  List<Achievement> get achievements => throw _privateConstructorUsedError;
  int get earnedCount => throw _privateConstructorUsedError;
  int get totalCount => throw _privateConstructorUsedError;

  /// Serializes this AchievementList to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AchievementList
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AchievementListCopyWith<AchievementList> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AchievementListCopyWith<$Res> {
  factory $AchievementListCopyWith(
          AchievementList value, $Res Function(AchievementList) then) =
      _$AchievementListCopyWithImpl<$Res, AchievementList>;
  @useResult
  $Res call({List<Achievement> achievements, int earnedCount, int totalCount});
}

/// @nodoc
class _$AchievementListCopyWithImpl<$Res, $Val extends AchievementList>
    implements $AchievementListCopyWith<$Res> {
  _$AchievementListCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AchievementList
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? achievements = null,
    Object? earnedCount = null,
    Object? totalCount = null,
  }) {
    return _then(_value.copyWith(
      achievements: null == achievements
          ? _value.achievements
          : achievements // ignore: cast_nullable_to_non_nullable
              as List<Achievement>,
      earnedCount: null == earnedCount
          ? _value.earnedCount
          : earnedCount // ignore: cast_nullable_to_non_nullable
              as int,
      totalCount: null == totalCount
          ? _value.totalCount
          : totalCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AchievementListImplCopyWith<$Res>
    implements $AchievementListCopyWith<$Res> {
  factory _$$AchievementListImplCopyWith(_$AchievementListImpl value,
          $Res Function(_$AchievementListImpl) then) =
      __$$AchievementListImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<Achievement> achievements, int earnedCount, int totalCount});
}

/// @nodoc
class __$$AchievementListImplCopyWithImpl<$Res>
    extends _$AchievementListCopyWithImpl<$Res, _$AchievementListImpl>
    implements _$$AchievementListImplCopyWith<$Res> {
  __$$AchievementListImplCopyWithImpl(
      _$AchievementListImpl _value, $Res Function(_$AchievementListImpl) _then)
      : super(_value, _then);

  /// Create a copy of AchievementList
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? achievements = null,
    Object? earnedCount = null,
    Object? totalCount = null,
  }) {
    return _then(_$AchievementListImpl(
      achievements: null == achievements
          ? _value._achievements
          : achievements // ignore: cast_nullable_to_non_nullable
              as List<Achievement>,
      earnedCount: null == earnedCount
          ? _value.earnedCount
          : earnedCount // ignore: cast_nullable_to_non_nullable
              as int,
      totalCount: null == totalCount
          ? _value.totalCount
          : totalCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AchievementListImpl implements _AchievementList {
  const _$AchievementListImpl(
      {required final List<Achievement> achievements,
      required this.earnedCount,
      required this.totalCount})
      : _achievements = achievements;

  factory _$AchievementListImpl.fromJson(Map<String, dynamic> json) =>
      _$$AchievementListImplFromJson(json);

  final List<Achievement> _achievements;
  @override
  List<Achievement> get achievements {
    if (_achievements is EqualUnmodifiableListView) return _achievements;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_achievements);
  }

  @override
  final int earnedCount;
  @override
  final int totalCount;

  @override
  String toString() {
    return 'AchievementList(achievements: $achievements, earnedCount: $earnedCount, totalCount: $totalCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AchievementListImpl &&
            const DeepCollectionEquality()
                .equals(other._achievements, _achievements) &&
            (identical(other.earnedCount, earnedCount) ||
                other.earnedCount == earnedCount) &&
            (identical(other.totalCount, totalCount) ||
                other.totalCount == totalCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_achievements),
      earnedCount,
      totalCount);

  /// Create a copy of AchievementList
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AchievementListImplCopyWith<_$AchievementListImpl> get copyWith =>
      __$$AchievementListImplCopyWithImpl<_$AchievementListImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AchievementListImplToJson(
      this,
    );
  }
}

abstract class _AchievementList implements AchievementList {
  const factory _AchievementList(
      {required final List<Achievement> achievements,
      required final int earnedCount,
      required final int totalCount}) = _$AchievementListImpl;

  factory _AchievementList.fromJson(Map<String, dynamic> json) =
      _$AchievementListImpl.fromJson;

  @override
  List<Achievement> get achievements;
  @override
  int get earnedCount;
  @override
  int get totalCount;

  /// Create a copy of AchievementList
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AchievementListImplCopyWith<_$AchievementListImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
