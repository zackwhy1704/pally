import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/shared/models/avatar.dart';
import 'package:pally/shared/models/upload_result.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/utils/logger.dart';

part 'upload_view_model.g.dart';

// ── Per-file upload error (shown alongside the file, not as a global toast) ──

class FileUploadError {
  const FileUploadError({required this.fileName, required this.message});
  final String fileName;
  final String message;
}

@immutable
class UploadState {
  const UploadState({
    this.avatar,
    this.files = const [],
    this.isUploading = false,
    this.isCheckingRelevance = false,
    this.error,
    this.fileErrors = const [],
    this.pendingFile,
    this.pendingRelevance,
    this.topicTag,
    this.sourceType,
  });

  final Avatar? avatar;
  final List<UploadResult> files;
  final bool isUploading;
  final bool isCheckingRelevance;
  final String? error;
  /// Per-file errors for multi-upload: one entry per file that failed so
  /// the user sees which file had which problem.
  final List<FileUploadError> fileErrors;
  final PlatformFile? pendingFile;
  final RelevanceCheckResponse? pendingRelevance;
  final String? topicTag;
  final String? sourceType;

  int get totalFiles => files.length;
  bool get hasFiles => files.isNotEmpty;

  UploadState copyWith({
    Avatar? avatar,
    List<UploadResult>? files,
    bool? isUploading,
    bool? isCheckingRelevance,
    Object? error = _sentinel,
    List<FileUploadError>? fileErrors,
    Object? pendingFile = _sentinel,
    Object? pendingRelevance = _sentinel,
    Object? topicTag = _sentinel,
    Object? sourceType = _sentinel,
  }) {
    return UploadState(
      avatar: avatar ?? this.avatar,
      files: files ?? this.files,
      isUploading: isUploading ?? this.isUploading,
      isCheckingRelevance: isCheckingRelevance ?? this.isCheckingRelevance,
      error: error == _sentinel ? this.error : error as String?,
      fileErrors: fileErrors ?? this.fileErrors,
      pendingFile: pendingFile == _sentinel
          ? this.pendingFile
          : pendingFile as PlatformFile?,
      pendingRelevance: pendingRelevance == _sentinel
          ? this.pendingRelevance
          : pendingRelevance as RelevanceCheckResponse?,
      topicTag: topicTag == _sentinel ? this.topicTag : topicTag as String?,
      sourceType:
          sourceType == _sentinel ? this.sourceType : sourceType as String?,
    );
  }
}

const _sentinel = Object();

// ── Max file size enforced client-side (matches backend 25MB cap) ──
const _maxFileSizeBytes = 25 * 1024 * 1024;

@riverpod
class UploadViewModel extends _$UploadViewModel {
  late String _avatarId;

  @override
  UploadState build(String avatarId) {
    _avatarId = avatarId;
    _loadAvatar();
    _loadFiles();
    return const UploadState();
  }

  void setTopicTag(String? tag) => state = state.copyWith(topicTag: tag);
  void setSourceType(String? type) => state = state.copyWith(sourceType: type);

  Future<void> _loadAvatar() async {
    try {
      final dio = ref.read(dioProvider);
      final response =
          await dio.get<Map<String, dynamic>>('/api/v1/avatars/$_avatarId');
      state = state.copyWith(avatar: Avatar.fromJson(response.data!));
    } catch (e, st) {
      appLog.w('[Upload] Avatar load failed', error: e, stackTrace: st);
    }
  }

  Future<void> _loadFiles() async {
    try {
      final dio = ref.read(dioProvider);
      final response =
          await dio.get<List<dynamic>>('/api/v1/avatars/$_avatarId/files');
      final files = (response.data ?? [])
          .map((e) => UploadResult.fromJson(e as Map<String, dynamic>))
          .toList();
      state = state.copyWith(files: files);
    } catch (e, st) {
      appLog.w('[Upload] File list load failed', error: e, stackTrace: st);
    }
  }

  // ── Client-side file validation ────────────────────────────────────────────

  /// Returns a user-friendly error string if the file is invalid, or null.
  String? _validateFile(PlatformFile file) {
    if (file.path == null) {
      return 'Could not read "${file.name}" — try selecting it again.';
    }
    if (file.size == 0) {
      return '"${file.name}" appears to be empty.';
    }
    if (file.size > _maxFileSizeBytes) {
      final mb = (file.size / (1024 * 1024)).toStringAsFixed(1);
      return '"${file.name}" is ${mb}MB — max is 25MB. '
          'Try splitting it into smaller sections.';
    }
    final ext = file.name.split('.').last.toLowerCase();
    const allowed = {'pdf', 'jpg', 'jpeg', 'png', 'heic', 'webp', 'txt'};
    if (!allowed.contains(ext)) {
      return '"${file.name}" is a .$ext file — only PDFs, images, and text '
          'files are supported.';
    }
    return null;
  }

