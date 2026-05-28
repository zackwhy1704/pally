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

@immutable
class UploadState {
  const UploadState({
    this.avatar,
    this.files = const [],
    this.isUploading = false,
    this.isCheckingRelevance = false,
    this.error,
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
      pendingFile: pendingFile == _sentinel
          ? this.pendingFile
          : pendingFile as PlatformFile?,
      pendingRelevance: pendingRelevance == _sentinel
          ? this.pendingRelevance
          : pendingRelevance as RelevanceCheckResponse?,
      topicTag: topicTag == _sentinel ? this.topicTag : topicTag as String?,
      sourceType: sourceType == _sentinel ? this.sourceType : sourceType as String?,
    );
  }
}

const _sentinel = Object();

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
      appLog.d('[Upload] Avatar loaded: ${state.avatar?.name}');
    } catch (e, st) {
      appLog.w('[Upload] Avatar load failed, continuing without it', error: e, stackTrace: st);
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
      appLog.d('[Upload] Loaded ${files.length} existing files');
      state = state.copyWith(files: files);
    } catch (e, st) {
      appLog.w('[Upload] File list load failed', error: e, stackTrace: st);
    }
  }

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

    for (final file in result.files) {
      await _checkRelevanceAndUpload(file);
    }
  }

  /// Save pasted text to a temporary .txt file and run it through the same
  /// relevance-check + upload pipeline as PDFs.
  Future<void> pasteText(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    appLog.i('[Upload] Paste text received: ${trimmed.length} chars');

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
      appLog.e('[Upload] Paste-text upload failed', error: e, stackTrace: st);
      state = state.copyWith(error: 'Could not save your notes. Try again.');
    }
  }

  Future<void> _checkRelevanceAndUpload(PlatformFile file) async {
    appLog.i('[Upload] Starting relevance check for file: ${file.name}');
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
          // Binary file — use filename as sample
        }
      }

      appLog.d('[Upload] Sending relevance check, sampleChars=${sample.length}');
      final dio = ref.read(dioProvider);
      final response = await dio.post<Map<String, dynamic>>(
        '/api/v1/avatars/$_avatarId/relevance',
        data: {'contentSample': sample},  // backend field name
      );
      final relevance = RelevanceCheckResponse.fromJson(response.data!);
      appLog.i('[Upload] Relevance score=${relevance.score} isRelevant=${relevance.isRelevant}');

      state = state.copyWith(
        isCheckingRelevance: false,
        pendingRelevance: relevance,
      );

      if (relevance.isRelevant) {
        await uploadFile(file);
      }
      // If not relevant, the UI will show the warning dialog
    } on DioException catch (e, st) {
      appLog.w('[Upload] Relevance check failed, skipping and uploading directly', error: e, stackTrace: st);
      state = state.copyWith(
        isCheckingRelevance: false,
        pendingRelevance: const RelevanceCheckResponse(isRelevant: true, score: 1.0),
      );
      await uploadFile(file);
    }
  }

  Future<void> uploadFile(PlatformFile file, {bool skipRelevance = false}) async {
    appLog.i('[Upload] Uploading file: ${file.name} (${file.size} bytes) skipRelevance=$skipRelevance');
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
      final data = response.data ?? const {};
      // Backend Success: { fileId, pageCount }
      // Backend RelevanceWarning: { fileId, score, reason }
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
      appLog.i('[Upload] Upload success: fileId=${result.id} '
          'pages=${result.pageCount} wikiTitles=${wikiPageTitles.length}');
      state = state.copyWith(
        isUploading: false,
        files: [...state.files, result],
      );
    } on DioException catch (e, st) {
      appLog.e('[Upload] Upload failed', error: e, stackTrace: st);

      // Surface the actual error instead of silently faking a successful stub.
      // Faking ready stubs made the UI show "uploaded" when nothing was compiled.
      String errorMessage = 'Upload failed. Please try again.';
      final body = e.response?.data;
      if (body is Map) {
        final reason = body['reason'] as String?;
        final score = body['score'] as num?;
        final err = body['error'] as String?;
        if (reason != null) {
          errorMessage = reason;
        } else if (err != null) {
          errorMessage = err;
        }
        if (score != null && score < 0.3) {
          errorMessage =
              'This doesn\'t look like ${state.topicTag ?? "this subject"}. $reason';
        }
      }

      state = state.copyWith(
        isUploading: false,
        error: errorMessage,
      );
    }
  }

  Future<void> deleteFile(String fileId) async {
    appLog.d('[Upload] Deleting file $fileId');
    try {
      final dio = ref.read(dioProvider);
      await dio.delete('/api/v1/avatars/$_avatarId/files/$fileId');
      state = state.copyWith(
        files: state.files.where((f) => f.id != fileId).toList(),
      );
    } catch (e, st) {
      appLog.w('[Upload] Delete failed, removing locally', error: e, stackTrace: st);
      state = state.copyWith(
        files: state.files.where((f) => f.id != fileId).toList(),
      );
    }
  }

  void clearPendingRelevance() {
    state = state.copyWith(pendingFile: null, pendingRelevance: null);
  }
}
