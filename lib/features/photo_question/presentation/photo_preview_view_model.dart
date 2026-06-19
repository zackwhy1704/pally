import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:pally/core/services/text_recognition_service.dart';
import 'package:pally/shared/models/photo_question.dart';

part 'photo_preview_view_model.g.dart';

// ── State ─────────────────────────────────────────────────────────────────────

@immutable
sealed class PhotoPreviewState {
  const PhotoPreviewState();
}

class PhotoPreviewDetecting extends PhotoPreviewState {
  const PhotoPreviewDetecting();
}

class PhotoPreviewDetected extends PhotoPreviewState {
  const PhotoPreviewDetected({
    required this.questions,
    required this.photoPath,
  });
  final List<PhotoQuestion> questions;
  final String photoPath;

  PhotoPreviewDetected copyWith({List<PhotoQuestion>? questions}) {
    return PhotoPreviewDetected(
      questions: questions ?? this.questions,
      photoPath: photoPath,
    );
  }
}

class PhotoPreviewError extends PhotoPreviewState {
  const PhotoPreviewError(this.message);
  final String message;
}

// ── ViewModel ─────────────────────────────────────────────────────────────────

const _uuid = Uuid();

@riverpod
class PhotoPreviewViewModel extends _$PhotoPreviewViewModel {
  @override
  PhotoPreviewState build(String photoPath) {
    _runDetection(photoPath);
    return const PhotoPreviewDetecting();
  }

  Future<void> _runDetection(String photoPath) async {
    try {
      final text = await TextRecognitionService.recognize(photoPath);
      final questions = _parseQuestions(text);
      state = PhotoPreviewDetected(questions: questions, photoPath: photoPath);
    } catch (_) {
      // Never leak raw exception text — on-device OCR errors are mostly
      // model-internal noise the user can't act on.
      state = const PhotoPreviewError(
          "Couldn't read text from this photo. Try a clearer shot.");
    }
  }

  List<PhotoQuestion> _parseQuestions(String text) {
    final lines = text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    final questionStartRe = RegExp(r'^(Q?\d+[\.\):\s]|[a-e][\.\)])');
    final questions = <PhotoQuestion>[];
    final List<List<String>> groups = [];

    // Group lines: a new group starts at each numbered question line
    for (final line in lines) {
      if (questionStartRe.hasMatch(line)) {
        groups.add([line]);
      } else if (groups.isNotEmpty) {
        // Continuation of the current question
        groups.last.add(line);
      }
    }

    for (final group in groups) {
      questions.add(PhotoQuestion(
        id: _uuid.v4(),
        rawText: group.join(' '),
        questionIndex: questions.length + 1,
        isSelected: true,
      ));
    }

    // Fallback: treat entire text as a single question if no numbered lines found
    if (questions.isEmpty && text.trim().isNotEmpty) {
      questions.add(PhotoQuestion(
        id: _uuid.v4(),
        rawText: text.trim(),
        questionIndex: 1,
        isSelected: true,
      ));
    }

    return questions;
  }

  void toggleQuestion(String questionId) {
    final current = state;
    if (current is! PhotoPreviewDetected) return;
    final updated = current.questions.map((q) {
      return q.id == questionId ? q.copyWith(isSelected: !q.isSelected) : q;
    }).toList();
    state = current.copyWith(questions: updated);
  }

  // Replaces question text with user-corrected versions from EditQuestionsSheet.
  // Does NOT re-run OCR — only updates rawText fields.
  void updateQuestions(List<PhotoQuestion> updated) {
    final current = state;
    if (current is! PhotoPreviewDetected) return;
    state = current.copyWith(questions: updated);
  }

  List<PhotoQuestion> get selectedQuestions {
    final current = state;
    if (current is! PhotoPreviewDetected) return [];
    return current.questions.where((q) => q.isSelected).toList();
  }
}
