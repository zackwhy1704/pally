// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'learning_module.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LearningModule _$LearningModuleFromJson(Map<String, dynamic> json) {
  return _LearningModule.fromJson(json);
}

/// @nodoc
mixin _$LearningModule {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get wikiSlug => throw _privateConstructorUsedError;
  String get stage => throw _privateConstructorUsedError;

  /// Mastery on a 0–100 scale (the canonical backend contract; written at
  /// ModuleProgressionService avg*100). NEVER multiply this by 100 to display —
  /// use [masteryDisplayPct] for the "%" and [masteryFraction] for a 0–1 bar.
  double get masteryPct => throw _privateConstructorUsedError;
  Map<String, int> get itemCounts => throw _privateConstructorUsedError;

  /// C3 — true when a teacher has reviewed/approved this centre content.
  bool get teacherReviewed => throw _privateConstructorUsedError;

  /// Serializes this LearningModule to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LearningModule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LearningModuleCopyWith<LearningModule> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LearningModuleCopyWith<$Res> {
  factory $LearningModuleCopyWith(
          LearningModule value, $Res Function(LearningModule) then) =
      _$LearningModuleCopyWithImpl<$Res, LearningModule>;
  @useResult
  $Res call(
      {String id,
      String title,
      String wikiSlug,
      String stage,
      double masteryPct,
      Map<String, int> itemCounts,
      bool teacherReviewed});
}

/// @nodoc
class _$LearningModuleCopyWithImpl<$Res, $Val extends LearningModule>
    implements $LearningModuleCopyWith<$Res> {
  _$LearningModuleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LearningModule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? wikiSlug = null,
    Object? stage = null,
    Object? masteryPct = null,
    Object? itemCounts = null,
    Object? teacherReviewed = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      wikiSlug: null == wikiSlug
          ? _value.wikiSlug
          : wikiSlug // ignore: cast_nullable_to_non_nullable
              as String,
      stage: null == stage
          ? _value.stage
          : stage // ignore: cast_nullable_to_non_nullable
              as String,
      masteryPct: null == masteryPct
          ? _value.masteryPct
          : masteryPct // ignore: cast_nullable_to_non_nullable
              as double,
      itemCounts: null == itemCounts
          ? _value.itemCounts
          : itemCounts // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      teacherReviewed: null == teacherReviewed
          ? _value.teacherReviewed
          : teacherReviewed // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LearningModuleImplCopyWith<$Res>
    implements $LearningModuleCopyWith<$Res> {
  factory _$$LearningModuleImplCopyWith(_$LearningModuleImpl value,
          $Res Function(_$LearningModuleImpl) then) =
      __$$LearningModuleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String wikiSlug,
      String stage,
      double masteryPct,
      Map<String, int> itemCounts,
      bool teacherReviewed});
}

