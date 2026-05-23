import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:pally/shared/models/avatar.dart';
import 'package:pally/shared/models/chat_message.dart';
import 'package:pally/shared/models/photo_question.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/utils/logger.dart';

part 'chat_view_model.g.dart';

@immutable
class ChatState {
  const ChatState({
    this.avatar,
    this.messages = const [],
    this.isTyping = false,
    this.isSending = false,
    this.isProcessingPhoto = false,
    this.processingPhotoQuestions = const [],
    this.error,
  });

  final Avatar? avatar;
  final List<ChatMessage> messages;
  final bool isTyping;
  final bool isSending;
  final bool isProcessingPhoto;
  final List<PhotoQuestion> processingPhotoQuestions;
  final String? error;

  bool get canSend => !isSending && !isTyping && !isProcessingPhoto;

  List<ChatMessage> get sortedMessages => messages;

  ChatState copyWith({
    Avatar? avatar,
    List<ChatMessage>? messages,
    bool? isTyping,
    bool? isSending,
    bool? isProcessingPhoto,
    List<PhotoQuestion>? processingPhotoQuestions,
    Object? error = _sentinel,
  }) {
    return ChatState(
      avatar: avatar ?? this.avatar,
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      isSending: isSending ?? this.isSending,
      isProcessingPhoto: isProcessingPhoto ?? this.isProcessingPhoto,
      processingPhotoQuestions:
          processingPhotoQuestions ?? this.processingPhotoQuestions,
      error: error == _sentinel ? this.error : error as String?,
    );
  }
}

const _sentinel = Object();
const _uuid = Uuid();

@riverpod
class ChatViewModel extends _$ChatViewModel {
  late String _avatarId;

  @override
  ChatState build(String avatarId) {
    _avatarId = avatarId;
    _loadAvatar();
    _loadHistory();
    return const ChatState();
  }

  Future<void> _loadAvatar() async {
    appLog.d('[Chat] Loading avatar $_avatarId');
    try {
      final dio = ref.read(dioProvider);
      final response =
          await dio.get<Map<String, dynamic>>('/api/v1/avatars/$_avatarId');
      final avatar = Avatar.fromJson(response.data!);
      appLog.i('[Chat] Avatar loaded: ${avatar.name} (${avatar.subject})');
      state = state.copyWith(avatar: avatar);
    } catch (e, st) {
      appLog.w('[Chat] Avatar load failed, using stub', error: e, stackTrace: st);
      state = state.copyWith(
        avatar: const Avatar(
          id: 'stub',
          name: 'Zap',
          character: AvatarCharacter.zap,
          subject: 'Maths',
        ),
      );
    }
  }

