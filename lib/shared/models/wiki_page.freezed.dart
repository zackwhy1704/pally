// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wiki_page.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

WikiPage _$WikiPageFromJson(Map<String, dynamic> json) {
  return _WikiPage.fromJson(json);
}

/// @nodoc
mixin _$WikiPage {
  String get id => throw _privateConstructorUsedError;
  String get avatarId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  String get certainty => throw _privateConstructorUsedError;
  bool get hasConflict => throw _privateConstructorUsedError;
  List<String> get sourceFileIds => throw _privateConstructorUsedError;
  String? get slug => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  DateTime? get compiledAt => throw _privateConstructorUsedError;
  int get qualityScore => throw _privateConstructorUsedError;
  bool get humanVerified => throw _privateConstructorUsedError;
  String? get humanCorrection =>
      throw _privateConstructorUsedError; // Fix 3: provenance — names of knowledge files that contributed to this page
  List<String> get sourceFileNames =>
      throw _privateConstructorUsedError; // Review lifecycle — see [WikiReviewState]. Null-tolerant: a missing or
// unknown value parses to UNVERIFIED rather than throwing.
  @JsonKey(fromJson: _reviewStateFromJson)
  WikiReviewState get reviewState =>
      throw _privateConstructorUsedError; // Display name of whoever verified/flagged the page (e.g. "Mum", a tutor).
// Null when never reviewed.
  String? get verifiedBy =>
      throw _privateConstructorUsedError; // Present (and non-empty) only when [reviewState] == flagged — the
// reviewer's note on what looked wrong.
  String? get flagNote => throw _privateConstructorUsedError;

  /// Serializes this WikiPage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WikiPage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WikiPageCopyWith<WikiPage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WikiPageCopyWith<$Res> {
  factory $WikiPageCopyWith(WikiPage value, $Res Function(WikiPage) then) =
      _$WikiPageCopyWithImpl<$Res, WikiPage>;
  @useResult
  $Res call(
      {String id,
      String avatarId,
      String title,
      String content,
      String certainty,
      bool hasConflict,
      List<String> sourceFileIds,
      String? slug,
      DateTime? updatedAt,
      DateTime? compiledAt,
      int qualityScore,
      bool humanVerified,
      String? humanCorrection,
      List<String> sourceFileNames,
      @JsonKey(fromJson: _reviewStateFromJson) WikiReviewState reviewState,
      String? verifiedBy,
      String? flagNote});
}

/// @nodoc
class _$WikiPageCopyWithImpl<$Res, $Val extends WikiPage>
    implements $WikiPageCopyWith<$Res> {
  _$WikiPageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WikiPage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? avatarId = null,
    Object? title = null,
    Object? content = null,
    Object? certainty = null,
    Object? hasConflict = null,
    Object? sourceFileIds = null,
    Object? slug = freezed,
    Object? updatedAt = freezed,
    Object? compiledAt = freezed,
    Object? qualityScore = null,
    Object? humanVerified = null,
    Object? humanCorrection = freezed,
    Object? sourceFileNames = null,
    Object? reviewState = null,
    Object? verifiedBy = freezed,
    Object? flagNote = freezed,
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
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      certainty: null == certainty
          ? _value.certainty
          : certainty // ignore: cast_nullable_to_non_nullable
              as String,
      hasConflict: null == hasConflict
          ? _value.hasConflict
          : hasConflict // ignore: cast_nullable_to_non_nullable
              as bool,
      sourceFileIds: null == sourceFileIds
          ? _value.sourceFileIds
          : sourceFileIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      slug: freezed == slug
          ? _value.slug
          : slug // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      compiledAt: freezed == compiledAt
          ? _value.compiledAt
          : compiledAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      qualityScore: null == qualityScore
          ? _value.qualityScore
          : qualityScore // ignore: cast_nullable_to_non_nullable
              as int,
      humanVerified: null == humanVerified
          ? _value.humanVerified
          : humanVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      humanCorrection: freezed == humanCorrection
          ? _value.humanCorrection
          : humanCorrection // ignore: cast_nullable_to_non_nullable
              as String?,
      sourceFileNames: null == sourceFileNames
          ? _value.sourceFileNames
          : sourceFileNames // ignore: cast_nullable_to_non_nullable
              as List<String>,
      reviewState: null == reviewState
          ? _value.reviewState
          : reviewState // ignore: cast_nullable_to_non_nullable
              as WikiReviewState,
      verifiedBy: freezed == verifiedBy
          ? _value.verifiedBy
          : verifiedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      flagNote: freezed == flagNote
          ? _value.flagNote
          : flagNote // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WikiPageImplCopyWith<$Res>
    implements $WikiPageCopyWith<$Res> {
  factory _$$WikiPageImplCopyWith(
          _$WikiPageImpl value, $Res Function(_$WikiPageImpl) then) =
      __$$WikiPageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String avatarId,
      String title,
      String content,
      String certainty,
      bool hasConflict,
      List<String> sourceFileIds,
      String? slug,
      DateTime? updatedAt,
      DateTime? compiledAt,
      int qualityScore,
      bool humanVerified,
      String? humanCorrection,
      List<String> sourceFileNames,
      @JsonKey(fromJson: _reviewStateFromJson) WikiReviewState reviewState,
      String? verifiedBy,
      String? flagNote});
}