/// @nodoc
class __$$LearningModuleImplCopyWithImpl<$Res>
    extends _$LearningModuleCopyWithImpl<$Res, _$LearningModuleImpl>
    implements _$$LearningModuleImplCopyWith<$Res> {
  __$$LearningModuleImplCopyWithImpl(
      _$LearningModuleImpl _value, $Res Function(_$LearningModuleImpl) _then)
      : super(_value, _then);

  /// Create a copy of LearningModule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? wikiSlug = null,
    Object? stage = null,
    Object? masteryPct = null,
    Object? itemCounts = null,
    Object? teacherReviewed = null,
  }) {
    return _then(_$LearningModuleImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      wikiSlug: null == wikiSlug
          ? _value.wikiSlug
          : wikiSlug // ignore: cast_nullable_to_non_nullable
              as String,
      stage: null == stage
          ? _value.stage
          : stage // ignore: cast_nullable_to_non_nullable
              as String,
      masteryPct: null == masteryPct
          ? _value.masteryPct
          : masteryPct // ignore: cast_nullable_to_non_nullable
              as double,
      itemCounts: null == itemCounts
          ? _value._itemCounts
          : itemCounts // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      teacherReviewed: null == teacherReviewed
          ? _value.teacherReviewed
          : teacherReviewed // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LearningModuleImpl implements _LearningModule {
  const _$LearningModuleImpl(
      {required this.id,
      required this.title,
      this.wikiSlug = '',
      this.stage = 'LEARN',
      this.masteryPct = 0,
      final Map<String, int> itemCounts = const {},
      this.teacherReviewed = false})
      : _itemCounts = itemCounts;

  factory _$LearningModuleImpl.fromJson(Map<String, dynamic> json) =>
      _$$LearningModuleImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  @JsonKey()
  final String wikiSlug;
  @override
  @JsonKey()
  final String stage;

  /// Mastery on a 0–100 scale (the canonical backend contract; written at
  /// ModuleProgressionService avg*100). NEVER multiply this by 100 to display —
  /// use [masteryDisplayPct] for the "%" and [masteryFraction] for a 0–1 bar.
  @override
  @JsonKey()
  final double masteryPct;
  final Map<String, int> _itemCounts;
  @override
  @JsonKey()
  Map<String, int> get itemCounts {
    if (_itemCounts is EqualUnmodifiableMapView) return _itemCounts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_itemCounts);
  }

  /// C3 — true when a teacher has reviewed/approved this centre content.
  @override
  @JsonKey()
  final bool teacherReviewed;

  @override
  String toString() {
    return 'LearningModule(id: $id, title: $title, wikiSlug: $wikiSlug, stage: $stage, masteryPct: $masteryPct, itemCounts: $itemCounts, teacherReviewed: $teacherReviewed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LearningModuleImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.wikiSlug, wikiSlug) ||
                other.wikiSlug == wikiSlug) &&
            (identical(other.stage, stage) || other.stage == stage) &&
            (identical(other.masteryPct, masteryPct) ||
                other.masteryPct == masteryPct) &&
            const DeepCollectionEquality()
                .equals(other._itemCounts, _itemCounts) &&
            (identical(other.teacherReviewed, teacherReviewed) ||
                other.teacherReviewed == teacherReviewed));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      wikiSlug,
      stage,
      masteryPct,
      const DeepCollectionEquality().hash(_itemCounts),
      teacherReviewed);

  /// Create a copy of LearningModule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LearningModuleImplCopyWith<_$LearningModuleImpl> get copyWith =>
      __$$LearningModuleImplCopyWithImpl<_$LearningModuleImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LearningModuleImplToJson(
      this,
    );
  }
}

abstract class _LearningModule implements LearningModule {
  const factory _LearningModule(
      {required final String id,
      required final String title,
      final String wikiSlug,
      final String stage,
      final double masteryPct,
      final Map<String, int> itemCounts,
      final bool teacherReviewed}) = _$LearningModuleImpl;

  factory _LearningModule.fromJson(Map<String, dynamic> json) =
      _$LearningModuleImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get wikiSlug;
  @override
  String get stage;

  /// Mastery on a 0–100 scale (the canonical backend contract; written at
  /// ModuleProgressionService avg*100). NEVER multiply this by 100 to display —
  /// use [masteryDisplayPct] for the "%" and [masteryFraction] for a 0–1 bar.
  @override
  double get masteryPct;
  @override
  Map<String, int> get itemCounts;

  /// C3 — true when a teacher has reviewed/approved this centre content.
  @override
  bool get teacherReviewed;

  /// Create a copy of LearningModule
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LearningModuleImplCopyWith<_$LearningModuleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ModuleContentItem _$ModuleContentItemFromJson(Map<String, dynamic> json) {
  return _ModuleContentItem.fromJson(json);
}

/// @nodoc
mixin _$ModuleContentItem {
  String get id =>
      throw _privateConstructorUsedError; // The per-item stage is informational on mobile (rendering keys off the
// response-level stage), so default it for resilience if a server omits it.
  String get stage => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _contentJsonFromJson)
  Map<String, dynamic> get contentJson => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _answerJsonFromJson)
  Map<String, dynamic>? get answerJson => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _revealJsonFromJson)
  Map<String, dynamic>? get revealJson => throw _privateConstructorUsedError;
  int get sortOrder =>
      throw _privateConstructorUsedError; // Adaptive-provenance serve metadata (all nullable — absent on old content, so the
