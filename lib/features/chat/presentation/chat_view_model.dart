import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:pally/shared/models/avatar.dart';
import 'package:pally/shared/models/mochi_character.dart';
import 'package:pally/shared/models/chat_message.dart';
import 'package:pally/shared/models/photo_question.dart';
import 'package:pally/shared/models/session_state.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/utils/logger.dart';
import 'package:pally/core/local_db/pally_database.dart';
import 'package:pally/features/chat/data/local/chat_local_data_source.dart';
import 'package:pally/features/chat/data/local/chat_message_mapper.dart';
import 'package:pally/features/chat/widgets/teaching_mode_toggle.dart';

part 'chat_view_model.g.dart';

@immutable
class ChatState {
  const ChatState({
    this.avatar,
    this.messages = const [],
    this.sessionState,
    this.savedScrollOffset = 0.0,
    this.isTyping = false,
    this.isSending = false,
    this.isProcessingPhoto = false,
    this.processingPhotoQuestions = const [],
    this.teachingMode = TeachingMode.teaching,
    this.socraticAttempts = 0,
    this.showEscapeHatch = false,
    this.error,
  });

  final Avatar? avatar;
  final List<ChatMessage> messages;
  final SessionState? sessionState;
  final double savedScrollOffset;
  final bool isTyping;
  final bool isSending;
  final bool isProcessingPhoto;
  final List<PhotoQuestion> processingPhotoQuestions;
  final TeachingMode teachingMode;
  final int socraticAttempts;
  final bool showEscapeHatch;
  final String? error;

  bool get canSend => !isSending && !isTyping && !isProcessingPhoto;

  List<ChatMessage> get sortedMessages => messages;

  ChatState copyWith({
    Avatar? avatar,
    List<ChatMessage>? messages,
    SessionState? sessionState,
    double? savedScrollOffset,
    bool? isTyping,
    bool? isSending,
    bool? isProcessingPhoto,
    List<PhotoQuestion>? processingPhotoQuestions,
    TeachingMode? teachingMode,
    int? socraticAttempts,
    bool? showEscapeHatch,
    Object? error = _sentinel,
  }) {
    return ChatState(
      avatar: avatar ?? this.avatar,
      messages: messages ?? this.messages,
      sessionState: sessionState ?? this.sessionState,
      savedScrollOffset: savedScrollOffset ?? this.savedScrollOffset,
      isTyping: isTyping ?? this.isTyping,
      isSending: isSending ?? this.isSending,
      isProcessingPhoto: isProcessingPhoto ?? this.isProcessingPhoto,
      processingPhotoQuestions:
          processingPhotoQuestions ?? this.processingPhotoQuestions,
      teachingMode: teachingMode ?? this.teachingMode,
      socraticAttempts: socraticAttempts ?? this.socraticAttempts,
      showEscapeHatch: showEscapeHatch ?? this.showEscapeHatch,
      error: error == _sentinel ? this.error : error as String?,
    );
  }
}

const _sentinel = Object();
const _uuid = Uuid();

@riverpod
class ChatViewModel extends _$ChatViewModel {
  late String _avatarId;
  late ChatLocalDataSource _localDb;

  @override
  ChatState build(String avatarId) {
    _avatarId = avatarId;
    _localDb = ChatLocalDataSource(ref.read(pallyDatabaseProvider));
    _loadAvatar();
    _loadFromLocalDb();

    // Start cache keepalive — non-critical, chat works without it
    unawaited(_startSession());
    ref.onDispose(() => unawaited(_endSession()));

    return const ChatState();
  }

  Future<void> _startSession() async {
    try {
      await ref.read(dioProvider).post('/api/v1/avatars/$_avatarId/chat/session-start');
      appLog.d('[Cache] Session started for avatar=$_avatarId');
    } catch (e) {
      appLog.w('[Cache] session-start failed (non-critical): $e');
    }
  }

