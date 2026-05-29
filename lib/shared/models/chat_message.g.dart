// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatMessageImpl _$$ChatMessageImplFromJson(Map<String, dynamic> json) =>
    _$ChatMessageImpl(
      id: json['id'] as String,
      avatarId: json['avatarId'] as String,
      role: _messageRoleFromJson(json['role']),
      content: json['content'] as String,
      sources: (json['sources'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      isStreaming: json['isStreaming'] as bool? ?? false,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      messageType:
          $enumDecodeNullable(_$MessageTypeEnumMap, json['messageType']) ??
              MessageType.text,
      imagePath: json['imagePath'] as String?,
      photoQuestions: (json['photoQuestions'] as List<dynamic>?)
              ?.map((e) => PhotoQuestion.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      scanResult: json['scanResult'] == null
          ? null
          : HomeworkScanResult.fromJson(
              json['scanResult'] as Map<String, dynamic>),
      feedbackType:
          $enumDecodeNullable(_$FeedbackTypeEnumMap, json['feedbackType']),
      savedToBrain: json['savedToBrain'] as bool? ?? false,
      syncStatus: json['syncStatus'] == null
          ? SyncStatus.synced
          : _syncStatusFromJson(json['syncStatus']),
      isError: json['isError'] as bool? ?? false,
      error: json['error'] as String?,
    );

Map<String, dynamic> _$$ChatMessageImplToJson(_$ChatMessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'avatarId': instance.avatarId,
      'role': _messageRoleToJson(instance.role),
      'content': instance.content,
      'sources': instance.sources,
      'isStreaming': instance.isStreaming,
      'createdAt': instance.createdAt?.toIso8601String(),
      'messageType': _$MessageTypeEnumMap[instance.messageType]!,
      'imagePath': instance.imagePath,
      'photoQuestions': instance.photoQuestions,
      'scanResult': instance.scanResult,
      'feedbackType': _$FeedbackTypeEnumMap[instance.feedbackType],
      'savedToBrain': instance.savedToBrain,
      'syncStatus': _syncStatusToJson(instance.syncStatus),
      'isError': instance.isError,
      'error': instance.error,
    };

const _$MessageTypeEnumMap = {
  MessageType.text: 'text',
  MessageType.photo: 'photo',
  MessageType.homeworkResult: 'homeworkResult',
};

const _$FeedbackTypeEnumMap = {
  FeedbackType.helpful: 'helpful',
  FeedbackType.wrong: 'wrong',
  FeedbackType.confused: 'confused',
  FeedbackType.saveToBrain: 'saveToBrain',
};

_$ChatRequestImpl _$$ChatRequestImplFromJson(Map<String, dynamic> json) =>
    _$ChatRequestImpl(
      message: json['message'] as String,
      history: (json['history'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$ChatRequestImplToJson(_$ChatRequestImpl instance) =>
    <String, dynamic>{
      'message': instance.message,
      'history': instance.history,
    };

_$ChatStreamEventTokenImpl _$$ChatStreamEventTokenImplFromJson(
        Map<String, dynamic> json) =>
    _$ChatStreamEventTokenImpl(
      text: json['text'] as String,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$ChatStreamEventTokenImplToJson(
        _$ChatStreamEventTokenImpl instance) =>
    <String, dynamic>{
      'text': instance.text,
      'runtimeType': instance.$type,
    };

_$ChatStreamEventSourcesImpl _$$ChatStreamEventSourcesImplFromJson(
        Map<String, dynamic> json) =>
    _$ChatStreamEventSourcesImpl(
      sources:
          (json['sources'] as List<dynamic>).map((e) => e as String).toList(),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$ChatStreamEventSourcesImplToJson(
        _$ChatStreamEventSourcesImpl instance) =>
    <String, dynamic>{
      'sources': instance.sources,
      'runtimeType': instance.$type,
    };

_$ChatStreamEventDoneImpl _$$ChatStreamEventDoneImplFromJson(
        Map<String, dynamic> json) =>
    _$ChatStreamEventDoneImpl(
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$ChatStreamEventDoneImplToJson(
        _$ChatStreamEventDoneImpl instance) =>
    <String, dynamic>{
      'runtimeType': instance.$type,
    };

_$ChatStreamEventErrorImpl _$$ChatStreamEventErrorImplFromJson(
        Map<String, dynamic> json) =>
    _$ChatStreamEventErrorImpl(
      message: json['message'] as String,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$ChatStreamEventErrorImplToJson(
        _$ChatStreamEventErrorImpl instance) =>
    <String, dynamic>{
      'message': instance.message,
      'runtimeType': instance.$type,
    };