// chips/badges degrade silently): the source page this item came from, the concept it
// targets, and (PROVE only) the student's prior TEST score on that concept.
  String? get sourcePageTitle => throw _privateConstructorUsedError;
  String? get sourcePageSlug => throw _privateConstructorUsedError;
  String? get targetConcept => throw _privateConstructorUsedError;
  double? get priorScore => throw _privateConstructorUsedError;

  /// Serializes this ModuleContentItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ModuleContentItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ModuleContentItemCopyWith<ModuleContentItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ModuleContentItemCopyWith<$Res> {
  factory $ModuleContentItemCopyWith(
          ModuleContentItem value, $Res Function(ModuleContentItem) then) =
      _$ModuleContentItemCopyWithImpl<$Res, ModuleContentItem>;
  @useResult
  $Res call(
      {String id,
      String stage,
      String type,
      @JsonKey(fromJson: _contentJsonFromJson) Map<String, dynamic> contentJson,
      @JsonKey(fromJson: _answerJsonFromJson) Map<String, dynamic>? answerJson,
      @JsonKey(fromJson: _revealJsonFromJson) Map<String, dynamic>? revealJson,
      int sortOrder,
      String? sourcePageTitle,
      String? sourcePageSlug,
      String? targetConcept,
      double? priorScore});
}

/// @nodoc
class _$ModuleContentItemCopyWithImpl<$Res, $Val extends ModuleContentItem>
    implements $ModuleContentItemCopyWith<$Res> {
  _$ModuleContentItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ModuleContentItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? stage = null,
    Object? type = null,
    Object? contentJson = null,
    Object? answerJson = freezed,
    Object? revealJson = freezed,
    Object? sortOrder = null,
    Object? sourcePageTitle = freezed,
    Object? sourcePageSlug = freezed,
    Object? targetConcept = freezed,
    Object? priorScore = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      stage: null == stage
          ? _value.stage
          : stage // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      contentJson: null == contentJson
          ? _value.contentJson
          : contentJson // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      answerJson: freezed == answerJson
          ? _value.answerJson
          : answerJson // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      revealJson: freezed == revealJson
          ? _value.revealJson
          : revealJson // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
      sourcePageTitle: freezed == sourcePageTitle
          ? _value.sourcePageTitle
          : sourcePageTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      sourcePageSlug: freezed == sourcePageSlug
          ? _value.sourcePageSlug
          : sourcePageSlug // ignore: cast_nullable_to_non_nullable
              as String?,
      targetConcept: freezed == targetConcept
          ? _value.targetConcept
          : targetConcept // ignore: cast_nullable_to_non_nullable
              as String?,
      priorScore: freezed == priorScore
          ? _value.priorScore
          : priorScore // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ModuleContentItemImplCopyWith<$Res>
    implements $ModuleContentItemCopyWith<$Res> {
  factory _$$ModuleContentItemImplCopyWith(_$ModuleContentItemImpl value,
          $Res Function(_$ModuleContentItemImpl) then) =
      __$$ModuleContentItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String stage,
      String type,
      @JsonKey(fromJson: _contentJsonFromJson) Map<String, dynamic> contentJson,
      @JsonKey(fromJson: _answerJsonFromJson) Map<String, dynamic>? answerJson,
      @JsonKey(fromJson: _revealJsonFromJson) Map<String, dynamic>? revealJson,
      int sortOrder,
      String? sourcePageTitle,
      String? sourcePageSlug,
      String? targetConcept,
      double? priorScore});
}

