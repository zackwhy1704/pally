// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'flash_card.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

FlashCard _$FlashCardFromJson(Map<String, dynamic> json) {
  return _FlashCard.fromJson(json);
}

/// @nodoc
mixin _$FlashCard {
  String get id => throw _privateConstructorUsedError;
  String get front => throw _privateConstructorUsedError;
  String get back => throw _privateConstructorUsedError;
  String get sourceFile => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _cardRatingFromJson, toJson: _cardRatingToJson)
  CardRating? get lastRating => throw _privateConstructorUsedError;
  DateTime? get nextReview => throw _privateConstructorUsedError;

  /// Serializes this FlashCard to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FlashCard
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FlashCardCopyWith<FlashCard> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FlashCardCopyWith<$Res> {
  factory $FlashCardCopyWith(FlashCard value, $Res Function(FlashCard) then) =
      _$FlashCardCopyWithImpl<$Res, FlashCard>;
  @useResult
  $Res call(
      {String id,
      String front,
      String back,
      String sourceFile,
      @JsonKey(fromJson: _cardRatingFromJson, toJson: _cardRatingToJson)
      CardRating? lastRating,
      DateTime? nextReview});
}

/// @nodoc
class _$FlashCardCopyWithImpl<$Res, $Val extends FlashCard>
    implements $FlashCardCopyWith<$Res> {
  _$FlashCardCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FlashCard
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? front = null,
    Object? back = null,
    Object? sourceFile = null,
    Object? lastRating = freezed,
    Object? nextReview = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      front: null == front
          ? _value.front
          : front // ignore: cast_nullable_to_non_nullable
              as String,
      back: null == back
          ? _value.back
          : back // ignore: cast_nullable_to_non_nullable
              as String,
      sourceFile: null == sourceFile
          ? _value.sourceFile
          : sourceFile // ignore: cast_nullable_to_non_nullable
              as String,
      lastRating: freezed == lastRating
          ? _value.lastRating
          : lastRating // ignore: cast_nullable_to_non_nullable
              as CardRating?,
      nextReview: freezed == nextReview
          ? _value.nextReview
          : nextReview // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FlashCardImplCopyWith<$Res>
    implements $FlashCardCopyWith<$Res> {
  factory _$$FlashCardImplCopyWith(
          _$FlashCardImpl value, $Res Function(_$FlashCardImpl) then) =
      __$$FlashCardImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String front,
      String back,
      String sourceFile,
      @JsonKey(fromJson: _cardRatingFromJson, toJson: _cardRatingToJson)
      CardRating? lastRating,
      DateTime? nextReview});
}

/// @nodoc
class __$$FlashCardImplCopyWithImpl<$Res>
    extends _$FlashCardCopyWithImpl<$Res, _$FlashCardImpl>
    implements _$$FlashCardImplCopyWith<$Res> {
  __$$FlashCardImplCopyWithImpl(
      _$FlashCardImpl _value, $Res Function(_$FlashCardImpl) _then)
      : super(_value, _then);

  /// Create a copy of FlashCard
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? front = null,
    Object? back = null,
    Object? sourceFile = null,
    Object? lastRating = freezed,
    Object? nextReview = freezed,
  }) {
    return _then(_$FlashCardImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      front: null == front
          ? _value.front
          : front // ignore: cast_nullable_to_non_nullable
              as String,
      back: null == back
          ? _value.back
          : back // ignore: cast_nullable_to_non_nullable
              as String,
      sourceFile: null == sourceFile
          ? _value.sourceFile
          : sourceFile // ignore: cast_nullable_to_non_nullable
              as String,
      lastRating: freezed == lastRating
          ? _value.lastRating
          : lastRating // ignore: cast_nullable_to_non_nullable
              as CardRating?,
      nextReview: freezed == nextReview
          ? _value.nextReview
          : nextReview // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FlashCardImpl implements _FlashCard {
  const _$FlashCardImpl(
      {this.id = '',
      this.front = '',
      this.back = '',
      this.sourceFile = '',
      @JsonKey(fromJson: _cardRatingFromJson, toJson: _cardRatingToJson)
      this.lastRating,
      this.nextReview});

  factory _$FlashCardImpl.fromJson(Map<String, dynamic> json) =>
      _$$FlashCardImplFromJson(json);

  @override
  @JsonKey()
  final String id;
  @override
  @JsonKey()
  final String front;
  @override
  @JsonKey()
  final String back;
  @override
  @JsonKey()
  final String sourceFile;
  @override
  @JsonKey(fromJson: _cardRatingFromJson, toJson: _cardRatingToJson)
  final CardRating? lastRating;
  @override
  final DateTime? nextReview;

  @override
  String toString() {
    return 'FlashCard(id: $id, front: $front, back: $back, sourceFile: $sourceFile, lastRating: $lastRating, nextReview: $nextReview)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FlashCardImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.front, front) || other.front == front) &&
            (identical(other.back, back) || other.back == back) &&
            (identical(other.sourceFile, sourceFile) ||
                other.sourceFile == sourceFile) &&
            (identical(other.lastRating, lastRating) ||
                other.lastRating == lastRating) &&
            (identical(other.nextReview, nextReview) ||
                other.nextReview == nextReview));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, front, back, sourceFile, lastRating, nextReview);

  /// Create a copy of FlashCard
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FlashCardImplCopyWith<_$FlashCardImpl> get copyWith =>
      __$$FlashCardImplCopyWithImpl<_$FlashCardImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FlashCardImplToJson(
      this,
    );
  }
}

abstract class _FlashCard implements FlashCard {
  const factory _FlashCard(
      {final String id,
      final String front,
      final String back,
      final String sourceFile,
      @JsonKey(fromJson: _cardRatingFromJson, toJson: _cardRatingToJson)
      final CardRating? lastRating,
      final DateTime? nextReview}) = _$FlashCardImpl;

  factory _FlashCard.fromJson(Map<String, dynamic> json) =
      _$FlashCardImpl.fromJson;

  @override
  String get id;
  @override
  String get front;
  @override
  String get back;
  @override
  String get sourceFile;
  @override
  @JsonKey(fromJson: _cardRatingFromJson, toJson: _cardRatingToJson)
  CardRating? get lastRating;
  @override
  DateTime? get nextReview;

  /// Create a copy of FlashCard
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FlashCardImplCopyWith<_$FlashCardImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
