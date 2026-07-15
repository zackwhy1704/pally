// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'quiz_question.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

QuizQuestion _$QuizQuestionFromJson(Map<String, dynamic> json) {
  return _QuizQuestion.fromJson(json);
}

/// @nodoc
mixin _$QuizQuestion {
  String get id => throw _privateConstructorUsedError;
  String get question => throw _privateConstructorUsedError;
  List<String> get options =>
      throw _privateConstructorUsedError; // Nullable BY CONTRACT: the backend WITHHOLDS the answer key for
// teacher-graded (centre) quizzes — `correctIndex` is null then, and the
// correct answer is revealed only post-submit (QuizResult.feedback). A
// `@Default(0)` here would collapse "withheld" into "index 0" and make the
// UI confidently highlight option A as correct — the exact bug this
// nullability prevents. Non-null = B2C daily quiz (instant feedback OK).
  int? get correctIndex => throw _privateConstructorUsedError;
  String get sourcePage => throw _privateConstructorUsedError;
  String get explanation =>
      throw _privateConstructorUsedError; // Adaptive-provenance serve metadata (nullable/empty on old content → chips/badges
// degrade silently): the source page title, and "WEAK_TOPIC:{concept}" when the
// weak-first picker chose this question (else null).
  String get pageTitle => throw _privateConstructorUsedError;
  String? get selectionReason => throw _privateConstructorUsedError;

  /// Serializes this QuizQuestion to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of QuizQuestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $QuizQuestionCopyWith<QuizQuestion> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuizQuestionCopyWith<$Res> {
  factory $QuizQuestionCopyWith(
          QuizQuestion value, $Res Function(QuizQuestion) then) =
      _$QuizQuestionCopyWithImpl<$Res, QuizQuestion>;
  @useResult
  $Res call(
      {String id,
      String question,
      List<String> options,
      int? correctIndex,
      String sourcePage,
      String explanation,
      String pageTitle,
      String? selectionReason});
}

/// @nodoc
class _$QuizQuestionCopyWithImpl<$Res, $Val extends QuizQuestion>
    implements $QuizQuestionCopyWith<$Res> {
  _$QuizQuestionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of QuizQuestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? question = null,
    Object? options = null,
    Object? correctIndex = freezed,
    Object? sourcePage = null,
    Object? explanation = null,
    Object? pageTitle = null,
    Object? selectionReason = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      question: null == question
          ? _value.question
          : question // ignore: cast_nullable_to_non_nullable
              as String,
      options: null == options
          ? _value.options
          : options // ignore: cast_nullable_to_non_nullable
              as List<String>,
      correctIndex: freezed == correctIndex
          ? _value.correctIndex
          : correctIndex // ignore: cast_nullable_to_non_nullable
              as int?,
      sourcePage: null == sourcePage
          ? _value.sourcePage
          : sourcePage // ignore: cast_nullable_to_non_nullable
              as String,
      explanation: null == explanation
          ? _value.explanation
          : explanation // ignore: cast_nullable_to_non_nullable
              as String,
      pageTitle: null == pageTitle
          ? _value.pageTitle
          : pageTitle // ignore: cast_nullable_to_non_nullable
              as String,
      selectionReason: freezed == selectionReason
          ? _value.selectionReason
          : selectionReason // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$QuizQuestionImplCopyWith<$Res>
    implements $QuizQuestionCopyWith<$Res> {
  factory _$$QuizQuestionImplCopyWith(
          _$QuizQuestionImpl value, $Res Function(_$QuizQuestionImpl) then) =
      __$$QuizQuestionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String question,
      List<String> options,
      int? correctIndex,
      String sourcePage,
      String explanation,
      String pageTitle,
      String? selectionReason});
}

