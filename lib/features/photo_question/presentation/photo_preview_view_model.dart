import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
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
      final inputImage = InputImage.fromFilePath(photoPath);
      final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final recognised = await recognizer.processImage(inputImage);
      await recognizer.close();

      final questions = _parseQuestions(recognised.text);
      state = PhotoPreviewDetected(questions: questions, photoPath: photoPath);
    } catch (e) {
      state = PhotoPreviewError(e.toString());
    }
  }

  List<PhotoQuestion> _parseQuestions(String text) {
    final lines = text.split('\n').where((l) => l.trim().isNotEmpty).toList();
    final questions = <PhotoQuestion>[];

    for (final line in lines) {
      final trimmed = line.trim();
      if (RegExp(r'^(Q?\d+[\.\):]|[a-e][\.\)])').hasMatch(trimmed)) {
        questions.add(PhotoQuestion(
          id: _uuid.v4(),
          rawText: trimmed,
          questionIndex: questions.length + 1,
          isSelected: true,
        ));
      }
    }

    // Fallback: treat entire text as a single question
    if (questions.isEmpty && text.trim().isNotEmpty) {
      final trimmed = text.trim().length > 120
          ? '${text.trim().substring(0, 120)}…'
          : text.trim();
      questions.add(PhotoQuestion(
        id: _uuid.v4(),
        rawText: trimmed,
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

  List<PhotoQuestion> get selectedQuestions {
    final current = state;
    if (current is! PhotoPreviewDetected) return [];
    return current.questions.where((q) => q.isSelected).toList();
  }
}
