import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pally_database.g.dart';

// ── Chat messages ─────────────────────────────────────────────────────────────

@DataClassName('ChatMessageRecord')
class ChatMessages extends Table {
  TextColumn get id => text()();
  TextColumn get avatarId => text()();
  TextColumn get role => text()(); // 'user' or 'tutor'
  TextColumn get content => text()();
  TextColumn get messageType =>
      text().withDefault(const Constant('text'))(); // 'text'|'photo'|'homeworkResult'
  TextColumn get sourceWikiSlug => text().nullable()();
  TextColumn get feedbackType => text().nullable()(); // 'helpful'|'wrong'|'confused'|'saveToBrain'
  BoolColumn get savedToBrain =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get isPhotoMessage =>
      boolean().withDefault(const Constant(false))();
  TextColumn get photoPath => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// ── Session states ────────────────────────────────────────────────────────────

@DataClassName('SessionStateRecord')
class SessionStates extends Table {
  TextColumn get id => text()();
  TextColumn get avatarId => text()();
  DateTimeColumn get sessionDate => dateTime()();
  TextColumn get topicsCovered =>
      text().withDefault(const Constant('[]'))();
  TextColumn get conceptsMastered =>
      text().withDefault(const Constant('[]'))();
  TextColumn get lastStruggle => text().nullable()();
  IntColumn get questionsAsked =>
      integer().withDefault(const Constant(0))();
  TextColumn get lastTopicSlug => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// ── Scroll positions ──────────────────────────────────────────────────────────

@DataClassName('ChatScrollRecord')
class ChatScrollPositions extends Table {
  TextColumn get avatarId => text()();
  RealColumn get scrollOffset =>
      real().withDefault(const Constant(0.0))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {avatarId};
}

// ── Database ──────────────────────────────────────────────────────────────────

@DriftDatabase(
    tables: [ChatMessages, SessionStates, ChatScrollPositions])
class PallyDatabase extends _$PallyDatabase {
  PallyDatabase() : super(_openConnection());
  PallyDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'pally.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

// ── Provider ──────────────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
PallyDatabase pallyDatabase(Ref ref) {
  final db = PallyDatabase();
  ref.onDispose(db.close);
  return db;
}