/// @nodoc
class __$$QuizQuestionImplCopyWithImpl<$Res>
    extends _$QuizQuestionCopyWithImpl<$Res, _$QuizQuestionImpl>
    implements _$$QuizQuestionImplCopyWith<$Res> {
  __$$QuizQuestionImplCopyWithImpl(
      _$QuizQuestionImpl _value, $Res Function(_$QuizQuestionImpl) _then)
      : super(_value, _then);

  /// Create a copy of QuizQuestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? question = null,
    Object? options = null,
    Object? correctIndex = freezed,
    Object? sourcePage = null,
    Object? explanation = null,
    Object? pageTitle = null,
    Object? selectionReason = freezed,
  }) {
    return _then(_$QuizQuestionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      question: null == question
          ? _value.question
          : question // ignore: cast_nullable_to_non_nullable
              as String,
      options: null == options
          ? _value._options
          : options // ignore: cast_nullable_to_non_nullable
              as List<String>,
      correctIndex: freezed == correctIndex
          ? _value.correctIndex
          : correctIndex // ignore: cast_nullable_to_non_nullable
              as int?,
      sourcePage: null == sourcePage
          ? _value.sourcePage
          : sourcePage // ignore: cast_nullable_to_non_nullable
              as String,
      explanation: null == explanation
          ? _value.explanation
          : explanation // ignore: cast_nullable_to_non_nullable
              as String,
      pageTitle: null == pageTitle
          ? _value.pageTitle
          : pageTitle // ignore: cast_nullable_to_non_nullable
              as String,
      selectionReason: freezed == selectionReason
          ? _value.selectionReason
          : selectionReason // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$QuizQuestionImpl implements _QuizQuestion {
  const _$QuizQuestionImpl(
      {this.id = '',
      this.question = '',
      final List<String> options = const [],
      this.correctIndex,
      this.sourcePage = '',
      this.explanation = '',
      this.pageTitle = '',
      this.selectionReason})
      : _options = options;

  factory _$QuizQuestionImpl.fromJson(Map<String, dynamic> json) =>
      _$$QuizQuestionImplFromJson(json);

  @override
  @JsonKey()
  final String id;
  @override
  @JsonKey()
  final String question;
  final List<String> _options;
  @override
  @JsonKey()
  List<String> get options {
    if (_options is EqualUnmodifiableListView) return _options;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_options);
  }

// Nullable BY CONTRACT: the backend WITHHOLDS the answer key for
// teacher-graded (centre) quizzes — `correctIndex` is null then, and the
// correct answer is revealed only post-submit (QuizResult.feedback). A
// `@Default(0)` here would collapse "withheld" into "index 0" and make the
// UI confidently highlight option A as correct — the exact bug this
// nullability prevents. Non-null = B2C daily quiz (instant feedback OK).
  @override
  final int? correctIndex;
  @override
  @JsonKey()
  final String sourcePage;
  @override
  @JsonKey()
  final String explanation;
// Adaptive-provenance serve metadata (nullable/empty on old content → chips/badges
// degrade silently): the source page title, and "WEAK_TOPIC:{concept}" when the
// weak-first picker chose this question (else null).
  @override
  @JsonKey()
  final String pageTitle;
  @override
  final String? selectionReason;

  @override
  String toString() {
    return 'QuizQuestion(id: $id, question: $question, options: $options, correctIndex: $correctIndex, sourcePage: $sourcePage, explanation: $explanation, pageTitle: $pageTitle, selectionReason: $selectionReason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuizQuestionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.question, question) ||
                other.question == question) &&
            const DeepCollectionEquality().equals(other._options, _options) &&
            (identical(other.correctIndex, correctIndex) ||
                other.correctIndex == correctIndex) &&
            (identical(other.sourcePage, sourcePage) ||
                other.sourcePage == sourcePage) &&
            (identical(other.explanation, explanation) ||
                other.explanation == explanation) &&
            (identical(other.pageTitle, pageTitle) ||
                other.pageTitle == pageTitle) &&
            (identical(other.selectionReason, selectionReason) ||
                other.selectionReason == selectionReason));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      question,
      const DeepCollectionEquality().hash(_options),
      correctIndex,
      sourcePage,
      explanation,
      pageTitle,
      selectionReason);

  /// Create a copy of QuizQuestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$QuizQuestionImplCopyWith<_$QuizQuestionImpl> get copyWith =>
      __$$QuizQuestionImplCopyWithImpl<_$QuizQuestionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QuizQuestionImplToJson(
      this,
    );
  }
}

abstract class _QuizQuestion implements QuizQuestion {
  const factory _QuizQuestion(
      {final String id,
      final String question,
      final List<String> options,
      final int? correctIndex,
      final String sourcePage,
      final String explanation,
      final String pageTitle,
      final String? selectionReason}) = _$QuizQuestionImpl;

  factory _QuizQuestion.fromJson(Map<String, dynamic> json) =
      _$QuizQuestionImpl.fromJson;

  @override
  String get id;
  @override
  String get question;
  @override
  List<String>
      get options; // Nullable BY CONTRACT: the backend WITHHOLDS the answer key for
// teacher-graded (centre) quizzes — `correctIndex` is null then, and the
// correct answer is revealed only post-submit (QuizResult.feedback). A
// `@Default(0)` here would collapse "withheld" into "index 0" and make the
// UI confidently highlight option A as correct — the exact bug this
// nullability prevents. Non-null = B2C daily quiz (instant feedback OK).
  @override
  int? get correctIndex;
  @override
  String get sourcePage;
  @override
  String
      get explanation; // Adaptive-provenance serve metadata (nullable/empty on old content → chips/badges
// degrade silently): the source page title, and "WEAK_TOPIC:{concept}" when the
// weak-first picker chose this question (else null).
  @override
  String get pageTitle;
  @override
  String? get selectionReason;

  /// Create a copy of QuizQuestion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$QuizQuestionImplCopyWith<_$QuizQuestionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
