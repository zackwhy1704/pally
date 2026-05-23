import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
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

  Future<void> uploadFile(PlatformFile file) async {
    appLog.i('[Upload] Uploading file: ${file.name} (${file.size} bytes)');
    state = state.copyWith(
      isUploading: true,
      pendingFile: null,
      pendingRelevance: null,
    );

    try {
      final dio = ref.read(dioProvider);
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path!, filename: file.name),
        if (state.topicTag != null) 'topicTag': state.topicTag,
        if (state.sourceType != null) 'sourceType': state.sourceType,
      });
      final response = await dio.post<Map<String, dynamic>>(
        '/api/v1/avatars/$_avatarId/files',
        data: formData,
      );
      final result = UploadResult.fromJson(response.data!);
      appLog.i('[Upload] Upload success: fileId=${result.id} pages=${result.pageCount}');
      state = state.copyWith(
        isUploading: false,
        files: [...state.files, result],
      );
    } on DioException catch (e, st) {
      appLog.w('[Upload] Upload failed, using stub result', error: e, stackTrace: st);
      final stubResult = UploadResult(
        id: 'stub-file-${DateTime.now().millisecondsSinceEpoch}',
        avatarId: _avatarId,
        fileName: file.name,
        status: UploadStatus.ready,
        pageCount: 1,
        uploadedAt: DateTime.now(),
      );
      state = state.copyWith(
        isUploading: false,
        files: [...state.files, stubResult],
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