  // ── Specific server-error messages ─────────────────────────────────────────

  /// Maps HTTP status codes + response bodies to actionable user messages.
  String _friendlyUploadError(DioException e, String fileName) {
    final status = e.response?.statusCode;
    final body = e.response?.data;
    final serverMsg = body is Map
        ? (body['error'] as String?)?.trim()
        : null;

    // Extract structured 409 payload for duplicate/similar content
    String? dupCode;
    String? dupExisting;
    if (status == 409 && body is Map) {
      final data = body['data'] is Map
          ? body['data'] as Map
          : body;
      dupCode     = data['code'] as String?;
      dupExisting = data['existingFileName'] as String?;
    }

    return switch (status) {
      400 => '"$fileName" couldn\'t be read — it may be empty or corrupted.',
      401 => 'Session expired. Please sign in again.',
      402 => 'You\'ve hit the upload limit. Upgrade for unlimited uploads.',
      403 => 'You don\'t have permission to upload here.',
      409 when dupCode == 'DUPLICATE_FILE' =>
            '"$fileName" is identical to '
            '"${dupExisting ?? 'an existing file'}" already in your Mochi\'s brain. '
            'No need to upload it again!',
      409 when dupCode == 'SIMILAR_CONTENT' =>
            '"$fileName" is very similar to '
            '"${dupExisting ?? 'existing notes'}" already in your Mochi\'s brain. '
            'Uploading it again won\'t teach Mochi anything new.',
      413 => '"$fileName" is too large (max 25MB). '
            'Try splitting it into smaller sections.',
      415 => '"$fileName" isn\'t a supported file type. '
            'Use a PDF, image, or text file.',
      429 => 'Too many uploads at once. Wait a moment and try again.',
      500 => serverMsg?.isNotEmpty == true
            ? serverMsg!
            : '"$fileName" couldn\'t be processed — it may be '
              'password-protected or corrupted. Try a different version.',
      502 || 503 || 504 => 'The server is busy right now. '
            'Wait a moment and try uploading "$fileName" again.',
      _ when e.type == DioExceptionType.connectionTimeout ||
             e.type == DioExceptionType.receiveTimeout ||
             e.type == DioExceptionType.sendTimeout =>
            'Upload of "$fileName" timed out. '
            'Check your connection and try again.',
      _ when e.type == DioExceptionType.connectionError =>
            'No internet connection. Check your WiFi and try again.',
      _ => serverMsg?.isNotEmpty == true
            ? serverMsg!
            : 'Upload of "$fileName" failed. Please try again.',
    };
  }

  // ── Pick & upload flows ────────────────────────────────────────────────────