/// @nodoc
class __$$ModuleContentItemImplCopyWithImpl<$Res>
    extends _$ModuleContentItemCopyWithImpl<$Res, _$ModuleContentItemImpl>
    implements _$$ModuleContentItemImplCopyWith<$Res> {
  __$$ModuleContentItemImplCopyWithImpl(_$ModuleContentItemImpl _value,
      $Res Function(_$ModuleContentItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of ModuleContentItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? stage = null,
    Object? type = null,
    Object? contentJson = null,
    Object? answerJson = freezed,
    Object? revealJson = freezed,
    Object? sortOrder = null,
    Object? sourcePageTitle = freezed,
    Object? sourcePageSlug = freezed,
    Object? targetConcept = freezed,
    Object? priorScore = freezed,
  }) {
    return _then(_$ModuleContentItemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      stage: null == stage
          ? _value.stage
          : stage // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      contentJson: null == contentJson
          ? _value._contentJson
          : contentJson // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      answerJson: freezed == answerJson
          ? _value._answerJson
          : answerJson // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      revealJson: freezed == revealJson
          ? _value._revealJson
          : revealJson // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
      sourcePageTitle: freezed == sourcePageTitle
          ? _value.sourcePageTitle
          : sourcePageTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      sourcePageSlug: freezed == sourcePageSlug
          ? _value.sourcePageSlug
          : sourcePageSlug // ignore: cast_nullable_to_non_nullable
              as String?,
      targetConcept: freezed == targetConcept
          ? _value.targetConcept
          : targetConcept // ignore: cast_nullable_to_non_nullable
              as String?,
      priorScore: freezed == priorScore
          ? _value.priorScore
          : priorScore // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ModuleContentItemImpl implements _ModuleContentItem {
  const _$ModuleContentItemImpl(
      {required this.id,
      this.stage = 'LEARN',
      required this.type,
      @JsonKey(fromJson: _contentJsonFromJson)
      required final Map<String, dynamic> contentJson,
      @JsonKey(fromJson: _answerJsonFromJson)
      final Map<String, dynamic>? answerJson,
      @JsonKey(fromJson: _revealJsonFromJson)
      final Map<String, dynamic>? revealJson,
      this.sortOrder = 0,
      this.sourcePageTitle,
      this.sourcePageSlug,
      this.targetConcept,
      this.priorScore})
      : _contentJson = contentJson,
        _answerJson = answerJson,
        _revealJson = revealJson;

  factory _$ModuleContentItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$ModuleContentItemImplFromJson(json);

  @override
  final String id;
// The per-item stage is informational on mobile (rendering keys off the
// response-level stage), so default it for resilience if a server omits it.
  @override
  @JsonKey()
  final String stage;
  @override
  final String type;
  final Map<String, dynamic> _contentJson;
  @override
  @JsonKey(fromJson: _contentJsonFromJson)
  Map<String, dynamic> get contentJson {
    if (_contentJson is EqualUnmodifiableMapView) return _contentJson;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_contentJson);
  }

  final Map<String, dynamic>? _answerJson;
  @override
  @JsonKey(fromJson: _answerJsonFromJson)
  Map<String, dynamic>? get answerJson {
    final value = _answerJson;
    if (value == null) return null;
    if (_answerJson is EqualUnmodifiableMapView) return _answerJson;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic>? _revealJson;
  @override
  @JsonKey(fromJson: _revealJsonFromJson)
  Map<String, dynamic>? get revealJson {
    final value = _revealJson;
    if (value == null) return null;
    if (_revealJson is EqualUnmodifiableMapView) return _revealJson;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey()
  final int sortOrder;
// Adaptive-provenance serve metadata (all nullable — absent on old content, so the
// chips/badges degrade silently): the source page this item came from, the concept it
// targets, and (PROVE only) the student's prior TEST score on that concept.
  @override
  final String? sourcePageTitle;
  @override
  final String? sourcePageSlug;
  @override
  final String? targetConcept;
  @override
  final double? priorScore;

  @override
  String toString() {
    return 'ModuleContentItem(id: $id, stage: $stage, type: $type, contentJson: $contentJson, answerJson: $answerJson, revealJson: $revealJson, sortOrder: $sortOrder, sourcePageTitle: $sourcePageTitle, sourcePageSlug: $sourcePageSlug, targetConcept: $targetConcept, priorScore: $priorScore)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ModuleContentItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.stage, stage) || other.stage == stage) &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality()
                .equals(other._contentJson, _contentJson) &&
            const DeepCollectionEquality()
                .equals(other._answerJson, _answerJson) &&
            const DeepCollectionEquality()
                .equals(other._revealJson, _revealJson) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.sourcePageTitle, sourcePageTitle) ||
                other.sourcePageTitle == sourcePageTitle) &&
            (identical(other.sourcePageSlug, sourcePageSlug) ||
                other.sourcePageSlug == sourcePageSlug) &&
            (identical(other.targetConcept, targetConcept) ||
                other.targetConcept == targetConcept) &&
            (identical(other.priorScore, priorScore) ||
                other.priorScore == priorScore));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      stage,
      type,
      const DeepCollectionEquality().hash(_contentJson),
      const DeepCollectionEquality().hash(_answerJson),
      const DeepCollectionEquality().hash(_revealJson),
      sortOrder,
      sourcePageTitle,
      sourcePageSlug,
      targetConcept,
      priorScore);

  /// Create a copy of ModuleContentItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ModuleContentItemImplCopyWith<_$ModuleContentItemImpl> get copyWith =>
      __$$ModuleContentItemImplCopyWithImpl<_$ModuleContentItemImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ModuleContentItemImplToJson(
      this,
    );
  }
}

