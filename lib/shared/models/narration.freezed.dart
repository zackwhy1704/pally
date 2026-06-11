// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'narration.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Narration _$NarrationFromJson(Map<String, dynamic> json) {
  return _Narration.fromJson(json);
}

/// @nodoc
mixin _$Narration {
  String get id => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  List<NarrationSegment> get segments => throw _privateConstructorUsedError;

  /// Serializes this Narration to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Narration
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NarrationCopyWith<Narration> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NarrationCopyWith<$Res> {
  factory $NarrationCopyWith(Narration value, $Res Function(Narration) then) =
      _$NarrationCopyWithImpl<$Res, Narration>;
  @useResult
  $Res call({String id, String status, List<NarrationSegment> segments});
}

/// @nodoc
class _$NarrationCopyWithImpl<$Res, $Val extends Narration>
    implements $NarrationCopyWith<$Res> {
  _$NarrationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Narration
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? status = null,
    Object? segments = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      segments: null == segments
          ? _value.segments
          : segments // ignore: cast_nullable_to_non_nullable
              as List<NarrationSegment>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NarrationImplCopyWith<$Res>
    implements $NarrationCopyWith<$Res> {
  factory _$$NarrationImplCopyWith(
          _$NarrationImpl value, $Res Function(_$NarrationImpl) then) =
      __$$NarrationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String status, List<NarrationSegment> segments});
}