  Future<void> _loadHistory() async {
    appLog.d('[Chat] Loading history for avatar $_avatarId');
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get<List<dynamic>>(
        '/api/v1/avatars/$_avatarId/chat/history',
      );
      final messages = (response.data ?? [])
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList();
      appLog.i('[Chat] Loaded ${messages.length} history messages');
      state = state.copyWith(messages: messages);
    } catch (e, st) {
      appLog.w('[Chat] History load failed, starting fresh', error: e, stackTrace: st);
    }
  }

  Future<void> togglePedagogyMode() async {
    final current = state.avatar?.pedagogyMode ?? PedagogyMode.socratic;
    final next = current == PedagogyMode.socratic ? PedagogyMode.direct : PedagogyMode.socratic;
    try {
      final dio = ref.read(dioProvider);
      await dio.patch<void>(
        '/api/v1/avatars/$_avatarId/pedagogy',
        data: {'mode': next.name.toUpperCase()},
      );
      final updated = state.avatar?.copyWith(pedagogyMode: next);
      if (updated != null) state = state.copyWith(avatar: updated);
      appLog.i('[Chat] Pedagogy toggled to $next');
    } catch (e, st) {
      appLog.w('[Chat] Pedagogy toggle failed', error: e, stackTrace: st);
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || !state.canSend) return;
    appLog.i('[Chat] Sending message to avatar $_avatarId: "${text.substring(0, text.length.clamp(0, 60))}"');

    final userMessage = ChatMessage(
      id: 'user-${DateTime.now().millisecondsSinceEpoch}',
      avatarId: _avatarId,
      role: MessageRole.user,
      content: text.trim(),
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isSending: true,
      isTyping: true,
      error: null,
    );

    final streamId = 'tutor-${DateTime.now().millisecondsSinceEpoch}';
    final streamingMessage = ChatMessage(
      id: streamId,
      avatarId: _avatarId,
      role: MessageRole.tutor,
      content: '',
      isStreaming: true,
      createdAt: DateTime.now(),
    );
    state = state.copyWith(
      messages: [...state.messages, streamingMessage],
      isSending: false,
    );

    try {
      await _streamResponse(text, streamId);
    } catch (e, st) {
      appLog.e('[Chat] sendMessage failed', error: e, stackTrace: st);
      _finaliseStreamingMessage(
        streamId,
        'Sorry, I had trouble answering that. Please try again!',
        [],
      );
      state = state.copyWith(isTyping: false, error: e.toString());
    }
  }

  Future<void> sendPhotoMessage(
      String imagePath, List<PhotoQuestion> questions) async {
    final messageId = _uuid.v4();

    // Add user-side photo bubble immediately
    final photoMessage = ChatMessage(
      id: messageId,
      avatarId: _avatarId,
      role: MessageRole.user,
      content: '📷 Homework photo',
      messageType: MessageType.photo,
      imagePath: imagePath,
      photoQuestions: questions,
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, photoMessage],
      isProcessingPhoto: true,
      processingPhotoQuestions: questions,
      error: null,
    );

    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post<Map<String, dynamic>>(
        '/api/v1/avatars/$_avatarId/photo-question',
        data: {
          'questions': questions
              .where((q) => q.isSelected)
              .map((q) => q.rawText)
              .toList(),
          'wikiPageIds': <String>[],
        },
      );

      final data = response.data ?? {};
      final answersJson = data['answers'] as List<dynamic>? ?? [];
      final answers = answersJson
          .map((e) => QuestionAnswer.fromJson(e as Map<String, dynamic>))
          .toList();

      final result = HomeworkScanResult(
        messageId: messageId,
        imageLocalPath: imagePath,
        questions: questions,
        answers: answers,
        xpEarned: (data['xpEarned'] as int?) ?? 5,
        sourceWikiPage: data['sourceWikiPage'] as String?,
        status: HomeworkScanStatus.complete,
      );

      // Replace photo message with result message
      state = state.copyWith(
        messages: state.messages.map((m) {
          if (m.id == messageId) {
            return ChatMessage(
              id: messageId,
              avatarId: _avatarId,
              role: MessageRole.tutor,
              content: '',
              messageType: MessageType.homeworkResult,
              scanResult: result,
              createdAt: DateTime.now(),
            );
          }
          return m;
        }).toList(),
        isProcessingPhoto: false,
        processingPhotoQuestions: const [],
      );
    } on DioException catch (_) {
      // Offline stub — show a fake result so the UI still renders
      final stubAnswers = questions.where((q) => q.isSelected).map((q) {
        return QuestionAnswer(
          questionId: q.id,
          questionText: q.rawText,
          answer: 'x = 5 (example)',
          steps: ['Step 1: Rearrange', 'Step 2: Solve', 'Step 3: Check'],
          explanation: "Great question! Here's how we solve it step by step.",
        );
      }).toList();

      final stubResult = HomeworkScanResult(
        messageId: messageId,
        imageLocalPath: imagePath,
        questions: questions,
        answers: stubAnswers,
        xpEarned: 5,
        status: HomeworkScanStatus.complete,
      );

      state = state.copyWith(
        messages: state.messages.map((m) {
          if (m.id == messageId) {
            return ChatMessage(
              id: messageId,
              avatarId: _avatarId,
              role: MessageRole.tutor,
              content: '',
              messageType: MessageType.homeworkResult,
              scanResult: stubResult,
              createdAt: DateTime.now(),
            );
          }
          return m;
        }).toList(),
        isProcessingPhoto: false,
        processingPhotoQuestions: const [],
      );
    } catch (e) {
      state = state.copyWith(
        isProcessingPhoto: false,
        processingPhotoQuestions: const [],
        error: e.toString(),
      );
    }
  }

  Future<String> cacheImage(File file) async {
    final dir = await getApplicationDocumentsDirectory();
    final dest = File('${dir.path}/photo_questions/${_uuid.v4()}.jpg');
    await dest.parent.create(recursive: true);
    await file.copy(dest.path);
    return dest.path;
  }

  Future<void> _streamResponse(String text, String streamId) async {
    final dio = ref.read(dioProvider);
    appLog.d('[Chat] Starting SSE stream for avatar $_avatarId');

    try {
      final response = await dio.post<ResponseBody>(
        '/api/v1/avatars/$_avatarId/chat',
        data: ChatRequest(message: text).toJson(),
        options: Options(responseType: ResponseType.stream),
      );

      final stream = response.data!.stream;
      final buffer = StringBuffer();
      final sources = <String>[];

      await for (final chunk in stream) {
        final raw = utf8.decode(chunk);
        for (final line in raw.split('\n')) {
          if (line.startsWith('data: ')) {
            final data = line.substring(6);
            if (data == '[DONE]') {
              _finaliseStreamingMessage(streamId, buffer.toString(), sources);
              state = state.copyWith(isTyping: false);
              return;
            }
            try {
              final json = jsonDecode(data) as Map<String, dynamic>;
              final event = ChatStreamEvent.fromJson(json);
              event.when(
                token: (token) {
                  buffer.write(token);
                  _updateStreamingMessage(streamId, buffer.toString());
                },
                sources: (s) => sources.addAll(s),
                done: () {
                  appLog.i('[Chat] Stream complete. source=${sources.firstOrNull}');
                  _finaliseStreamingMessage(
                      streamId, buffer.toString(), sources);
                  state = state.copyWith(isTyping: false);
                },
                error: (msg) {
                  appLog.e('[Chat] SSE error event: $msg');
                  _finaliseStreamingMessage(streamId, msg, []);
                  state = state.copyWith(isTyping: false);
                },
              );
            } catch (_) {}
          }
        }
      }

      appLog.i('[Chat] Stream ended, chars=${buffer.length}');
      _finaliseStreamingMessage(streamId, buffer.toString(), sources);
      state = state.copyWith(isTyping: false);
    } on DioException catch (e, st) {
      appLog.w('[Chat] SSE request failed, falling back to stub', error: e, stackTrace: st);
      await _simulateStubResponse(streamId);
    }
  }

  Future<void> _simulateStubResponse(String streamId) async {
    final stubWords = [
      'Great',
      ' question!',
      ' Let',
      ' me',
      ' think',
      ' about',
      ' that',
      '...',
      ' Based',
      ' on',
      ' your',
      ' notes,',
      ' here\'s',
      ' what',
      ' I',
      ' know!',
      ' 🎉',
    ];

    final buffer = StringBuffer();
    for (final word in stubWords) {
      await Future<void>.delayed(const Duration(milliseconds: 60));
      buffer.write(word);
      _updateStreamingMessage(streamId, buffer.toString());
    }
    _finaliseStreamingMessage(streamId, buffer.toString(), ['stub-source.pdf']);
    state = state.copyWith(isTyping: false);
  }

  void _updateStreamingMessage(String id, String content) {
    final updated = state.messages.map((m) {
      if (m.id == id) return m.copyWith(content: content);
      return m;
    }).toList();
    state = state.copyWith(messages: updated);
  }

  void _finaliseStreamingMessage(
      String id, String content, List<String> sources) {
    final updated = state.messages.map((m) {
      if (m.id == id) {
        return m.copyWith(
          content: content,
          isStreaming: false,
          sources: sources,
        );
      }
      return m;
    }).toList();
    state = state.copyWith(messages: updated);
  }

  List<String> get quickReplies => const [
        'Can you explain more?',
        'Give me an example',
        'How do I solve this?',
        'What does this mean?',
      ];
}