abstract class _ModuleContentItem implements ModuleContentItem {
  const factory _ModuleContentItem(
      {required final String id,
      final String stage,
      required final String type,
      @JsonKey(fromJson: _contentJsonFromJson)
      required final Map<String, dynamic> contentJson,
      @JsonKey(fromJson: _answerJsonFromJson)
      final Map<String, dynamic>? answerJson,
      @JsonKey(fromJson: _revealJsonFromJson)
      final Map<String, dynamic>? revealJson,
      final int sortOrder,
      final String? sourcePageTitle,
      final String? sourcePageSlug,
      final String? targetConcept,
      final double? priorScore}) = _$ModuleContentItemImpl;

  factory _ModuleContentItem.fromJson(Map<String, dynamic> json) =
      _$ModuleContentItemImpl.fromJson;

  @override
  String
      get id; // The per-item stage is informational on mobile (rendering keys off the
// response-level stage), so default it for resilience if a server omits it.
  @override
  String get stage;
  @override
  String get type;
  @override
  @JsonKey(fromJson: _contentJsonFromJson)
  Map<String, dynamic> get contentJson;
  @override
  @JsonKey(fromJson: _answerJsonFromJson)
  Map<String, dynamic>? get answerJson;
  @override
  @JsonKey(fromJson: _revealJsonFromJson)
  Map<String, dynamic>? get revealJson;
  @override
  int get sortOrder; // Adaptive-provenance serve metadata (all nullable — absent on old content, so the
// chips/badges degrade silently): the source page this item came from, the concept it
// targets, and (PROVE only) the student's prior TEST score on that concept.
  @override
  String? get sourcePageTitle;
  @override
  String? get sourcePageSlug;
  @override
  String? get targetConcept;
  @override
  double? get priorScore;

  /// Create a copy of ModuleContentItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ModuleContentItemImplCopyWith<_$ModuleContentItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ModuleResults _$ModuleResultsFromJson(Map<String, dynamic> json) {
  return _ModuleResults.fromJson(json);
}

