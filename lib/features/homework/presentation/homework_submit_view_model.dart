import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/error/pally_error.dart';
import 'package:pally/core/utils/logger.dart';

part 'homework_submit_view_model.g.dart';

/// Immutable state for the homework submit flow. The title/subject text live in
/// the screen's controllers and are passed into [submit]; the VM owns the
/// attached files (camera/PDF picking is async and belongs here, not in the
/// widget), the in-flight flag, the persistent error, and a one-shot success.
@immutable
class HomeworkSubmitState {
  const HomeworkSubmitState({
    this.files = const [],
    this.isSubmitting = false,
    this.error,
    this.submitted = false,
  });

  final List<PlatformFile> files;
  final bool isSubmitting;

  /// Persistent inline error (never a toast for this primary action).
  final String? error;

  /// Set once on a successful submit so the screen can pop back to the list.
  final bool submitted;

  bool get canSubmit => files.isNotEmpty && !isSubmitting;

  HomeworkSubmitState copyWith({
    List<PlatformFile>? files,
    bool? isSubmitting,
    String? error,
    bool clearError = false,
    bool? submitted,
  }) =>
      HomeworkSubmitState(
        files: files ?? this.files,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        error: clearError ? null : (error ?? this.error),
        submitted: submitted ?? this.submitted,
      );
}

@riverpod
class HomeworkSubmitViewModel extends _$HomeworkSubmitViewModel {
  late String _avatarId;

  static const int _maxFiles = 10;

  @override
  HomeworkSubmitState build(String avatarId) {
    _avatarId = avatarId;
    return const HomeworkSubmitState();
  }

  /// Scan a page with the ML Kit document scanner (auto-crop/deskew); falls
  /// back to a plain camera capture if the scanner is unavailable.
  Future<void> pickFromCamera() async {
    try {
      final paths = await CunningDocumentScanner.getPictures(
        noOfPages: 1,
        isGalleryImportAllowed: false,
      );
      if (paths == null || paths.isEmpty) return;
      final path = paths.first;
      final file = File(path);
      _addFile(PlatformFile(
        name: '${DateTime.now().millisecondsSinceEpoch}_homework.jpg',
        path: path,
        size: await file.length(),
      ));
    } catch (e) {
      appLog.w('[Homework] scanner unavailable, falling back to ImagePicker: $e');
      final picker = ImagePicker();
      final image =
          await picker.pickImage(source: ImageSource.camera, imageQuality: 90);
      if (image == null) return;
      _addFile(PlatformFile(
        name: image.name,
        path: image.path,
        size: await File(image.path).length(),
      ));
    }
  }

  /// Pick an existing photo of the work from the gallery.
  Future<void> pickPhoto() async {
    final picker = ImagePicker();
    final image =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (image == null) return;
    _addFile(PlatformFile(
      name: image.name,
      path: image.path,
      size: await File(image.path).length(),
    ));
  }

  Future<void> pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
    );
    if (result == null || result.files.isEmpty) return;
    for (final f in result.files) {
      if (f.path != null) _addFile(f);
    }
  }

  void _addFile(PlatformFile f) {
    if (state.files.length >= _maxFiles) {
      state = state.copyWith(error: 'You can attach up to $_maxFiles files.');
      return;
    }
    state = state.copyWith(files: [...state.files, f], clearError: true);
  }

  void removeFile(int index) {
    if (index < 0 || index >= state.files.length) return;
    final next = [...state.files]..removeAt(index);
    state = state.copyWith(files: next, clearError: true);
  }

  /// Uploads the attached files as one submission. Returns early if already in
  /// flight (re-entry guard) and surfaces a persistent inline error on failure.
  Future<void> submit({required String title, String? subject}) async {
    if (state.isSubmitting) return; // re-entry guard
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      state = state.copyWith(error: 'Please give your homework a title.');
      return;
    }
    if (state.files.isEmpty) {
      state =
          state.copyWith(error: 'Add at least one photo or PDF of your work.');
      return;
    }

    appLog.i('[Homework] Submitting "$trimmedTitle" with '
        '${state.files.length} file(s) for $_avatarId');
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final dio = ref.read(dioProvider);
      final formData = FormData();
      formData.fields.add(MapEntry('title', trimmedTitle));
      final s = subject?.trim() ?? '';
      if (s.isNotEmpty) formData.fields.add(MapEntry('subject', s));
      for (final f in state.files) {
        formData.files.add(MapEntry(
          'files',
          await MultipartFile.fromFile(f.path!, filename: f.name),
        ));
      }
      await dio.post<dynamic>(
        '/api/v1/avatars/$_avatarId/homework',
        data: formData,
        options: Options(
          receiveTimeout: const Duration(minutes: 3),
          sendTimeout: const Duration(minutes: 2),
        ),
      );
      appLog.i('[Homework] Submission uploaded');
      state = state.copyWith(isSubmitting: false, submitted: true);
    } on DioException catch (e, st) {
      appLog.e('[Homework] submit failed', error: e, stackTrace: st);
      state = state.copyWith(
          isSubmitting: false, error: PallyError.from(e).userMessage);
    } catch (e, st) {
      appLog.e('[Homework] submit unexpected error', error: e, stackTrace: st);
      state = state.copyWith(
          isSubmitting: false, error: PallyError.unknown.userMessage);
    }
  }
}
