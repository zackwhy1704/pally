import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pally/shared/models/photo_question.dart';

part 'chat_message.freezed.dart';
part 'chat_message.g.dart';

enum MessageRole { user, tutor }

MessageRole _messageRoleFromJson(dynamic value) {
  final s = (value as String? ?? '').toUpperCase();
  return switch (s) {
    'USER' => MessageRole.user,
    'TUTOR' || 'ASSISTANT' => MessageRole.tutor,
    _ => MessageRole.tutor,
  };
}

String _messageRoleToJson(MessageRole r) => switch (r) {
      MessageRole.user => 'USER',
      MessageRole.tutor => 'ASSISTANT',
    };

enum MessageType { text, photo, homeworkResult }

enum FeedbackType { helpful, wrong, confused, saveToBrain }

enum SyncStatus { pending, synced, failed }

SyncStatus _syncStatusFromJson(dynamic value) {
  final s = (value as String? ?? '').toLowerCase();
  return switch (s) {
    'synced' => SyncStatus.synced,
    'failed' => SyncStatus.failed,
    _ => SyncStatus.pending,
  };
}

String _syncStatusToJson(SyncStatus s) => s.name;

@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    required String avatarId,
    @JsonKey(fromJson: _messageRoleFromJson, toJson: _messageRoleToJson)
    required MessageRole role,
    required String content,
    @Default([]) List<String> sources,
    @Default(false) bool isStreaming,
    DateTime? createdAt,
    // Photo question fields
    @Default(MessageType.text) MessageType messageType,
    String? imagePath,
    @Default([]) List<PhotoQuestion> photoQuestions,
    HomeworkScanResult? scanResult,
    // Persistence / feedback fields
    FeedbackType? feedbackType,
    @Default(false) bool savedToBrain,
    @JsonKey(fromJson: _syncStatusFromJson, toJson: _syncStatusToJson)
    @Default(SyncStatus.synced)
    SyncStatus syncStatus,
    // Error rendering — when true, the bubble shows a coral retry pill
    // instead of normal text. `error` is the user-facing message.
    @Default(false) bool isError,
    String? error,
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
