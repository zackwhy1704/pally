// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) {
  return _ChatMessage.fromJson(json);
}

/// @nodoc
mixin _$ChatMessage {
  String get id => throw _privateConstructorUsedError;
  String get avatarId => throw _privateConstructorUsedError;
  MessageRole get role => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  List<String> get sources => throw _privateConstructorUsedError;
  bool get isStreaming => throw _privateConstructorUsedError;
  DateTime? get createdAt =>
      throw _privateConstructorUsedError; // Photo question fields
  MessageType get messageType => throw _privateConstructorUsedError;
  String? get imagePath => throw _privateConstructorUsedError;
  List<PhotoQuestion> get photoQuestions => throw _privateConstructorUsedError;
  HomeworkScanResult? get scanResult =>
      throw _privateConstructorUsedError; // Persistence / feedback fields
  FeedbackType? get feedbackType => throw _privateConstructorUsedError;
  bool get savedToBrain => throw _privateConstructorUsedError;

  /// Serializes this ChatMessage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatMessageCopyWith<ChatMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatMessageCopyWith<$Res> {
  factory $ChatMessageCopyWith(
          ChatMessage value, $Res Function(ChatMessage) then) =
      _$ChatMessageCopyWithImpl<$Res, ChatMessage>;
  @useResult
  $Res call(
      {String id,
      String avatarId,
      MessageRole role,
      String content,
      List<String> sources,
      bool isStreaming,
      DateTime? createdAt,
      MessageType messageType,
      String? imagePath,
      List<PhotoQuestion> photoQuestions,
      HomeworkScanResult? scanResult,
      FeedbackType? feedbackType,
      bool savedToBrain});

  $HomeworkScanResultCopyWith<$Res>? get scanResult;
}

