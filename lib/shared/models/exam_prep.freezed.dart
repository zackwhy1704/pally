// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exam_prep.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ExamPrep _$ExamPrepFromJson(Map<String, dynamic> json) {
  return _ExamPrep.fromJson(json);
}

/// @nodoc
mixin _$ExamPrep {
  String? get testDate => throw _privateConstructorUsedError;
  int? get daysRemaining => throw _privateConstructorUsedError;
  List<ExamConceptMastery> get concepts => throw _privateConstructorUsedError;
  List<String> get recommendedOrder => throw _privateConstructorUsedError;
  int get dailyTarget => throw _privateConstructorUsedError;

  /// Serializes this ExamPrep to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExamPrep
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExamPrepCopyWith<ExamPrep> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExamPrepCopyWith<$Res> {
  factory $ExamPrepCopyWith(ExamPrep value, $Res Function(ExamPrep) then) =
      _$ExamPrepCopyWithImpl<$Res, ExamPrep>;
  @useResult
  $Res call(
      {String? testDate,
      int? daysRemaining,
      List<ExamConceptMastery> concepts,
      List<String> recommendedOrder,
      int dailyTarget});
}

/// @nodoc
class _$ExamPrepCopyWithImpl<$Res, $Val extends ExamPrep>
    implements $ExamPrepCopyWith<$Res> {
  _$ExamPrepCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExamPrep
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? testDate = freezed,
    Object? daysRemaining = freezed,
    Object? concepts = null,
    Object? recommendedOrder = null,
    Object? dailyTarget = null,
  }) {
    return _then(_value.copyWith(
      testDate: freezed == testDate
          ? _value.testDate
          : testDate // ignore: cast_nullable_to_non_nullable
              as String?,
      daysRemaining: freezed == daysRemaining
          ? _value.daysRemaining
          : daysRemaining // ignore: cast_nullable_to_non_nullable
              as int?,
      concepts: null == concepts
          ? _value.concepts
          : concepts // ignore: cast_nullable_to_non_nullable
              as List<ExamConceptMastery>,
      recommendedOrder: null == recommendedOrder
          ? _value.recommendedOrder
          : recommendedOrder // ignore: cast_nullable_to_non_nullable
              as List<String>,
      dailyTarget: null == dailyTarget
          ? _value.dailyTarget
          : dailyTarget // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ExamPrepImplCopyWith<$Res>
    implements $ExamPrepCopyWith<$Res> {
  factory _$$ExamPrepImplCopyWith(
          _$ExamPrepImpl value, $Res Function(_$ExamPrepImpl) then) =
      __$$ExamPrepImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? testDate,
      int? daysRemaining,
      List<ExamConceptMastery> concepts,
      List<String> recommendedOrder,
      int dailyTarget});
}

/// @nodoc
class __$$ExamPrepImplCopyWithImpl<$Res>
    extends _$ExamPrepCopyWithImpl<$Res, _$ExamPrepImpl>
    implements _$$ExamPrepImplCopyWith<$Res> {
  __$$ExamPrepImplCopyWithImpl(
      _$ExamPrepImpl _value, $Res Function(_$ExamPrepImpl) _then)
      : super(_value, _then);

  /// Create a copy of ExamPrep
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? testDate = freezed,
    Object? daysRemaining = freezed,
    Object? concepts = null,
    Object? recommendedOrder = null,
    Object? dailyTarget = null,
  }) {
    return _then(_$ExamPrepImpl(
      testDate: freezed == testDate
          ? _value.testDate
          : testDate // ignore: cast_nullable_to_non_nullable
              as String?,
      daysRemaining: freezed == daysRemaining
          ? _value.daysRemaining
          : daysRemaining // ignore: cast_nullable_to_non_nullable
              as int?,
      concepts: null == concepts
          ? _value._concepts
          : concepts // ignore: cast_nullable_to_non_nullable
              as List<ExamConceptMastery>,
      recommendedOrder: null == recommendedOrder
          ? _value._recommendedOrder
          : recommendedOrder // ignore: cast_nullable_to_non_nullable
              as List<String>,
      dailyTarget: null == dailyTarget
          ? _value.dailyTarget
          : dailyTarget // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ExamPrepImpl implements _ExamPrep {
  const _$ExamPrepImpl(
      {this.testDate,
      this.daysRemaining,
      final List<ExamConceptMastery> concepts = const [],
      final List<String> recommendedOrder = const [],
      this.dailyTarget = 2})
      : _concepts = concepts,
        _recommendedOrder = recommendedOrder;

  factory _$ExamPrepImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExamPrepImplFromJson(json);

  @override
  final String? testDate;
  @override
  final int? daysRemaining;
  final List<ExamConceptMastery> _concepts;
  @override
  @JsonKey()
  List<ExamConceptMastery> get concepts {
    if (_concepts is EqualUnmodifiableListView) return _concepts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_concepts);
  }

  final List<String> _recommendedOrder;
  @override
  @JsonKey()
  List<String> get recommendedOrder {
    if (_recommendedOrder is EqualUnmodifiableListView)
      return _recommendedOrder;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recommendedOrder);
  }

  @override
  @JsonKey()
  final int dailyTarget;

  @override
  String toString() {
    return 'ExamPrep(testDate: $testDate, daysRemaining: $daysRemaining, concepts: $concepts, recommendedOrder: $recommendedOrder, dailyTarget: $dailyTarget)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExamPrepImpl &&
            (identical(other.testDate, testDate) ||
                other.testDate == testDate) &&
            (identical(other.daysRemaining, daysRemaining) ||
                other.daysRemaining == daysRemaining) &&
            const DeepCollectionEquality().equals(other._concepts, _concepts) &&
            const DeepCollectionEquality()
                .equals(other._recommendedOrder, _recommendedOrder) &&
            (identical(other.dailyTarget, dailyTarget) ||
                other.dailyTarget == dailyTarget));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      testDate,
      daysRemaining,
      const DeepCollectionEquality().hash(_concepts),
      const DeepCollectionEquality().hash(_recommendedOrder),
      dailyTarget);

  /// Create a copy of ExamPrep
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExamPrepImplCopyWith<_$ExamPrepImpl> get copyWith =>
      __$$ExamPrepImplCopyWithImpl<_$ExamPrepImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExamPrepImplToJson(
      this,
    );
  }
}

