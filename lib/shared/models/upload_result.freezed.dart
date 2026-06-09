// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'upload_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UploadResult _$UploadResultFromJson(Map<String, dynamic> json) {
  return _UploadResult.fromJson(json);
}

/// @nodoc
mixin _$UploadResult {
  String get id => throw _privateConstructorUsedError;
  String get avatarId => throw _privateConstructorUsedError;
  String get fileName => throw _privateConstructorUsedError;
  UploadStatus get status => throw _privateConstructorUsedError;
  int get pageCount => throw _privateConstructorUsedError;
  List<String> get wikiPageTitles => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;
  DateTime? get uploadedAt => throw _privateConstructorUsedError;

  /// Which backend node served this request (null if backend hasn't upgraded).
  String? get servedBy => throw _privateConstructorUsedError;

  /// True when the backend fell back to a secondary text extractor.
  bool get degraded => throw _privateConstructorUsedError;

  /// Pages compiled so far (for partial-progress display during chunked compile).
  int get pagesCompiled => throw _privateConstructorUsedError;

  /// Total pages expected (null until the backend reports it).
  int? get pagesTotal => throw _privateConstructorUsedError;

  /// Serializes this UploadResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UploadResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UploadResultCopyWith<UploadResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UploadResultCopyWith<$Res> {
  factory $UploadResultCopyWith(
          UploadResult value, $Res Function(UploadResult) then) =
      _$UploadResultCopyWithImpl<$Res, UploadResult>;
  @useResult
  $Res call(
      {String id,
      String avatarId,
      String fileName,
      UploadStatus status,
      int pageCount,
      List<String> wikiPageTitles,
      String? errorMessage,
      DateTime? uploadedAt,
      String? servedBy,
      bool degraded,
      int pagesCompiled,
      int? pagesTotal});
}

/// @nodoc
class _$UploadResultCopyWithImpl<$Res, $Val extends UploadResult>
    implements $UploadResultCopyWith<$Res> {
  _$UploadResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UploadResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? avatarId = null,
    Object? fileName = null,
    Object? status = null,
    Object? pageCount = null,
    Object? wikiPageTitles = null,
    Object? errorMessage = freezed,
    Object? uploadedAt = freezed,
    Object? servedBy = freezed,
    Object? degraded = null,
    Object? pagesCompiled = null,
    Object? pagesTotal = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      avatarId: null == avatarId
          ? _value.avatarId
          : avatarId // ignore: cast_nullable_to_non_nullable
              as String,
      fileName: null == fileName
          ? _value.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as UploadStatus,
      pageCount: null == pageCount
          ? _value.pageCount
          : pageCount // ignore: cast_nullable_to_non_nullable
              as int,
      wikiPageTitles: null == wikiPageTitles
          ? _value.wikiPageTitles
          : wikiPageTitles // ignore: cast_nullable_to_non_nullable
              as List<String>,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      uploadedAt: freezed == uploadedAt
          ? _value.uploadedAt
          : uploadedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      servedBy: freezed == servedBy
          ? _value.servedBy
          : servedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      degraded: null == degraded
          ? _value.degraded
          : degraded // ignore: cast_nullable_to_non_nullable
              as bool,
      pagesCompiled: null == pagesCompiled
          ? _value.pagesCompiled
          : pagesCompiled // ignore: cast_nullable_to_non_nullable
              as int,
      pagesTotal: freezed == pagesTotal
          ? _value.pagesTotal
          : pagesTotal // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UploadResultImplCopyWith<$Res>
    implements $UploadResultCopyWith<$Res> {
  factory _$$UploadResultImplCopyWith(
          _$UploadResultImpl value, $Res Function(_$UploadResultImpl) then) =
      __$$UploadResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String avatarId,
      String fileName,
      UploadStatus status,
      int pageCount,
      List<String> wikiPageTitles,
      String? errorMessage,
      DateTime? uploadedAt,
      String? servedBy,
      bool degraded,
      int pagesCompiled,
      int? pagesTotal});
}

