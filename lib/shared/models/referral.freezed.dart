// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'referral.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ReferralSummary _$ReferralSummaryFromJson(Map<String, dynamic> json) {
  return _ReferralSummary.fromJson(json);
}

/// @nodoc
mixin _$ReferralSummary {
  String get code => throw _privateConstructorUsedError;
  int get totalReferred => throw _privateConstructorUsedError;
  int get activatedCount => throw _privateConstructorUsedError;
  int get rewardsEarned => throw _privateConstructorUsedError;
  int get nextTierAt => throw _privateConstructorUsedError;

  /// Serializes this ReferralSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReferralSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReferralSummaryCopyWith<ReferralSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReferralSummaryCopyWith<$Res> {
  factory $ReferralSummaryCopyWith(
          ReferralSummary value, $Res Function(ReferralSummary) then) =
      _$ReferralSummaryCopyWithImpl<$Res, ReferralSummary>;
  @useResult
  $Res call(
      {String code,
      int totalReferred,
      int activatedCount,
      int rewardsEarned,
      int nextTierAt});
}

/// @nodoc
class _$ReferralSummaryCopyWithImpl<$Res, $Val extends ReferralSummary>
    implements $ReferralSummaryCopyWith<$Res> {
  _$ReferralSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReferralSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? totalReferred = null,
    Object? activatedCount = null,
    Object? rewardsEarned = null,
    Object? nextTierAt = null,
  }) {
    return _then(_value.copyWith(
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      totalReferred: null == totalReferred
          ? _value.totalReferred
          : totalReferred // ignore: cast_nullable_to_non_nullable
              as int,
      activatedCount: null == activatedCount
          ? _value.activatedCount
          : activatedCount // ignore: cast_nullable_to_non_nullable
              as int,
      rewardsEarned: null == rewardsEarned
          ? _value.rewardsEarned
          : rewardsEarned // ignore: cast_nullable_to_non_nullable
              as int,
      nextTierAt: null == nextTierAt
          ? _value.nextTierAt
          : nextTierAt // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReferralSummaryImplCopyWith<$Res>
    implements $ReferralSummaryCopyWith<$Res> {
  factory _$$ReferralSummaryImplCopyWith(_$ReferralSummaryImpl value,
          $Res Function(_$ReferralSummaryImpl) then) =
      __$$ReferralSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String code,
      int totalReferred,
      int activatedCount,
      int rewardsEarned,
      int nextTierAt});
}

/// @nodoc
class __$$ReferralSummaryImplCopyWithImpl<$Res>
    extends _$ReferralSummaryCopyWithImpl<$Res, _$ReferralSummaryImpl>
    implements _$$ReferralSummaryImplCopyWith<$Res> {
  __$$ReferralSummaryImplCopyWithImpl(
      _$ReferralSummaryImpl _value, $Res Function(_$ReferralSummaryImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReferralSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? totalReferred = null,
    Object? activatedCount = null,
    Object? rewardsEarned = null,
    Object? nextTierAt = null,
  }) {
    return _then(_$ReferralSummaryImpl(
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      totalReferred: null == totalReferred
          ? _value.totalReferred
          : totalReferred // ignore: cast_nullable_to_non_nullable
              as int,
      activatedCount: null == activatedCount
          ? _value.activatedCount
          : activatedCount // ignore: cast_nullable_to_non_nullable
              as int,
      rewardsEarned: null == rewardsEarned
          ? _value.rewardsEarned
          : rewardsEarned // ignore: cast_nullable_to_non_nullable
              as int,
      nextTierAt: null == nextTierAt
          ? _value.nextTierAt
          : nextTierAt // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReferralSummaryImpl implements _ReferralSummary {
  const _$ReferralSummaryImpl(
      {this.code = '',
      this.totalReferred = 0,
      this.activatedCount = 0,
      this.rewardsEarned = 0,
      this.nextTierAt = 0});

  factory _$ReferralSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReferralSummaryImplFromJson(json);

  @override
  @JsonKey()
  final String code;
  @override
  @JsonKey()
  final int totalReferred;
  @override
  @JsonKey()
  final int activatedCount;
  @override
  @JsonKey()
  final int rewardsEarned;
  @override
  @JsonKey()
  final int nextTierAt;

  @override
  String toString() {
    return 'ReferralSummary(code: $code, totalReferred: $totalReferred, activatedCount: $activatedCount, rewardsEarned: $rewardsEarned, nextTierAt: $nextTierAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReferralSummaryImpl &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.totalReferred, totalReferred) ||
                other.totalReferred == totalReferred) &&
            (identical(other.activatedCount, activatedCount) ||
                other.activatedCount == activatedCount) &&
            (identical(other.rewardsEarned, rewardsEarned) ||
                other.rewardsEarned == rewardsEarned) &&
            (identical(other.nextTierAt, nextTierAt) ||
                other.nextTierAt == nextTierAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, code, totalReferred,
      activatedCount, rewardsEarned, nextTierAt);

  /// Create a copy of ReferralSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReferralSummaryImplCopyWith<_$ReferralSummaryImpl> get copyWith =>
      __$$ReferralSummaryImplCopyWithImpl<_$ReferralSummaryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReferralSummaryImplToJson(
      this,
    );
  }
}

abstract class _ReferralSummary implements ReferralSummary {
  const factory _ReferralSummary(
      {final String code,
      final int totalReferred,
      final int activatedCount,
      final int rewardsEarned,
      final int nextTierAt}) = _$ReferralSummaryImpl;

  factory _ReferralSummary.fromJson(Map<String, dynamic> json) =
      _$ReferralSummaryImpl.fromJson;

  @override
  String get code;
  @override
  int get totalReferred;
  @override
  int get activatedCount;
  @override
  int get rewardsEarned;
  @override
  int get nextTierAt;

  /// Create a copy of ReferralSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReferralSummaryImplCopyWith<_$ReferralSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ReferralRedemption _$ReferralRedemptionFromJson(Map<String, dynamic> json) {
  return _ReferralRedemption.fromJson(json);
}

/// @nodoc
mixin _$ReferralRedemption {
  String get displayName => throw _privateConstructorUsedError;
  String get status =>
      throw _privateConstructorUsedError; // pending | activated
  String get joinedAt => throw _privateConstructorUsedError;
  String? get activatedAt => throw _privateConstructorUsedError;

  /// Serializes this ReferralRedemption to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReferralRedemption
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReferralRedemptionCopyWith<ReferralRedemption> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReferralRedemptionCopyWith<$Res> {
  factory $ReferralRedemptionCopyWith(
          ReferralRedemption value, $Res Function(ReferralRedemption) then) =
      _$ReferralRedemptionCopyWithImpl<$Res, ReferralRedemption>;
  @useResult
  $Res call(
      {String displayName,
      String status,
      String joinedAt,
      String? activatedAt});
}

/// @nodoc
class _$ReferralRedemptionCopyWithImpl<$Res, $Val extends ReferralRedemption>
    implements $ReferralRedemptionCopyWith<$Res> {
  _$ReferralRedemptionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReferralRedemption
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? displayName = null,
    Object? status = null,
    Object? joinedAt = null,
    Object? activatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      joinedAt: null == joinedAt
          ? _value.joinedAt
          : joinedAt // ignore: cast_nullable_to_non_nullable
              as String,
      activatedAt: freezed == activatedAt
          ? _value.activatedAt
          : activatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReferralRedemptionImplCopyWith<$Res>
    implements $ReferralRedemptionCopyWith<$Res> {
  factory _$$ReferralRedemptionImplCopyWith(_$ReferralRedemptionImpl value,
          $Res Function(_$ReferralRedemptionImpl) then) =
      __$$ReferralRedemptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String displayName,
      String status,
      String joinedAt,
      String? activatedAt});
}

/// @nodoc
class __$$ReferralRedemptionImplCopyWithImpl<$Res>
    extends _$ReferralRedemptionCopyWithImpl<$Res, _$ReferralRedemptionImpl>
    implements _$$ReferralRedemptionImplCopyWith<$Res> {
  __$$ReferralRedemptionImplCopyWithImpl(_$ReferralRedemptionImpl _value,
      $Res Function(_$ReferralRedemptionImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReferralRedemption
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? displayName = null,
    Object? status = null,
    Object? joinedAt = null,
    Object? activatedAt = freezed,
  }) {
    return _then(_$ReferralRedemptionImpl(
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      joinedAt: null == joinedAt
          ? _value.joinedAt
          : joinedAt // ignore: cast_nullable_to_non_nullable
              as String,
      activatedAt: freezed == activatedAt
          ? _value.activatedAt
          : activatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReferralRedemptionImpl implements _ReferralRedemption {
  const _$ReferralRedemptionImpl(
      {this.displayName = '',
      this.status = 'pending',
      this.joinedAt = '',
      this.activatedAt});

  factory _$ReferralRedemptionImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReferralRedemptionImplFromJson(json);

  @override
  @JsonKey()
  final String displayName;
  @override
  @JsonKey()
  final String status;
// pending | activated
  @override
  @JsonKey()
  final String joinedAt;
  @override
  final String? activatedAt;

  @override
  String toString() {
    return 'ReferralRedemption(displayName: $displayName, status: $status, joinedAt: $joinedAt, activatedAt: $activatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReferralRedemptionImpl &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.joinedAt, joinedAt) ||
                other.joinedAt == joinedAt) &&
            (identical(other.activatedAt, activatedAt) ||
                other.activatedAt == activatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, displayName, status, joinedAt, activatedAt);

  /// Create a copy of ReferralRedemption
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReferralRedemptionImplCopyWith<_$ReferralRedemptionImpl> get copyWith =>
      __$$ReferralRedemptionImplCopyWithImpl<_$ReferralRedemptionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReferralRedemptionImplToJson(
      this,
    );
  }
}

abstract class _ReferralRedemption implements ReferralRedemption {
  const factory _ReferralRedemption(
      {final String displayName,
      final String status,
      final String joinedAt,
      final String? activatedAt}) = _$ReferralRedemptionImpl;

  factory _ReferralRedemption.fromJson(Map<String, dynamic> json) =
      _$ReferralRedemptionImpl.fromJson;

  @override
  String get displayName;
  @override
  String get status; // pending | activated
  @override
  String get joinedAt;
  @override
  String? get activatedAt;

  /// Create a copy of ReferralRedemption
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReferralRedemptionImplCopyWith<_$ReferralRedemptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
