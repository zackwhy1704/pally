// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'entitlement.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Entitlement _$EntitlementFromJson(Map<String, dynamic> json) {
  return _Entitlement.fromJson(json);
}

/// @nodoc
mixin _$Entitlement {
  bool get isPremium => throw _privateConstructorUsedError;
  String get source =>
      throw _privateConstructorUsedError; // SELF | PARENT | CENTRE | NONE
  String? get plan => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;
  String? get trialEndsAt => throw _privateConstructorUsedError;

  /// Serializes this Entitlement to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Entitlement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EntitlementCopyWith<Entitlement> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EntitlementCopyWith<$Res> {
  factory $EntitlementCopyWith(
          Entitlement value, $Res Function(Entitlement) then) =
      _$EntitlementCopyWithImpl<$Res, Entitlement>;
  @useResult
  $Res call(
      {bool isPremium,
      String source,
      String? plan,
      String? status,
      String? trialEndsAt});
}

/// @nodoc
class _$EntitlementCopyWithImpl<$Res, $Val extends Entitlement>
    implements $EntitlementCopyWith<$Res> {
  _$EntitlementCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Entitlement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isPremium = null,
    Object? source = null,
    Object? plan = freezed,
    Object? status = freezed,
    Object? trialEndsAt = freezed,
  }) {
    return _then(_value.copyWith(
      isPremium: null == isPremium
          ? _value.isPremium
          : isPremium // ignore: cast_nullable_to_non_nullable
              as bool,
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as String,
      plan: freezed == plan
          ? _value.plan
          : plan // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      trialEndsAt: freezed == trialEndsAt
          ? _value.trialEndsAt
          : trialEndsAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EntitlementImplCopyWith<$Res>
    implements $EntitlementCopyWith<$Res> {
  factory _$$EntitlementImplCopyWith(
          _$EntitlementImpl value, $Res Function(_$EntitlementImpl) then) =
      __$$EntitlementImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isPremium,
      String source,
      String? plan,
      String? status,
      String? trialEndsAt});
}

/// @nodoc
class __$$EntitlementImplCopyWithImpl<$Res>
    extends _$EntitlementCopyWithImpl<$Res, _$EntitlementImpl>
    implements _$$EntitlementImplCopyWith<$Res> {
  __$$EntitlementImplCopyWithImpl(
      _$EntitlementImpl _value, $Res Function(_$EntitlementImpl) _then)
      : super(_value, _then);

  /// Create a copy of Entitlement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isPremium = null,
    Object? source = null,
    Object? plan = freezed,
    Object? status = freezed,
    Object? trialEndsAt = freezed,
  }) {
    return _then(_$EntitlementImpl(
      isPremium: null == isPremium
          ? _value.isPremium
          : isPremium // ignore: cast_nullable_to_non_nullable
              as bool,
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as String,
      plan: freezed == plan
          ? _value.plan
          : plan // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      trialEndsAt: freezed == trialEndsAt
          ? _value.trialEndsAt
          : trialEndsAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EntitlementImpl implements _Entitlement {
  const _$EntitlementImpl(
      {this.isPremium = false,
      this.source = 'NONE',
      this.plan,
      this.status,
      this.trialEndsAt});

  factory _$EntitlementImpl.fromJson(Map<String, dynamic> json) =>
      _$$EntitlementImplFromJson(json);

  @override
  @JsonKey()
  final bool isPremium;
  @override
  @JsonKey()
  final String source;
// SELF | PARENT | CENTRE | NONE
  @override
  final String? plan;
  @override
  final String? status;
  @override
  final String? trialEndsAt;

  @override
  String toString() {
    return 'Entitlement(isPremium: $isPremium, source: $source, plan: $plan, status: $status, trialEndsAt: $trialEndsAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EntitlementImpl &&
            (identical(other.isPremium, isPremium) ||
                other.isPremium == isPremium) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.plan, plan) || other.plan == plan) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.trialEndsAt, trialEndsAt) ||
                other.trialEndsAt == trialEndsAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, isPremium, source, plan, status, trialEndsAt);

  /// Create a copy of Entitlement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EntitlementImplCopyWith<_$EntitlementImpl> get copyWith =>
      __$$EntitlementImplCopyWithImpl<_$EntitlementImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EntitlementImplToJson(
      this,
    );
  }
}

abstract class _Entitlement implements Entitlement {
  const factory _Entitlement(
      {final bool isPremium,
      final String source,
      final String? plan,
      final String? status,
      final String? trialEndsAt}) = _$EntitlementImpl;

  factory _Entitlement.fromJson(Map<String, dynamic> json) =
      _$EntitlementImpl.fromJson;

  @override
  bool get isPremium;
  @override
  String get source; // SELF | PARENT | CENTRE | NONE
  @override
  String? get plan;
  @override
  String? get status;
  @override
  String? get trialEndsAt;

  /// Create a copy of Entitlement
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EntitlementImplCopyWith<_$EntitlementImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
