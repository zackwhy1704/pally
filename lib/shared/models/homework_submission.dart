import 'package:flutter/foundation.dart';
import 'package:pally/core/utils/json_reader.dart';

/// Student-facing homework submission (the artifact a student uploaded to a
/// centre class, plus — once the teacher RELEASES — the teacher's feedback).
///
/// Backend shape (student view, `HomeworkStudentController.toStudentDto`):
/// `{id, classId, title, subject, status, files[], teacherFeedback,
///   teacherGrade, releasedAt, createdAt}`.
///
/// The server WITHHOLDS the AI draft and any pre-release teacher notes entirely
/// — `teacherFeedback`/`teacherGrade` arrive only once `status == RELEASED`. The
/// student-facing `status` is collapsed server-side to one of
/// `IN_REVIEW` / `RETURNED` / `RELEASED`. Parsed defensively: a missing field
/// degrades gracefully rather than throwing.
@immutable
class HomeworkSubmission {
  const HomeworkSubmission({
    required this.id,
    required this.classId,
    required this.title,
    required this.subject,
    required this.status,
    required this.files,
    required this.teacherFeedback,
    required this.teacherGrade,
    required this.releasedAt,
    required this.createdAt,
  });

  final String id;
  final String classId;
  final String title;
  final String? subject;

  /// Collapsed student-facing state: `IN_REVIEW` / `RETURNED` / `RELEASED`.
  final String status;
  final List<HomeworkFile> files;

  /// Only present once the teacher RELEASES — the server withholds it otherwise,
  /// so a null here is correct and must never be invented client-side.
  final String? teacherFeedback;
  final String? teacherGrade;
  final String? releasedAt;
  final String createdAt;

  bool get isReleased => status == 'RELEASED';
  bool get isReturned => status == 'RETURNED';
  bool get hasFeedback =>
      teacherFeedback != null && teacherFeedback!.trim().isNotEmpty;
  bool get hasGrade => teacherGrade != null && teacherGrade!.trim().isNotEmpty;

  static HomeworkSubmission fromJson(Map<String, dynamic> j) {
    final rawFiles = j['files'];
    final files = rawFiles is List
        ? rawFiles
            .whereType<Map>()
            .map((m) => HomeworkFile.fromJson(Map<String, dynamic>.from(m)))
            .toList(growable: false)
        : const <HomeworkFile>[];
    return HomeworkSubmission(
      // id is the one field the UI genuinely cannot work without.
      id: j.require<String>('id'),
      classId: j.optional<String>('classId', ''),
      title: j.optional<String>('title', 'Homework'),
      subject: j['subject'] as String?,
      status: j.optional<String>('status', 'IN_REVIEW'),
      files: files,
      teacherFeedback: j['teacherFeedback'] as String?,
      teacherGrade: j['teacherGrade'] as String?,
      releasedAt: j['releasedAt'] as String?,
      createdAt: j.optional<String>('createdAt', ''),
    );
  }
}

/// Metadata for one uploaded artifact (we list names; the bytes are fetched
/// on demand via the authed `/files/{index}` endpoint when needed).
@immutable
class HomeworkFile {
  const HomeworkFile({
    required this.index,
    required this.name,
    required this.contentType,
    required this.size,
  });

  final int index;
  final String name;
  final String contentType;
  final int size;

  bool get isPdf => contentType.toLowerCase().contains('pdf');
  bool get isImage => contentType.toLowerCase().startsWith('image/');

  static HomeworkFile fromJson(Map<String, dynamic> j) => HomeworkFile(
        index: j.optional<int>('index', 0),
        name: j.optional<String>('name', 'file'),
        contentType:
            j.optional<String>('contentType', 'application/octet-stream'),
        size: j.optional<int>('size', 0),
      );
}
