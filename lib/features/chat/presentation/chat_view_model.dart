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
import 'package:pally/features/consent/presentation/parental_consent_pending_sheet.dart';

import 'package:pally/core/error/pally_error.dart';
import 'package:pally/core/observability/observability_providers.dart';

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
    this.guideAttempts = 0,
    this.showEscapeHatch = false,
    this.error,
    this.pendingLevelUp = 0,
    this.historyParseWarning,
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
  final int guideAttempts;
  final bool showEscapeHatch;
  final String? error;
  // When the backend reports a level-up from photo solve or session-end,
  // this carries the new level so the screen can fire LevelUpController.
  // 0 = nothing to celebrate. Cleared by the screen after the overlay shows.
  final int pendingLevelUp;
  // Non-null when ≥1 history message failed to parse (P3: non-silent drops).
  // Displayed as a soft banner — not a crash, not lost silently.
  final String? historyParseWarning;

  bool get canSend => !isSending && !isTyping && !isProcessingPhoto;

  List<ChatMessage> get sortedMessages {
    final sorted = List<ChatMessage>.from(messages);
    sorted.sort((a, b) {
      final cmp = (a.createdAt ?? DateTime(0))
          .compareTo(b.createdAt ?? DateTime(0));
      if (cmp != 0) return cmp;
      final aOrder = a.role == MessageRole.user ? 0 : 1;
      final bOrder = b.role == MessageRole.user ? 0 : 1;
      return aOrder.compareTo(bOrder);
    });
    return sorted;
  }

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
    int? guideAttempts,
    bool? showEscapeHatch,
    Object? error = _sentinel,
    int? pendingLevelUp,
    Object? historyParseWarning = _sentinel,
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
      guideAttempts: guideAttempts ?? this.guideAttempts,
      showEscapeHatch: showEscapeHatch ?? this.showEscapeHatch,
      error: error == _sentinel ? this.error : error as String?,
      pendingLevelUp: pendingLevelUp ?? this.pendingLevelUp,
      historyParseWarning: historyParseWarning == _sentinel
          ? this.historyParseWarning
          : historyParseWarning as String?,
    );
  }
}

const _sentinel = Object();
const _uuid = Uuid();

