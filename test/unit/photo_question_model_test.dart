import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/photo_question/presentation/photo_preview_view_model.dart';
import 'package:pally/shared/models/photo_question.dart';

void main() {
  group('PhotoQuestion', () {
    test('copyWith toggles isSelected', () {
      const q = PhotoQuestion(
        id: 'q1',
        rawText: 'What is 2+2?',
        questionIndex: 1,
      );
      final toggled = q.copyWith(isSelected: false);
      expect(toggled.isSelected, isFalse);
      expect(toggled.rawText, equals('What is 2+2?'));
    });

    test('fromJson / toJson roundtrip', () {
      const q = PhotoQuestion(
        id: 'q1',
        rawText: 'Solve x + 3 = 7',
        questionIndex: 2,
        isSelected: true,
      );
      final restored = PhotoQuestion.fromJson(
          jsonDecode(jsonEncode(q.toJson())) as Map<String, dynamic>);
      expect(restored.id, equals(q.id));
      expect(restored.rawText, equals(q.rawText));
      expect(restored.questionIndex, equals(q.questionIndex));
      expect(restored.isSelected, equals(q.isSelected));
    });

    test('isSelected defaults to true', () {
      const q = PhotoQuestion(id: 'q1', rawText: 'test', questionIndex: 1);
      expect(q.isSelected, isTrue);
    });
  });

  group('QuestionAnswer', () {
    test('fromJson / toJson roundtrip', () {
      const qa = QuestionAnswer(
        questionId: 'qid',
        questionText: 'Solve 2x = 8',
        answer: 'x = 4',
        steps: ['Divide both sides by 2', 'x = 4'],
        explanation: 'Dividing 8 by 2 gives 4.',
      );
      final restored = QuestionAnswer.fromJson(
          jsonDecode(jsonEncode(qa.toJson())) as Map<String, dynamic>);
      expect(restored.questionId, equals('qid'));
      expect(restored.answer, equals('x = 4'));
      expect(restored.steps.length, equals(2));
      expect(restored.explanation, equals('Dividing 8 by 2 gives 4.'));
    });

    test('steps defaults to empty list', () {
      const qa = QuestionAnswer(
        questionId: 'q',
        questionText: 'Q',
        answer: 'A',
      );
      expect(qa.steps, isEmpty);
      expect(qa.explanation, isEmpty);
    });
  });

  group('HomeworkScanResult', () {
    test('status defaults to complete', () {
      const result = HomeworkScanResult(
        messageId: 'msg1',
        imageLocalPath: '/tmp/photo.jpg',
        questions: [],
      );
      expect(result.status, equals(HomeworkScanStatus.complete));
    });

    test('xpEarned defaults to 5', () {
      const result = HomeworkScanResult(
        messageId: 'msg1',
        imageLocalPath: '/tmp/photo.jpg',
        questions: [],
      );
      expect(result.xpEarned, equals(5));
    });

    test('fromJson / toJson roundtrip preserves answers', () {
      const result = HomeworkScanResult(
        messageId: 'msg1',
        imageLocalPath: '/img.jpg',
        questions: [],
        answers: [
          QuestionAnswer(
            questionId: 'q1',
            questionText: 'Q?',
            answer: 'A',
          ),
        ],
        xpEarned: 10,
        sourceWikiPage: 'algebra-basics',
        status: HomeworkScanStatus.complete,
      );
      // Use jsonDecode(jsonEncode(...)) to ensure nested objects are maps
      final jsonStr = jsonEncode(result.toJson());
      final restored = HomeworkScanResult.fromJson(
          jsonDecode(jsonStr) as Map<String, dynamic>);
      expect(restored.messageId, equals('msg1'));
      expect(restored.answers.length, equals(1));
      expect(restored.xpEarned, equals(10));
      expect(restored.sourceWikiPage, equals('algebra-basics'));
    });
  });

  group('PhotoPreviewState', () {
    test('PhotoPreviewDetected copyWith updates questions', () {
      const q1 = PhotoQuestion(id: 'q1', rawText: 'Q1', questionIndex: 1);
      const q2 = PhotoQuestion(id: 'q2', rawText: 'Q2', questionIndex: 2);
      const state = PhotoPreviewDetected(
        questions: [q1],
        photoPath: '/path/to/photo.jpg',
      );
      final updated = state.copyWith(questions: [q1, q2]);
      expect(updated.questions.length, equals(2));
      expect(updated.photoPath, equals('/path/to/photo.jpg'));
    });

    test('PhotoPreviewError holds message', () {
      const error = PhotoPreviewError('OCR failed');
      expect(error.message, equals('OCR failed'));
    });

    test('PhotoPreviewDetecting is a valid state', () {
      const detecting = PhotoPreviewDetecting();
      expect(detecting, isA<PhotoPreviewState>());
    });
  });
}