/// @nodoc
class __$$NarrationImplCopyWithImpl<$Res>
    extends _$NarrationCopyWithImpl<$Res, _$NarrationImpl>
    implements _$$NarrationImplCopyWith<$Res> {
  __$$NarrationImplCopyWithImpl(
      _$NarrationImpl _value, $Res Function(_$NarrationImpl) _then)
      : super(_value, _then);

  /// Create a copy of Narration
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? status = null,
    Object? segments = null,
  }) {
    return _then(_$NarrationImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      segments: null == segments
          ? _value._segments
          : segments // ignore: cast_nullable_to_non_nullable
              as List<NarrationSegment>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NarrationImpl implements _Narration {
  const _$NarrationImpl(
      {this.id = '',
      this.status = 'PENDING',
      final List<NarrationSegment> segments = const []})
      : _segments = segments;

  factory _$NarrationImpl.fromJson(Map<String, dynamic> json) =>
      _$$NarrationImplFromJson(json);

  @override
  @JsonKey()
  final String id;
  @override
  @JsonKey()
  final String status;
  final List<NarrationSegment> _segments;
  @override
  @JsonKey()
  List<NarrationSegment> get segments {
    if (_segments is EqualUnmodifiableListView) return _segments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_segments);
  }

  @override
  String toString() {
    return 'Narration(id: $id, status: $status, segments: $segments)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NarrationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other._segments, _segments));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, status, const DeepCollectionEquality().hash(_segments));

  /// Create a copy of Narration
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NarrationImplCopyWith<_$NarrationImpl> get copyWith =>
      __$$NarrationImplCopyWithImpl<_$NarrationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NarrationImplToJson(
      this,
    );
  }
}

abstract class _Narration implements Narration {
  const factory _Narration(
      {final String id,
      final String status,
      final List<NarrationSegment> segments}) = _$NarrationImpl;

  factory _Narration.fromJson(Map<String, dynamic> json) =
      _$NarrationImpl.fromJson;

  @override
  String get id;
  @override
  String get status;
  @override
  List<NarrationSegment> get segments;

  /// Create a copy of Narration
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NarrationImplCopyWith<_$NarrationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

NarrationSegment _$NarrationSegmentFromJson(Map<String, dynamic> json) {
  return _NarrationSegment.fromJson(json);
}

/// @nodoc
mixin _$NarrationSegment {
  int get cardIndex => throw _privateConstructorUsedError;
  String get scriptText => throw _privateConstructorUsedError;
  String get audioUrl => throw _privateConstructorUsedError;
  int get durationMs => throw _privateConstructorUsedError;

  /// Serializes this NarrationSegment to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NarrationSegment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NarrationSegmentCopyWith<NarrationSegment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NarrationSegmentCopyWith<$Res> {
  factory $NarrationSegmentCopyWith(
          NarrationSegment value, $Res Function(NarrationSegment) then) =
      _$NarrationSegmentCopyWithImpl<$Res, NarrationSegment>;
  @useResult
  $Res call(
      {int cardIndex, String scriptText, String audioUrl, int durationMs});
}

/// @nodoc
class _$NarrationSegmentCopyWithImpl<$Res, $Val extends NarrationSegment>
    implements $NarrationSegmentCopyWith<$Res> {
  _$NarrationSegmentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NarrationSegment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cardIndex = null,
    Object? scriptText = null,
    Object? audioUrl = null,
    Object? durationMs = null,
  }) {
    return _then(_value.copyWith(
      cardIndex: null == cardIndex
          ? _value.cardIndex
          : cardIndex // ignore: cast_nullable_to_non_nullable
              as int,
      scriptText: null == scriptText
          ? _value.scriptText
          : scriptText // ignore: cast_nullable_to_non_nullable
              as String,
      audioUrl: null == audioUrl
          ? _value.audioUrl
          : audioUrl // ignore: cast_nullable_to_non_nullable
              as String,
      durationMs: null == durationMs
          ? _value.durationMs
          : durationMs // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NarrationSegmentImplCopyWith<$Res>
    implements $NarrationSegmentCopyWith<$Res> {
  factory _$$NarrationSegmentImplCopyWith(_$NarrationSegmentImpl value,
          $Res Function(_$NarrationSegmentImpl) then) =
      __$$NarrationSegmentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int cardIndex, String scriptText, String audioUrl, int durationMs});
}

/// @nodoc
class __$$NarrationSegmentImplCopyWithImpl<$Res>
    extends _$NarrationSegmentCopyWithImpl<$Res, _$NarrationSegmentImpl>
    implements _$$NarrationSegmentImplCopyWith<$Res> {
  __$$NarrationSegmentImplCopyWithImpl(_$NarrationSegmentImpl _value,
      $Res Function(_$NarrationSegmentImpl) _then)
      : super(_value, _then);

  /// Create a copy of NarrationSegment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cardIndex = null,
    Object? scriptText = null,
    Object? audioUrl = null,
    Object? durationMs = null,
  }) {
    return _then(_$NarrationSegmentImpl(
      cardIndex: null == cardIndex
          ? _value.cardIndex
          : cardIndex // ignore: cast_nullable_to_non_nullable
              as int,
      scriptText: null == scriptText
          ? _value.scriptText
          : scriptText // ignore: cast_nullable_to_non_nullable
              as String,
      audioUrl: null == audioUrl
          ? _value.audioUrl
          : audioUrl // ignore: cast_nullable_to_non_nullable
              as String,
      durationMs: null == durationMs
          ? _value.durationMs
          : durationMs // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NarrationSegmentImpl implements _NarrationSegment {
  const _$NarrationSegmentImpl(
      {this.cardIndex = 0,
      this.scriptText = '',
      this.audioUrl = '',
      this.durationMs = 0});

  factory _$NarrationSegmentImpl.fromJson(Map<String, dynamic> json) =>
      _$$NarrationSegmentImplFromJson(json);

  @override
  @JsonKey()
  final int cardIndex;
  @override
  @JsonKey()
  final String scriptText;
  @override
  @JsonKey()
  final String audioUrl;
  @override
  @JsonKey()
  final int durationMs;

  @override
  String toString() {
    return 'NarrationSegment(cardIndex: $cardIndex, scriptText: $scriptText, audioUrl: $audioUrl, durationMs: $durationMs)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NarrationSegmentImpl &&
            (identical(other.cardIndex, cardIndex) ||
                other.cardIndex == cardIndex) &&
            (identical(other.scriptText, scriptText) ||
                other.scriptText == scriptText) &&
            (identical(other.audioUrl, audioUrl) ||
                other.audioUrl == audioUrl) &&
            (identical(other.durationMs, durationMs) ||
                other.durationMs == durationMs));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, cardIndex, scriptText, audioUrl, durationMs);

  /// Create a copy of NarrationSegment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NarrationSegmentImplCopyWith<_$NarrationSegmentImpl> get copyWith =>
      __$$NarrationSegmentImplCopyWithImpl<_$NarrationSegmentImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NarrationSegmentImplToJson(
      this,
    );
  }
}

abstract class _NarrationSegment implements NarrationSegment {
  const factory _NarrationSegment(
      {final int cardIndex,
      final String scriptText,
      final String audioUrl,
      final int durationMs}) = _$NarrationSegmentImpl;

  factory _NarrationSegment.fromJson(Map<String, dynamic> json) =
      _$NarrationSegmentImpl.fromJson;

  @override
  int get cardIndex;
  @override
  String get scriptText;
  @override
  String get audioUrl;
  @override
  int get durationMs;

  /// Create a copy of NarrationSegment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NarrationSegmentImplCopyWith<_$NarrationSegmentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