/// @nodoc
class __$$UploadResultImplCopyWithImpl<$Res>
    extends _$UploadResultCopyWithImpl<$Res, _$UploadResultImpl>
    implements _$$UploadResultImplCopyWith<$Res> {
  __$$UploadResultImplCopyWithImpl(
      _$UploadResultImpl _value, $Res Function(_$UploadResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of UploadResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? avatarId = null,
    Object? fileName = null,
    Object? status = null,
    Object? pageCount = null,
    Object? wikiPageTitles = null,
    Object? errorMessage = freezed,
    Object? uploadedAt = freezed,
    Object? servedBy = freezed,
    Object? degraded = null,
    Object? pagesCompiled = null,
    Object? pagesTotal = freezed,
  }) {
    return _then(_$UploadResultImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      avatarId: null == avatarId
          ? _value.avatarId
          : avatarId // ignore: cast_nullable_to_non_nullable
              as String,
      fileName: null == fileName
          ? _value.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as UploadStatus,
      pageCount: null == pageCount
          ? _value.pageCount
          : pageCount // ignore: cast_nullable_to_non_nullable
              as int,
      wikiPageTitles: null == wikiPageTitles
          ? _value._wikiPageTitles
          : wikiPageTitles // ignore: cast_nullable_to_non_nullable
              as List<String>,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      uploadedAt: freezed == uploadedAt
          ? _value.uploadedAt
          : uploadedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      servedBy: freezed == servedBy
          ? _value.servedBy
          : servedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      degraded: null == degraded
          ? _value.degraded
          : degraded // ignore: cast_nullable_to_non_nullable
              as bool,
      pagesCompiled: null == pagesCompiled
          ? _value.pagesCompiled
          : pagesCompiled // ignore: cast_nullable_to_non_nullable
              as int,
      pagesTotal: freezed == pagesTotal
          ? _value.pagesTotal
          : pagesTotal // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UploadResultImpl implements _UploadResult {
  const _$UploadResultImpl(
      {this.id = '',
      this.avatarId = '',
      this.fileName = '',
      this.status = UploadStatus.processing,
      this.pageCount = 0,
      final List<String> wikiPageTitles = const <String>[],
      this.errorMessage,
      this.uploadedAt,
      this.servedBy,
      this.degraded = false,
      this.pagesCompiled = 0,
      this.pagesTotal})
      : _wikiPageTitles = wikiPageTitles;

  factory _$UploadResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$UploadResultImplFromJson(json);

  @override
  @JsonKey()
  final String id;
  @override
  @JsonKey()
  final String avatarId;
  @override
  @JsonKey()
  final String fileName;
  @override
  @JsonKey()
  final UploadStatus status;
  @override
  @JsonKey()
  final int pageCount;
  final List<String> _wikiPageTitles;
  @override
  @JsonKey()
  List<String> get wikiPageTitles {
    if (_wikiPageTitles is EqualUnmodifiableListView) return _wikiPageTitles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_wikiPageTitles);
  }

  @override
  final String? errorMessage;
  @override
  final DateTime? uploadedAt;

  /// Which backend node served this request (null if backend hasn't upgraded).
  @override
  final String? servedBy;

  /// True when the backend fell back to a secondary text extractor.
  @override
  @JsonKey()
  final bool degraded;

  /// Pages compiled so far (for partial-progress display during chunked compile).
  @override
  @JsonKey()
  final int pagesCompiled;

  /// Total pages expected (null until the backend reports it).
  @override
  final int? pagesTotal;

  @override
  String toString() {
    return 'UploadResult(id: $id, avatarId: $avatarId, fileName: $fileName, status: $status, pageCount: $pageCount, wikiPageTitles: $wikiPageTitles, errorMessage: $errorMessage, uploadedAt: $uploadedAt, servedBy: $servedBy, degraded: $degraded, pagesCompiled: $pagesCompiled, pagesTotal: $pagesTotal)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UploadResultImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.avatarId, avatarId) ||
                other.avatarId == avatarId) &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.pageCount, pageCount) ||
                other.pageCount == pageCount) &&
            const DeepCollectionEquality()
                .equals(other._wikiPageTitles, _wikiPageTitles) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.uploadedAt, uploadedAt) ||
                other.uploadedAt == uploadedAt) &&
            (identical(other.servedBy, servedBy) ||
                other.servedBy == servedBy) &&
            (identical(other.degraded, degraded) ||
                other.degraded == degraded) &&
            (identical(other.pagesCompiled, pagesCompiled) ||
                other.pagesCompiled == pagesCompiled) &&
            (identical(other.pagesTotal, pagesTotal) ||
                other.pagesTotal == pagesTotal));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      avatarId,
      fileName,
      status,
      pageCount,
      const DeepCollectionEquality().hash(_wikiPageTitles),
      errorMessage,
      uploadedAt,
      servedBy,
      degraded,
      pagesCompiled,
      pagesTotal);

  /// Create a copy of UploadResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UploadResultImplCopyWith<_$UploadResultImpl> get copyWith =>
      __$$UploadResultImplCopyWithImpl<_$UploadResultImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UploadResultImplToJson(
      this,
    );
  }
}

abstract class _UploadResult implements UploadResult {
  const factory _UploadResult(
      {final String id,
      final String avatarId,
      final String fileName,
      final UploadStatus status,
      final int pageCount,
      final List<String> wikiPageTitles,
      final String? errorMessage,
      final DateTime? uploadedAt,
      final String? servedBy,
      final bool degraded,
      final int pagesCompiled,
      final int? pagesTotal}) = _$UploadResultImpl;

  factory _UploadResult.fromJson(Map<String, dynamic> json) =
      _$UploadResultImpl.fromJson;

  @override
  String get id;
  @override
  String get avatarId;
  @override
  String get fileName;
  @override
  UploadStatus get status;
  @override
  int get pageCount;
  @override
  List<String> get wikiPageTitles;
  @override
  String? get errorMessage;
  @override
  DateTime? get uploadedAt;

