import 'package:flutter/foundation.dart';
import 'package:pally/core/utils/json_reader.dart';

/// Student-facing assignment detail (A2 — answer compare).
///
/// Backend shape:
/// `{id, classId, title, type, moduleIds, stages, dueDate, answersReleased,
///   answersReleasedAt, status}` plus `modelAnswer` ONLY when released.
///
/// The exact shape of `stages` / `modelAnswer` is not pinned by the contract,
/// so everything here is parsed defensively per CLAUDE.md PART 16 — every
/// field is null-tolerant and a missing field degrades gracefully rather than
/// throwing. The model answer is intentionally only surfaced when the server
/// actually sends it (it withholds the field pre-release).
@immutable
class AssignmentDetail {
  const AssignmentDetail({
    required this.id,
    required this.classId,
    required this.title,
    required this.type,
    required this.status,
    required this.dueDate,
    required this.answersReleased,
    required this.answersReleasedAt,
    required this.moduleIds,
    required this.questions,
  });

  final String id;
  final String classId;
  final String title;
  final String type;
  final String status;
  final String? dueDate;
  final bool answersReleased;
  final String? answersReleasedAt;
  final List<String> moduleIds;

  /// Per-question compare rows. Empty when the backend doesn't break the
  /// assignment into discrete questions (we then fall back to a single
  /// whole-assignment compare card built from `modelAnswer`).
  final List<AssignmentQuestion> questions;

  /// True when there is something to compare against (released + at least one
  /// model answer present somewhere).
  bool get hasModelAnswer =>
      answersReleased && questions.any((q) => q.hasModelAnswer);

  static AssignmentDetail fromJson(Map<String, dynamic> j) {
    // `answersReleased` gates whether the model answer is shown at all, so it
    // is load-bearing — but the server always sends it, hence optional with a
    // safe `false` default rather than throwing on a transient bad payload.
    final released = j.optional<bool>('answersReleased', false);

    // moduleIds — list of strings, tolerant of nulls / non-strings.
    final moduleIds = ((j['moduleIds'] as List?) ?? const [])
        .map((e) => e?.toString() ?? '')
        .where((s) => s.isNotEmpty)
        .toList(growable: false);

    return AssignmentDetail(
      // id is the one field the UI genuinely cannot work without.
      id: j.require<String>('id'),
      classId: j.optional<String>('classId', ''),
      title: j.optional<String>('title', 'Assignment'),
      type: j.optional<String>('type', 'PRE_CLASS'),
      status: j.optional<String>('status', 'PENDING'),
      dueDate: j['dueDate'] as String?,
      answersReleased: released,
      answersReleasedAt: j['answersReleasedAt'] as String?,
      moduleIds: moduleIds,
      questions: _parseQuestions(j, released),
    );
  }

  /// The contract leaves the per-question shape open. We probe the most likely
  /// container keys in order and stop at the first list we find. Each entry is
  /// expected to (optionally) carry the prompt, the student's answer, the
  /// model answer, and a per-concept evaluation list.
  static List<AssignmentQuestion> _parseQuestions(
      Map<String, dynamic> j, bool released) {
    List<dynamic>? raw;
    for (final key in const [
      'questions',
      'items',
      'answers',
      'responses',
      'stages',
    ]) {
      final node = j[key];
      if (node is List && node.isNotEmpty) {
        raw = node;
        break;
      }
    }

    final out = <AssignmentQuestion>[];
    if (raw != null) {
      var idx = 0;
      for (final e in raw) {
        if (e is Map) {
          out.add(AssignmentQuestion.fromJson(
            Map<String, dynamic>.from(e),
            index: idx,
            released: released,
          ));
        }
        idx++;
      }
    }

    // Fallback: no per-question breakdown, but a whole-assignment model answer
    // is present (only ever sent when released).
    if (out.isEmpty) {
      final whole = j['modelAnswer'];
      final mine = (j['studentAnswer'] ?? j['answer'])?.toString();
      if (whole != null || (mine != null && mine.isNotEmpty)) {
        out.add(AssignmentQuestion(
          index: 0,
          prompt: '',
          studentAnswer: mine,
          modelAnswer: released ? whole?.toString() : null,
          concepts: const [],
        ));
      }
    }
    return out;
  }
}

@immutable
class AssignmentQuestion {
  const AssignmentQuestion({
    required this.index,
    required this.prompt,
    required this.studentAnswer,
    required this.modelAnswer,
    required this.concepts,
  });

  final int index;
  final String prompt;
  final String? studentAnswer;

  /// Null when the server withheld it (pre-release) — never invent one.
  final String? modelAnswer;
  final List<ConceptEval> concepts;

  bool get hasModelAnswer =>
      modelAnswer != null && modelAnswer!.trim().isNotEmpty;

  static AssignmentQuestion fromJson(
    Map<String, dynamic> j, {
    required int index,
    required bool released,
  }) {
    final prompt =
        (j['prompt'] ?? j['question'] ?? j['title'] ?? '').toString();
    final mine = (j['studentAnswer'] ??
            j['yourAnswer'] ??
            j['answer'] ??
            j['response'])
        ?.toString();

    // Only adopt a model answer when the server actually sent it. The contract
    // omits this field entirely before release, so a null here is correct and
    // must NOT be papered over.
    final modelRaw =
        released ? (j['modelAnswer'] ?? j['expectedAnswer']) : null;

    final concepts = ((j['concepts'] ?? j['evaluation'] ?? j['evaluations'])
                as List? ??
            const [])
        .whereType<Map>()
        .map((m) => ConceptEval.fromJson(Map<String, dynamic>.from(m)))
        .toList(growable: false);

    return AssignmentQuestion(
      index: index,
      prompt: prompt,
      studentAnswer: mine,
      modelAnswer: modelRaw?.toString(),
      concepts: concepts,
    );
  }
}

/// Per-concept evaluation of the student's answer.
@immutable
class ConceptEval {
  const ConceptEval({
    required this.concept,
    required this.passed,
    required this.feedback,
  });

  final String concept;

  /// Null when the backend reports neither pass nor fail (renders neutral).
  final bool? passed;
  final String feedback;

  static ConceptEval fromJson(Map<String, dynamic> j) {
    bool? passed;
    final p = j['passed'] ?? j['correct'] ?? j['mastered'];
    if (p is bool) {
      passed = p;
    } else if (p is String) {
      final lower = p.toLowerCase();
      if (lower == 'pass' || lower == 'true' || lower == 'correct') {
        passed = true;
      } else if (lower == 'fail' || lower == 'false' || lower == 'wrong') {
        passed = false;
      }
    }
    return ConceptEval(
      concept: (j['concept'] ?? j['name'] ?? j['conceptName'] ?? '').toString(),
      passed: passed,
      feedback: (j['feedback'] ?? j['comment'] ?? '').toString(),
    );
  }
}