/// @nodoc
class _$ChatMessageCopyWithImpl<$Res, $Val extends ChatMessage>
    implements $ChatMessageCopyWith<$Res> {
  _$ChatMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? avatarId = null,
    Object? role = null,
    Object? content = null,
    Object? sources = null,
    Object? isStreaming = null,
    Object? createdAt = freezed,
    Object? messageType = null,
    Object? imagePath = freezed,
    Object? photoQuestions = null,
    Object? scanResult = freezed,
    Object? feedbackType = freezed,
    Object? savedToBrain = null,
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
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as MessageRole,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      sources: null == sources
          ? _value.sources
          : sources // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isStreaming: null == isStreaming
          ? _value.isStreaming
          : isStreaming // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      messageType: null == messageType
          ? _value.messageType
          : messageType // ignore: cast_nullable_to_non_nullable
              as MessageType,
      imagePath: freezed == imagePath
          ? _value.imagePath
          : imagePath // ignore: cast_nullable_to_non_nullable
              as String?,
      photoQuestions: null == photoQuestions
          ? _value.photoQuestions
          : photoQuestions // ignore: cast_nullable_to_non_nullable
              as List<PhotoQuestion>,
      scanResult: freezed == scanResult
          ? _value.scanResult
          : scanResult // ignore: cast_nullable_to_non_nullable
              as HomeworkScanResult?,
      feedbackType: freezed == feedbackType
          ? _value.feedbackType
          : feedbackType // ignore: cast_nullable_to_non_nullable
              as FeedbackType?,
      savedToBrain: null == savedToBrain
          ? _value.savedToBrain
          : savedToBrain // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $HomeworkScanResultCopyWith<$Res>? get scanResult {
    if (_value.scanResult == null) {
      return null;
    }

    return $HomeworkScanResultCopyWith<$Res>(_value.scanResult!, (value) {
      return _then(_value.copyWith(scanResult: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ChatMessageImplCopyWith<$Res>
    implements $ChatMessageCopyWith<$Res> {
  factory _$$ChatMessageImplCopyWith(
          _$ChatMessageImpl value, $Res Function(_$ChatMessageImpl) then) =
      __$$ChatMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String avatarId,
      MessageRole role,
      String content,
      List<String> sources,
      bool isStreaming,
      DateTime? createdAt,
      MessageType messageType,
      String? imagePath,
      List<PhotoQuestion> photoQuestions,
      HomeworkScanResult? scanResult,
      FeedbackType? feedbackType,
      bool savedToBrain});

  @override
  $HomeworkScanResultCopyWith<$Res>? get scanResult;
}

/// @nodoc
class __$$ChatMessageImplCopyWithImpl<$Res>
    extends _$ChatMessageCopyWithImpl<$Res, _$ChatMessageImpl>
    implements _$$ChatMessageImplCopyWith<$Res> {
  __$$ChatMessageImplCopyWithImpl(
      _$ChatMessageImpl _value, $Res Function(_$ChatMessageImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? avatarId = null,
    Object? role = null,
    Object? content = null,
    Object? sources = null,
    Object? isStreaming = null,
    Object? createdAt = freezed,
    Object? messageType = null,
    Object? imagePath = freezed,
    Object? photoQuestions = null,
    Object? scanResult = freezed,
    Object? feedbackType = freezed,
    Object? savedToBrain = null,
  }) {
    return _then(_$ChatMessageImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      avatarId: null == avatarId
          ? _value.avatarId
          : avatarId // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as MessageRole,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      sources: null == sources
          ? _value._sources
          : sources // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isStreaming: null == isStreaming
          ? _value.isStreaming
          : isStreaming // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      messageType: null == messageType
          ? _value.messageType
          : messageType // ignore: cast_nullable_to_non_nullable
              as MessageType,
      imagePath: freezed == imagePath
          ? _value.imagePath
          : imagePath // ignore: cast_nullable_to_non_nullable
              as String?,
      photoQuestions: null == photoQuestions
          ? _value._photoQuestions
          : photoQuestions // ignore: cast_nullable_to_non_nullable
              as List<PhotoQuestion>,
      scanResult: freezed == scanResult
          ? _value.scanResult
          : scanResult // ignore: cast_nullable_to_non_nullable
              as HomeworkScanResult?,
      feedbackType: freezed == feedbackType
          ? _value.feedbackType
          : feedbackType // ignore: cast_nullable_to_non_nullable
              as FeedbackType?,
      savedToBrain: null == savedToBrain
          ? _value.savedToBrain
          : savedToBrain // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatMessageImpl implements _ChatMessage {
  const _$ChatMessageImpl(
      {required this.id,
      required this.avatarId,
      required this.role,
      required this.content,
      final List<String> sources = const [],
      this.isStreaming = false,
      this.createdAt,
      this.messageType = MessageType.text,
      this.imagePath,
      final List<PhotoQuestion> photoQuestions = const [],
      this.scanResult,
      this.feedbackType,
      this.savedToBrain = false})
      : _sources = sources,
        _photoQuestions = photoQuestions;

  factory _$ChatMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatMessageImplFromJson(json);

  @override
  final String id;
  @override
  final String avatarId;
  @override
  final MessageRole role;
  @override
  final String content;
  final List<String> _sources;
  @override
  @JsonKey()
  List<String> get sources {
    if (_sources is EqualUnmodifiableListView) return _sources;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sources);
  }

  @override
  @JsonKey()
  final bool isStreaming;
  @override
  final DateTime? createdAt;
// Photo question fields
  @override
  @JsonKey()
  final MessageType messageType;
  @override
  final String? imagePath;
  final List<PhotoQuestion> _photoQuestions;
  @override
  @JsonKey()
  List<PhotoQuestion> get photoQuestions {
    if (_photoQuestions is EqualUnmodifiableListView) return _photoQuestions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_photoQuestions);
  }

  @override
  final HomeworkScanResult? scanResult;
// Persistence / feedback fields
  @override
  final FeedbackType? feedbackType;
  @override
  @JsonKey()
  final bool savedToBrain;

  @override
  String toString() {
    return 'ChatMessage(id: $id, avatarId: $avatarId, role: $role, content: $content, sources: $sources, isStreaming: $isStreaming, createdAt: $createdAt, messageType: $messageType, imagePath: $imagePath, photoQuestions: $photoQuestions, scanResult: $scanResult, feedbackType: $feedbackType, savedToBrain: $savedToBrain)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatMessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.avatarId, avatarId) ||
                other.avatarId == avatarId) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.content, content) || other.content == content) &&
            const DeepCollectionEquality().equals(other._sources, _sources) &&
            (identical(other.isStreaming, isStreaming) ||
                other.isStreaming == isStreaming) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.messageType, messageType) ||
                other.messageType == messageType) &&
            (identical(other.imagePath, imagePath) ||
                other.imagePath == imagePath) &&
            const DeepCollectionEquality()
                .equals(other._photoQuestions, _photoQuestions) &&
            (identical(other.scanResult, scanResult) ||
                other.scanResult == scanResult) &&
            (identical(other.feedbackType, feedbackType) ||
                other.feedbackType == feedbackType) &&
            (identical(other.savedToBrain, savedToBrain) ||
                other.savedToBrain == savedToBrain));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      avatarId,
      role,
      content,
      const DeepCollectionEquality().hash(_sources),
      isStreaming,
      createdAt,
      messageType,
      imagePath,
      const DeepCollectionEquality().hash(_photoQuestions),
      scanResult,
      feedbackType,
      savedToBrain);

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatMessageImplCopyWith<_$ChatMessageImpl> get copyWith =>
      __$$ChatMessageImplCopyWithImpl<_$ChatMessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatMessageImplToJson(
      this,
    );
  }
}