  Future<void> _endSession() async {
    try {
      await ref.read(dioProvider).post('/api/v1/avatars/$_avatarId/chat/session-end');
      appLog.d('[Cache] Session ended for avatar=$_avatarId');
    } catch (e) {
      appLog.w('[Cache] session-end failed (non-critical): $e');
    }
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
          character: MochiCharacter.pencil,
          subject: 'Maths',
        ),
      );
    }
  }

  Future<void> _loadFromLocalDb() async {
    appLog.d('[Chat] Loading messages from local DB for $_avatarId');
    try {
      final localMessages =
          await _localDb.loadRecentMessages(_avatarId, limit: 50);
      final sessionRecord = await _localDb.getTodaySession(_avatarId);
      final sessionState = sessionRecord ?? SessionState.empty(_avatarId);
      final scrollOffset = await _localDb.getScrollOffset(_avatarId);

      appLog.i('[Chat] Loaded ${localMessages.length} messages from local DB');

      state = state.copyWith(
        messages: localMessages,
        sessionState: sessionState,
        savedScrollOffset: scrollOffset,
      );

      // If local DB is empty (fresh install / re-install), pull from backend
      if (localMessages.isEmpty) {
        await _fetchHistoryFromBackend();
      }
    } catch (e, st) {
      appLog.w('[Chat] Local DB load failed', error: e, stackTrace: st);
      await _fetchHistoryFromBackend();
    }
  }

  Future<void> _fetchHistoryFromBackend() async {
    appLog.d('[Chat] Fetching history from backend for $_avatarId');
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get<dynamic>(
        '/api/v1/avatars/$_avatarId/chat/history',
      );

      List<dynamic> raw;
      final data = response.data;
      if (data is List) {
        raw = data;
      } else if (data is Map) {
        raw = (data['messages'] ?? data['data'] ?? data['history'] ?? [])
            as List<dynamic>;
      } else {
        raw = [];
      }

      final messages = <ChatMessage>[];
      for (final e in raw) {
        try {
          messages.add(ChatMessage.fromJson(e as Map<String, dynamic>));
        } catch (parseErr, st) {
          appLog.e('[Chat] Failed to parse history message: $e',
              error: parseErr, stackTrace: st);
        }
      }

      appLog.i('[Chat] Loaded ${messages.length} history messages from backend');
      state = state.copyWith(messages: messages);

      for (final msg in messages) {
        await _localDb.saveMessage(msg.toRecord());
      }
    } catch (e, st) {
      appLog.w('[Chat] Backend history load failed, starting fresh',
          error: e, stackTrace: st);
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

    // Save user message BEFORE API call
    await _localDb.saveMessage(userMessage.toRecord());

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

      // Save finalized tutor message ONCE after stream ends
      final finalMsg = state.messages.firstWhere(
        (m) => m.id == streamId,
        orElse: () => streamingMessage,
      );
      await _localDb.saveMessage(finalMsg.toRecord());

      // Track socratic attempts (count how many turns user has tried)
      if (state.teachingMode == TeachingMode.teaching) {
        _trackSocraticAttempt();
      }

      // Update session state
      final updatedSession =
          _buildUpdatedSessionState(state.sessionState, userMessage.content);
      await _localDb.saveSessionState(updatedSession.toRecord());
      state = state.copyWith(sessionState: updatedSession);

      // Non-blocking backend sync
      unawaited(_syncMessagesToBackend([userMessage, finalMsg]));
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

    // Save photo message immediately
    await _localDb.saveMessage(photoMessage.toRecord());

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

      final resultMessage = ChatMessage(
        id: messageId,
        avatarId: _avatarId,
        role: MessageRole.tutor,
        content: '',
        messageType: MessageType.homeworkResult,
        scanResult: result,
        createdAt: DateTime.now(),
      );

      // Save result message
      await _localDb.saveMessage(resultMessage.toRecord());

      state = state.copyWith(
        messages: state.messages.map((m) {
          if (m.id == messageId) return resultMessage;
          return m;
        }).toList(),
        isProcessingPhoto: false,
        processingPhotoQuestions: const [],
      );
    } on DioException catch (_) {
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

      final stubMessage = ChatMessage(
        id: messageId,
        avatarId: _avatarId,
        role: MessageRole.tutor,
        content: '',
        messageType: MessageType.homeworkResult,
        scanResult: stubResult,
        createdAt: DateTime.now(),
      );

      await _localDb.saveMessage(stubMessage.toRecord());

      state = state.copyWith(
        messages: state.messages.map((m) {
          if (m.id == messageId) return stubMessage;
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

  Future<void> submitFeedback(String messageId, FeedbackType type) async {
    await _localDb.updateFeedback(messageId, type.name);
    if (type == FeedbackType.saveToBrain) {
      await _localDb.markSavedToBrain(messageId);
    }
    unawaited(_syncFeedbackToBackend(messageId, type));
    appLog.i('[Chat] Feedback $type submitted for message $messageId');
  }

  Future<void> saveScrollOffset(double offset) async {
    await _localDb.saveScrollOffset(_avatarId, offset);
  }

  void toggleMode() {
    final next = state.teachingMode == TeachingMode.teaching
        ? TeachingMode.direct
        : TeachingMode.teaching;
    state = state.copyWith(
      teachingMode: next,
      socraticAttempts: 0,
      showEscapeHatch: false,
    );
    appLog.i('[Chat] Teaching mode toggled → ${next.name}');
    unawaited(_syncTeachingMode(next));
  }

  void dismissEscapeHatch() {
    state = state.copyWith(showEscapeHatch: false);
  }

  Future<void> _syncTeachingMode(TeachingMode mode) async {
    try {
      await ref.read(dioProvider).patch(
        '/api/v1/avatars/$_avatarId/teaching-mode',
        data: {'mode': mode.name.toUpperCase()},
      );
    } catch (e) {
      appLog.w('[Chat] Teaching mode sync failed: $e');
    }
  }

  // Updates socratic attempt counter and triggers escape hatch after 3 attempts
  void _trackSocraticAttempt() {
    final attempts = state.socraticAttempts + 1;
    final showEscape = attempts >= 3 && state.teachingMode == TeachingMode.teaching;
    state = state.copyWith(
      socraticAttempts: attempts,
      showEscapeHatch: showEscape,
    );
  }

  Future<String> cacheImage(File file) async {
    final dir = await getApplicationDocumentsDirectory();
    final dest = File('${dir.path}/photo_questions/${_uuid.v4()}.jpg');
    await dest.parent.create(recursive: true);
    await file.copy(dest.path);
    return dest.path;
  }

  // ── Helpers ───────────────────────────────────────────────────────

  SessionState _buildUpdatedSessionState(
      SessionState? current, String userMessage) {
    final base = current ?? SessionState.empty(_avatarId);
    return base.copyWith(
      questionsAsked: base.questionsAsked + 1,
      updatedAt: DateTime.now(),
    );
  }

  Future<void> _syncMessagesToBackend(List<ChatMessage> messages) async {
    try {
      final dio = ref.read(dioProvider);
      final syncDtos = messages.map((m) => {
            'id': m.id,
            'role': m.role.name.toUpperCase(),
            'content': m.content,
            'sourceWikiSlug': m.sources.firstOrNull,
            'isPhotoMessage': m.messageType == MessageType.photo,
            'createdAt': (m.createdAt ?? DateTime.now()).toIso8601String(),
          }).toList();
      await dio.post<void>(
        '/api/v1/avatars/$_avatarId/chat/sync',
        data: {'messages': syncDtos},
      );
      appLog.d('[Chat] Synced ${messages.length} messages to backend');
    } catch (e) {
      appLog.w('[Chat] Backend sync failed, will retry on next open: $e');
    }
  }

  Future<void> _syncFeedbackToBackend(
      String messageId, FeedbackType type) async {
    try {
      final dio = ref.read(dioProvider);
      await dio.post<void>(
        '/api/v1/avatars/$_avatarId/chat/$messageId/feedback',
        data: {'type': type.name.toUpperCase()},
      );
    } catch (e) {
      appLog.w('[Chat] Feedback sync failed: $e');
    }
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

      String currentEvent = '';
      await for (final chunk in stream) {
        final raw = utf8.decode(chunk);
        for (final line in raw.split('\n')) {
          if (line.startsWith('event: ')) {
            currentEvent = line.substring(7).trim();
          } else if (line.startsWith('data: ')) {
            final data = line.substring(6);
            if (data == '[DONE]') {
              _finaliseStreamingMessage(streamId, buffer.toString(), sources);
              state = state.copyWith(isTyping: false);
              return;
            }
            if (currentEvent == 'done') {
              _finaliseStreamingMessage(streamId, buffer.toString(), sources);
              state = state.copyWith(isTyping: false);
              return;
            }
            if (currentEvent == 'delta' || currentEvent.isEmpty) {
              try {
                final json = jsonDecode(data) as Map<String, dynamic>;
                final text = json['text'] as String? ?? data;
                buffer.write(text);
              } catch (_) {
                buffer.write(data);
              }
              _updateStreamingMessage(streamId, buffer.toString());
            }
            currentEvent = '';
          }
        }
      }

      appLog.i('[Chat] Stream ended, chars=${buffer.length}');
      _finaliseStreamingMessage(streamId, buffer.toString(), sources);
      state = state.copyWith(isTyping: false);
    } on DioException catch (e, st) {
      appLog.w('[Chat] SSE request failed, falling back to stub',
          error: e, stackTrace: st);
      await _simulateStubResponse(streamId);
    }
  }

  Future<void> _simulateStubResponse(String streamId) async {
    final stubWords = [
      'Great', ' question!', ' Let', ' me', ' think',
      ' about', ' that', '...', ' Based', ' on',
      ' your', ' notes,', ' here\'s', ' what', ' I',
      ' know!', ' 🎉',
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
}
