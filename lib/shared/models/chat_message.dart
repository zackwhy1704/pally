import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pally/shared/models/photo_question.dart';

part 'chat_message.freezed.dart';
part 'chat_message.g.dart';

enum MessageRole { user, tutor }

enum MessageType { text, photo, homeworkResult }

@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    required String avatarId,
    required MessageRole role,
    required String content,
    @Default([]) List<String> sources,
    @Default(false) bool isStreaming,
    DateTime? createdAt,
    // Photo question fields — not persisted on backend
    @Default(MessageType.text) MessageType messageType,
    String? imagePath,
    @Default([]) List<PhotoQuestion> photoQuestions,
    HomeworkScanResult? scanResult,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
}

@freezed
class ChatRequest with _$ChatRequest {
  const factory ChatRequest({
    required String message,
    @Default([]) List<String> history,
  }) = _ChatRequest;

  factory ChatRequest.fromJson(Map<String, dynamic> json) =>
      _$ChatRequestFromJson(json);
}

@freezed
class ChatStreamEvent with _$ChatStreamEvent {
  const factory ChatStreamEvent.token({
    required String text,
  }) = ChatStreamEventToken;

  const factory ChatStreamEvent.sources({
    required List<String> sources,
  }) = ChatStreamEventSources;

  const factory ChatStreamEvent.done() = ChatStreamEventDone;

  const factory ChatStreamEvent.error({
    required String message,
  }) = ChatStreamEventError;

  factory ChatStreamEvent.fromJson(Map<String, dynamic> json) =>
      _$ChatStreamEventFromJson(json);
}