abstract class _ChatMessage implements ChatMessage {
  const factory _ChatMessage(
      {required final String id,
      required final String avatarId,
      required final MessageRole role,
      required final String content,
      final List<String> sources,
      final bool isStreaming,
      final DateTime? createdAt,
      final MessageType messageType,
      final String? imagePath,
      final List<PhotoQuestion> photoQuestions,
      final HomeworkScanResult? scanResult,
      final FeedbackType? feedbackType,
      final bool savedToBrain}) = _$ChatMessageImpl;

  factory _ChatMessage.fromJson(Map<String, dynamic> json) =
      _$ChatMessageImpl.fromJson;

  @override
  String get id;
  @override
  String get avatarId;
  @override
  MessageRole get role;
  @override
  String get content;
  @override
  List<String> get sources;
  @override
  bool get isStreaming;
  @override
  DateTime? get createdAt; // Photo question fields
  @override
  MessageType get messageType;
  @override
  String? get imagePath;
  @override
  List<PhotoQuestion> get photoQuestions;
  @override
  HomeworkScanResult? get scanResult; // Persistence / feedback fields
  @override
  FeedbackType? get feedbackType;
  @override
  bool get savedToBrain;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatMessageImplCopyWith<_$ChatMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ChatRequest _$ChatRequestFromJson(Map<String, dynamic> json) {
  return _ChatRequest.fromJson(json);
}

/// @nodoc
mixin _$ChatRequest {
  String get message => throw _privateConstructorUsedError;
  List<String> get history => throw _privateConstructorUsedError;

  /// Serializes this ChatRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChatRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatRequestCopyWith<ChatRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatRequestCopyWith<$Res> {
  factory $ChatRequestCopyWith(
          ChatRequest value, $Res Function(ChatRequest) then) =
      _$ChatRequestCopyWithImpl<$Res, ChatRequest>;
  @useResult
  $Res call({String message, List<String> history});
}

/// @nodoc
class _$ChatRequestCopyWithImpl<$Res, $Val extends ChatRequest>
    implements $ChatRequestCopyWith<$Res> {
  _$ChatRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? history = null,
  }) {
    return _then(_value.copyWith(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      history: null == history
          ? _value.history
          : history // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChatRequestImplCopyWith<$Res>
    implements $ChatRequestCopyWith<$Res> {
  factory _$$ChatRequestImplCopyWith(
          _$ChatRequestImpl value, $Res Function(_$ChatRequestImpl) then) =
      __$$ChatRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, List<String> history});
}

/// @nodoc
class __$$ChatRequestImplCopyWithImpl<$Res>
    extends _$ChatRequestCopyWithImpl<$Res, _$ChatRequestImpl>
    implements _$$ChatRequestImplCopyWith<$Res> {
  __$$ChatRequestImplCopyWithImpl(
      _$ChatRequestImpl _value, $Res Function(_$ChatRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChatRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? history = null,
  }) {
    return _then(_$ChatRequestImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      history: null == history
          ? _value._history
          : history // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatRequestImpl implements _ChatRequest {
  const _$ChatRequestImpl(
      {required this.message, final List<String> history = const []})
      : _history = history;

  factory _$ChatRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatRequestImplFromJson(json);

  @override
  final String message;
  final List<String> _history;
  @override
  @JsonKey()
  List<String> get history {
    if (_history is EqualUnmodifiableListView) return _history;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_history);
  }

  @override
  String toString() {
    return 'ChatRequest(message: $message, history: $history)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatRequestImpl &&
            (identical(other.message, message) || other.message == message) &&
            const DeepCollectionEquality().equals(other._history, _history));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, message, const DeepCollectionEquality().hash(_history));

  /// Create a copy of ChatRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatRequestImplCopyWith<_$ChatRequestImpl> get copyWith =>
      __$$ChatRequestImplCopyWithImpl<_$ChatRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatRequestImplToJson(
      this,
    );
  }
}