/// @nodoc
class __$$WikiPageImplCopyWithImpl<$Res>
    extends _$WikiPageCopyWithImpl<$Res, _$WikiPageImpl>
    implements _$$WikiPageImplCopyWith<$Res> {
  __$$WikiPageImplCopyWithImpl(
      _$WikiPageImpl _value, $Res Function(_$WikiPageImpl) _then)
      : super(_value, _then);

  /// Create a copy of WikiPage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? avatarId = null,
    Object? title = null,
    Object? content = null,
    Object? certainty = null,
    Object? hasConflict = null,
    Object? sourceFileIds = null,
    Object? slug = freezed,
    Object? updatedAt = freezed,
    Object? compiledAt = freezed,
    Object? qualityScore = null,
    Object? humanVerified = null,
    Object? humanCorrection = freezed,
    Object? sourceFileNames = null,
    Object? reviewState = null,
    Object? verifiedBy = freezed,
    Object? flagNote = freezed,
  }) {
    return _then(_$WikiPageImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      avatarId: null == avatarId
          ? _value.avatarId
          : avatarId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      certainty: null == certainty
          ? _value.certainty
          : certainty // ignore: cast_nullable_to_non_nullable
              as String,
      hasConflict: null == hasConflict
          ? _value.hasConflict
          : hasConflict // ignore: cast_nullable_to_non_nullable
              as bool,
      sourceFileIds: null == sourceFileIds
          ? _value._sourceFileIds
          : sourceFileIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      slug: freezed == slug
          ? _value.slug
          : slug // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      compiledAt: freezed == compiledAt
          ? _value.compiledAt
          : compiledAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      qualityScore: null == qualityScore
          ? _value.qualityScore
          : qualityScore // ignore: cast_nullable_to_non_nullable
              as int,
      humanVerified: null == humanVerified
          ? _value.humanVerified
          : humanVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      humanCorrection: freezed == humanCorrection
          ? _value.humanCorrection
          : humanCorrection // ignore: cast_nullable_to_non_nullable
              as String?,
      sourceFileNames: null == sourceFileNames
          ? _value._sourceFileNames
          : sourceFileNames // ignore: cast_nullable_to_non_nullable
              as List<String>,
      reviewState: null == reviewState
          ? _value.reviewState
          : reviewState // ignore: cast_nullable_to_non_nullable
              as WikiReviewState,
      verifiedBy: freezed == verifiedBy
          ? _value.verifiedBy
          : verifiedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      flagNote: freezed == flagNote
          ? _value.flagNote
          : flagNote // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WikiPageImpl implements _WikiPage {
  const _$WikiPageImpl(
      {this.id = '',
      this.avatarId = '',
      this.title = '',
      this.content = '',
      this.certainty = 'inferred',
      this.hasConflict = false,
      final List<String> sourceFileIds = const [],
      this.slug,
      this.updatedAt,
      this.compiledAt,
      this.qualityScore = 0,
      this.humanVerified = false,
      this.humanCorrection,
      final List<String> sourceFileNames = const [],
      @JsonKey(fromJson: _reviewStateFromJson)
      this.reviewState = WikiReviewState.unverified,
      this.verifiedBy,
      this.flagNote})
      : _sourceFileIds = sourceFileIds,
        _sourceFileNames = sourceFileNames;

  factory _$WikiPageImpl.fromJson(Map<String, dynamic> json) =>
      _$$WikiPageImplFromJson(json);

  @override
  @JsonKey()
  final String id;
  @override
  @JsonKey()
  final String avatarId;
  @override
  @JsonKey()
  final String title;
  @override
  @JsonKey()
  final String content;
  @override
  @JsonKey()
  final String certainty;
  @override
  @JsonKey()
  final bool hasConflict;
  final List<String> _sourceFileIds;
  @override
  @JsonKey()
  List<String> get sourceFileIds {
    if (_sourceFileIds is EqualUnmodifiableListView) return _sourceFileIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sourceFileIds);
  }

  @override
  final String? slug;
  @override
  final DateTime? updatedAt;
  @override
  final DateTime? compiledAt;
  @override
  @JsonKey()
  final int qualityScore;
  @override
  @JsonKey()
  final bool humanVerified;
  @override
  final String? humanCorrection;
// Fix 3: provenance — names of knowledge files that contributed to this page
  final List<String> _sourceFileNames;
// Fix 3: provenance — names of knowledge files that contributed to this page
  @override
  @JsonKey()
  List<String> get sourceFileNames {
    if (_sourceFileNames is EqualUnmodifiableListView) return _sourceFileNames;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sourceFileNames);
  }

