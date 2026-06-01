// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'photo_question.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PhotoQuestion _$PhotoQuestionFromJson(Map<String, dynamic> json) {
  return _PhotoQuestion.fromJson(json);
}

/// @nodoc
mixin _$PhotoQuestion {
  String get id => throw _privateConstructorUsedError;
  String get rawText => throw _privateConstructorUsedError;
  int get questionIndex => throw _privateConstructorUsedError;
  bool get isSelected => throw _privateConstructorUsedError;

  /// Serializes this PhotoQuestion to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PhotoQuestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PhotoQuestionCopyWith<PhotoQuestion> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PhotoQuestionCopyWith<$Res> {
  factory $PhotoQuestionCopyWith(
          PhotoQuestion value, $Res Function(PhotoQuestion) then) =
      _$PhotoQuestionCopyWithImpl<$Res, PhotoQuestion>;
  @useResult
  $Res call({String id, String rawText, int questionIndex, bool isSelected});
}

/// @nodoc
class _$PhotoQuestionCopyWithImpl<$Res, $Val extends PhotoQuestion>
    implements $PhotoQuestionCopyWith<$Res> {
  _$PhotoQuestionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PhotoQuestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? rawText = null,
    Object? questionIndex = null,
    Object? isSelected = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      rawText: null == rawText
          ? _value.rawText
          : rawText // ignore: cast_nullable_to_non_nullable
              as String,
      questionIndex: null == questionIndex
          ? _value.questionIndex
          : questionIndex // ignore: cast_nullable_to_non_nullable
              as int,
      isSelected: null == isSelected
          ? _value.isSelected
          : isSelected // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PhotoQuestionImplCopyWith<$Res>
    implements $PhotoQuestionCopyWith<$Res> {
  factory _$$PhotoQuestionImplCopyWith(
          _$PhotoQuestionImpl value, $Res Function(_$PhotoQuestionImpl) then) =
      __$$PhotoQuestionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String rawText, int questionIndex, bool isSelected});
}

/// @nodoc
class __$$PhotoQuestionImplCopyWithImpl<$Res>
    extends _$PhotoQuestionCopyWithImpl<$Res, _$PhotoQuestionImpl>
    implements _$$PhotoQuestionImplCopyWith<$Res> {
  __$$PhotoQuestionImplCopyWithImpl(
      _$PhotoQuestionImpl _value, $Res Function(_$PhotoQuestionImpl) _then)
      : super(_value, _then);

  /// Create a copy of PhotoQuestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? rawText = null,
    Object? questionIndex = null,
    Object? isSelected = null,
  }) {
    return _then(_$PhotoQuestionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      rawText: null == rawText
          ? _value.rawText
          : rawText // ignore: cast_nullable_to_non_nullable
              as String,
      questionIndex: null == questionIndex
          ? _value.questionIndex
          : questionIndex // ignore: cast_nullable_to_non_nullable
              as int,
      isSelected: null == isSelected
          ? _value.isSelected
          : isSelected // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PhotoQuestionImpl implements _PhotoQuestion {
  const _$PhotoQuestionImpl(
      {this.id = '',
      this.rawText = '',
      this.questionIndex = 0,
      this.isSelected = true});

  factory _$PhotoQuestionImpl.fromJson(Map<String, dynamic> json) =>
      _$$PhotoQuestionImplFromJson(json);

  @override
  @JsonKey()
  final String id;
  @override
  @JsonKey()
  final String rawText;
  @override
  @JsonKey()
  final int questionIndex;
  @override
  @JsonKey()
  final bool isSelected;

  @override
  String toString() {
    return 'PhotoQuestion(id: $id, rawText: $rawText, questionIndex: $questionIndex, isSelected: $isSelected)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PhotoQuestionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.rawText, rawText) || other.rawText == rawText) &&
            (identical(other.questionIndex, questionIndex) ||
                other.questionIndex == questionIndex) &&
            (identical(other.isSelected, isSelected) ||
                other.isSelected == isSelected));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, rawText, questionIndex, isSelected);

  /// Create a copy of PhotoQuestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PhotoQuestionImplCopyWith<_$PhotoQuestionImpl> get copyWith =>
      __$$PhotoQuestionImplCopyWithImpl<_$PhotoQuestionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PhotoQuestionImplToJson(
      this,
    );
  }
}