abstract class _ChatRequest implements ChatRequest {
  const factory _ChatRequest(
      {required final String message,
      final List<String> history}) = _$ChatRequestImpl;

  factory _ChatRequest.fromJson(Map<String, dynamic> json) =
      _$ChatRequestImpl.fromJson;

  @override
  String get message;
  @override
  List<String> get history;

  /// Create a copy of ChatRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatRequestImplCopyWith<_$ChatRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ChatStreamEvent _$ChatStreamEventFromJson(Map<String, dynamic> json) {
  switch (json['runtimeType']) {
    case 'token':
      return ChatStreamEventToken.fromJson(json);
    case 'sources':
      return ChatStreamEventSources.fromJson(json);
    case 'done':
      return ChatStreamEventDone.fromJson(json);
    case 'error':
      return ChatStreamEventError.fromJson(json);

    default:
      throw CheckedFromJsonException(json, 'runtimeType', 'ChatStreamEvent',
          'Invalid union type "${json['runtimeType']}"!');
  }
}

/// @nodoc
mixin _$ChatStreamEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String text) token,
    required TResult Function(List<String> sources) sources,
    required TResult Function() done,
    required TResult Function(String message) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String text)? token,
    TResult? Function(List<String> sources)? sources,
    TResult? Function()? done,
    TResult? Function(String message)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String text)? token,
    TResult Function(List<String> sources)? sources,
    TResult Function()? done,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ChatStreamEventToken value) token,
    required TResult Function(ChatStreamEventSources value) sources,
    required TResult Function(ChatStreamEventDone value) done,
    required TResult Function(ChatStreamEventError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ChatStreamEventToken value)? token,
    TResult? Function(ChatStreamEventSources value)? sources,
    TResult? Function(ChatStreamEventDone value)? done,
    TResult? Function(ChatStreamEventError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ChatStreamEventToken value)? token,
    TResult Function(ChatStreamEventSources value)? sources,
    TResult Function(ChatStreamEventDone value)? done,
    TResult Function(ChatStreamEventError value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  /// Serializes this ChatStreamEvent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatStreamEventCopyWith<$Res> {
  factory $ChatStreamEventCopyWith(
          ChatStreamEvent value, $Res Function(ChatStreamEvent) then) =
      _$ChatStreamEventCopyWithImpl<$Res, ChatStreamEvent>;
}

/// @nodoc
class _$ChatStreamEventCopyWithImpl<$Res, $Val extends ChatStreamEvent>
    implements $ChatStreamEventCopyWith<$Res> {
  _$ChatStreamEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatStreamEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$ChatStreamEventTokenImplCopyWith<$Res> {
  factory _$$ChatStreamEventTokenImplCopyWith(_$ChatStreamEventTokenImpl value,
          $Res Function(_$ChatStreamEventTokenImpl) then) =
      __$$ChatStreamEventTokenImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String text});
}

