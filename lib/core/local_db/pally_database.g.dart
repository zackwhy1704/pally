// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pally_database.dart';

// ignore_for_file: type=lint
class $ChatMessagesTable extends ChatMessages
    with TableInfo<$ChatMessagesTable, ChatMessageRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _avatarIdMeta =
      const VerificationMeta('avatarId');
  @override
  late final GeneratedColumn<String> avatarId = GeneratedColumn<String>(
      'avatar_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _messageTypeMeta =
      const VerificationMeta('messageType');
  @override
  late final GeneratedColumn<String> messageType = GeneratedColumn<String>(
      'message_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('text'));
  static const VerificationMeta _sourceWikiSlugMeta =
      const VerificationMeta('sourceWikiSlug');
  @override
  late final GeneratedColumn<String> sourceWikiSlug = GeneratedColumn<String>(
      'source_wiki_slug', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _feedbackTypeMeta =
      const VerificationMeta('feedbackType');
  @override
  late final GeneratedColumn<String> feedbackType = GeneratedColumn<String>(
      'feedback_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _savedToBrainMeta =
      const VerificationMeta('savedToBrain');
  @override
  late final GeneratedColumn<bool> savedToBrain = GeneratedColumn<bool>(
      'saved_to_brain', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("saved_to_brain" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isPhotoMessageMeta =
      const VerificationMeta('isPhotoMessage');
  @override
  late final GeneratedColumn<bool> isPhotoMessage = GeneratedColumn<bool>(
      'is_photo_message', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_photo_message" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _photoPathMeta =
      const VerificationMeta('photoPath');
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
      'photo_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        avatarId,
        role,
        content,
        messageType,
        sourceWikiSlug,
        feedbackType,
        savedToBrain,
        isPhotoMessage,
        photoPath,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_messages';
  @override
  VerificationContext validateIntegrity(Insertable<ChatMessageRecord> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('avatar_id')) {
      context.handle(_avatarIdMeta,
          avatarId.isAcceptableOrUnknown(data['avatar_id']!, _avatarIdMeta));
    } else if (isInserting) {
      context.missing(_avatarIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('message_type')) {
      context.handle(
          _messageTypeMeta,
          messageType.isAcceptableOrUnknown(
              data['message_type']!, _messageTypeMeta));
    }
    if (data.containsKey('source_wiki_slug')) {
      context.handle(
          _sourceWikiSlugMeta,
          sourceWikiSlug.isAcceptableOrUnknown(
              data['source_wiki_slug']!, _sourceWikiSlugMeta));
    }
    if (data.containsKey('feedback_type')) {
      context.handle(
          _feedbackTypeMeta,
          feedbackType.isAcceptableOrUnknown(
              data['feedback_type']!, _feedbackTypeMeta));
    }
    if (data.containsKey('saved_to_brain')) {
      context.handle(
          _savedToBrainMeta,
          savedToBrain.isAcceptableOrUnknown(
              data['saved_to_brain']!, _savedToBrainMeta));
    }
    if (data.containsKey('is_photo_message')) {
      context.handle(
          _isPhotoMessageMeta,
          isPhotoMessage.isAcceptableOrUnknown(
              data['is_photo_message']!, _isPhotoMessageMeta));
    }
    if (data.containsKey('photo_path')) {
      context.handle(_photoPathMeta,
          photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatMessageRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatMessageRecord(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      avatarId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}avatar_id'])!,
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      messageType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}message_type'])!,
      sourceWikiSlug: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}source_wiki_slug']),
      feedbackType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}feedback_type']),
      savedToBrain: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}saved_to_brain'])!,
      isPhotoMessage: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_photo_message'])!,
      photoPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}photo_path']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ChatMessagesTable createAlias(String alias) {
    return $ChatMessagesTable(attachedDatabase, alias);
  }
}

class ChatMessageRecord extends DataClass
    implements Insertable<ChatMessageRecord> {
  final String id;
  final String avatarId;
  final String role;
  final String content;
  final String messageType;
  final String? sourceWikiSlug;
  final String? feedbackType;
  final bool savedToBrain;
  final bool isPhotoMessage;
  final String? photoPath;
  final DateTime createdAt;
  const ChatMessageRecord(
      {required this.id,
      required this.avatarId,
      required this.role,
      required this.content,
      required this.messageType,
      this.sourceWikiSlug,
      this.feedbackType,
      required this.savedToBrain,
      required this.isPhotoMessage,
      this.photoPath,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['avatar_id'] = Variable<String>(avatarId);
    map['role'] = Variable<String>(role);
    map['content'] = Variable<String>(content);
    map['message_type'] = Variable<String>(messageType);
    if (!nullToAbsent || sourceWikiSlug != null) {
      map['source_wiki_slug'] = Variable<String>(sourceWikiSlug);
    }
    if (!nullToAbsent || feedbackType != null) {
      map['feedback_type'] = Variable<String>(feedbackType);
    }
    map['saved_to_brain'] = Variable<bool>(savedToBrain);
    map['is_photo_message'] = Variable<bool>(isPhotoMessage);
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ChatMessagesCompanion toCompanion(bool nullToAbsent) {
    return ChatMessagesCompanion(
      id: Value(id),
      avatarId: Value(avatarId),
      role: Value(role),
      content: Value(content),
      messageType: Value(messageType),
      sourceWikiSlug: sourceWikiSlug == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceWikiSlug),
      feedbackType: feedbackType == null && nullToAbsent
          ? const Value.absent()
          : Value(feedbackType),
      savedToBrain: Value(savedToBrain),
      isPhotoMessage: Value(isPhotoMessage),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
      createdAt: Value(createdAt),
    );
  }

  factory ChatMessageRecord.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatMessageRecord(
      id: serializer.fromJson<String>(json['id']),
      avatarId: serializer.fromJson<String>(json['avatarId']),
      role: serializer.fromJson<String>(json['role']),
      content: serializer.fromJson<String>(json['content']),
      messageType: serializer.fromJson<String>(json['messageType']),
      sourceWikiSlug: serializer.fromJson<String?>(json['sourceWikiSlug']),
      feedbackType: serializer.fromJson<String?>(json['feedbackType']),
      savedToBrain: serializer.fromJson<bool>(json['savedToBrain']),
      isPhotoMessage: serializer.fromJson<bool>(json['isPhotoMessage']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'avatarId': serializer.toJson<String>(avatarId),
      'role': serializer.toJson<String>(role),
      'content': serializer.toJson<String>(content),
      'messageType': serializer.toJson<String>(messageType),
      'sourceWikiSlug': serializer.toJson<String?>(sourceWikiSlug),
      'feedbackType': serializer.toJson<String?>(feedbackType),
      'savedToBrain': serializer.toJson<bool>(savedToBrain),
      'isPhotoMessage': serializer.toJson<bool>(isPhotoMessage),
      'photoPath': serializer.toJson<String?>(photoPath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ChatMessageRecord copyWith(
          {String? id,
          String? avatarId,
          String? role,
          String? content,
          String? messageType,
          Value<String?> sourceWikiSlug = const Value.absent(),
          Value<String?> feedbackType = const Value.absent(),
          bool? savedToBrain,
          bool? isPhotoMessage,
          Value<String?> photoPath = const Value.absent(),
          DateTime? createdAt}) =>
      ChatMessageRecord(
        id: id ?? this.id,
        avatarId: avatarId ?? this.avatarId,
        role: role ?? this.role,
        content: content ?? this.content,
        messageType: messageType ?? this.messageType,
        sourceWikiSlug:
            sourceWikiSlug.present ? sourceWikiSlug.value : this.sourceWikiSlug,
        feedbackType:
            feedbackType.present ? feedbackType.value : this.feedbackType,
        savedToBrain: savedToBrain ?? this.savedToBrain,
        isPhotoMessage: isPhotoMessage ?? this.isPhotoMessage,
        photoPath: photoPath.present ? photoPath.value : this.photoPath,
        createdAt: createdAt ?? this.createdAt,
      );
  ChatMessageRecord copyWithCompanion(ChatMessagesCompanion data) {
    return ChatMessageRecord(
      id: data.id.present ? data.id.value : this.id,
      avatarId: data.avatarId.present ? data.avatarId.value : this.avatarId,
      role: data.role.present ? data.role.value : this.role,
      content: data.content.present ? data.content.value : this.content,
      messageType:
          data.messageType.present ? data.messageType.value : this.messageType,
      sourceWikiSlug: data.sourceWikiSlug.present
          ? data.sourceWikiSlug.value
          : this.sourceWikiSlug,
      feedbackType: data.feedbackType.present
          ? data.feedbackType.value
          : this.feedbackType,
      savedToBrain: data.savedToBrain.present
          ? data.savedToBrain.value
          : this.savedToBrain,
      isPhotoMessage: data.isPhotoMessage.present
          ? data.isPhotoMessage.value
          : this.isPhotoMessage,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessageRecord(')
          ..write('id: $id, ')
          ..write('avatarId: $avatarId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('messageType: $messageType, ')
          ..write('sourceWikiSlug: $sourceWikiSlug, ')
          ..write('feedbackType: $feedbackType, ')
          ..write('savedToBrain: $savedToBrain, ')
          ..write('isPhotoMessage: $isPhotoMessage, ')
          ..write('photoPath: $photoPath, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      avatarId,
      role,
      content,
      messageType,
      sourceWikiSlug,
      feedbackType,
      savedToBrain,
      isPhotoMessage,
      photoPath,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatMessageRecord &&
          other.id == this.id &&
          other.avatarId == this.avatarId &&
          other.role == this.role &&
          other.content == this.content &&
          other.messageType == this.messageType &&
          other.sourceWikiSlug == this.sourceWikiSlug &&
          other.feedbackType == this.feedbackType &&
          other.savedToBrain == this.savedToBrain &&
          other.isPhotoMessage == this.isPhotoMessage &&
          other.photoPath == this.photoPath &&
          other.createdAt == this.createdAt);
}

class ChatMessagesCompanion extends UpdateCompanion<ChatMessageRecord> {
  final Value<String> id;
  final Value<String> avatarId;
  final Value<String> role;
  final Value<String> content;
  final Value<String> messageType;
  final Value<String?> sourceWikiSlug;
  final Value<String?> feedbackType;
  final Value<bool> savedToBrain;
  final Value<bool> isPhotoMessage;
  final Value<String?> photoPath;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ChatMessagesCompanion({
    this.id = const Value.absent(),
    this.avatarId = const Value.absent(),
    this.role = const Value.absent(),
    this.content = const Value.absent(),
    this.messageType = const Value.absent(),
    this.sourceWikiSlug = const Value.absent(),
    this.feedbackType = const Value.absent(),
    this.savedToBrain = const Value.absent(),
    this.isPhotoMessage = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChatMessagesCompanion.insert({
    required String id,
    required String avatarId,
    required String role,
    required String content,
    this.messageType = const Value.absent(),
    this.sourceWikiSlug = const Value.absent(),
    this.feedbackType = const Value.absent(),
    this.savedToBrain = const Value.absent(),
    this.isPhotoMessage = const Value.absent(),
    this.photoPath = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        avatarId = Value(avatarId),
        role = Value(role),
        content = Value(content),
        createdAt = Value(createdAt);
  static Insertable<ChatMessageRecord> custom({
    Expression<String>? id,
    Expression<String>? avatarId,
    Expression<String>? role,
    Expression<String>? content,
    Expression<String>? messageType,
    Expression<String>? sourceWikiSlug,
    Expression<String>? feedbackType,
    Expression<bool>? savedToBrain,
    Expression<bool>? isPhotoMessage,
    Expression<String>? photoPath,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (avatarId != null) 'avatar_id': avatarId,
      if (role != null) 'role': role,
      if (content != null) 'content': content,
      if (messageType != null) 'message_type': messageType,
      if (sourceWikiSlug != null) 'source_wiki_slug': sourceWikiSlug,
      if (feedbackType != null) 'feedback_type': feedbackType,
      if (savedToBrain != null) 'saved_to_brain': savedToBrain,
      if (isPhotoMessage != null) 'is_photo_message': isPhotoMessage,
      if (photoPath != null) 'photo_path': photoPath,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChatMessagesCompanion copyWith(
      {Value<String>? id,
      Value<String>? avatarId,
      Value<String>? role,
      Value<String>? content,
      Value<String>? messageType,
      Value<String?>? sourceWikiSlug,
      Value<String?>? feedbackType,
      Value<bool>? savedToBrain,
      Value<bool>? isPhotoMessage,
      Value<String?>? photoPath,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return ChatMessagesCompanion(
      id: id ?? this.id,
      avatarId: avatarId ?? this.avatarId,
      role: role ?? this.role,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      sourceWikiSlug: sourceWikiSlug ?? this.sourceWikiSlug,
      feedbackType: feedbackType ?? this.feedbackType,
      savedToBrain: savedToBrain ?? this.savedToBrain,
      isPhotoMessage: isPhotoMessage ?? this.isPhotoMessage,
      photoPath: photoPath ?? this.photoPath,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (avatarId.present) {
      map['avatar_id'] = Variable<String>(avatarId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (messageType.present) {
      map['message_type'] = Variable<String>(messageType.value);
    }
    if (sourceWikiSlug.present) {
      map['source_wiki_slug'] = Variable<String>(sourceWikiSlug.value);
    }
    if (feedbackType.present) {
      map['feedback_type'] = Variable<String>(feedbackType.value);
    }
    if (savedToBrain.present) {
      map['saved_to_brain'] = Variable<bool>(savedToBrain.value);
    }
    if (isPhotoMessage.present) {
      map['is_photo_message'] = Variable<bool>(isPhotoMessage.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessagesCompanion(')
          ..write('id: $id, ')
          ..write('avatarId: $avatarId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('messageType: $messageType, ')
          ..write('sourceWikiSlug: $sourceWikiSlug, ')
          ..write('feedbackType: $feedbackType, ')
          ..write('savedToBrain: $savedToBrain, ')
          ..write('isPhotoMessage: $isPhotoMessage, ')
          ..write('photoPath: $photoPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionStatesTable extends SessionStates
    with TableInfo<$SessionStatesTable, SessionStateRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _avatarIdMeta =
      const VerificationMeta('avatarId');
  @override
  late final GeneratedColumn<String> avatarId = GeneratedColumn<String>(
      'avatar_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sessionDateMeta =
      const VerificationMeta('sessionDate');
  @override
  late final GeneratedColumn<DateTime> sessionDate = GeneratedColumn<DateTime>(
      'session_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _topicsCoveredMeta =
      const VerificationMeta('topicsCovered');
  @override
  late final GeneratedColumn<String> topicsCovered = GeneratedColumn<String>(
      'topics_covered', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _conceptsMasteredMeta =
      const VerificationMeta('conceptsMastered');
  @override
  late final GeneratedColumn<String> conceptsMastered = GeneratedColumn<String>(
      'concepts_mastered', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _lastStruggleMeta =
      const VerificationMeta('lastStruggle');
  @override
  late final GeneratedColumn<String> lastStruggle = GeneratedColumn<String>(
      'last_struggle', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _questionsAskedMeta =
      const VerificationMeta('questionsAsked');
  @override
  late final GeneratedColumn<int> questionsAsked = GeneratedColumn<int>(
      'questions_asked', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastTopicSlugMeta =
      const VerificationMeta('lastTopicSlug');
  @override
  late final GeneratedColumn<String> lastTopicSlug = GeneratedColumn<String>(
      'last_topic_slug', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        avatarId,
        sessionDate,
        topicsCovered,
        conceptsMastered,
        lastStruggle,
        questionsAsked,
        lastTopicSlug,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_states';
  @override
  VerificationContext validateIntegrity(Insertable<SessionStateRecord> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('avatar_id')) {
      context.handle(_avatarIdMeta,
          avatarId.isAcceptableOrUnknown(data['avatar_id']!, _avatarIdMeta));
    } else if (isInserting) {
      context.missing(_avatarIdMeta);
    }
    if (data.containsKey('session_date')) {
      context.handle(
          _sessionDateMeta,
          sessionDate.isAcceptableOrUnknown(
              data['session_date']!, _sessionDateMeta));
    } else if (isInserting) {
      context.missing(_sessionDateMeta);
    }
    if (data.containsKey('topics_covered')) {
      context.handle(
          _topicsCoveredMeta,
          topicsCovered.isAcceptableOrUnknown(
              data['topics_covered']!, _topicsCoveredMeta));
    }
    if (data.containsKey('concepts_mastered')) {
      context.handle(
          _conceptsMasteredMeta,
          conceptsMastered.isAcceptableOrUnknown(
              data['concepts_mastered']!, _conceptsMasteredMeta));
    }
    if (data.containsKey('last_struggle')) {
      context.handle(
          _lastStruggleMeta,
          lastStruggle.isAcceptableOrUnknown(
              data['last_struggle']!, _lastStruggleMeta));
    }
    if (data.containsKey('questions_asked')) {
      context.handle(
          _questionsAskedMeta,
          questionsAsked.isAcceptableOrUnknown(
              data['questions_asked']!, _questionsAskedMeta));
    }
    if (data.containsKey('last_topic_slug')) {
      context.handle(
          _lastTopicSlugMeta,
          lastTopicSlug.isAcceptableOrUnknown(
              data['last_topic_slug']!, _lastTopicSlugMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionStateRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionStateRecord(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      avatarId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}avatar_id'])!,
      sessionDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}session_date'])!,
      topicsCovered: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}topics_covered'])!,
      conceptsMastered: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}concepts_mastered'])!,
      lastStruggle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_struggle']),
      questionsAsked: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}questions_asked'])!,
      lastTopicSlug: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_topic_slug']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $SessionStatesTable createAlias(String alias) {
    return $SessionStatesTable(attachedDatabase, alias);
  }
}

class SessionStateRecord extends DataClass
    implements Insertable<SessionStateRecord> {
  final String id;
  final String avatarId;
  final DateTime sessionDate;
  final String topicsCovered;
  final String conceptsMastered;
  final String? lastStruggle;
  final int questionsAsked;
  final String? lastTopicSlug;
  final DateTime updatedAt;
  const SessionStateRecord(
      {required this.id,
      required this.avatarId,
      required this.sessionDate,
      required this.topicsCovered,
      required this.conceptsMastered,
      this.lastStruggle,
      required this.questionsAsked,
      this.lastTopicSlug,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['avatar_id'] = Variable<String>(avatarId);
    map['session_date'] = Variable<DateTime>(sessionDate);
    map['topics_covered'] = Variable<String>(topicsCovered);
    map['concepts_mastered'] = Variable<String>(conceptsMastered);
    if (!nullToAbsent || lastStruggle != null) {
      map['last_struggle'] = Variable<String>(lastStruggle);
    }
    map['questions_asked'] = Variable<int>(questionsAsked);
    if (!nullToAbsent || lastTopicSlug != null) {
      map['last_topic_slug'] = Variable<String>(lastTopicSlug);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SessionStatesCompanion toCompanion(bool nullToAbsent) {
    return SessionStatesCompanion(
      id: Value(id),
      avatarId: Value(avatarId),
      sessionDate: Value(sessionDate),
      topicsCovered: Value(topicsCovered),
      conceptsMastered: Value(conceptsMastered),
      lastStruggle: lastStruggle == null && nullToAbsent
          ? const Value.absent()
          : Value(lastStruggle),
      questionsAsked: Value(questionsAsked),
      lastTopicSlug: lastTopicSlug == null && nullToAbsent
          ? const Value.absent()
          : Value(lastTopicSlug),
      updatedAt: Value(updatedAt),
    );
  }

  factory SessionStateRecord.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionStateRecord(
      id: serializer.fromJson<String>(json['id']),
      avatarId: serializer.fromJson<String>(json['avatarId']),
      sessionDate: serializer.fromJson<DateTime>(json['sessionDate']),
      topicsCovered: serializer.fromJson<String>(json['topicsCovered']),
      conceptsMastered: serializer.fromJson<String>(json['conceptsMastered']),
      lastStruggle: serializer.fromJson<String?>(json['lastStruggle']),
      questionsAsked: serializer.fromJson<int>(json['questionsAsked']),
      lastTopicSlug: serializer.fromJson<String?>(json['lastTopicSlug']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'avatarId': serializer.toJson<String>(avatarId),
      'sessionDate': serializer.toJson<DateTime>(sessionDate),
      'topicsCovered': serializer.toJson<String>(topicsCovered),
      'conceptsMastered': serializer.toJson<String>(conceptsMastered),
      'lastStruggle': serializer.toJson<String?>(lastStruggle),
      'questionsAsked': serializer.toJson<int>(questionsAsked),
      'lastTopicSlug': serializer.toJson<String?>(lastTopicSlug),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SessionStateRecord copyWith(
          {String? id,
          String? avatarId,
          DateTime? sessionDate,
          String? topicsCovered,
          String? conceptsMastered,
          Value<String?> lastStruggle = const Value.absent(),
          int? questionsAsked,
          Value<String?> lastTopicSlug = const Value.absent(),
          DateTime? updatedAt}) =>
      SessionStateRecord(
        id: id ?? this.id,
        avatarId: avatarId ?? this.avatarId,
        sessionDate: sessionDate ?? this.sessionDate,
        topicsCovered: topicsCovered ?? this.topicsCovered,
        conceptsMastered: conceptsMastered ?? this.conceptsMastered,
        lastStruggle:
            lastStruggle.present ? lastStruggle.value : this.lastStruggle,
        questionsAsked: questionsAsked ?? this.questionsAsked,
        lastTopicSlug:
            lastTopicSlug.present ? lastTopicSlug.value : this.lastTopicSlug,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  SessionStateRecord copyWithCompanion(SessionStatesCompanion data) {
    return SessionStateRecord(
      id: data.id.present ? data.id.value : this.id,
      avatarId: data.avatarId.present ? data.avatarId.value : this.avatarId,
      sessionDate:
          data.sessionDate.present ? data.sessionDate.value : this.sessionDate,
      topicsCovered: data.topicsCovered.present
          ? data.topicsCovered.value
          : this.topicsCovered,
      conceptsMastered: data.conceptsMastered.present
          ? data.conceptsMastered.value
          : this.conceptsMastered,
      lastStruggle: data.lastStruggle.present
          ? data.lastStruggle.value
          : this.lastStruggle,
      questionsAsked: data.questionsAsked.present
          ? data.questionsAsked.value
          : this.questionsAsked,
      lastTopicSlug: data.lastTopicSlug.present
          ? data.lastTopicSlug.value
          : this.lastTopicSlug,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionStateRecord(')
          ..write('id: $id, ')
          ..write('avatarId: $avatarId, ')
          ..write('sessionDate: $sessionDate, ')
          ..write('topicsCovered: $topicsCovered, ')
          ..write('conceptsMastered: $conceptsMastered, ')
          ..write('lastStruggle: $lastStruggle, ')
          ..write('questionsAsked: $questionsAsked, ')
          ..write('lastTopicSlug: $lastTopicSlug, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, avatarId, sessionDate, topicsCovered,
      conceptsMastered, lastStruggle, questionsAsked, lastTopicSlug, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionStateRecord &&
          other.id == this.id &&
          other.avatarId == this.avatarId &&
          other.sessionDate == this.sessionDate &&
          other.topicsCovered == this.topicsCovered &&
          other.conceptsMastered == this.conceptsMastered &&
          other.lastStruggle == this.lastStruggle &&
          other.questionsAsked == this.questionsAsked &&
          other.lastTopicSlug == this.lastTopicSlug &&
          other.updatedAt == this.updatedAt);
}

class SessionStatesCompanion extends UpdateCompanion<SessionStateRecord> {
  final Value<String> id;
  final Value<String> avatarId;
  final Value<DateTime> sessionDate;
  final Value<String> topicsCovered;
  final Value<String> conceptsMastered;
  final Value<String?> lastStruggle;
  final Value<int> questionsAsked;
  final Value<String?> lastTopicSlug;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SessionStatesCompanion({
    this.id = const Value.absent(),
    this.avatarId = const Value.absent(),
    this.sessionDate = const Value.absent(),
    this.topicsCovered = const Value.absent(),
    this.conceptsMastered = const Value.absent(),
    this.lastStruggle = const Value.absent(),
    this.questionsAsked = const Value.absent(),
    this.lastTopicSlug = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionStatesCompanion.insert({
    required String id,
    required String avatarId,
    required DateTime sessionDate,
    this.topicsCovered = const Value.absent(),
    this.conceptsMastered = const Value.absent(),
    this.lastStruggle = const Value.absent(),
    this.questionsAsked = const Value.absent(),
    this.lastTopicSlug = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        avatarId = Value(avatarId),
        sessionDate = Value(sessionDate),
        updatedAt = Value(updatedAt);
  static Insertable<SessionStateRecord> custom({
    Expression<String>? id,
    Expression<String>? avatarId,
    Expression<DateTime>? sessionDate,
    Expression<String>? topicsCovered,
    Expression<String>? conceptsMastered,
    Expression<String>? lastStruggle,
    Expression<int>? questionsAsked,
    Expression<String>? lastTopicSlug,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (avatarId != null) 'avatar_id': avatarId,
      if (sessionDate != null) 'session_date': sessionDate,
      if (topicsCovered != null) 'topics_covered': topicsCovered,
      if (conceptsMastered != null) 'concepts_mastered': conceptsMastered,
      if (lastStruggle != null) 'last_struggle': lastStruggle,
      if (questionsAsked != null) 'questions_asked': questionsAsked,
      if (lastTopicSlug != null) 'last_topic_slug': lastTopicSlug,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionStatesCompanion copyWith(
      {Value<String>? id,
      Value<String>? avatarId,
      Value<DateTime>? sessionDate,
      Value<String>? topicsCovered,
      Value<String>? conceptsMastered,
      Value<String?>? lastStruggle,
      Value<int>? questionsAsked,
      Value<String?>? lastTopicSlug,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return SessionStatesCompanion(
      id: id ?? this.id,
      avatarId: avatarId ?? this.avatarId,
      sessionDate: sessionDate ?? this.sessionDate,
      topicsCovered: topicsCovered ?? this.topicsCovered,
      conceptsMastered: conceptsMastered ?? this.conceptsMastered,
      lastStruggle: lastStruggle ?? this.lastStruggle,
      questionsAsked: questionsAsked ?? this.questionsAsked,
      lastTopicSlug: lastTopicSlug ?? this.lastTopicSlug,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (avatarId.present) {
      map['avatar_id'] = Variable<String>(avatarId.value);
    }
    if (sessionDate.present) {
      map['session_date'] = Variable<DateTime>(sessionDate.value);
    }
    if (topicsCovered.present) {
      map['topics_covered'] = Variable<String>(topicsCovered.value);
    }
    if (conceptsMastered.present) {
      map['concepts_mastered'] = Variable<String>(conceptsMastered.value);
    }
    if (lastStruggle.present) {
      map['last_struggle'] = Variable<String>(lastStruggle.value);
    }
    if (questionsAsked.present) {
      map['questions_asked'] = Variable<int>(questionsAsked.value);
    }
    if (lastTopicSlug.present) {
      map['last_topic_slug'] = Variable<String>(lastTopicSlug.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionStatesCompanion(')
          ..write('id: $id, ')
          ..write('avatarId: $avatarId, ')
          ..write('sessionDate: $sessionDate, ')
          ..write('topicsCovered: $topicsCovered, ')
          ..write('conceptsMastered: $conceptsMastered, ')
          ..write('lastStruggle: $lastStruggle, ')
          ..write('questionsAsked: $questionsAsked, ')
          ..write('lastTopicSlug: $lastTopicSlug, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChatScrollPositionsTable extends ChatScrollPositions
    with TableInfo<$ChatScrollPositionsTable, ChatScrollRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatScrollPositionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _avatarIdMeta =
      const VerificationMeta('avatarId');
  @override
  late final GeneratedColumn<String> avatarId = GeneratedColumn<String>(
      'avatar_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _scrollOffsetMeta =
      const VerificationMeta('scrollOffset');
  @override
  late final GeneratedColumn<double> scrollOffset = GeneratedColumn<double>(
      'scroll_offset', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [avatarId, scrollOffset, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_scroll_positions';
  @override
  VerificationContext validateIntegrity(Insertable<ChatScrollRecord> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('avatar_id')) {
      context.handle(_avatarIdMeta,
          avatarId.isAcceptableOrUnknown(data['avatar_id']!, _avatarIdMeta));
    } else if (isInserting) {
      context.missing(_avatarIdMeta);
    }
    if (data.containsKey('scroll_offset')) {
      context.handle(
          _scrollOffsetMeta,
          scrollOffset.isAcceptableOrUnknown(
              data['scroll_offset']!, _scrollOffsetMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {avatarId};
  @override
  ChatScrollRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatScrollRecord(
      avatarId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}avatar_id'])!,
      scrollOffset: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}scroll_offset'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ChatScrollPositionsTable createAlias(String alias) {
    return $ChatScrollPositionsTable(attachedDatabase, alias);
  }
}

class ChatScrollRecord extends DataClass
    implements Insertable<ChatScrollRecord> {
  final String avatarId;
  final double scrollOffset;
  final DateTime updatedAt;
  const ChatScrollRecord(
      {required this.avatarId,
      required this.scrollOffset,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['avatar_id'] = Variable<String>(avatarId);
    map['scroll_offset'] = Variable<double>(scrollOffset);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ChatScrollPositionsCompanion toCompanion(bool nullToAbsent) {
    return ChatScrollPositionsCompanion(
      avatarId: Value(avatarId),
      scrollOffset: Value(scrollOffset),
      updatedAt: Value(updatedAt),
    );
  }

  factory ChatScrollRecord.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatScrollRecord(
      avatarId: serializer.fromJson<String>(json['avatarId']),
      scrollOffset: serializer.fromJson<double>(json['scrollOffset']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'avatarId': serializer.toJson<String>(avatarId),
      'scrollOffset': serializer.toJson<double>(scrollOffset),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ChatScrollRecord copyWith(
          {String? avatarId, double? scrollOffset, DateTime? updatedAt}) =>
      ChatScrollRecord(
        avatarId: avatarId ?? this.avatarId,
        scrollOffset: scrollOffset ?? this.scrollOffset,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  ChatScrollRecord copyWithCompanion(ChatScrollPositionsCompanion data) {
    return ChatScrollRecord(
      avatarId: data.avatarId.present ? data.avatarId.value : this.avatarId,
      scrollOffset: data.scrollOffset.present
          ? data.scrollOffset.value
          : this.scrollOffset,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatScrollRecord(')
          ..write('avatarId: $avatarId, ')
          ..write('scrollOffset: $scrollOffset, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(avatarId, scrollOffset, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatScrollRecord &&
          other.avatarId == this.avatarId &&
          other.scrollOffset == this.scrollOffset &&
          other.updatedAt == this.updatedAt);
}

class ChatScrollPositionsCompanion extends UpdateCompanion<ChatScrollRecord> {
  final Value<String> avatarId;
  final Value<double> scrollOffset;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ChatScrollPositionsCompanion({
    this.avatarId = const Value.absent(),
    this.scrollOffset = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChatScrollPositionsCompanion.insert({
    required String avatarId,
    this.scrollOffset = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : avatarId = Value(avatarId),
        updatedAt = Value(updatedAt);
  static Insertable<ChatScrollRecord> custom({
    Expression<String>? avatarId,
    Expression<double>? scrollOffset,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (avatarId != null) 'avatar_id': avatarId,
      if (scrollOffset != null) 'scroll_offset': scrollOffset,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChatScrollPositionsCompanion copyWith(
      {Value<String>? avatarId,
      Value<double>? scrollOffset,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return ChatScrollPositionsCompanion(
      avatarId: avatarId ?? this.avatarId,
      scrollOffset: scrollOffset ?? this.scrollOffset,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (avatarId.present) {
      map['avatar_id'] = Variable<String>(avatarId.value);
    }
    if (scrollOffset.present) {
      map['scroll_offset'] = Variable<double>(scrollOffset.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatScrollPositionsCompanion(')
          ..write('avatarId: $avatarId, ')
          ..write('scrollOffset: $scrollOffset, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$PallyDatabase extends GeneratedDatabase {
  _$PallyDatabase(QueryExecutor e) : super(e);
  $PallyDatabaseManager get managers => $PallyDatabaseManager(this);
  late final $ChatMessagesTable chatMessages = $ChatMessagesTable(this);
  late final $SessionStatesTable sessionStates = $SessionStatesTable(this);
  late final $ChatScrollPositionsTable chatScrollPositions =
      $ChatScrollPositionsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [chatMessages, sessionStates, chatScrollPositions];
}

typedef $$ChatMessagesTableCreateCompanionBuilder = ChatMessagesCompanion
    Function({
  required String id,
  required String avatarId,
  required String role,
  required String content,
  Value<String> messageType,
  Value<String?> sourceWikiSlug,
  Value<String?> feedbackType,
  Value<bool> savedToBrain,
  Value<bool> isPhotoMessage,
  Value<String?> photoPath,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$ChatMessagesTableUpdateCompanionBuilder = ChatMessagesCompanion
    Function({
  Value<String> id,
  Value<String> avatarId,
  Value<String> role,
  Value<String> content,
  Value<String> messageType,
  Value<String?> sourceWikiSlug,
  Value<String?> feedbackType,
  Value<bool> savedToBrain,
  Value<bool> isPhotoMessage,
  Value<String?> photoPath,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$ChatMessagesTableFilterComposer
    extends Composer<_$PallyDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get avatarId => $composableBuilder(
      column: $table.avatarId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get messageType => $composableBuilder(
      column: $table.messageType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceWikiSlug => $composableBuilder(
      column: $table.sourceWikiSlug,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get feedbackType => $composableBuilder(
      column: $table.feedbackType, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get savedToBrain => $composableBuilder(
      column: $table.savedToBrain, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isPhotoMessage => $composableBuilder(
      column: $table.isPhotoMessage,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get photoPath => $composableBuilder(
      column: $table.photoPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$ChatMessagesTableOrderingComposer
    extends Composer<_$PallyDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get avatarId => $composableBuilder(
      column: $table.avatarId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get messageType => $composableBuilder(
      column: $table.messageType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceWikiSlug => $composableBuilder(
      column: $table.sourceWikiSlug,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get feedbackType => $composableBuilder(
      column: $table.feedbackType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get savedToBrain => $composableBuilder(
      column: $table.savedToBrain,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isPhotoMessage => $composableBuilder(
      column: $table.isPhotoMessage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get photoPath => $composableBuilder(
      column: $table.photoPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$ChatMessagesTableAnnotationComposer
    extends Composer<_$PallyDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get avatarId =>
      $composableBuilder(column: $table.avatarId, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get messageType => $composableBuilder(
      column: $table.messageType, builder: (column) => column);

  GeneratedColumn<String> get sourceWikiSlug => $composableBuilder(
      column: $table.sourceWikiSlug, builder: (column) => column);

  GeneratedColumn<String> get feedbackType => $composableBuilder(
      column: $table.feedbackType, builder: (column) => column);

  GeneratedColumn<bool> get savedToBrain => $composableBuilder(
      column: $table.savedToBrain, builder: (column) => column);

  GeneratedColumn<bool> get isPhotoMessage => $composableBuilder(
      column: $table.isPhotoMessage, builder: (column) => column);

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ChatMessagesTableTableManager extends RootTableManager<
    _$PallyDatabase,
    $ChatMessagesTable,
    ChatMessageRecord,
    $$ChatMessagesTableFilterComposer,
    $$ChatMessagesTableOrderingComposer,
    $$ChatMessagesTableAnnotationComposer,
    $$ChatMessagesTableCreateCompanionBuilder,
    $$ChatMessagesTableUpdateCompanionBuilder,
    (
      ChatMessageRecord,
      BaseReferences<_$PallyDatabase, $ChatMessagesTable, ChatMessageRecord>
    ),
    ChatMessageRecord,
    PrefetchHooks Function()> {
  $$ChatMessagesTableTableManager(_$PallyDatabase db, $ChatMessagesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatMessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> avatarId = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<String> messageType = const Value.absent(),
            Value<String?> sourceWikiSlug = const Value.absent(),
            Value<String?> feedbackType = const Value.absent(),
            Value<bool> savedToBrain = const Value.absent(),
            Value<bool> isPhotoMessage = const Value.absent(),
            Value<String?> photoPath = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ChatMessagesCompanion(
            id: id,
            avatarId: avatarId,
            role: role,
            content: content,
            messageType: messageType,
            sourceWikiSlug: sourceWikiSlug,
            feedbackType: feedbackType,
            savedToBrain: savedToBrain,
            isPhotoMessage: isPhotoMessage,
            photoPath: photoPath,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String avatarId,
            required String role,
            required String content,
            Value<String> messageType = const Value.absent(),
            Value<String?> sourceWikiSlug = const Value.absent(),
            Value<String?> feedbackType = const Value.absent(),
            Value<bool> savedToBrain = const Value.absent(),
            Value<bool> isPhotoMessage = const Value.absent(),
            Value<String?> photoPath = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ChatMessagesCompanion.insert(
            id: id,
            avatarId: avatarId,
            role: role,
            content: content,
            messageType: messageType,
            sourceWikiSlug: sourceWikiSlug,
            feedbackType: feedbackType,
            savedToBrain: savedToBrain,
            isPhotoMessage: isPhotoMessage,
            photoPath: photoPath,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ChatMessagesTableProcessedTableManager = ProcessedTableManager<
    _$PallyDatabase,
    $ChatMessagesTable,
    ChatMessageRecord,
    $$ChatMessagesTableFilterComposer,
    $$ChatMessagesTableOrderingComposer,
    $$ChatMessagesTableAnnotationComposer,
    $$ChatMessagesTableCreateCompanionBuilder,
    $$ChatMessagesTableUpdateCompanionBuilder,
    (
      ChatMessageRecord,
      BaseReferences<_$PallyDatabase, $ChatMessagesTable, ChatMessageRecord>
    ),
    ChatMessageRecord,
    PrefetchHooks Function()>;
typedef $$SessionStatesTableCreateCompanionBuilder = SessionStatesCompanion
    Function({
  required String id,
  required String avatarId,
  required DateTime sessionDate,
  Value<String> topicsCovered,
  Value<String> conceptsMastered,
  Value<String?> lastStruggle,
  Value<int> questionsAsked,
  Value<String?> lastTopicSlug,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$SessionStatesTableUpdateCompanionBuilder = SessionStatesCompanion
    Function({
  Value<String> id,
  Value<String> avatarId,
  Value<DateTime> sessionDate,
  Value<String> topicsCovered,
  Value<String> conceptsMastered,
  Value<String?> lastStruggle,
  Value<int> questionsAsked,
  Value<String?> lastTopicSlug,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$SessionStatesTableFilterComposer
    extends Composer<_$PallyDatabase, $SessionStatesTable> {
  $$SessionStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get avatarId => $composableBuilder(
      column: $table.avatarId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get sessionDate => $composableBuilder(
      column: $table.sessionDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get topicsCovered => $composableBuilder(
      column: $table.topicsCovered, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get conceptsMastered => $composableBuilder(
      column: $table.conceptsMastered,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastStruggle => $composableBuilder(
      column: $table.lastStruggle, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get questionsAsked => $composableBuilder(
      column: $table.questionsAsked,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastTopicSlug => $composableBuilder(
      column: $table.lastTopicSlug, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$SessionStatesTableOrderingComposer
    extends Composer<_$PallyDatabase, $SessionStatesTable> {
  $$SessionStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get avatarId => $composableBuilder(
      column: $table.avatarId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get sessionDate => $composableBuilder(
      column: $table.sessionDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get topicsCovered => $composableBuilder(
      column: $table.topicsCovered,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get conceptsMastered => $composableBuilder(
      column: $table.conceptsMastered,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastStruggle => $composableBuilder(
      column: $table.lastStruggle,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get questionsAsked => $composableBuilder(
      column: $table.questionsAsked,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastTopicSlug => $composableBuilder(
      column: $table.lastTopicSlug,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$SessionStatesTableAnnotationComposer
    extends Composer<_$PallyDatabase, $SessionStatesTable> {
  $$SessionStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get avatarId =>
      $composableBuilder(column: $table.avatarId, builder: (column) => column);

  GeneratedColumn<DateTime> get sessionDate => $composableBuilder(
      column: $table.sessionDate, builder: (column) => column);

  GeneratedColumn<String> get topicsCovered => $composableBuilder(
      column: $table.topicsCovered, builder: (column) => column);

  GeneratedColumn<String> get conceptsMastered => $composableBuilder(
      column: $table.conceptsMastered, builder: (column) => column);

  GeneratedColumn<String> get lastStruggle => $composableBuilder(
      column: $table.lastStruggle, builder: (column) => column);

  GeneratedColumn<int> get questionsAsked => $composableBuilder(
      column: $table.questionsAsked, builder: (column) => column);

  GeneratedColumn<String> get lastTopicSlug => $composableBuilder(
      column: $table.lastTopicSlug, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SessionStatesTableTableManager extends RootTableManager<
    _$PallyDatabase,
    $SessionStatesTable,
    SessionStateRecord,
    $$SessionStatesTableFilterComposer,
    $$SessionStatesTableOrderingComposer,
    $$SessionStatesTableAnnotationComposer,
    $$SessionStatesTableCreateCompanionBuilder,
    $$SessionStatesTableUpdateCompanionBuilder,
    (
      SessionStateRecord,
      BaseReferences<_$PallyDatabase, $SessionStatesTable, SessionStateRecord>
    ),
    SessionStateRecord,
    PrefetchHooks Function()> {
  $$SessionStatesTableTableManager(
      _$PallyDatabase db, $SessionStatesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> avatarId = const Value.absent(),
            Value<DateTime> sessionDate = const Value.absent(),
            Value<String> topicsCovered = const Value.absent(),
            Value<String> conceptsMastered = const Value.absent(),
            Value<String?> lastStruggle = const Value.absent(),
            Value<int> questionsAsked = const Value.absent(),
            Value<String?> lastTopicSlug = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SessionStatesCompanion(
            id: id,
            avatarId: avatarId,
            sessionDate: sessionDate,
            topicsCovered: topicsCovered,
            conceptsMastered: conceptsMastered,
            lastStruggle: lastStruggle,
            questionsAsked: questionsAsked,
            lastTopicSlug: lastTopicSlug,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String avatarId,
            required DateTime sessionDate,
            Value<String> topicsCovered = const Value.absent(),
            Value<String> conceptsMastered = const Value.absent(),
            Value<String?> lastStruggle = const Value.absent(),
            Value<int> questionsAsked = const Value.absent(),
            Value<String?> lastTopicSlug = const Value.absent(),
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              SessionStatesCompanion.insert(
            id: id,
            avatarId: avatarId,
            sessionDate: sessionDate,
            topicsCovered: topicsCovered,
            conceptsMastered: conceptsMastered,
            lastStruggle: lastStruggle,
            questionsAsked: questionsAsked,
            lastTopicSlug: lastTopicSlug,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SessionStatesTableProcessedTableManager = ProcessedTableManager<
    _$PallyDatabase,
    $SessionStatesTable,
    SessionStateRecord,
    $$SessionStatesTableFilterComposer,
    $$SessionStatesTableOrderingComposer,
    $$SessionStatesTableAnnotationComposer,
    $$SessionStatesTableCreateCompanionBuilder,
    $$SessionStatesTableUpdateCompanionBuilder,
    (
      SessionStateRecord,
      BaseReferences<_$PallyDatabase, $SessionStatesTable, SessionStateRecord>
    ),
    SessionStateRecord,
    PrefetchHooks Function()>;
typedef $$ChatScrollPositionsTableCreateCompanionBuilder
    = ChatScrollPositionsCompanion Function({
  required String avatarId,
  Value<double> scrollOffset,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$ChatScrollPositionsTableUpdateCompanionBuilder
    = ChatScrollPositionsCompanion Function({
  Value<String> avatarId,
  Value<double> scrollOffset,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$ChatScrollPositionsTableFilterComposer
    extends Composer<_$PallyDatabase, $ChatScrollPositionsTable> {
  $$ChatScrollPositionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get avatarId => $composableBuilder(
      column: $table.avatarId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get scrollOffset => $composableBuilder(
      column: $table.scrollOffset, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$ChatScrollPositionsTableOrderingComposer
    extends Composer<_$PallyDatabase, $ChatScrollPositionsTable> {
  $$ChatScrollPositionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get avatarId => $composableBuilder(
      column: $table.avatarId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get scrollOffset => $composableBuilder(
      column: $table.scrollOffset,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$ChatScrollPositionsTableAnnotationComposer
    extends Composer<_$PallyDatabase, $ChatScrollPositionsTable> {
  $$ChatScrollPositionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get avatarId =>
      $composableBuilder(column: $table.avatarId, builder: (column) => column);

  GeneratedColumn<double> get scrollOffset => $composableBuilder(
      column: $table.scrollOffset, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ChatScrollPositionsTableTableManager extends RootTableManager<
    _$PallyDatabase,
    $ChatScrollPositionsTable,
    ChatScrollRecord,
    $$ChatScrollPositionsTableFilterComposer,
    $$ChatScrollPositionsTableOrderingComposer,
    $$ChatScrollPositionsTableAnnotationComposer,
    $$ChatScrollPositionsTableCreateCompanionBuilder,
    $$ChatScrollPositionsTableUpdateCompanionBuilder,
    (
      ChatScrollRecord,
      BaseReferences<_$PallyDatabase, $ChatScrollPositionsTable,
          ChatScrollRecord>
    ),
    ChatScrollRecord,
    PrefetchHooks Function()> {
  $$ChatScrollPositionsTableTableManager(
      _$PallyDatabase db, $ChatScrollPositionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatScrollPositionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatScrollPositionsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatScrollPositionsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> avatarId = const Value.absent(),
            Value<double> scrollOffset = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ChatScrollPositionsCompanion(
            avatarId: avatarId,
            scrollOffset: scrollOffset,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String avatarId,
            Value<double> scrollOffset = const Value.absent(),
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ChatScrollPositionsCompanion.insert(
            avatarId: avatarId,
            scrollOffset: scrollOffset,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ChatScrollPositionsTableProcessedTableManager = ProcessedTableManager<
    _$PallyDatabase,
    $ChatScrollPositionsTable,
    ChatScrollRecord,
    $$ChatScrollPositionsTableFilterComposer,
    $$ChatScrollPositionsTableOrderingComposer,
    $$ChatScrollPositionsTableAnnotationComposer,
    $$ChatScrollPositionsTableCreateCompanionBuilder,
    $$ChatScrollPositionsTableUpdateCompanionBuilder,
    (
      ChatScrollRecord,
      BaseReferences<_$PallyDatabase, $ChatScrollPositionsTable,
          ChatScrollRecord>
    ),
    ChatScrollRecord,
    PrefetchHooks Function()>;

class $PallyDatabaseManager {
  final _$PallyDatabase _db;
  $PallyDatabaseManager(this._db);
  $$ChatMessagesTableTableManager get chatMessages =>
      $$ChatMessagesTableTableManager(_db, _db.chatMessages);
  $$SessionStatesTableTableManager get sessionStates =>
      $$SessionStatesTableTableManager(_db, _db.sessionStates);
  $$ChatScrollPositionsTableTableManager get chatScrollPositions =>
      $$ChatScrollPositionsTableTableManager(_db, _db.chatScrollPositions);
}

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$pallyDatabaseHash() => r'd68c7bd707c49032a4b3ee4634d42fbe5cf7835c';

/// See also [pallyDatabase].
@ProviderFor(pallyDatabase)
final pallyDatabaseProvider = Provider<PallyDatabase>.internal(
  pallyDatabase,
  name: r'pallyDatabaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pallyDatabaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PallyDatabaseRef = ProviderRef<PallyDatabase>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