abstract class _PhotoQuestion implements PhotoQuestion {
  const factory _PhotoQuestion(
      {final String id,
      final String rawText,
      final int questionIndex,
      final bool isSelected}) = _$PhotoQuestionImpl;

  factory _PhotoQuestion.fromJson(Map<String, dynamic> json) =
      _$PhotoQuestionImpl.fromJson;

  @override
  String get id;
  @override
  String get rawText;
  @override
  int get questionIndex;
  @override
  bool get isSelected;

  /// Create a copy of PhotoQuestion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PhotoQuestionImplCopyWith<_$PhotoQuestionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

QuestionAnswer _$QuestionAnswerFromJson(Map<String, dynamic> json) {
  return _QuestionAnswer.fromJson(json);
}

/// @nodoc
mixin _$QuestionAnswer {
  String get questionId => throw _privateConstructorUsedError;
  String get questionText => throw _privateConstructorUsedError;
  String get answer => throw _privateConstructorUsedError;
  List<String> get steps => throw _privateConstructorUsedError;
  String get explanation =>
      throw _privateConstructorUsedError; // Tier 0/2 fields from the backend visual classifier
  String get visualType => throw _privateConstructorUsedError;
  bool get calculatorVerified => throw _privateConstructorUsedError;

  /// Serializes this QuestionAnswer to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of QuestionAnswer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $QuestionAnswerCopyWith<QuestionAnswer> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuestionAnswerCopyWith<$Res> {
  factory $QuestionAnswerCopyWith(
          QuestionAnswer value, $Res Function(QuestionAnswer) then) =
      _$QuestionAnswerCopyWithImpl<$Res, QuestionAnswer>;
  @useResult
  $Res call(
      {String questionId,
      String questionText,
      String answer,
      List<String> steps,
      String explanation,
      String visualType,
      bool calculatorVerified});
}

/// @nodoc
class _$QuestionAnswerCopyWithImpl<$Res, $Val extends QuestionAnswer>
    implements $QuestionAnswerCopyWith<$Res> {
  _$QuestionAnswerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of QuestionAnswer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? questionId = null,
    Object? questionText = null,
    Object? answer = null,
    Object? steps = null,
    Object? explanation = null,
    Object? visualType = null,
    Object? calculatorVerified = null,
  }) {
    return _then(_value.copyWith(
      questionId: null == questionId
          ? _value.questionId
          : questionId // ignore: cast_nullable_to_non_nullable
              as String,
      questionText: null == questionText
          ? _value.questionText
          : questionText // ignore: cast_nullable_to_non_nullable
              as String,
      answer: null == answer
          ? _value.answer
          : answer // ignore: cast_nullable_to_non_nullable
              as String,
      steps: null == steps
          ? _value.steps
          : steps // ignore: cast_nullable_to_non_nullable
              as List<String>,
      explanation: null == explanation
          ? _value.explanation
          : explanation // ignore: cast_nullable_to_non_nullable
              as String,
      visualType: null == visualType
          ? _value.visualType
          : visualType // ignore: cast_nullable_to_non_nullable
              as String,
      calculatorVerified: null == calculatorVerified
          ? _value.calculatorVerified
          : calculatorVerified // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$QuestionAnswerImplCopyWith<$Res>
    implements $QuestionAnswerCopyWith<$Res> {
  factory _$$QuestionAnswerImplCopyWith(_$QuestionAnswerImpl value,
          $Res Function(_$QuestionAnswerImpl) then) =
      __$$QuestionAnswerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String questionId,
      String questionText,
      String answer,
      List<String> steps,
      String explanation,
      String visualType,
      bool calculatorVerified});
}

/// @nodoc
class __$$QuestionAnswerImplCopyWithImpl<$Res>
    extends _$QuestionAnswerCopyWithImpl<$Res, _$QuestionAnswerImpl>
    implements _$$QuestionAnswerImplCopyWith<$Res> {
  __$$QuestionAnswerImplCopyWithImpl(
      _$QuestionAnswerImpl _value, $Res Function(_$QuestionAnswerImpl) _then)
      : super(_value, _then);

  /// Create a copy of QuestionAnswer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? questionId = null,
    Object? questionText = null,
    Object? answer = null,
    Object? steps = null,
    Object? explanation = null,
    Object? visualType = null,
    Object? calculatorVerified = null,
  }) {
    return _then(_$QuestionAnswerImpl(
      questionId: null == questionId
          ? _value.questionId
          : questionId // ignore: cast_nullable_to_non_nullable
              as String,
      questionText: null == questionText
          ? _value.questionText
          : questionText // ignore: cast_nullable_to_non_nullable
              as String,
      answer: null == answer
          ? _value.answer
          : answer // ignore: cast_nullable_to_non_nullable
              as String,
      steps: null == steps
          ? _value._steps
          : steps // ignore: cast_nullable_to_non_nullable
              as List<String>,
      explanation: null == explanation
          ? _value.explanation
          : explanation // ignore: cast_nullable_to_non_nullable
              as String,
      visualType: null == visualType
          ? _value.visualType
          : visualType // ignore: cast_nullable_to_non_nullable
              as String,
      calculatorVerified: null == calculatorVerified
          ? _value.calculatorVerified
          : calculatorVerified // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$QuestionAnswerImpl implements _QuestionAnswer {
  const _$QuestionAnswerImpl(
      {this.questionId = '',
      this.questionText = '',
      this.answer = '',
      final List<String> steps = const [],
      this.explanation = '',
      this.visualType = 'NONE',
      this.calculatorVerified = false})
      : _steps = steps;

  factory _$QuestionAnswerImpl.fromJson(Map<String, dynamic> json) =>
      _$$QuestionAnswerImplFromJson(json);

  @override
  @JsonKey()
  final String questionId;
  @override
  @JsonKey()
  final String questionText;
  @override
  @JsonKey()
  final String answer;
  final List<String> _steps;
  @override
  @JsonKey()
  List<String> get steps {
    if (_steps is EqualUnmodifiableListView) return _steps;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_steps);
  }

  @override
  @JsonKey()
  final String explanation;
// Tier 0/2 fields from the backend visual classifier
  @override
  @JsonKey()
  final String visualType;
  @override
  @JsonKey()
  final bool calculatorVerified;

  @override
  String toString() {
    return 'QuestionAnswer(questionId: $questionId, questionText: $questionText, answer: $answer, steps: $steps, explanation: $explanation, visualType: $visualType, calculatorVerified: $calculatorVerified)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuestionAnswerImpl &&
            (identical(other.questionId, questionId) ||
                other.questionId == questionId) &&
            (identical(other.questionText, questionText) ||
                other.questionText == questionText) &&
            (identical(other.answer, answer) || other.answer == answer) &&
            const DeepCollectionEquality().equals(other._steps, _steps) &&
            (identical(other.explanation, explanation) ||
                other.explanation == explanation) &&
            (identical(other.visualType, visualType) ||
                other.visualType == visualType) &&
            (identical(other.calculatorVerified, calculatorVerified) ||
                other.calculatorVerified == calculatorVerified));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      questionId,
      questionText,
      answer,
      const DeepCollectionEquality().hash(_steps),
      explanation,
      visualType,
      calculatorVerified);

  /// Create a copy of QuestionAnswer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$QuestionAnswerImplCopyWith<_$QuestionAnswerImpl> get copyWith =>
      __$$QuestionAnswerImplCopyWithImpl<_$QuestionAnswerImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QuestionAnswerImplToJson(
      this,
    );
  }
}

