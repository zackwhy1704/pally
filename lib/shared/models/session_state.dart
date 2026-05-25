import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:pally/core/local_db/pally_database.dart';

class SessionState {
  const SessionState({
    required this.id,
    required this.avatarId,
    this.topicsCovered = const [],
    this.conceptsMastered = const [],
    this.lastStruggle,
    this.questionsAsked = 0,
    this.lastTopicSlug,
    this.updatedAt,
  });

  final String id;
  final String avatarId;
  final List<String> topicsCovered;
  final List<String> conceptsMastered;
  final String? lastStruggle;
  final int questionsAsked;
  final String? lastTopicSlug;
  final DateTime? updatedAt;

  factory SessionState.empty(String avatarId) => SessionState(
        id: const Uuid().v4(),
        avatarId: avatarId,
      );

  factory SessionState.fromRecord(SessionStateRecord r) => SessionState(
        id: r.id,
        avatarId: r.avatarId,
        topicsCovered:
            (jsonDecode(r.topicsCovered) as List).cast<String>(),
        conceptsMastered:
            (jsonDecode(r.conceptsMastered) as List).cast<String>(),
        lastStruggle: r.lastStruggle,
        questionsAsked: r.questionsAsked,
        lastTopicSlug: r.lastTopicSlug,
        updatedAt: r.updatedAt,
      );

  SessionStateRecord toRecord() => SessionStateRecord(
        id: id,
        avatarId: avatarId,
        sessionDate: DateTime(
            DateTime.now().year, DateTime.now().month, DateTime.now().day),
        topicsCovered: jsonEncode(topicsCovered),
        conceptsMastered: jsonEncode(conceptsMastered),
        lastStruggle: lastStruggle,
        questionsAsked: questionsAsked,
        lastTopicSlug: lastTopicSlug,
        updatedAt: updatedAt ?? DateTime.now(),
      );

  SessionState copyWith({
    List<String>? topicsCovered,
    List<String>? conceptsMastered,
    String? lastStruggle,
    int? questionsAsked,
    String? lastTopicSlug,
    DateTime? updatedAt,
  }) =>
      SessionState(
        id: id,
        avatarId: avatarId,
        topicsCovered: topicsCovered ?? this.topicsCovered,
        conceptsMastered: conceptsMastered ?? this.conceptsMastered,
        lastStruggle: lastStruggle ?? this.lastStruggle,
        questionsAsked: questionsAsked ?? this.questionsAsked,
        lastTopicSlug: lastTopicSlug ?? this.lastTopicSlug,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
