import 'dart:convert';
import 'package:pally/core/local_db/pally_database.dart';
import 'package:pally/shared/models/chat_message.dart';
import 'package:pally/shared/models/photo_question.dart';

extension ChatMessagePersistence on ChatMessage {
  ChatMessageRecord toRecord() => ChatMessageRecord(
        id: id,
        avatarId: avatarId,
        role: role.name,
        messageType: messageType.name,
        content: _serialiseContent(),
        sourceWikiSlug: sources.firstOrNull,
        feedbackType: feedbackType?.name,
        savedToBrain: savedToBrain,
        isPhotoMessage: messageType == MessageType.photo,
        photoPath: imagePath,
        createdAt: createdAt ?? DateTime.now(),
      );

  String _serialiseContent() {
    if (messageType == MessageType.homeworkResult && scanResult != null) {
      return jsonEncode(scanResult!.toJson());
    }
    return content;
  }
}

MessageRole _parseRoleFromDb(String role) => switch (role.toUpperCase()) {
      'USER' => MessageRole.user,
      'TUTOR' || 'ASSISTANT' => MessageRole.tutor,
      _ => MessageRole.tutor,
    };

class ChatMessageMapper {
  static ChatMessage fromRecord(ChatMessageRecord r) {
    final mt = MessageType.values.byName(r.messageType);
    HomeworkScanResult? scanResult;

    if (mt == MessageType.homeworkResult && r.content.isNotEmpty) {
      try {
        scanResult =
            HomeworkScanResult.fromJson(jsonDecode(r.content) as Map<String, dynamic>);
      } catch (_) {}
    }

    return ChatMessage(
      id: r.id,
      avatarId: r.avatarId,
      role: _parseRoleFromDb(r.role),
      content: mt == MessageType.homeworkResult ? '' : r.content,
      messageType: mt,
      sources: r.sourceWikiSlug != null ? [r.sourceWikiSlug!] : [],
      feedbackType: r.feedbackType != null
          ? FeedbackType.values.byName(r.feedbackType!)
          : null,
      savedToBrain: r.savedToBrain,
      imagePath: r.photoPath,
      scanResult: scanResult,
      createdAt: r.createdAt,
    );
  }
}