abstract class _QuestionAnswer implements QuestionAnswer {
  const factory _QuestionAnswer(
      {final String questionId,
      final String questionText,
      final String answer,
      final List<String> steps,
      final String explanation,
      final String visualType,
      final bool calculatorVerified}) = _$QuestionAnswerImpl;

  factory _QuestionAnswer.fromJson(Map<String, dynamic> json) =
      _$QuestionAnswerImpl.fromJson;

  @override
  String get questionId;
  @override
  String get questionText;
  @override
  String get answer;
  @override
  List<String> get steps;
  @override
  String get explanation; // Tier 0/2 fields from the backend visual classifier
  @override
  String get visualType;
  @override
  bool get calculatorVerified;

  /// Create a copy of QuestionAnswer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$QuestionAnswerImplCopyWith<_$QuestionAnswerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

HomeworkScanResult _$HomeworkScanResultFromJson(Map<String, dynamic> json) {
  return _HomeworkScanResult.fromJson(json);
}

/// @nodoc
mixin _$HomeworkScanResult {
  String get messageId => throw _privateConstructorUsedError;
  String get imageLocalPath => throw _privateConstructorUsedError;
  List<PhotoQuestion> get questions => throw _privateConstructorUsedError;
  List<QuestionAnswer> get answers => throw _privateConstructorUsedError;
  int get xpEarned => throw _privateConstructorUsedError;
  String? get sourceWikiPage => throw _privateConstructorUsedError;
  HomeworkScanStatus get status => throw _privateConstructorUsedError;

  /// Serializes this HomeworkScanResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HomeworkScanResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HomeworkScanResultCopyWith<HomeworkScanResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HomeworkScanResultCopyWith<$Res> {
  factory $HomeworkScanResultCopyWith(
          HomeworkScanResult value, $Res Function(HomeworkScanResult) then) =
      _$HomeworkScanResultCopyWithImpl<$Res, HomeworkScanResult>;
  @useResult
  $Res call(
      {String messageId,
      String imageLocalPath,
      List<PhotoQuestion> questions,
      List<QuestionAnswer> answers,
      int xpEarned,
      String? sourceWikiPage,
      HomeworkScanStatus status});
}

/// @nodoc
class _$HomeworkScanResultCopyWithImpl<$Res, $Val extends HomeworkScanResult>
    implements $HomeworkScanResultCopyWith<$Res> {
  _$HomeworkScanResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HomeworkScanResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? messageId = null,
    Object? imageLocalPath = null,
    Object? questions = null,
    Object? answers = null,
    Object? xpEarned = null,
    Object? sourceWikiPage = freezed,
    Object? status = null,
  }) {
    return _then(_value.copyWith(
      messageId: null == messageId
          ? _value.messageId
          : messageId // ignore: cast_nullable_to_non_nullable
              as String,
      imageLocalPath: null == imageLocalPath
          ? _value.imageLocalPath
          : imageLocalPath // ignore: cast_nullable_to_non_nullable
              as String,
      questions: null == questions
          ? _value.questions
          : questions // ignore: cast_nullable_to_non_nullable
              as List<PhotoQuestion>,
      answers: null == answers
          ? _value.answers
          : answers // ignore: cast_nullable_to_non_nullable
              as List<QuestionAnswer>,
      xpEarned: null == xpEarned
          ? _value.xpEarned
          : xpEarned // ignore: cast_nullable_to_non_nullable
              as int,
      sourceWikiPage: freezed == sourceWikiPage
          ? _value.sourceWikiPage
          : sourceWikiPage // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as HomeworkScanStatus,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HomeworkScanResultImplCopyWith<$Res>
    implements $HomeworkScanResultCopyWith<$Res> {
  factory _$$HomeworkScanResultImplCopyWith(_$HomeworkScanResultImpl value,
          $Res Function(_$HomeworkScanResultImpl) then) =
      __$$HomeworkScanResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String messageId,
      String imageLocalPath,
      List<PhotoQuestion> questions,
      List<QuestionAnswer> answers,
      int xpEarned,
      String? sourceWikiPage,
      HomeworkScanStatus status});
}

/// @nodoc
class __$$HomeworkScanResultImplCopyWithImpl<$Res>
    extends _$HomeworkScanResultCopyWithImpl<$Res, _$HomeworkScanResultImpl>
    implements _$$HomeworkScanResultImplCopyWith<$Res> {
  __$$HomeworkScanResultImplCopyWithImpl(_$HomeworkScanResultImpl _value,
      $Res Function(_$HomeworkScanResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of HomeworkScanResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? messageId = null,
    Object? imageLocalPath = null,
    Object? questions = null,
    Object? answers = null,
    Object? xpEarned = null,
    Object? sourceWikiPage = freezed,
    Object? status = null,
  }) {
    return _then(_$HomeworkScanResultImpl(
      messageId: null == messageId
          ? _value.messageId
          : messageId // ignore: cast_nullable_to_non_nullable
              as String,
      imageLocalPath: null == imageLocalPath
          ? _value.imageLocalPath
          : imageLocalPath // ignore: cast_nullable_to_non_nullable
              as String,
      questions: null == questions
          ? _value._questions
          : questions // ignore: cast_nullable_to_non_nullable
              as List<PhotoQuestion>,
      answers: null == answers
          ? _value._answers
          : answers // ignore: cast_nullable_to_non_nullable
              as List<QuestionAnswer>,
      xpEarned: null == xpEarned
          ? _value.xpEarned
          : xpEarned // ignore: cast_nullable_to_non_nullable
              as int,
      sourceWikiPage: freezed == sourceWikiPage
          ? _value.sourceWikiPage
          : sourceWikiPage // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as HomeworkScanStatus,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HomeworkScanResultImpl implements _HomeworkScanResult {
  const _$HomeworkScanResultImpl(
      {this.messageId = '',
      this.imageLocalPath = '',
      final List<PhotoQuestion> questions = const [],
      final List<QuestionAnswer> answers = const [],
      this.xpEarned = 5,
      this.sourceWikiPage,
      this.status = HomeworkScanStatus.complete})
      : _questions = questions,
        _answers = answers;

  factory _$HomeworkScanResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$HomeworkScanResultImplFromJson(json);

  @override
  @JsonKey()
  final String messageId;
  @override
  @JsonKey()
  final String imageLocalPath;
  final List<PhotoQuestion> _questions;
  @override
  @JsonKey()
  List<PhotoQuestion> get questions {
    if (_questions is EqualUnmodifiableListView) return _questions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_questions);
  }

  final List<QuestionAnswer> _answers;
  @override
  @JsonKey()
  List<QuestionAnswer> get answers {
    if (_answers is EqualUnmodifiableListView) return _answers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_answers);
  }

  @override
  @JsonKey()
  final int xpEarned;
  @override
  final String? sourceWikiPage;
  @override
  @JsonKey()
  final HomeworkScanStatus status;

  @override
  String toString() {
    return 'HomeworkScanResult(messageId: $messageId, imageLocalPath: $imageLocalPath, questions: $questions, answers: $answers, xpEarned: $xpEarned, sourceWikiPage: $sourceWikiPage, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HomeworkScanResultImpl &&
            (identical(other.messageId, messageId) ||
                other.messageId == messageId) &&
            (identical(other.imageLocalPath, imageLocalPath) ||
                other.imageLocalPath == imageLocalPath) &&
            const DeepCollectionEquality()
                .equals(other._questions, _questions) &&
            const DeepCollectionEquality().equals(other._answers, _answers) &&
            (identical(other.xpEarned, xpEarned) ||
                other.xpEarned == xpEarned) &&
            (identical(other.sourceWikiPage, sourceWikiPage) ||
                other.sourceWikiPage == sourceWikiPage) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      messageId,
      imageLocalPath,
      const DeepCollectionEquality().hash(_questions),
      const DeepCollectionEquality().hash(_answers),
      xpEarned,
      sourceWikiPage,
      status);

  /// Create a copy of HomeworkScanResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HomeworkScanResultImplCopyWith<_$HomeworkScanResultImpl> get copyWith =>
      __$$HomeworkScanResultImplCopyWithImpl<_$HomeworkScanResultImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HomeworkScanResultImplToJson(
      this,
    );
  }
}

abstract class _HomeworkScanResult implements HomeworkScanResult {
  const factory _HomeworkScanResult(
      {final String messageId,
      final String imageLocalPath,
      final List<PhotoQuestion> questions,
      final List<QuestionAnswer> answers,
      final int xpEarned,
      final String? sourceWikiPage,
      final HomeworkScanStatus status}) = _$HomeworkScanResultImpl;

  factory _HomeworkScanResult.fromJson(Map<String, dynamic> json) =
      _$HomeworkScanResultImpl.fromJson;

  @override
  String get messageId;
  @override
  String get imageLocalPath;
  @override
  List<PhotoQuestion> get questions;
  @override
  List<QuestionAnswer> get answers;
  @override
  int get xpEarned;
  @override
  String? get sourceWikiPage;
  @override
  HomeworkScanStatus get status;

  /// Create a copy of HomeworkScanResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HomeworkScanResultImplCopyWith<_$HomeworkScanResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
