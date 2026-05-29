// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'coverage_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CoverageBucket _$CoverageBucketFromJson(Map<String, dynamic> json) {
  return _CoverageBucket.fromJson(json);
}

/// @nodoc
mixin _$CoverageBucket {
  int get mastered => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;

  /// Serializes this CoverageBucket to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CoverageBucket
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CoverageBucketCopyWith<CoverageBucket> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CoverageBucketCopyWith<$Res> {
  factory $CoverageBucketCopyWith(
          CoverageBucket value, $Res Function(CoverageBucket) then) =
      _$CoverageBucketCopyWithImpl<$Res, CoverageBucket>;
  @useResult
  $Res call({int mastered, int total});
}

/// @nodoc
class _$CoverageBucketCopyWithImpl<$Res, $Val extends CoverageBucket>
    implements $CoverageBucketCopyWith<$Res> {
  _$CoverageBucketCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CoverageBucket
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mastered = null,
    Object? total = null,
  }) {
    return _then(_value.copyWith(
      mastered: null == mastered
          ? _value.mastered
          : mastered // ignore: cast_nullable_to_non_nullable
              as int,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CoverageBucketImplCopyWith<$Res>
    implements $CoverageBucketCopyWith<$Res> {
  factory _$$CoverageBucketImplCopyWith(_$CoverageBucketImpl value,
          $Res Function(_$CoverageBucketImpl) then) =
      __$$CoverageBucketImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int mastered, int total});
}

/// @nodoc
class __$$CoverageBucketImplCopyWithImpl<$Res>
    extends _$CoverageBucketCopyWithImpl<$Res, _$CoverageBucketImpl>
    implements _$$CoverageBucketImplCopyWith<$Res> {
  __$$CoverageBucketImplCopyWithImpl(
      _$CoverageBucketImpl _value, $Res Function(_$CoverageBucketImpl) _then)
      : super(_value, _then);

  /// Create a copy of CoverageBucket
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mastered = null,
    Object? total = null,
  }) {
    return _then(_$CoverageBucketImpl(
      mastered: null == mastered
          ? _value.mastered
          : mastered // ignore: cast_nullable_to_non_nullable
              as int,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CoverageBucketImpl implements _CoverageBucket {
  const _$CoverageBucketImpl({required this.mastered, required this.total});

  factory _$CoverageBucketImpl.fromJson(Map<String, dynamic> json) =>
      _$$CoverageBucketImplFromJson(json);

  @override
  final int mastered;
  @override
  final int total;

  @override
  String toString() {
    return 'CoverageBucket(mastered: $mastered, total: $total)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CoverageBucketImpl &&
            (identical(other.mastered, mastered) ||
                other.mastered == mastered) &&
            (identical(other.total, total) || other.total == total));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, mastered, total);

  /// Create a copy of CoverageBucket
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CoverageBucketImplCopyWith<_$CoverageBucketImpl> get copyWith =>
      __$$CoverageBucketImplCopyWithImpl<_$CoverageBucketImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CoverageBucketImplToJson(
      this,
    );
  }
}

abstract class _CoverageBucket implements CoverageBucket {
  const factory _CoverageBucket(
      {required final int mastered,
      required final int total}) = _$CoverageBucketImpl;

  factory _CoverageBucket.fromJson(Map<String, dynamic> json) =
      _$CoverageBucketImpl.fromJson;

  @override
  int get mastered;
  @override
  int get total;

  /// Create a copy of CoverageBucket
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CoverageBucketImplCopyWith<_$CoverageBucketImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SubjectCoverage _$SubjectCoverageFromJson(Map<String, dynamic> json) {
  return _SubjectCoverage.fromJson(json);
}

/// @nodoc
mixin _$SubjectCoverage {
  String get subject => throw _privateConstructorUsedError;
  int get mastered => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;

  /// Serializes this SubjectCoverage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SubjectCoverage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubjectCoverageCopyWith<SubjectCoverage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubjectCoverageCopyWith<$Res> {
  factory $SubjectCoverageCopyWith(
          SubjectCoverage value, $Res Function(SubjectCoverage) then) =
      _$SubjectCoverageCopyWithImpl<$Res, SubjectCoverage>;
  @useResult
  $Res call({String subject, int mastered, int total});
}

/// @nodoc
class _$SubjectCoverageCopyWithImpl<$Res, $Val extends SubjectCoverage>
    implements $SubjectCoverageCopyWith<$Res> {
  _$SubjectCoverageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SubjectCoverage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subject = null,
    Object? mastered = null,
    Object? total = null,
  }) {
    return _then(_value.copyWith(
      subject: null == subject
          ? _value.subject
          : subject // ignore: cast_nullable_to_non_nullable
              as String,
      mastered: null == mastered
          ? _value.mastered
          : mastered // ignore: cast_nullable_to_non_nullable
              as int,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SubjectCoverageImplCopyWith<$Res>
    implements $SubjectCoverageCopyWith<$Res> {
  factory _$$SubjectCoverageImplCopyWith(_$SubjectCoverageImpl value,
          $Res Function(_$SubjectCoverageImpl) then) =
      __$$SubjectCoverageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String subject, int mastered, int total});
}

/// @nodoc
class __$$SubjectCoverageImplCopyWithImpl<$Res>
    extends _$SubjectCoverageCopyWithImpl<$Res, _$SubjectCoverageImpl>
    implements _$$SubjectCoverageImplCopyWith<$Res> {
  __$$SubjectCoverageImplCopyWithImpl(
      _$SubjectCoverageImpl _value, $Res Function(_$SubjectCoverageImpl) _then)
      : super(_value, _then);

  /// Create a copy of SubjectCoverage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subject = null,
    Object? mastered = null,
    Object? total = null,
  }) {
    return _then(_$SubjectCoverageImpl(
      subject: null == subject
          ? _value.subject
          : subject // ignore: cast_nullable_to_non_nullable
              as String,
      mastered: null == mastered
          ? _value.mastered
          : mastered // ignore: cast_nullable_to_non_nullable
              as int,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SubjectCoverageImpl implements _SubjectCoverage {
  const _$SubjectCoverageImpl(
      {required this.subject, required this.mastered, required this.total});

  factory _$SubjectCoverageImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubjectCoverageImplFromJson(json);

  @override
  final String subject;
  @override
  final int mastered;
  @override
  final int total;

  @override
  String toString() {
    return 'SubjectCoverage(subject: $subject, mastered: $mastered, total: $total)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubjectCoverageImpl &&
            (identical(other.subject, subject) || other.subject == subject) &&
            (identical(other.mastered, mastered) ||
                other.mastered == mastered) &&
            (identical(other.total, total) || other.total == total));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, subject, mastered, total);

  /// Create a copy of SubjectCoverage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubjectCoverageImplCopyWith<_$SubjectCoverageImpl> get copyWith =>
      __$$SubjectCoverageImplCopyWithImpl<_$SubjectCoverageImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SubjectCoverageImplToJson(
      this,
    );
  }
}

abstract class _SubjectCoverage implements SubjectCoverage {
  const factory _SubjectCoverage(
      {required final String subject,
      required final int mastered,
      required final int total}) = _$SubjectCoverageImpl;

  factory _SubjectCoverage.fromJson(Map<String, dynamic> json) =
      _$SubjectCoverageImpl.fromJson;

  @override
  String get subject;
  @override
  int get mastered;
  @override
  int get total;

  /// Create a copy of SubjectCoverage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubjectCoverageImplCopyWith<_$SubjectCoverageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CoverageSummary _$CoverageSummaryFromJson(Map<String, dynamic> json) {
  return _CoverageSummary.fromJson(json);
}

/// @nodoc
mixin _$CoverageSummary {
  CoverageBucket get overall => throw _privateConstructorUsedError;
  List<SubjectCoverage> get bySubject => throw _privateConstructorUsedError;

  /// Serializes this CoverageSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CoverageSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CoverageSummaryCopyWith<CoverageSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CoverageSummaryCopyWith<$Res> {
  factory $CoverageSummaryCopyWith(
          CoverageSummary value, $Res Function(CoverageSummary) then) =
      _$CoverageSummaryCopyWithImpl<$Res, CoverageSummary>;
  @useResult
  $Res call({CoverageBucket overall, List<SubjectCoverage> bySubject});

  $CoverageBucketCopyWith<$Res> get overall;
}

/// @nodoc
class _$CoverageSummaryCopyWithImpl<$Res, $Val extends CoverageSummary>
    implements $CoverageSummaryCopyWith<$Res> {
  _$CoverageSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CoverageSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? overall = null,
    Object? bySubject = null,
  }) {
    return _then(_value.copyWith(
      overall: null == overall
          ? _value.overall
          : overall // ignore: cast_nullable_to_non_nullable
              as CoverageBucket,
      bySubject: null == bySubject
          ? _value.bySubject
          : bySubject // ignore: cast_nullable_to_non_nullable
              as List<SubjectCoverage>,
    ) as $Val);
  }

  /// Create a copy of CoverageSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CoverageBucketCopyWith<$Res> get overall {
    return $CoverageBucketCopyWith<$Res>(_value.overall, (value) {
      return _then(_value.copyWith(overall: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CoverageSummaryImplCopyWith<$Res>
    implements $CoverageSummaryCopyWith<$Res> {
  factory _$$CoverageSummaryImplCopyWith(_$CoverageSummaryImpl value,
          $Res Function(_$CoverageSummaryImpl) then) =
      __$$CoverageSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({CoverageBucket overall, List<SubjectCoverage> bySubject});

  @override
  $CoverageBucketCopyWith<$Res> get overall;
}

/// @nodoc
class __$$CoverageSummaryImplCopyWithImpl<$Res>
    extends _$CoverageSummaryCopyWithImpl<$Res, _$CoverageSummaryImpl>
    implements _$$CoverageSummaryImplCopyWith<$Res> {
  __$$CoverageSummaryImplCopyWithImpl(
      _$CoverageSummaryImpl _value, $Res Function(_$CoverageSummaryImpl) _then)
      : super(_value, _then);

  /// Create a copy of CoverageSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? overall = null,
    Object? bySubject = null,
  }) {
    return _then(_$CoverageSummaryImpl(
      overall: null == overall
          ? _value.overall
          : overall // ignore: cast_nullable_to_non_nullable
              as CoverageBucket,
      bySubject: null == bySubject
          ? _value._bySubject
          : bySubject // ignore: cast_nullable_to_non_nullable
              as List<SubjectCoverage>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CoverageSummaryImpl implements _CoverageSummary {
  const _$CoverageSummaryImpl(
      {required this.overall, required final List<SubjectCoverage> bySubject})
      : _bySubject = bySubject;

  factory _$CoverageSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$CoverageSummaryImplFromJson(json);

  @override
  final CoverageBucket overall;
  final List<SubjectCoverage> _bySubject;
  @override
  List<SubjectCoverage> get bySubject {
    if (_bySubject is EqualUnmodifiableListView) return _bySubject;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_bySubject);
  }

  @override
  String toString() {
    return 'CoverageSummary(overall: $overall, bySubject: $bySubject)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CoverageSummaryImpl &&
            (identical(other.overall, overall) || other.overall == overall) &&
            const DeepCollectionEquality()
                .equals(other._bySubject, _bySubject));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, overall, const DeepCollectionEquality().hash(_bySubject));

  /// Create a copy of CoverageSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CoverageSummaryImplCopyWith<_$CoverageSummaryImpl> get copyWith =>
      __$$CoverageSummaryImplCopyWithImpl<_$CoverageSummaryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CoverageSummaryImplToJson(
      this,
    );
  }
}

abstract class _CoverageSummary implements CoverageSummary {
  const factory _CoverageSummary(
      {required final CoverageBucket overall,
      required final List<SubjectCoverage> bySubject}) = _$CoverageSummaryImpl;

  factory _CoverageSummary.fromJson(Map<String, dynamic> json) =
      _$CoverageSummaryImpl.fromJson;

  @override
  CoverageBucket get overall;
  @override
  List<SubjectCoverage> get bySubject;

  /// Create a copy of CoverageSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CoverageSummaryImplCopyWith<_$CoverageSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
