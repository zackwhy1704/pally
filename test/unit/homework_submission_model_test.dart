import 'package:flutter_test/flutter_test.dart';
import 'package:pally/core/utils/json_reader.dart';
import 'package:pally/shared/models/homework_submission.dart';

/// The load-bearing invariant: the student model only ever exposes teacher
/// feedback/grade that the SERVER actually sent. Before release the server
/// omits those fields, so the model must report no feedback — never invent one.
void main() {
  Map<String, dynamic> base(Map<String, dynamic> over) => {
        'id': 's-1',
        'classId': 'cls-1',
        'title': 'Maths WS3',
        'subject': 'Maths',
        'status': 'IN_REVIEW',
        'files': [
          {'index': 0, 'name': 'work.jpg', 'contentType': 'image/jpeg', 'size': 1234},
        ],
        'teacherFeedback': null,
        'teacherGrade': null,
        'releasedAt': null,
        'createdAt': '2026-06-10T00:00:00Z',
        ...over,
      };

  test('an in-review submission exposes no feedback or grade', () {
    final s = HomeworkSubmission.fromJson(base({}));
    expect(s.isReleased, isFalse);
    expect(s.hasFeedback, isFalse);
    expect(s.hasGrade, isFalse);
    expect(s.files, hasLength(1));
    expect(s.files.first.isImage, isTrue);
  });

  test('a released submission exposes the teacher feedback and grade', () {
    final s = HomeworkSubmission.fromJson(base({
      'status': 'RELEASED',
      'teacherFeedback': 'Great working — watch your units.',
      'teacherGrade': 'A-',
      'releasedAt': '2026-06-11T00:00:00Z',
    }));
    expect(s.isReleased, isTrue);
    expect(s.hasFeedback, isTrue);
    expect(s.teacherFeedback, contains('units'));
    expect(s.teacherGrade, 'A-');
  });

  test('a returned submission is flagged for redo, still no feedback', () {
    final s = HomeworkSubmission.fromJson(base({'status': 'RETURNED'}));
    expect(s.isReturned, isTrue);
    expect(s.isReleased, isFalse);
    expect(s.hasFeedback, isFalse);
  });

  test('a missing id is a broken contract and throws (never silent)', () {
    final bad = base({})..remove('id');
    expect(() => HomeworkSubmission.fromJson(bad),
        throwsA(isA<JsonParseException>()));
  });

  test('a malformed files node degrades to empty rather than crashing', () {
    final s = HomeworkSubmission.fromJson(base({'files': 'not-a-list'}));
    expect(s.files, isEmpty);
  });
}