abstract class _ExamPrep implements ExamPrep {
  const factory _ExamPrep(
      {final String? testDate,
      final int? daysRemaining,
      final List<ExamConceptMastery> concepts,
      final List<String> recommendedOrder,
      final int dailyTarget}) = _$ExamPrepImpl;

  factory _ExamPrep.fromJson(Map<String, dynamic> json) =
      _$ExamPrepImpl.fromJson;

  @override
  String? get testDate;
  @override
  int? get daysRemaining;
  @override
  List<ExamConceptMastery> get concepts;
  @override
  List<String> get recommendedOrder;
  @override
  int get dailyTarget;

  /// Create a copy of ExamPrep
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExamPrepImplCopyWith<_$ExamPrepImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ExamConceptMastery _$ExamConceptMasteryFromJson(Map<String, dynamic> json) {
  return _ExamConceptMastery.fromJson(json);
}

/// @nodoc
mixin _$ExamConceptMastery {
  String get concept => throw _privateConstructorUsedError;
  double get mastery => throw _privateConstructorUsedError;
  String? get moduleId => throw _privateConstructorUsedError;
  String? get moduleTitle =>
      throw _privateConstructorUsedError; // Trust class of the mastery signal (backend GradingSignal.name()): only
// 'SELF_REPORT' concepts carry a self-assessed (trust-weighted) %, so the UI
// labels them "self-assessed" instead of implying a graded score.
  String? get signalType => throw _privateConstructorUsedError;

  /// Serializes this ExamConceptMastery to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExamConceptMastery
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExamConceptMasteryCopyWith<ExamConceptMastery> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExamConceptMasteryCopyWith<$Res> {
  factory $ExamConceptMasteryCopyWith(
          ExamConceptMastery value, $Res Function(ExamConceptMastery) then) =
      _$ExamConceptMasteryCopyWithImpl<$Res, ExamConceptMastery>;
  @useResult
  $Res call(
      {String concept,
      double mastery,
      String? moduleId,
      String? moduleTitle,
      String? signalType});
}

/// @nodoc
class _$ExamConceptMasteryCopyWithImpl<$Res, $Val extends ExamConceptMastery>
    implements $ExamConceptMasteryCopyWith<$Res> {
  _$ExamConceptMasteryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExamConceptMastery
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? concept = null,
    Object? mastery = null,
    Object? moduleId = freezed,
    Object? moduleTitle = freezed,
    Object? signalType = freezed,
  }) {
    return _then(_value.copyWith(
      concept: null == concept
          ? _value.concept
          : concept // ignore: cast_nullable_to_non_nullable
              as String,
      mastery: null == mastery
          ? _value.mastery
          : mastery // ignore: cast_nullable_to_non_nullable
              as double,
      moduleId: freezed == moduleId
          ? _value.moduleId
          : moduleId // ignore: cast_nullable_to_non_nullable
              as String?,
      moduleTitle: freezed == moduleTitle
          ? _value.moduleTitle
          : moduleTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      signalType: freezed == signalType
          ? _value.signalType
          : signalType // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ExamConceptMasteryImplCopyWith<$Res>
    implements $ExamConceptMasteryCopyWith<$Res> {
  factory _$$ExamConceptMasteryImplCopyWith(_$ExamConceptMasteryImpl value,
          $Res Function(_$ExamConceptMasteryImpl) then) =
      __$$ExamConceptMasteryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String concept,
      double mastery,
      String? moduleId,
      String? moduleTitle,
      String? signalType});
}

/// @nodoc
class __$$ExamConceptMasteryImplCopyWithImpl<$Res>
    extends _$ExamConceptMasteryCopyWithImpl<$Res, _$ExamConceptMasteryImpl>
    implements _$$ExamConceptMasteryImplCopyWith<$Res> {
  __$$ExamConceptMasteryImplCopyWithImpl(_$ExamConceptMasteryImpl _value,
      $Res Function(_$ExamConceptMasteryImpl) _then)
      : super(_value, _then);

  /// Create a copy of ExamConceptMastery
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? concept = null,
    Object? mastery = null,
    Object? moduleId = freezed,
    Object? moduleTitle = freezed,
    Object? signalType = freezed,
  }) {
    return _then(_$ExamConceptMasteryImpl(
      concept: null == concept
          ? _value.concept
          : concept // ignore: cast_nullable_to_non_nullable
              as String,
      mastery: null == mastery
          ? _value.mastery
          : mastery // ignore: cast_nullable_to_non_nullable
              as double,
      moduleId: freezed == moduleId
          ? _value.moduleId
          : moduleId // ignore: cast_nullable_to_non_nullable
              as String?,
      moduleTitle: freezed == moduleTitle
          ? _value.moduleTitle
          : moduleTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      signalType: freezed == signalType
          ? _value.signalType
          : signalType // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ExamConceptMasteryImpl implements _ExamConceptMastery {
  const _$ExamConceptMasteryImpl(
      {this.concept = '',
      this.mastery = 0,
      this.moduleId,
      this.moduleTitle,
      this.signalType});

  factory _$ExamConceptMasteryImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExamConceptMasteryImplFromJson(json);

  @override
  @JsonKey()
  final String concept;
  @override
  @JsonKey()
  final double mastery;
  @override
  final String? moduleId;
  @override
  final String? moduleTitle;
// Trust class of the mastery signal (backend GradingSignal.name()): only
// 'SELF_REPORT' concepts carry a self-assessed (trust-weighted) %, so the UI
// labels them "self-assessed" instead of implying a graded score.
  @override
  final String? signalType;

  @override
  String toString() {
    return 'ExamConceptMastery(concept: $concept, mastery: $mastery, moduleId: $moduleId, moduleTitle: $moduleTitle, signalType: $signalType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExamConceptMasteryImpl &&
            (identical(other.concept, concept) || other.concept == concept) &&
            (identical(other.mastery, mastery) || other.mastery == mastery) &&
            (identical(other.moduleId, moduleId) ||
                other.moduleId == moduleId) &&
            (identical(other.moduleTitle, moduleTitle) ||
                other.moduleTitle == moduleTitle) &&
            (identical(other.signalType, signalType) ||
                other.signalType == signalType));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, concept, mastery, moduleId, moduleTitle, signalType);

  /// Create a copy of ExamConceptMastery
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExamConceptMasteryImplCopyWith<_$ExamConceptMasteryImpl> get copyWith =>
      __$$ExamConceptMasteryImplCopyWithImpl<_$ExamConceptMasteryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExamConceptMasteryImplToJson(
      this,
    );
  }
}

abstract class _ExamConceptMastery implements ExamConceptMastery {
  const factory _ExamConceptMastery(
      {final String concept,
      final double mastery,
      final String? moduleId,
      final String? moduleTitle,
      final String? signalType}) = _$ExamConceptMasteryImpl;

  factory _ExamConceptMastery.fromJson(Map<String, dynamic> json) =
      _$ExamConceptMasteryImpl.fromJson;

  @override
  String get concept;
  @override
  double get mastery;
  @override
  String? get moduleId;
  @override
  String?
      get moduleTitle; // Trust class of the mastery signal (backend GradingSignal.name()): only
// 'SELF_REPORT' concepts carry a self-assessed (trust-weighted) %, so the UI
// labels them "self-assessed" instead of implying a graded score.
  @override
  String? get signalType;

  /// Create a copy of ExamConceptMastery
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExamConceptMasteryImplCopyWith<_$ExamConceptMasteryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