/// @nodoc
class __$$ChatStreamEventTokenImplCopyWithImpl<$Res>
    extends _$ChatStreamEventCopyWithImpl<$Res, _$ChatStreamEventTokenImpl>
    implements _$$ChatStreamEventTokenImplCopyWith<$Res> {
  __$$ChatStreamEventTokenImplCopyWithImpl(_$ChatStreamEventTokenImpl _value,
      $Res Function(_$ChatStreamEventTokenImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChatStreamEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? text = null,
  }) {
    return _then(_$ChatStreamEventTokenImpl(
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatStreamEventTokenImpl implements ChatStreamEventToken {
  const _$ChatStreamEventTokenImpl({required this.text, final String? $type})
      : $type = $type ?? 'token';

  factory _$ChatStreamEventTokenImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatStreamEventTokenImplFromJson(json);

  @override
  final String text;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'ChatStreamEvent.token(text: $text)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatStreamEventTokenImpl &&
            (identical(other.text, text) || other.text == text));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, text);

  /// Create a copy of ChatStreamEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatStreamEventTokenImplCopyWith<_$ChatStreamEventTokenImpl>
      get copyWith =>
          __$$ChatStreamEventTokenImplCopyWithImpl<_$ChatStreamEventTokenImpl>(
              this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String text) token,
    required TResult Function(List<String> sources) sources,
    required TResult Function() done,
    required TResult Function(String message) error,
  }) {
    return token(text);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String text)? token,
    TResult? Function(List<String> sources)? sources,
    TResult? Function()? done,
    TResult? Function(String message)? error,
  }) {
    return token?.call(text);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String text)? token,
    TResult Function(List<String> sources)? sources,
    TResult Function()? done,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (token != null) {
      return token(text);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ChatStreamEventToken value) token,
    required TResult Function(ChatStreamEventSources value) sources,
    required TResult Function(ChatStreamEventDone value) done,
    required TResult Function(ChatStreamEventError value) error,
  }) {
    return token(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ChatStreamEventToken value)? token,
    TResult? Function(ChatStreamEventSources value)? sources,
    TResult? Function(ChatStreamEventDone value)? done,
    TResult? Function(ChatStreamEventError value)? error,
  }) {
    return token?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ChatStreamEventToken value)? token,
    TResult Function(ChatStreamEventSources value)? sources,
    TResult Function(ChatStreamEventDone value)? done,
    TResult Function(ChatStreamEventError value)? error,
    required TResult orElse(),
  }) {
    if (token != null) {
      return token(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatStreamEventTokenImplToJson(
      this,
    );
  }
}

abstract class ChatStreamEventToken implements ChatStreamEvent {
  const factory ChatStreamEventToken({required final String text}) =
      _$ChatStreamEventTokenImpl;

  factory ChatStreamEventToken.fromJson(Map<String, dynamic> json) =
      _$ChatStreamEventTokenImpl.fromJson;

  String get text;

  /// Create a copy of ChatStreamEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatStreamEventTokenImplCopyWith<_$ChatStreamEventTokenImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ChatStreamEventSourcesImplCopyWith<$Res> {
  factory _$$ChatStreamEventSourcesImplCopyWith(
          _$ChatStreamEventSourcesImpl value,
          $Res Function(_$ChatStreamEventSourcesImpl) then) =
      __$$ChatStreamEventSourcesImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<String> sources});
}