/// @nodoc
mixin _$ModuleResults {
  List<ConceptMastery> get concepts => throw _privateConstructorUsedError;
  int get xpEarned => throw _privateConstructorUsedError;

  /// Serializes this ModuleResults to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ModuleResults
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ModuleResultsCopyWith<ModuleResults> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ModuleResultsCopyWith<$Res> {
  factory $ModuleResultsCopyWith(
          ModuleResults value, $Res Function(ModuleResults) then) =
      _$ModuleResultsCopyWithImpl<$Res, ModuleResults>;
  @useResult
  $Res call({List<ConceptMastery> concepts, int xpEarned});
}

/// @nodoc
class _$ModuleResultsCopyWithImpl<$Res, $Val extends ModuleResults>
    implements $ModuleResultsCopyWith<$Res> {
  _$ModuleResultsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ModuleResults
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? concepts = null,
    Object? xpEarned = null,
  }) {
    return _then(_value.copyWith(
      concepts: null == concepts
          ? _value.concepts
          : concepts // ignore: cast_nullable_to_non_nullable
              as List<ConceptMastery>,
      xpEarned: null == xpEarned
          ? _value.xpEarned
          : xpEarned // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ModuleResultsImplCopyWith<$Res>
    implements $ModuleResultsCopyWith<$Res> {
  factory _$$ModuleResultsImplCopyWith(
          _$ModuleResultsImpl value, $Res Function(_$ModuleResultsImpl) then) =
      __$$ModuleResultsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<ConceptMastery> concepts, int xpEarned});
}

/// @nodoc
class __$$ModuleResultsImplCopyWithImpl<$Res>
    extends _$ModuleResultsCopyWithImpl<$Res, _$ModuleResultsImpl>
    implements _$$ModuleResultsImplCopyWith<$Res> {
  __$$ModuleResultsImplCopyWithImpl(
      _$ModuleResultsImpl _value, $Res Function(_$ModuleResultsImpl) _then)
      : super(_value, _then);

  /// Create a copy of ModuleResults
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? concepts = null,
    Object? xpEarned = null,
  }) {
    return _then(_$ModuleResultsImpl(
      concepts: null == concepts
          ? _value._concepts
          : concepts // ignore: cast_nullable_to_non_nullable
              as List<ConceptMastery>,
      xpEarned: null == xpEarned
          ? _value.xpEarned
          : xpEarned // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ModuleResultsImpl implements _ModuleResults {
  const _$ModuleResultsImpl(
      {final List<ConceptMastery> concepts = const [], this.xpEarned = 0})
      : _concepts = concepts;

  factory _$ModuleResultsImpl.fromJson(Map<String, dynamic> json) =>
      _$$ModuleResultsImplFromJson(json);

  final List<ConceptMastery> _concepts;
  @override
  @JsonKey()
  List<ConceptMastery> get concepts {
    if (_concepts is EqualUnmodifiableListView) return _concepts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_concepts);
  }

  @override
  @JsonKey()
  final int xpEarned;

  @override
  String toString() {
    return 'ModuleResults(concepts: $concepts, xpEarned: $xpEarned)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ModuleResultsImpl &&
            const DeepCollectionEquality().equals(other._concepts, _concepts) &&
            (identical(other.xpEarned, xpEarned) ||
                other.xpEarned == xpEarned));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_concepts), xpEarned);

  /// Create a copy of ModuleResults
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ModuleResultsImplCopyWith<_$ModuleResultsImpl> get copyWith =>
      __$$ModuleResultsImplCopyWithImpl<_$ModuleResultsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ModuleResultsImplToJson(
      this,
    );
  }
}

abstract class _ModuleResults implements ModuleResults {
  const factory _ModuleResults(
      {final List<ConceptMastery> concepts,
      final int xpEarned}) = _$ModuleResultsImpl;

  factory _ModuleResults.fromJson(Map<String, dynamic> json) =
      _$ModuleResultsImpl.fromJson;

  @override
  List<ConceptMastery> get concepts;
  @override
  int get xpEarned;