// Review lifecycle — see [WikiReviewState]. Null-tolerant: a missing or
// unknown value parses to UNVERIFIED rather than throwing.
  @override
  @JsonKey(fromJson: _reviewStateFromJson)
  final WikiReviewState reviewState;
// Display name of whoever verified/flagged the page (e.g. "Mum", a tutor).
// Null when never reviewed.
  @override
  final String? verifiedBy;
// Present (and non-empty) only when [reviewState] == flagged — the
// reviewer's note on what looked wrong.
  @override
  final String? flagNote;

  @override
  String toString() {
    return 'WikiPage(id: $id, avatarId: $avatarId, title: $title, content: $content, certainty: $certainty, hasConflict: $hasConflict, sourceFileIds: $sourceFileIds, slug: $slug, updatedAt: $updatedAt, compiledAt: $compiledAt, qualityScore: $qualityScore, humanVerified: $humanVerified, humanCorrection: $humanCorrection, sourceFileNames: $sourceFileNames, reviewState: $reviewState, verifiedBy: $verifiedBy, flagNote: $flagNote)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WikiPageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.avatarId, avatarId) ||
                other.avatarId == avatarId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.certainty, certainty) ||
                other.certainty == certainty) &&
            (identical(other.hasConflict, hasConflict) ||
                other.hasConflict == hasConflict) &&
            const DeepCollectionEquality()
                .equals(other._sourceFileIds, _sourceFileIds) &&
            (identical(other.slug, slug) || other.slug == slug) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.compiledAt, compiledAt) ||
                other.compiledAt == compiledAt) &&
            (identical(other.qualityScore, qualityScore) ||
                other.qualityScore == qualityScore) &&
            (identical(other.humanVerified, humanVerified) ||
                other.humanVerified == humanVerified) &&
            (identical(other.humanCorrection, humanCorrection) ||
                other.humanCorrection == humanCorrection) &&
            const DeepCollectionEquality()
                .equals(other._sourceFileNames, _sourceFileNames) &&
            (identical(other.reviewState, reviewState) ||
                other.reviewState == reviewState) &&
            (identical(other.verifiedBy, verifiedBy) ||
                other.verifiedBy == verifiedBy) &&
            (identical(other.flagNote, flagNote) ||
                other.flagNote == flagNote));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      avatarId,
      title,
      content,
      certainty,
      hasConflict,
      const DeepCollectionEquality().hash(_sourceFileIds),
      slug,
      updatedAt,
      compiledAt,
      qualityScore,
      humanVerified,
      humanCorrection,
      const DeepCollectionEquality().hash(_sourceFileNames),
      reviewState,
      verifiedBy,
      flagNote);

  /// Create a copy of WikiPage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WikiPageImplCopyWith<_$WikiPageImpl> get copyWith =>
      __$$WikiPageImplCopyWithImpl<_$WikiPageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WikiPageImplToJson(
      this,
    );
  }
}

abstract class _WikiPage implements WikiPage {
  const factory _WikiPage(
      {final String id,
      final String avatarId,
      final String title,
      final String content,
      final String certainty,
      final bool hasConflict,
      final List<String> sourceFileIds,
      final String? slug,
      final DateTime? updatedAt,
      final DateTime? compiledAt,
      final int qualityScore,
      final bool humanVerified,
      final String? humanCorrection,
      final List<String> sourceFileNames,
      @JsonKey(fromJson: _reviewStateFromJson)
      final WikiReviewState reviewState,
      final String? verifiedBy,
      final String? flagNote}) = _$WikiPageImpl;

  factory _WikiPage.fromJson(Map<String, dynamic> json) =
      _$WikiPageImpl.fromJson;

  @override
  String get id;
  @override
  String get avatarId;
  @override
  String get title;
  @override
  String get content;
  @override
  String get certainty;
  @override
  bool get hasConflict;
  @override
  List<String> get sourceFileIds;
  @override
  String? get slug;
  @override
  DateTime? get updatedAt;
  @override
  DateTime? get compiledAt;
  @override
  int get qualityScore;
  @override
  bool get humanVerified;
  @override
  String?
      get humanCorrection; // Fix 3: provenance — names of knowledge files that contributed to this page
  @override
  List<String>
      get sourceFileNames; // Review lifecycle — see [WikiReviewState]. Null-tolerant: a missing or
// unknown value parses to UNVERIFIED rather than throwing.
  @override
  @JsonKey(fromJson: _reviewStateFromJson)
  WikiReviewState
      get reviewState; // Display name of whoever verified/flagged the page (e.g. "Mum", a tutor).
// Null when never reviewed.
  @override
  String?
      get verifiedBy; // Present (and non-empty) only when [reviewState] == flagged — the
// reviewer's note on what looked wrong.
  @override
  String? get flagNote;

  /// Create a copy of WikiPage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WikiPageImplCopyWith<_$WikiPageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
