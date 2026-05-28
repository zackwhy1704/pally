import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/core/local_db/pally_database.dart';
import 'package:pally/shared/models/chat_message.dart';
import 'package:pally/shared/models/session_state.dart';
import 'package:pally/features/chat/data/local/chat_message_mapper.dart';

part 'chat_local_data_source.g.dart';

@Riverpod(keepAlive: true)
ChatLocalDataSource chatLocalDataSource(Ref ref) =>
    ChatLocalDataSource(ref.watch(pallyDatabaseProvider));

class ChatLocalDataSource {
  ChatLocalDataSource(this._db);
  final PallyDatabase _db;

  // ── Messages ──────────────────────────────────────────────────────

  Future<List<ChatMessage>> loadRecentMessages(String avatarId,
      {int limit = 50}) async {
    final rows = await (_db.select(_db.chatMessages)
          ..where((t) => t.avatarId.equals(avatarId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(limit))
        .get();
    return rows.reversed.map(ChatMessageMapper.fromRecord).toList();
  }

  Future<void> saveMessage(ChatMessageRecord record) async {
    await _db.into(_db.chatMessages).insertOnConflictUpdate(record);
  }

  Future<void> updateFeedback(String messageId, String feedbackType) async {
    await (_db.update(_db.chatMessages)
          ..where((t) => t.id.equals(messageId)))
        .write(ChatMessagesCompanion(
          feedbackType: Value(feedbackType),
        ));
  }

  Future<void> markSavedToBrain(String messageId) async {
    await (_db.update(_db.chatMessages)
          ..where((t) => t.id.equals(messageId)))
        .write(const ChatMessagesCompanion(
          savedToBrain: Value(true),
        ));
  }

  // ── Pruning ───────────────────────────────────────────────────────

  Future<int> pruneOldMessages(String avatarId, {int days = 90}) async {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return (_db.delete(_db.chatMessages)
          ..where((t) =>
              t.avatarId.equals(avatarId) &
              t.createdAt.isSmallerThanValue(cutoff)))
        .go();
  }

  Future<int> pruneExcessMessages(String avatarId,
      {int maxMessages = 500, int deleteCount = 200}) async {
    final all = await (_db.select(_db.chatMessages)
          ..where((t) => t.avatarId.equals(avatarId)))
        .get();

    if (all.length <= maxMessages) return 0;

    final oldest = await (_db.select(_db.chatMessages)
          ..where((t) => t.avatarId.equals(avatarId))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
          ..limit(deleteCount))
        .get();

    return (_db.delete(_db.chatMessages)
          ..where((t) =>
              t.id.isIn(oldest.map((r) => r.id).toList())))
        .go();
  }

  // ── Session state ─────────────────────────────────────────────────

  Future<SessionState?> getTodaySession(String avatarId) async {
    final today = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final row = await (_db.select(_db.sessionStates)
          ..where((t) =>
              t.avatarId.equals(avatarId) &
              t.sessionDate.isBiggerOrEqualValue(today))
          ..orderBy([(t) => OrderingTerm.desc(t.sessionDate)])
          ..limit(1))
        .getSingleOrNull();
    return row != null ? SessionState.fromRecord(row) : null;
  }

  Future<void> saveSessionState(SessionStateRecord record) async {
    await _db.into(_db.sessionStates).insertOnConflictUpdate(record);
  }

  // ── Scroll position ───────────────────────────────────────────────

  Future<double> getScrollOffset(String avatarId) async {
    final row = await (_db.select(_db.chatScrollPositions)
          ..where((t) => t.avatarId.equals(avatarId)))
        .getSingleOrNull();
    return row?.scrollOffset ?? 0.0;
  }

  Future<void> saveScrollOffset(String avatarId, double offset) async {
    await _db.into(_db.chatScrollPositions).insertOnConflictUpdate(
          ChatScrollPositionsCompanion.insert(
            avatarId: avatarId,
            scrollOffset: Value(offset),
            updatedAt: DateTime.now(),
          ),
        );
  }

  // ── Pending sync queue ────────────────────────────────────────────

  Future<void> addPendingSync(String messageId, String avatarId) async {
    await _db.into(_db.pendingSyncs).insertOnConflictUpdate(
          PendingSyncsCompanion.insert(
            messageId: messageId,
            avatarId: avatarId,
            queuedAt: DateTime.now(),
          ),
        );
  }

  Future<void> removePendingSync(String messageId) async {
    await (_db.delete(_db.pendingSyncs)
          ..where((t) => t.messageId.equals(messageId)))
        .go();
  }

  Future<List<PendingSyncRecord>> getPendingSyncs(String avatarId) async {
    return (_db.select(_db.pendingSyncs)
          ..where((t) => t.avatarId.equals(avatarId))
          ..orderBy([(t) => OrderingTerm.asc(t.queuedAt)]))
        .get();
  }

  Future<ChatMessage?> getMessage(String messageId) async {
    final row = await (_db.select(_db.chatMessages)
          ..where((t) => t.id.equals(messageId))
          ..limit(1))
        .getSingleOrNull();
    return row != null ? ChatMessageMapper.fromRecord(row) : null;
  }

  // ── Avatar deletion cleanup ───────────────────────────────────────

  /// Removes all local rows belonging to [avatarId]: messages, session
  /// state, scroll position, and pending sync queue entries.
  Future<void> deleteAllForAvatar(String avatarId) async {
    await (_db.delete(_db.chatMessages)
          ..where((t) => t.avatarId.equals(avatarId)))
        .go();
    await (_db.delete(_db.sessionStates)
          ..where((t) => t.avatarId.equals(avatarId)))
        .go();
    await (_db.delete(_db.chatScrollPositions)
          ..where((t) => t.avatarId.equals(avatarId)))
        .go();
    await (_db.delete(_db.pendingSyncs)
          ..where((t) => t.avatarId.equals(avatarId)))
        .go();
  }
}