  /// Create a copy of ModuleResults
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ModuleResultsImplCopyWith<_$ModuleResultsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ConceptMastery _$ConceptMasteryFromJson(Map<String, dynamic> json) {
  return _ConceptMastery.fromJson(json);
}

/// @nodoc
mixin _$ConceptMastery {
  String get concept => throw _privateConstructorUsedError;
  double get mastery => throw _privateConstructorUsedError;
  String get feedback => throw _privateConstructorUsedError;
  bool get passed => throw _privateConstructorUsedError;

  /// Serializes this ConceptMastery to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ConceptMastery
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConceptMasteryCopyWith<ConceptMastery> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConceptMasteryCopyWith<$Res> {
  factory $ConceptMasteryCopyWith(
          ConceptMastery value, $Res Function(ConceptMastery) then) =
      _$ConceptMasteryCopyWithImpl<$Res, ConceptMastery>;
  @useResult
  $Res call({String concept, double mastery, String feedback, bool passed});
}

/// @nodoc
class _$ConceptMasteryCopyWithImpl<$Res, $Val extends ConceptMastery>
    implements $ConceptMasteryCopyWith<$Res> {
  _$ConceptMasteryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConceptMastery
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? concept = null,
    Object? mastery = null,
    Object? feedback = null,
    Object? passed = null,
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
      feedback: null == feedback
          ? _value.feedback
          : feedback // ignore: cast_nullable_to_non_nullable
              as String,
      passed: null == passed
          ? _value.passed
          : passed // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ConceptMasteryImplCopyWith<$Res>
    implements $ConceptMasteryCopyWith<$Res> {
  factory _$$ConceptMasteryImplCopyWith(_$ConceptMasteryImpl value,
          $Res Function(_$ConceptMasteryImpl) then) =
      __$$ConceptMasteryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String concept, double mastery, String feedback, bool passed});
}

/// @nodoc
class __$$ConceptMasteryImplCopyWithImpl<$Res>
    extends _$ConceptMasteryCopyWithImpl<$Res, _$ConceptMasteryImpl>
    implements _$$ConceptMasteryImplCopyWith<$Res> {
  __$$ConceptMasteryImplCopyWithImpl(
      _$ConceptMasteryImpl _value, $Res Function(_$ConceptMasteryImpl) _then)
      : super(_value, _then);

  /// Create a copy of ConceptMastery
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? concept = null,
    Object? mastery = null,
    Object? feedback = null,
    Object? passed = null,
  }) {
    return _then(_$ConceptMasteryImpl(
      concept: null == concept
          ? _value.concept
          : concept // ignore: cast_nullable_to_non_nullable
              as String,
      mastery: null == mastery
          ? _value.mastery
          : mastery // ignore: cast_nullable_to_non_nullable
              as double,
      feedback: null == feedback
          ? _value.feedback
          : feedback // ignore: cast_nullable_to_non_nullable
              as String,
      passed: null == passed
          ? _value.passed
          : passed // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ConceptMasteryImpl implements _ConceptMastery {
  const _$ConceptMasteryImpl(
      {this.concept = '',
      this.mastery = 0,
      this.feedback = '',
      this.passed = false});

  factory _$ConceptMasteryImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConceptMasteryImplFromJson(json);

  @override
  @JsonKey()
  final String concept;
  @override
  @JsonKey()
  final double mastery;
  @override
  @JsonKey()
  final String feedback;
  @override
  @JsonKey()
  final bool passed;

  @override
  String toString() {
    return 'ConceptMastery(concept: $concept, mastery: $mastery, feedback: $feedback, passed: $passed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConceptMasteryImpl &&
            (identical(other.concept, concept) || other.concept == concept) &&
            (identical(other.mastery, mastery) || other.mastery == mastery) &&
            (identical(other.feedback, feedback) ||
                other.feedback == feedback) &&
            (identical(other.passed, passed) || other.passed == passed));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, concept, mastery, feedback, passed);

  /// Create a copy of ConceptMastery
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConceptMasteryImplCopyWith<_$ConceptMasteryImpl> get copyWith =>
      __$$ConceptMasteryImplCopyWithImpl<_$ConceptMasteryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ConceptMasteryImplToJson(
      this,
    );
  }
}

abstract class _ConceptMastery implements ConceptMastery {
  const factory _ConceptMastery(
      {final String concept,
      final double mastery,
      final String feedback,
      final bool passed}) = _$ConceptMasteryImpl;

  factory _ConceptMastery.fromJson(Map<String, dynamic> json) =
      _$ConceptMasteryImpl.fromJson;

  @override
  String get concept;
  @override
  double get mastery;
  @override
  String get feedback;
  @override
  bool get passed;

  /// Create a copy of ConceptMastery
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConceptMasteryImplCopyWith<_$ConceptMasteryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