  Future<void> pickFromCamera() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image == null) return;

    final platformFile = PlatformFile(
      name: image.name,
      path: image.path,
      size: await File(image.path).length(),
    );
    await _checkRelevanceAndUpload(platformFile);
  }

  Future<void> pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
    );
    if (result == null || result.files.isEmpty) return;

    // Clear previous per-file errors before a new batch.
    state = state.copyWith(fileErrors: []);

    // Validate all files client-side first, collect invalid ones.
    final valid = <PlatformFile>[];
    final newErrors = <FileUploadError>[];
    for (final file in result.files) {
      final err = _validateFile(file);
      if (err != null) {
        newErrors.add(FileUploadError(fileName: file.name, message: err));
        appLog.w('[Upload] Client validation failed: ${file.name} — $err');
      } else {
        valid.add(file);
      }
    }
    if (newErrors.isNotEmpty) {
      state = state.copyWith(fileErrors: newErrors);
    }

    // Upload valid files sequentially; errors on one file don't stop the rest.
    for (final file in valid) {
      await _checkRelevanceAndUpload(file);
    }
  }

  Future<void> pasteText(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    appLog.i('[Upload] Paste text: ${trimmed.length} chars');

    try {
      final dir = await getTemporaryDirectory();
      final ts = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'notes-$ts.txt';
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(trimmed);

      final platformFile = PlatformFile(
        name: fileName,
        path: file.path,
        size: await file.length(),
      );
      await _checkRelevanceAndUpload(platformFile);
    } catch (e, st) {
      appLog.e('[Upload] Paste-text failed', error: e, stackTrace: st);
      state = state.copyWith(
          error: 'Could not save your notes. Try again.');
    }
  }

  Future<void> _checkRelevanceAndUpload(PlatformFile file) async {
    appLog.i('[Upload] Relevance check: ${file.name}');
    state = state.copyWith(
      isCheckingRelevance: true,
      pendingFile: file,
      pendingRelevance: null,
    );

    try {
      String sample = file.name;
      if (file.path != null) {
        try {
          final content = await File(file.path!).readAsString();
          sample = content.substring(0, content.length.clamp(0, 500));
        } catch (_) {
          // Binary — fall back to filename as sample
        }
      }

      final dio = ref.read(dioProvider);
      final response = await dio.post<Map<String, dynamic>>(
        '/api/v1/avatars/$_avatarId/relevance',
        data: {'contentSample': sample},
      );
      final relevance = RelevanceCheckResponse.fromJson(response.data!);
      appLog.i('[Upload] Relevance score=${relevance.score}');

      state = state.copyWith(
        isCheckingRelevance: false,
        pendingRelevance: relevance,
      );

      if (relevance.isRelevant) await uploadFile(file);
      // Otherwise UI shows the warning dialog
    } on DioException catch (e, st) {
      // Relevance check failing → upload anyway (fail-open: better to
      // upload and let Claude judge than to silently block the user)
      appLog.w('[Upload] Relevance check failed, uploading directly',
          error: e, stackTrace: st);
      state = state.copyWith(
        isCheckingRelevance: false,
        pendingRelevance:
            const RelevanceCheckResponse(isRelevant: true, score: 1.0),
      );
      await uploadFile(file);
    }
  }

  Future<void> uploadFile(PlatformFile file,
      {bool skipRelevance = false}) async {
    // Guard: path must be present
    if (file.path == null) {
      final msg = 'Could not read "${file.name}" — try selecting it again.';
      appLog.w('[Upload] Null path for file: ${file.name}');
      _appendFileError(FileUploadError(fileName: file.name, message: msg));
      state = state.copyWith(isUploading: false);
      return;
    }

    appLog.i('[Upload] Uploading: ${file.name} (${file.size}B)');
    state = state.copyWith(
      isUploading: true,
      pendingFile: null,
      pendingRelevance: null,
      error: null,
    );

    try {
      final dio = ref.read(dioProvider);
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path!, filename: file.name),
        if (state.topicTag != null) 'topicTag': state.topicTag,
        if (state.sourceType != null) 'sourceType': state.sourceType,
        if (skipRelevance) 'skipRelevance': 'true',
      });
      final response = await dio.post<Map<String, dynamic>>(
        '/api/v1/avatars/$_avatarId/files',
        data: formData,
      );
      final data = response.data ?? const <String, dynamic>{};
      final titlesRaw = data['wikiPageTitles'];
      final wikiPageTitles = titlesRaw is List
          ? titlesRaw.whereType<String>().toList()
          : <String>[];
      final result = UploadResult(
        id: (data['fileId'] ?? data['id'] ?? '') as String,
        avatarId: _avatarId,
        fileName: file.name,
        status: UploadStatus.ready,
        pageCount: (data['pageCount'] as num?)?.toInt() ?? 0,
        wikiPageTitles: wikiPageTitles,
        uploadedAt: DateTime.now(),
      );
      appLog.i('[Upload] Success: ${result.id} pages=${result.pageCount}');
      state = state.copyWith(
        isUploading: false,
        files: [...state.files, result],
      );
    } on DioException catch (e, st) {
      appLog.e('[Upload] Failed: ${file.name} status=${e.response?.statusCode}',
          error: e, stackTrace: st);
      final msg = _friendlyUploadError(e, file.name);
      // Append to per-file errors (so multiple files show individual problems)
      // and also set the top-level error for single-file scenarios.
      _appendFileError(FileUploadError(fileName: file.name, message: msg));
      state = state.copyWith(isUploading: false, error: msg);
    } catch (e, st) {
      appLog.e('[Upload] Unexpected error: ${file.name}', error: e, stackTrace: st);
      final msg =
          'Something unexpected went wrong uploading "${file.name}". Try again.';
      _appendFileError(FileUploadError(fileName: file.name, message: msg));
      state = state.copyWith(isUploading: false, error: msg);
    }
  }

  void _appendFileError(FileUploadError err) {
    state = state.copyWith(
      fileErrors: [...state.fileErrors, err],
    );
  }

  Future<void> deleteFile(String fileId) async {
    try {
      final dio = ref.read(dioProvider);
      await dio.delete('/api/v1/avatars/$_avatarId/files/$fileId');
    } catch (e, st) {
      appLog.w('[Upload] Delete failed, removing locally', error: e, stackTrace: st);
    }
    state = state.copyWith(
      files: state.files.where((f) => f.id != fileId).toList(),
    );
  }

  void clearPendingRelevance() {
    state = state.copyWith(pendingFile: null, pendingRelevance: null);
  }

  void clearErrors() {
    state = state.copyWith(error: null, fileErrors: []);
  }
}