/// @nodoc
class __$$ChatStreamEventSourcesImplCopyWithImpl<$Res>
    extends _$ChatStreamEventCopyWithImpl<$Res, _$ChatStreamEventSourcesImpl>
    implements _$$ChatStreamEventSourcesImplCopyWith<$Res> {
  __$$ChatStreamEventSourcesImplCopyWithImpl(
      _$ChatStreamEventSourcesImpl _value,
      $Res Function(_$ChatStreamEventSourcesImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChatStreamEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sources = null,
  }) {
    return _then(_$ChatStreamEventSourcesImpl(
      sources: null == sources
          ? _value._sources
          : sources // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatStreamEventSourcesImpl implements ChatStreamEventSources {
  const _$ChatStreamEventSourcesImpl(
      {required final List<String> sources, final String? $type})
      : _sources = sources,
        $type = $type ?? 'sources';

  factory _$ChatStreamEventSourcesImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatStreamEventSourcesImplFromJson(json);

  final List<String> _sources;
  @override
  List<String> get sources {
    if (_sources is EqualUnmodifiableListView) return _sources;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sources);
  }

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'ChatStreamEvent.sources(sources: $sources)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatStreamEventSourcesImpl &&
            const DeepCollectionEquality().equals(other._sources, _sources));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_sources));

  /// Create a copy of ChatStreamEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatStreamEventSourcesImplCopyWith<_$ChatStreamEventSourcesImpl>
      get copyWith => __$$ChatStreamEventSourcesImplCopyWithImpl<
          _$ChatStreamEventSourcesImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String text) token,
    required TResult Function(List<String> sources) sources,
    required TResult Function() done,
    required TResult Function(String message) error,
  }) {
    return sources(this.sources);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String text)? token,
    TResult? Function(List<String> sources)? sources,
    TResult? Function()? done,
    TResult? Function(String message)? error,
  }) {
    return sources?.call(this.sources);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String text)? token,
    TResult Function(List<String> sources)? sources,
    TResult Function()? done,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (sources != null) {
      return sources(this.sources);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ChatStreamEventToken value) token,
    required TResult Function(ChatStreamEventSources value) sources,
    required TResult Function(ChatStreamEventDone value) done,
    required TResult Function(ChatStreamEventError value) error,
  }) {
    return sources(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ChatStreamEventToken value)? token,
    TResult? Function(ChatStreamEventSources value)? sources,
    TResult? Function(ChatStreamEventDone value)? done,
    TResult? Function(ChatStreamEventError value)? error,
  }) {
    return sources?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ChatStreamEventToken value)? token,
    TResult Function(ChatStreamEventSources value)? sources,
    TResult Function(ChatStreamEventDone value)? done,
    TResult Function(ChatStreamEventError value)? error,
    required TResult orElse(),
  }) {
    if (sources != null) {
      return sources(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatStreamEventSourcesImplToJson(
      this,
    );
  }
}

abstract class ChatStreamEventSources implements ChatStreamEvent {
  const factory ChatStreamEventSources({required final List<String> sources}) =
      _$ChatStreamEventSourcesImpl;

  factory ChatStreamEventSources.fromJson(Map<String, dynamic> json) =
      _$ChatStreamEventSourcesImpl.fromJson;

  List<String> get sources;

  /// Create a copy of ChatStreamEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatStreamEventSourcesImplCopyWith<_$ChatStreamEventSourcesImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ChatStreamEventDoneImplCopyWith<$Res> {
  factory _$$ChatStreamEventDoneImplCopyWith(_$ChatStreamEventDoneImpl value,
          $Res Function(_$ChatStreamEventDoneImpl) then) =
      __$$ChatStreamEventDoneImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$ChatStreamEventDoneImplCopyWithImpl<$Res>
    extends _$ChatStreamEventCopyWithImpl<$Res, _$ChatStreamEventDoneImpl>
    implements _$$ChatStreamEventDoneImplCopyWith<$Res> {
  __$$ChatStreamEventDoneImplCopyWithImpl(_$ChatStreamEventDoneImpl _value,
      $Res Function(_$ChatStreamEventDoneImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChatStreamEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
@JsonSerializable()
class _$ChatStreamEventDoneImpl implements ChatStreamEventDone {
  const _$ChatStreamEventDoneImpl({final String? $type})
      : $type = $type ?? 'done';

  factory _$ChatStreamEventDoneImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatStreamEventDoneImplFromJson(json);

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'ChatStreamEvent.done()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatStreamEventDoneImpl);
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String text) token,
    required TResult Function(List<String> sources) sources,
    required TResult Function() done,
    required TResult Function(String message) error,
  }) {
    return done();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String text)? token,
    TResult? Function(List<String> sources)? sources,
    TResult? Function()? done,
    TResult? Function(String message)? error,
  }) {
    return done?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String text)? token,
    TResult Function(List<String> sources)? sources,
    TResult Function()? done,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (done != null) {
      return done();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ChatStreamEventToken value) token,
    required TResult Function(ChatStreamEventSources value) sources,
    required TResult Function(ChatStreamEventDone value) done,
    required TResult Function(ChatStreamEventError value) error,
  }) {
    return done(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ChatStreamEventToken value)? token,
    TResult? Function(ChatStreamEventSources value)? sources,
    TResult? Function(ChatStreamEventDone value)? done,
    TResult? Function(ChatStreamEventError value)? error,
  }) {
    return done?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ChatStreamEventToken value)? token,
    TResult Function(ChatStreamEventSources value)? sources,
    TResult Function(ChatStreamEventDone value)? done,
    TResult Function(ChatStreamEventError value)? error,
    required TResult orElse(),
  }) {
    if (done != null) {
      return done(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatStreamEventDoneImplToJson(
      this,
    );
  }
}

abstract class ChatStreamEventDone implements ChatStreamEvent {
  const factory ChatStreamEventDone() = _$ChatStreamEventDoneImpl;

  factory ChatStreamEventDone.fromJson(Map<String, dynamic> json) =
      _$ChatStreamEventDoneImpl.fromJson;
}

/// @nodoc
abstract class _$$ChatStreamEventErrorImplCopyWith<$Res> {
  factory _$$ChatStreamEventErrorImplCopyWith(_$ChatStreamEventErrorImpl value,
          $Res Function(_$ChatStreamEventErrorImpl) then) =
      __$$ChatStreamEventErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$ChatStreamEventErrorImplCopyWithImpl<$Res>
    extends _$ChatStreamEventCopyWithImpl<$Res, _$ChatStreamEventErrorImpl>
    implements _$$ChatStreamEventErrorImplCopyWith<$Res> {
  __$$ChatStreamEventErrorImplCopyWithImpl(_$ChatStreamEventErrorImpl _value,
      $Res Function(_$ChatStreamEventErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChatStreamEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$ChatStreamEventErrorImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatStreamEventErrorImpl implements ChatStreamEventError {
  const _$ChatStreamEventErrorImpl({required this.message, final String? $type})
      : $type = $type ?? 'error';

  factory _$ChatStreamEventErrorImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatStreamEventErrorImplFromJson(json);

  @override
  final String message;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'ChatStreamEvent.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatStreamEventErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of ChatStreamEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatStreamEventErrorImplCopyWith<_$ChatStreamEventErrorImpl>
      get copyWith =>
          __$$ChatStreamEventErrorImplCopyWithImpl<_$ChatStreamEventErrorImpl>(
              this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String text) token,
    required TResult Function(List<String> sources) sources,
    required TResult Function() done,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String text)? token,
    TResult? Function(List<String> sources)? sources,
    TResult? Function()? done,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String text)? token,
    TResult Function(List<String> sources)? sources,
    TResult Function()? done,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ChatStreamEventToken value) token,
    required TResult Function(ChatStreamEventSources value) sources,
    required TResult Function(ChatStreamEventDone value) done,
    required TResult Function(ChatStreamEventError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ChatStreamEventToken value)? token,
    TResult? Function(ChatStreamEventSources value)? sources,
    TResult? Function(ChatStreamEventDone value)? done,
    TResult? Function(ChatStreamEventError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ChatStreamEventToken value)? token,
    TResult Function(ChatStreamEventSources value)? sources,
    TResult Function(ChatStreamEventDone value)? done,
    TResult Function(ChatStreamEventError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatStreamEventErrorImplToJson(
      this,
    );
  }
}

abstract class ChatStreamEventError implements ChatStreamEvent {
  const factory ChatStreamEventError({required final String message}) =
      _$ChatStreamEventErrorImpl;

  factory ChatStreamEventError.fromJson(Map<String, dynamic> json) =
      _$ChatStreamEventErrorImpl.fromJson;

  String get message;

  /// Create a copy of ChatStreamEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatStreamEventErrorImplCopyWith<_$ChatStreamEventErrorImpl>
      get copyWith => throw _privateConstructorUsedError;
}