  /// Which backend node served this request (null if backend hasn't upgraded).
  @override
  String? get servedBy;

  /// True when the backend fell back to a secondary text extractor.
  @override
  bool get degraded;

  /// Pages compiled so far (for partial-progress display during chunked compile).
  @override
  int get pagesCompiled;

  /// Total pages expected (null until the backend reports it).
  @override
  int? get pagesTotal;

  /// Create a copy of UploadResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UploadResultImplCopyWith<_$UploadResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RelevanceCheckResponse _$RelevanceCheckResponseFromJson(
    Map<String, dynamic> json) {
  return _RelevanceCheckResponse.fromJson(json);
}

/// @nodoc
mixin _$RelevanceCheckResponse {
  bool get isRelevant => throw _privateConstructorUsedError;
  double get score => throw _privateConstructorUsedError;
  String? get reason => throw _privateConstructorUsedError;

  /// Serializes this RelevanceCheckResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RelevanceCheckResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RelevanceCheckResponseCopyWith<RelevanceCheckResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RelevanceCheckResponseCopyWith<$Res> {
  factory $RelevanceCheckResponseCopyWith(RelevanceCheckResponse value,
          $Res Function(RelevanceCheckResponse) then) =
      _$RelevanceCheckResponseCopyWithImpl<$Res, RelevanceCheckResponse>;
  @useResult
  $Res call({bool isRelevant, double score, String? reason});
}

/// @nodoc
class _$RelevanceCheckResponseCopyWithImpl<$Res,
        $Val extends RelevanceCheckResponse>
    implements $RelevanceCheckResponseCopyWith<$Res> {
  _$RelevanceCheckResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RelevanceCheckResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isRelevant = null,
    Object? score = null,
    Object? reason = freezed,
  }) {
    return _then(_value.copyWith(
      isRelevant: null == isRelevant
          ? _value.isRelevant
          : isRelevant // ignore: cast_nullable_to_non_nullable
              as bool,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as double,
      reason: freezed == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RelevanceCheckResponseImplCopyWith<$Res>
    implements $RelevanceCheckResponseCopyWith<$Res> {
  factory _$$RelevanceCheckResponseImplCopyWith(
          _$RelevanceCheckResponseImpl value,
          $Res Function(_$RelevanceCheckResponseImpl) then) =
      __$$RelevanceCheckResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool isRelevant, double score, String? reason});
}

/// @nodoc
class __$$RelevanceCheckResponseImplCopyWithImpl<$Res>
    extends _$RelevanceCheckResponseCopyWithImpl<$Res,
        _$RelevanceCheckResponseImpl>
    implements _$$RelevanceCheckResponseImplCopyWith<$Res> {
  __$$RelevanceCheckResponseImplCopyWithImpl(
      _$RelevanceCheckResponseImpl _value,
      $Res Function(_$RelevanceCheckResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of RelevanceCheckResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isRelevant = null,
    Object? score = null,
    Object? reason = freezed,
  }) {
    return _then(_$RelevanceCheckResponseImpl(
      isRelevant: null == isRelevant
          ? _value.isRelevant
          : isRelevant // ignore: cast_nullable_to_non_nullable
              as bool,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as double,
      reason: freezed == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RelevanceCheckResponseImpl implements _RelevanceCheckResponse {
  const _$RelevanceCheckResponseImpl(
      {this.isRelevant = true, this.score = 1.0, this.reason});

  factory _$RelevanceCheckResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$RelevanceCheckResponseImplFromJson(json);

  @override
  @JsonKey()
  final bool isRelevant;
  @override
  @JsonKey()
  final double score;
  @override
  final String? reason;

  @override
  String toString() {
    return 'RelevanceCheckResponse(isRelevant: $isRelevant, score: $score, reason: $reason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RelevanceCheckResponseImpl &&
            (identical(other.isRelevant, isRelevant) ||
                other.isRelevant == isRelevant) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.reason, reason) || other.reason == reason));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, isRelevant, score, reason);

  /// Create a copy of RelevanceCheckResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RelevanceCheckResponseImplCopyWith<_$RelevanceCheckResponseImpl>
      get copyWith => __$$RelevanceCheckResponseImplCopyWithImpl<
          _$RelevanceCheckResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RelevanceCheckResponseImplToJson(
      this,
    );
  }
}

abstract class _RelevanceCheckResponse implements RelevanceCheckResponse {
  const factory _RelevanceCheckResponse(
      {final bool isRelevant,
      final double score,
      final String? reason}) = _$RelevanceCheckResponseImpl;

  factory _RelevanceCheckResponse.fromJson(Map<String, dynamic> json) =
      _$RelevanceCheckResponseImpl.fromJson;

  @override
  bool get isRelevant;
  @override
  double get score;
  @override
  String? get reason;

  /// Create a copy of RelevanceCheckResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RelevanceCheckResponseImplCopyWith<_$RelevanceCheckResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}