ChatMessage streamingMessageStub(String id, String avatarId) => ChatMessage(
      id: id,
      avatarId: avatarId,
      role: MessageRole.tutor,
      content: '',
      isStreaming: true,
      createdAt: DateTime.now(),
    );

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
      final response = await ref.read(dioProvider).post<Map<String, dynamic>>(
            '/api/v1/avatars/$_avatarId/chat/session-end',
          );
      // Pick up any level-up the +5 XP for closing this session triggered.
      // ref is auto-disposed once the screen pops; reading state safely
      // means guarding against the notifier being torn down.
      final data = response.data ?? const <String, dynamic>{};
      final levelledUp = data['levelledUp'] == true;
      final newLevel = (data['newLevel'] as num?)?.toInt() ?? 0;
      if (levelledUp && newLevel > 0) {
        try {
          state = state.copyWith(pendingLevelUp: newLevel);
        } catch (_) {/* notifier disposed — overlay will fire next entry */}
      }
      appLog.d('[Cache] Session ended for avatar=$_avatarId levelledUp=$levelledUp');
    } catch (e) {
      appLog.w('[Cache] session-end failed (non-critical): $e');
    }
  }

  /// Called by the screen after it shows the level-up overlay so the
  /// celebration only fires once per crossing.
  void clearPendingLevelUp() {
    if (state.pendingLevelUp == 0) return;
    state = state.copyWith(pendingLevelUp: 0);
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

      // Always fetch backend history in background — non-blocking.
      // If local was empty, the merge will populate the UI.
      // If local had data, the merge will pick up any messages added on other devices.
      unawaited(_fetchHistoryFromBackend());

      // Retry any previously-failed syncs from a prior session.
      unawaited(_retryPendingSyncs());
    } catch (e, st) {
      appLog.w('[Chat] Local DB load failed', error: e, stackTrace: st);
      unawaited(_fetchHistoryFromBackend());
      unawaited(_retryPendingSyncs());
    }
  }

  Future<void> _retryPendingSyncs() async {
    try {
      final pending = await _localDb.getPendingSyncs(_avatarId);
      if (pending.isEmpty) return;
      final messages = <ChatMessage>[];
      for (final p in pending) {
        final msg = await _localDb.getMessage(p.messageId);
        if (msg != null) messages.add(msg);
      }
      if (messages.isNotEmpty) {
        appLog.i('[Chat] Retrying ${messages.length} pending syncs');
        await _syncMessagesToBackend(messages);
      }
    } catch (e) {
      appLog.w('[Chat] Pending sync retry failed: $e');
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
      int parseFailures = 0;
      for (final e in raw) {
        try {
          // Backend history rows don't include avatarId per-row — inject it.
          // sourceFile (old field name) → sources (List<String>) normalization:
          // The backend now sends `sources: List`, but old persisted rows may
          // still have `sourceFile: String`. Handle both forms.
          final map = Map<String, dynamic>.from(e as Map<String, dynamic>);
          map.putIfAbsent('avatarId', () => _avatarId);
          map.putIfAbsent('content', () => '');
          if (!map.containsKey('sources') || map['sources'] == null) {
            final sf = map['sourceFile'];
            map['sources'] = (sf != null && (sf as String).isNotEmpty)
                ? [sf]
                : <String>[];
          }
          messages.add(ChatMessage.fromJson(map));
        } catch (parseErr, st) {
          parseFailures++;
          appLog.e(
              '[Chat] Failed to parse history message (raw=$e)',
              error: parseErr,
              stackTrace: st);
        }
      }

      // Surface a soft warning if any messages failed — non-blocking.
      if (parseFailures > 0) {
        appLog.w('[Chat] $parseFailures/${raw.length} history messages could not be parsed');
        state = state.copyWith(
          historyParseWarning:
              'Could not load $parseFailures message${parseFailures > 1 ? 's' : ''} — '
              'they may have been saved in an older format.',
        );
      }

      // Merge: keep local messages, add backend ones not already present (by id).
      final existingIds = state.messages.map((m) => m.id).toSet();
      final merged = [...state.messages];
      for (final m in messages) {
        if (!existingIds.contains(m.id)) merged.add(m);
      }
      merged.sort((a, b) {
        final cmp = (a.createdAt ?? DateTime(0))
            .compareTo(b.createdAt ?? DateTime(0));
        if (cmp != 0) return cmp;
        final aOrder = a.role == MessageRole.user ? 0 : 1;
        final bOrder = b.role == MessageRole.user ? 0 : 1;
        return aOrder.compareTo(bOrder);
      });
      appLog.i('[Chat] Merged ${messages.length} backend messages into state (total ${merged.length})');
      state = state.copyWith(messages: merged);

      for (final msg in messages) {
        await _localDb.saveMessage(msg.toRecord());
      }
    } catch (e, st) {
      appLog.w('[Chat] Backend history load failed, starting fresh',
          error: e, stackTrace: st);
    }
  }

  /// Re-sends the most recent user message after the previous attempt
  /// failed. Strips any error-bubble messages before retrying so the
  /// retry pill disappears as soon as a new attempt is in flight.
  Future<void> retryLastMessage() async {
    ChatMessage? lastUser;
    for (final m in state.messages.reversed) {
      if (m.role == MessageRole.user && !m.isError) {
        lastUser = m;
        break;
      }
    }
    if (lastUser == null) return;
    // Drop error bubbles so the user doesn't see two of them.
    state = state.copyWith(
      messages: state.messages.where((m) => !m.isError).toList(),
    );
    await sendMessage(lastUser.content);
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || !state.canSend) return;
    appLog.i('[Chat] Sending message to avatar $_avatarId: "${text.substring(0, text.length.clamp(0, 60))}"');

    final now = DateTime.now();

    final userMessage = ChatMessage(
      id: 'user-${now.millisecondsSinceEpoch}',
      avatarId: _avatarId,
      role: MessageRole.user,
      content: text.trim(),
      createdAt: now,
      syncStatus: SyncStatus.pending,
    );

    // Save user message BEFORE API call
    await _localDb.saveMessage(userMessage.toRecord());

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isSending: true,
      isTyping: true,
      error: null,
    );

    // Tutor message must be strictly AFTER user message so sort order is stable
    final tutorTimestamp = now.add(const Duration(seconds: 1));
    final streamId = 'tutor-${tutorTimestamp.millisecondsSinceEpoch}';
    final streamingMessage = ChatMessage(
      id: streamId,
      avatarId: _avatarId,
      role: MessageRole.tutor,
      content: '',
      isStreaming: true,
      createdAt: tutorTimestamp,
      syncStatus: SyncStatus.pending,
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

      // Track Guide Me attempts (count how many turns user has tried)
      if (state.teachingMode == TeachingMode.teaching) {
        _trackGuideAttempt();
      }

      // Update session state
      final updatedSession =
          _buildUpdatedSessionState(state.sessionState, userMessage.content);
      await _localDb.saveSessionState(updatedSession.toRecord());
      state = state.copyWith(sessionState: updatedSession);

      // Only sync completed, non-error messages. When the SSE stream fails
      // internally, _markStreamingMessageAsError sets isError=true without
      // rethrowing, so execution reaches here with an error-state finalMsg.
      // Syncing that to the backend would persist empty or error content.
      if (!finalMsg.isError && finalMsg.content.isNotEmpty) {
        unawaited(_syncMessagesToBackend([userMessage, finalMsg]));
      } else if (finalMsg.isError) {
        appLog.w('[Chat] Skipping sync — stream ended in error state');
        // Mark the user message as synced so its bubble clears the "pending"
        // (clock) indicator. The user DID send their message — the failure
        // was on the reply side, not the send side. Leaving it "pending"
        // misleads the user into thinking their message wasn't delivered.
        _clearPendingStatus(userMessage.id);
      } else {
        appLog.w('[Chat] Skipping sync — tutor message has no content');
        _clearPendingStatus(userMessage.id);
      }
    } catch (e, st) {
      appLog.e('[Chat] sendMessage failed', error: e, stackTrace: st);
      final pallyError = PallyError.from(e);
      if (pallyError.kind == PallyErrorKind.unauthorized) {
        // Recoverable: remove the streaming placeholder so no broken bubble
        // appears, then surface the error as a toast via state.error.
        _removeStreamingMessage(streamId);
        state = state.copyWith(
          isTyping: false,
          isSending: false,
          error: pallyError.userMessage,
        );
        return;
      }
      _finaliseStreamingMessage(
        streamId,
        'Sorry, I had trouble answering that. Please try again!',
        [],
      );
      // Clear "pending" clock on user message — it was sent.
      _clearPendingStatus(userMessage.id);
      state = state.copyWith(
          isTyping: false,
          error: "Mochi couldn't reply. Please try again.");
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

    final photoSpan = ref.read(perfMonitorProvider).startSpan(
        'ai.photo.solve',
        operation: 'ai',
        description: 'POST /photo-question');
    photoSpan.setTag('route', 'photo.solve');
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

      final pendingLevel = (data['levelledUp'] == true)
          ? ((data['newLevel'] as num?)?.toInt() ?? 0)
          : 0;
      state = state.copyWith(
        messages: state.messages.map((m) {
          if (m.id == messageId) return resultMessage;
          return m;
        }).toList(),
        isProcessingPhoto: false,
        processingPhotoQuestions: const [],
        pendingLevelUp:
            pendingLevel > 0 ? pendingLevel : state.pendingLevelUp,
      );
      photoSpan.setData('questions_answered', answers.length);
      photoSpan.finish(statusCode: 200);
    } on DioException catch (e, st) {
      photoSpan.finish(statusCode: 500);
      appLog.e('[Chat] Photo question solve failed',
          error: e, stackTrace: st);
      final isNetwork = e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown;
      final userFacingError = isNetwork
          ? 'No internet — reconnect and try again.'
          : "Mochi couldn't solve these questions. Try again!";
      // Remove the in-flight processing placeholder so the chat doesn't
      // get stuck showing a spinner, and surface the error via toast.
      state = state.copyWith(
        isProcessingPhoto: false,
        processingPhotoQuestions: const [],
        error: userFacingError,
        messages: state.messages.where((m) => m.id != messageId).toList(),
      );
    } catch (e, st) {
      photoSpan.finish(statusCode: 500);
      appLog.e('[Chat] Photo question unexpected error',
          error: e, stackTrace: st);
      state = state.copyWith(
        isProcessingPhoto: false,
        processingPhotoQuestions: const [],
        error: 'Something went wrong. Try again.',
        messages: state.messages.where((m) => m.id != messageId).toList(),
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
      guideAttempts: 0,
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

  // Updates Guide Me attempt counter and triggers hint ladder escape after 3 attempts
  void _trackGuideAttempt() {
    final attempts = state.guideAttempts + 1;
    final showEscape = attempts >= 3 && state.teachingMode == TeachingMode.teaching;
    state = state.copyWith(
      guideAttempts: attempts,
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
            'role': m.role == MessageRole.tutor ? 'ASSISTANT' : 'USER',
            'content': m.content,
            'sourceWikiSlug': m.sources.firstOrNull,
            'isPhotoMessage': m.messageType == MessageType.photo,
            'createdAt': (m.createdAt ?? DateTime.now()).toUtc().toIso8601String(),
          }).toList();
      await dio.post<void>(
        '/api/v1/avatars/$_avatarId/chat/sync',
        data: {'messages': syncDtos},
      );
      appLog.d('[Chat] Synced ${messages.length} messages to backend');

      // Mark synced + clear from retry queue
      for (final m in messages) {
        await _localDb.removePendingSync(m.id);
        final updated = m.copyWith(syncStatus: SyncStatus.synced);
        await _localDb.saveMessage(updated.toRecord());
      }
      _updateMessageStatuses(messages.map((m) => m.id).toSet(), SyncStatus.synced);
    } catch (e) {
      appLog.w('[Chat] Backend sync failed, queuing for retry: $e');
      for (final m in messages) {
        await _localDb.addPendingSync(m.id, _avatarId);
        final updated = m.copyWith(syncStatus: SyncStatus.failed);
        await _localDb.saveMessage(updated.toRecord());
      }
      _updateMessageStatuses(messages.map((m) => m.id).toSet(), SyncStatus.failed);
    }
  }

  /// Clears the "pending" (clock) indicator on a user-sent message when the
  /// stream fails. The user DID send their message — the failure is on the
  /// reply side. Marking it synced removes the misleading "still sending" UI.
  void _clearPendingStatus(String messageId) {
    final updated = state.messages.map((m) {
      if (m.id == messageId && m.syncStatus == SyncStatus.pending) {
        return m.copyWith(syncStatus: SyncStatus.synced);
      }
      return m;
    }).toList();
    state = state.copyWith(messages: updated);
  }

  void _updateMessageStatuses(Set<String> ids, SyncStatus status) {
    final updated = state.messages.map((m) {
      if (ids.contains(m.id)) return m.copyWith(syncStatus: status);
      return m;
    }).toList();
    state = state.copyWith(messages: updated);
  }

  /// Manually retry sync for a single failed message (called from UI).
  Future<void> retryMessage(String messageId) async {
    final msg = state.messages.firstWhere(
      (m) => m.id == messageId,
      orElse: () => streamingMessageStub('', _avatarId),
    );
    if (msg.id.isEmpty) return;
    _updateMessageStatuses({messageId}, SyncStatus.pending);
    await _syncMessagesToBackend([msg]);
  }

  Future<void> _syncFeedbackToBackend(
      String messageId, FeedbackType type) async {
    try {
      final dio = ref.read(dioProvider);
      await dio.post<void>(
        '/api/v1/avatars/$_avatarId/chat/$messageId/feedback',
        data: {'feedbackType': type.name.toUpperCase()},
      );
    } catch (e) {
      appLog.w('[Chat] Feedback sync failed: $e');
    }
  }

  Future<void> _streamResponse(String text, String streamId) async {
    final dio = ref.read(dioProvider);
    appLog.d('[Chat] Starting SSE stream for avatar $_avatarId');

    // ai.chat.send span: measures end-to-end Claude latency for this chat
    // route. Finished on EVERY exit (done / error event / empty / exception)
    // so it never leaks. Low-cardinality tags only — PDPA.
    final perf = ref.read(perfMonitorProvider);
    final span = perf.startSpan('ai.chat.send',
        operation: 'ai', description: 'POST /chat SSE');
    span.setTag('route', 'chat.send');
    span.setTag('mode', state.teachingMode == TeachingMode.teaching
        ? 'guide'
        : 'answer');

    try {
      final response = await dio.post<ResponseBody>(
        '/api/v1/avatars/$_avatarId/chat',
        data: ChatRequest(message: text).toJson(),
        options: Options(
          responseType: ResponseType.stream,
          headers: {'Accept': 'text/event-stream'},
          // Stream timeout: if no chunk for 30s, treat connection as dead.
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      final stream = response.data!.stream;
      final buffer = StringBuffer();
      final sources = <String>[];
      int tokenCount = 0;

      String currentEvent = '';
      final dataLines = <String>[];
      // 60s wall-clock cap: if the stream is silently half-open (no done,
      // no error, no chunks for >30s receive-timeout AND no close), we
      // resolve to the error+retry state rather than a permanent typing dot.
      await for (final chunk in stream.timeout(const Duration(seconds: 60),
          onTimeout: (sink) => sink.close())) {
        final raw = utf8.decode(chunk);
        for (final line in raw.split('\n')) {
          // SSE spec: lines starting with ':' are comments — skip explicitly.
          if (line.startsWith(':')) continue;
          if (line.startsWith('event: ')) {
            currentEvent = line.substring(7).trim();
          } else if (line.startsWith('data: ') || line.startsWith('data:')) {
            final data = line.startsWith('data: ')
                ? line.substring(6)
                : line.substring(5);
            dataLines.add(data);
          } else if (line.trim().isEmpty && dataLines.isNotEmpty) {
            final fullData = dataLines.join('\n');
            dataLines.clear();

            if (fullData == '[DONE]' || currentEvent == 'done') {
              // Done payload carries the wiki page slug per backend contract.
              if (currentEvent == 'done' &&
                  fullData.isNotEmpty &&
                  fullData != '[DONE]') {
                sources.add(fullData);
              }
              _finaliseStreamingMessage(
                  streamId, _stripSourceTrailer(buffer.toString()), sources);
              state = state.copyWith(isTyping: false);
              span.setData('chars_out', buffer.length);
              span.finish(statusCode: 200);
              return;
            }
            // Handle server-sent error events (e.g. moderation block,
            // internal server error after headers already flushed).
            if (currentEvent == 'error') {
              appLog.w('[Chat] Server sent error event: $fullData');
              _markStreamingMessageAsError(streamId, null);
              state = state.copyWith(isTyping: false);
              span.finish(statusCode: 500);
              return;
            }
            // SSE comment lines (": connected") — skip silently.
            if (fullData.isEmpty) {
              currentEvent = '';
              continue;
            }
            if (currentEvent == 'delta' || currentEvent.isEmpty) {
              try {
                final json = jsonDecode(fullData) as Map<String, dynamic>;
                final text = json['text'] as String? ?? fullData;
                buffer.write(text);
              } catch (_) {
                buffer.write(fullData);
              }
              _updateStreamingMessage(streamId, buffer.toString());

              // Periodically persist partial response so it survives
              // app crashes / network drops mid-stream.
              tokenCount++;
              if (tokenCount % 20 == 0) {
                final current = state.messages.firstWhere(
                  (m) => m.id == streamId,
                  orElse: () => streamingMessageStub(streamId, _avatarId),
                );
                unawaited(_localDb.saveMessage(
                  current.copyWith(content: buffer.toString()).toRecord(),
                ));
              }
            }
            currentEvent = '';
          }
        }
      }

      if (dataLines.isNotEmpty) {
        final fullData = dataLines.join('\n');
        if (currentEvent == 'done' || fullData == '[DONE]') {
          if (currentEvent == 'done' &&
              fullData.isNotEmpty &&
              fullData != '[DONE]') {
            sources.add(fullData);
          }
          _finaliseStreamingMessage(
              streamId, _stripSourceTrailer(buffer.toString()), sources);
        } else if (currentEvent == 'delta' || currentEvent.isEmpty) {
          try {
            final json = jsonDecode(fullData) as Map<String, dynamic>;
            buffer.write(json['text'] as String? ?? fullData);
          } catch (_) {
            buffer.write(fullData);
          }
          _updateStreamingMessage(streamId, buffer.toString());
        }
      }

      appLog.i('[Chat] Stream ended, chars=${buffer.length}');
      // If the stream closed without ANY content, treat it as a failure.
      if (buffer.isEmpty) {
        appLog.w('[Chat] Stream ended with 0 chars — treating as server error');
        _markStreamingMessageAsError(streamId, null);
        state = state.copyWith(isTyping: false);
        span.finish(statusCode: 500);
        return;
      }
      _finaliseStreamingMessage(
          streamId, _stripSourceTrailer(buffer.toString()), sources);
      state = state.copyWith(isTyping: false);
      span.setData('chars_out', buffer.length);
      span.finish(statusCode: 200);
    } on DioException catch (e, st) {
      // SSE requests use ResponseType.stream — Dio never decodes the body
      // even when the server returns JSON (e.g. the consent 403). Read the
      // raw bytes to check for the consent code so we can show the user
      // a clear error with a tap-to-retry CTA that re-triggers the consent
      // disclosure screen (via the interceptor on the next attempt).
      if (e.type == DioExceptionType.badResponse &&
          e.response?.statusCode == 403 &&
          e.response?.data is ResponseBody) {
        try {
          final rb = e.response!.data as ResponseBody;
          final bytes = await rb.stream.expand((c) => c).toList();
          final decoded = jsonDecode(utf8.decode(bytes));
          if (decoded is Map && decoded['data'] is Map) {
            final data = decoded['data'] as Map;
            final code = data['code'] as String?;
            if (code == 'PARENTAL_CONSENT_PENDING') {
              appLog.w('[Chat] Parental consent pending for SSE stream');
              _markStreamingMessageWithText(
                streamId,
                'Your account is waiting for a grown-up to approve it. '
                'Ask them to check their email.',
              );
              final masked = data['parentEmailMasked']?.toString();
              final secs = data['resendAvailableInSeconds'];
              final ctx =
                  ref.read(globalNavigatorKeyProvider)?.currentContext;
              if (ctx != null && ctx.mounted) {
                showParentalConsentPendingSheet(
                  context: ctx,
                  ref: ref,
                  maskedEmail: (masked == null || masked.isEmpty)
                      ? 'your grown-up'
                      : masked,
                  cooldownSeconds: secs is num ? secs.toInt() : 0,
                );
              }
              span.finish(statusCode: 403);
              return;
            }
            if (code == 'AI_CONSENT_REQUIRED' || code == 'CONSENT_REQUIRED') {
              appLog.w('[Chat] Consent required for SSE stream (under-13 gate)');
              _markStreamingMessageWithText(
                streamId,
                'Mochi needs your consent to chat. Tap to give consent.',
              );
              span.finish(statusCode: 403);
              return;
            }
          }
        } catch (_) {}
      }
      appLog.w('[Chat] SSE stream failed', error: e, stackTrace: st);
      _markStreamingMessageAsError(streamId, e);
      span.finish(statusCode: e.type == DioExceptionType.receiveTimeout ? 408 : 500);
    } catch (e, st) {
      appLog.e('[Chat] SSE unexpected error', error: e, stackTrace: st);
      _markStreamingMessageAsError(streamId, null);
      span.finish(statusCode: 500);
    }
  }

  /// Converts the in-flight streaming placeholder into an inline retry pill.
  /// Replaces the previous behaviour of streaming a hardcoded
  /// "Great question!" stub when the backend was unreachable — which
  /// silently deceived users into thinking the AI responded.
  void _markStreamingMessageAsError(String streamId, DioException? e) {
    final isNetwork = e != null &&
        (e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.unknown);
    final msg = isNetwork
        ? 'No internet connection. Tap to retry.'
        : 'Something went wrong. Tap to retry.';
    final updated = state.messages.map((m) {
      if (m.id != streamId) return m;
      return m.copyWith(
        content: msg,
        isStreaming: false,
        isError: true,
        error: msg,
      );
    }).toList();
    state = state.copyWith(messages: updated, isTyping: false);
  }

  void _markStreamingMessageWithText(String streamId, String msg) {
    final updated = state.messages.map((m) {
      if (m.id != streamId) return m;
      return m.copyWith(
        content: msg,
        isStreaming: false,
        isError: true,
        error: msg,
      );
    }).toList();
    state = state.copyWith(messages: updated, isTyping: false);
  }

  void _updateStreamingMessage(String id, String content) {
    final updated = state.messages.map((m) {
      if (m.id == id) return m.copyWith(content: content);
      return m;
    }).toList();
    state = state.copyWith(messages: updated);
  }

  // Defensive client-side strip — backend already removes the SOURCE trailer
  // before persisting, but a partial stream (e.g. dropped final SSE frame)
  // could leak it into the rendered bubble. Belt-and-braces.
  static final RegExp _sourceTrailerPattern = RegExp(
      r'\s*\n*SOURCE\s*:?\s*\[?[a-zA-Z0-9_\-/]+\]?\s*$');

  String _stripSourceTrailer(String content) =>
      content.replaceFirst(_sourceTrailerPattern, '').trimRight();

  void _removeStreamingMessage(String id) {
    state = state.copyWith(
      messages: state.messages.where((m) => m.id != id).toList(),
    );
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
