import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/shared/models/avatar.dart';
import 'package:pally/shared/models/upload_result.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/observability/observability.dart';
import 'package:pally/core/observability/observability_providers.dart';
import 'package:pally/core/utils/logger.dart';
import 'package:pally/features/library/presentation/library_view_model.dart';
import 'package:pally/features/home/presentation/home_view_model.dart';

part 'upload_view_model.g.dart';

// ── Per-file upload error (shown alongside the file, not as a global toast) ──

class FileUploadError {
  const FileUploadError({required this.fileName, required this.message});
  final String fileName;
  final String message;
}

/// Non-error info notes shown alongside a file (e.g. degraded fallback reader).
class FileUploadWarning {
  const FileUploadWarning({required this.fileName, required this.message});
  final String fileName;
  final String message;
}

@immutable
/// Which processing stage is actively running for a file.
enum UploadStage {
  idle,
  scanning,         // ML Kit document scanner open
  checkingSize,     // local validation
  checkingRelevance,
  uploading,
  extractingText,   // backend OCR/PDFBox
  compilingBrain,   // Gemini/Claude wiki compile
  chunkedCompile,   // large doc — split into chunks, takes longer
  compileSuccess,   // all pages created → show confetti/success
  compileFailed,    // compile permanently failed → show error + CTA
  compileTimeout,   // timed out waiting for compile → show error + CTA
}

class UploadState {
  const UploadState({
    this.avatar,
    this.files = const [],
    this.isUploading = false,
    this.isCheckingRelevance = false,
    this.error,
    this.fileErrors = const [],
    this.fileWarnings = const [],
    this.pendingFile,
    this.pendingRelevance,
    this.topicTag,
    this.sourceType,
    this.uploadStage = UploadStage.idle,
    this.pendingFileSizeBytes = 0,
    this.pendingFilePageCount = 0,
    this.compilingFileCount = 0,
    this.compileProgress,
    this.uploadQuality,
    this.uploadQualityReason,
    this.uploadExtractedText,
    this.reviewFileId,
  });

  final Avatar? avatar;
  final List<UploadResult> files;
  final bool isUploading;
  final bool isCheckingRelevance;
  final String? error;
  /// Per-file errors for multi-upload: one entry per file that failed so
  /// the user sees which file had which problem.
  final List<FileUploadError> fileErrors;
  /// Per-file info notes (non-error) — e.g. "backup reader" degraded notice.
  final List<FileUploadWarning> fileWarnings;
  final PlatformFile? pendingFile;
  final RelevanceCheckResponse? pendingRelevance;
  final String? topicTag;
  final String? sourceType;

  /// Granular stage shown in the loading overlay.
  final UploadStage uploadStage;

  /// Size of the file being uploaded (bytes) — drives time-estimate copy.
  final int pendingFileSizeBytes;

  /// Page count after upload — used to decide chunked-compile warning.
  final int pendingFilePageCount;

  /// How many files are currently in PROCESSING state (brain compiling).
  final int compilingFileCount;

  /// Partial compile progress string, e.g. "8 of 12 pages added".
  /// Null when no progress info is available from the backend.
  final String? compileProgress;

  /// OCR quality verdict from the backend: GOOD, BORDERLINE, or REJECTED.
  final String? uploadQuality;

  /// Reason for the quality verdict (shown to user for BORDERLINE).
  final String? uploadQualityReason;

  /// OCR-extracted text from the backend (for review/edit on BORDERLINE uploads).
  final String? uploadExtractedText;

  /// File ID of the file being reviewed (BORDERLINE quality).
  final String? reviewFileId;

  /// True when the user needs to review borderline OCR quality.
  bool get needsOcrReview =>
      uploadQuality == 'BORDERLINE' && reviewFileId != null;

  int get totalFiles => files.length;
  bool get hasFiles => files.isNotEmpty;

  /// True during any active processing that blocks new uploads.
  bool get isBusy => isUploading || isCheckingRelevance;

  /// True while the loading overlay should be shown (user cannot navigate).
  bool get showsLoadingOverlay =>
      isBusy ||
      uploadStage == UploadStage.compilingBrain ||
      uploadStage == UploadStage.chunkedCompile;

  /// Terminal states: success, failure, or timeout.
  bool get isTerminalState =>
      uploadStage == UploadStage.compileSuccess ||
      uploadStage == UploadStage.compileFailed ||
      uploadStage == UploadStage.compileTimeout;

  /// True when the pending file is large enough to trigger chunked compile.
  bool get isLargeFile => pendingFileSizeBytes > 5 * 1024 * 1024 || pendingFilePageCount > 20;

  /// Estimated minutes to compile based on file size.
  String get estimatedCompileTime {
    if (pendingFilePageCount > 50 || pendingFileSizeBytes > 15 * 1024 * 1024) return '3–5 min';
    if (pendingFilePageCount > 20 || pendingFileSizeBytes > 5 * 1024 * 1024) return '1–2 min';
    return '30–60 sec';
  }

  UploadState copyWith({
    Avatar? avatar,
    List<UploadResult>? files,
    bool? isUploading,
    bool? isCheckingRelevance,
    Object? error = _sentinel,
    List<FileUploadError>? fileErrors,
    List<FileUploadWarning>? fileWarnings,
    Object? pendingFile = _sentinel,
    Object? pendingRelevance = _sentinel,
    Object? topicTag = _sentinel,
    Object? sourceType = _sentinel,
    UploadStage? uploadStage,
    int? pendingFileSizeBytes,
    int? pendingFilePageCount,
    int? compilingFileCount,
    Object? compileProgress = _sentinel,
    Object? uploadQuality = _sentinel,
    Object? uploadQualityReason = _sentinel,
    Object? uploadExtractedText = _sentinel,
    Object? reviewFileId = _sentinel,
  }) {
    return UploadState(
      avatar: avatar ?? this.avatar,
      files: files ?? this.files,
      isUploading: isUploading ?? this.isUploading,
      isCheckingRelevance: isCheckingRelevance ?? this.isCheckingRelevance,
      error: error == _sentinel ? this.error : error as String?,
      fileErrors: fileErrors ?? this.fileErrors,
      fileWarnings: fileWarnings ?? this.fileWarnings,
      pendingFile: pendingFile == _sentinel
          ? this.pendingFile
          : pendingFile as PlatformFile?,
      pendingRelevance: pendingRelevance == _sentinel
          ? this.pendingRelevance
          : pendingRelevance as RelevanceCheckResponse?,
      topicTag: topicTag == _sentinel ? this.topicTag : topicTag as String?,
      sourceType:
          sourceType == _sentinel ? this.sourceType : sourceType as String?,
      uploadStage: uploadStage ?? this.uploadStage,
      pendingFileSizeBytes: pendingFileSizeBytes ?? this.pendingFileSizeBytes,
      pendingFilePageCount: pendingFilePageCount ?? this.pendingFilePageCount,
      compilingFileCount: compilingFileCount ?? this.compilingFileCount,
      compileProgress: compileProgress == _sentinel
          ? this.compileProgress
          : compileProgress as String?,
      uploadQuality: uploadQuality == _sentinel
          ? this.uploadQuality
          : uploadQuality as String?,
      uploadQualityReason: uploadQualityReason == _sentinel
          ? this.uploadQualityReason
          : uploadQualityReason as String?,
      uploadExtractedText: uploadExtractedText == _sentinel
          ? this.uploadExtractedText
          : uploadExtractedText as String?,
      reviewFileId: reviewFileId == _sentinel
          ? this.reviewFileId
          : reviewFileId as String?,
    );
  }
}

const _sentinel = Object();

// ── Max file size enforced client-side (matches backend 25MB cap) ──
const _maxFileSizeBytes = 25 * 1024 * 1024;

@riverpod
class UploadViewModel extends _$UploadViewModel {
  late String _avatarId;
  Timer? _compilePoller;
  DateTime? _compileStartedAt;

  // 5-minute hard timeout: must exceed the backend's 4-min cap so the app only
  // times out when the backend genuinely stalled (not while it's still working).
  static const _compileTimeout = Duration(minutes: 5);
  // Poll every 5s — fast enough to detect success, cheap enough not to flood.
  static const _pollInterval = Duration(seconds: 5);

  @override
  UploadState build(String avatarId) {
    _avatarId = avatarId;
    _loadAvatar();
    _loadFiles();
    ref.onDispose(() {
      _compilePoller?.cancel();
      _compilePoller = null;
    });
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
      502 => 'The server is busy right now. '
            'Wait a moment and try uploading "$fileName" again.',
      503 => 'Mochi is busy right now — try again in a moment.',
      504 => 'Mochi is still working on your notes in the background '
            '— check back in a few minutes.',
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

  /// Launches the ML Kit document scanner (auto-crop + deskew + brightness).
  /// Falls back to raw ImagePicker on any platform error (e.g. Android < 10,
  /// or simulator without ML Kit play services).
  Future<void> pickFromCamera() async {
    try {
      final paths = await CunningDocumentScanner.getPictures(
        noOfPages: 1,
        isGalleryImportAllowed: false,
      );
      if (paths == null || paths.isEmpty) return;
      final path = paths.first;
      final file = File(path);
      final platformFile = PlatformFile(
        name: '${DateTime.now().millisecondsSinceEpoch}_scan.jpg',
        path: path,
        size: await file.length(),
      );
      await _checkRelevanceAndUpload(platformFile);
    } catch (e) {
      // Fallback: plain camera capture (no auto-crop/deskew)
      appLog.w('[Upload] Document scanner unavailable, falling back to ImagePicker: $e');
      await _pickFromCameraFallback();
    }
  }

  Future<void> _pickFromCameraFallback() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera, imageQuality: 90);
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

  /// Upload typed/pasted text as a .txt file. Used by the Type tab.
  Future<void> uploadTypedText(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    appLog.i('[Upload] Typed text upload: ${trimmed.length} chars');

    try {
      final dir = await getTemporaryDirectory();
      final ts = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'typed-notes-$ts.txt';
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(trimmed);

      final platformFile = PlatformFile(
        name: fileName,
        path: file.path,
        size: trimmed.length,
      );
      await _checkRelevanceAndUpload(platformFile);
    } catch (e, st) {
      appLog.e('[Upload] Typed text upload failed', error: e, stackTrace: st);
      state = state.copyWith(
          error: 'Could not save your notes. Try again.');
    }
  }

  Future<void> _checkRelevanceAndUpload(PlatformFile file) async {
    appLog.i('[Upload] Relevance check: ${file.name} size=${file.size}B');
    state = state.copyWith(
      isCheckingRelevance: true,
      uploadStage: UploadStage.checkingRelevance,
      pendingFile: file,
      pendingFileSizeBytes: file.size,
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

      // A2: upload straight through only when it's on-topic AND looks like study
      // material; otherwise the UI shows the (gentle) add-anyway warning dialog.
      if (relevance.isRelevant && relevance.studyMaterial) await uploadFile(file);
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
      uploadStage: UploadStage.uploading,
      pendingFileSizeBytes: file.size,
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
        options: Options(
          receiveTimeout: const Duration(minutes: 3),
          sendTimeout: const Duration(minutes: 2),
        ),
      );
      final data = response.data ?? const <String, dynamic>{};
      final titlesRaw = data['wikiPageTitles'];
      final wikiPageTitles = titlesRaw is List
          ? titlesRaw.whereType<String>().toList()
          : <String>[];
      final servedBy = data['servedBy'] as String?;
      final degraded = data['degraded'] == true;
      final pagesCompiled = (data['pagesCompiled'] as num?)?.toInt() ?? 0;
      final pagesTotal = (data['pagesTotal'] as num?)?.toInt();
      // Parse OCR quality fields from the backend response
      final quality = data['quality'] as String?;
      final qualityReason = data['qualityReason'] as String?;
      final extractedTextFromServer = data['extractedText'] as String?;
      final fileId = (data['fileId'] ?? data['id'] ?? '') as String;

      final result = UploadResult(
        id: fileId,
        avatarId: _avatarId,
        fileName: file.name,
        status: UploadStatus.ready,
        pageCount: (data['pageCount'] as num?)?.toInt() ?? 0,
        wikiPageTitles: wikiPageTitles,
        uploadedAt: DateTime.now(),
        servedBy: servedBy,
        degraded: degraded,
        pagesCompiled: pagesCompiled,
        pagesTotal: pagesTotal,
      );
      appLog.i('[Upload] Success: ${result.id} pages=${result.pageCount}'
          '${servedBy != null ? " servedBy=$servedBy" : ""}'
          '${degraded ? " DEGRADED" : ""}'
          '${quality != null ? " quality=$quality" : ""}');
      ref.read(analyticsProvider).event(
        AnalyticsEvents.uploadNote,
        props: {
          'avatar_id': _avatarId,
          'file_name': file.name,
          'file_size_bytes': file.size,
          'page_count': result.pageCount,
        },
      );
      final isLarge = file.size > 5 * 1024 * 1024 || result.pageCount > 20;

      // If the backend used a fallback reader, surface a friendly info note.
      final warnings = [...state.fileWarnings];
      if (degraded) {
        warnings.add(FileUploadWarning(
          fileName: file.name,
          message: 'I used my backup reader for this one '
              '— double-check it looks right.',
        ));
      }

      state = state.copyWith(
        isUploading: false,
        uploadStage: isLarge ? UploadStage.chunkedCompile : UploadStage.compilingBrain,
        pendingFilePageCount: result.pageCount,
        compilingFileCount: state.compilingFileCount + 1,
        files: [...state.files, result],
        fileWarnings: warnings,
        uploadQuality: quality,
        uploadQualityReason: qualityReason,
        uploadExtractedText: extractedTextFromServer,
        reviewFileId: quality == 'BORDERLINE' ? fileId : null,
      );
      ref.invalidate(libraryViewModelProvider);
      ref.invalidate(homeViewModelProvider);
      // ignore: discarded_futures
      _triggerRecompile();
      // Start polling brainState so the loading overlay knows when to
      // transition to success or timeout — user is blocked on this screen.
      _startCompilePoller();
    } on DioException catch (e, st) {
      appLog.e('[Upload] Failed: ${file.name} status=${e.response?.statusCode}',
          error: e, stackTrace: st);

      // 504 Gateway Timeout: the backend is still working — transition to
      // compileTimeout stage so the user sees "still working in background"
      // instead of a hard error.
      if (e.response?.statusCode == 504) {
        appLog.w('[Upload] 504 for ${file.name} — treating as compile-in-progress');
        state = state.copyWith(
          isUploading: false,
          uploadStage: UploadStage.compileTimeout,
          compilingFileCount: 0,
          error: 'Mochi is still working on your notes in the background '
              '— check back in a few minutes.',
        );
        return;
      }

      // 409 duplicate/similar: the content IS already in the brain.
      // Invalidate library so the user sees the existing pages — then
      // surface a friendly info message, not a red error.
      if (e.response?.statusCode == 409) {
        ref.invalidate(libraryViewModelProvider);
        ref.invalidate(homeViewModelProvider);
      }

      final msg = _friendlyUploadError(e, file.name);
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

  // ── Compile polling ───────────────────────────────────────────────────────

  void _startCompilePoller() {
    _compilePoller?.cancel();
    _compileStartedAt = DateTime.now();
    appLog.d('[Upload] Compile poller started (timeout=${_compileTimeout.inSeconds}s)');
    _compilePoller = Timer.periodic(_pollInterval, (_) => _pollCompileStatus());
  }

  Future<void> _pollCompileStatus() async {
    final elapsed = DateTime.now().difference(_compileStartedAt ?? DateTime.now());
    if (elapsed >= _compileTimeout) {
      _compilePoller?.cancel();
      _compilePoller = null;
      appLog.w('[Upload] Compile timed out after ${elapsed.inSeconds}s for avatar=$_avatarId');
      state = state.copyWith(
        uploadStage: UploadStage.compileTimeout,
        compilingFileCount: 0,
        error: 'Mochi is taking too long to read your notes. '
            'The brain will continue updating in the background — '
            'check back in a few minutes.',
      );
      return;
    }

    try {
      final dio = ref.read(dioProvider);
      final resp = await dio.get<dynamic>('/api/v1/avatars/$_avatarId');
      final data = resp.data is Map ? resp.data as Map : {};
      final brainState = data['brainState']?.toString() ?? 'READY';
      final wikiPageCount = (data['wikiPageCount'] as num?)?.toInt() ?? 0;
      final pagesCompiled = (data['pagesCompiled'] as num?)?.toInt() ?? 0;
      final pagesTotal = (data['pagesTotal'] as num?)?.toInt();
      appLog.d('[Upload] Poll: brainState=$brainState wikiPageCount=$wikiPageCount'
          ' pagesCompiled=$pagesCompiled pagesTotal=$pagesTotal'
          ' elapsed=${elapsed.inSeconds}s');

      // Update partial progress display when the backend reports it.
      if (pagesCompiled > 0 && pagesTotal != null && pagesCompiled < pagesTotal) {
        state = state.copyWith(
          compileProgress: '$pagesCompiled of $pagesTotal pages added',
        );
      }

      if (brainState == 'READY') {
        _compilePoller?.cancel();
        _compilePoller = null;
        if (wikiPageCount > 0) {
          appLog.i('[Upload] Compile SUCCESS: $wikiPageCount pages for avatar=$_avatarId');
          state = state.copyWith(
            uploadStage: UploadStage.compileSuccess,
            compilingFileCount: 0,
          );
          ref.invalidate(libraryViewModelProvider);
          ref.invalidate(homeViewModelProvider);
        } else {
          // brainState == READY but 0 pages — compile ran and produced nothing
          // (parse error, empty extract, etc.). Show error so user can retry.
          appLog.w('[Upload] Compile finished but produced 0 pages for avatar=$_avatarId');
          state = state.copyWith(
            uploadStage: UploadStage.compileFailed,
            compilingFileCount: 0,
            error: 'Mochi couldn\'t process your notes. '
                'Try uploading again — if the problem persists, '
                'try a smaller file or a different format.',
          );
        }
      }
      // Still COMPILING or PENDING_RECOMPILE — keep polling
    } catch (e) {
      appLog.w('[Upload] Compile poll failed (non-fatal): $e');
      // Don't stop polling on transient errors — let the timeout handle it
    }
  }

  /// Calls POST /wiki/recompile to retry any FAILED files from prior outages.
  /// Fire-and-forget — never blocks the upload response.
  Future<void> _triggerRecompile() async {
    try {
      final dio = ref.read(dioProvider);
      final result = await dio.post<Map<String, dynamic>>(
        '/api/v1/avatars/$_avatarId/wiki/recompile',
      );
      final total = (result.data?['pagesCreated'] as num? ?? 0) +
          (result.data?['pagesUpdated'] as num? ?? 0);
      if (total > 0) {
        appLog.i('[Upload] Recompile produced $total page(s) from previously failed files');
        ref.invalidate(libraryViewModelProvider);
        ref.invalidate(homeViewModelProvider);
      }
    } catch (e) {
      appLog.d('[Upload] Recompile skipped or failed (non-fatal): $e');
    }
  }

  Future<void> deleteFile(String fileId) async {
    try {
      final dio = ref.read(dioProvider);
      await dio.delete('/api/v1/avatars/$_avatarId/files/$fileId');
      appLog.i('[Upload] Deleted file $fileId — triggering brain recompile');
      // Recompile so wiki pages from the deleted file are removed from the brain.
      // The backend DeleteFileUseCase also triggers async recompile server-side,
      // but we call it explicitly here to get the updated page count sooner.
      _triggerRecompile();
    } catch (e, st) {
      appLog.w('[Upload] Delete failed, removing locally', error: e, stackTrace: st);
    }
    state = state.copyWith(
      files: state.files.where((f) => f.id != fileId).toList(),
    );
    // Refresh library so the brain page count reflects the deletion.
    ref.invalidate(libraryViewModelProvider);
    ref.invalidate(homeViewModelProvider);
  }

  void clearPendingRelevance() {
    state = state.copyWith(pendingFile: null, pendingRelevance: null);
  }

  void clearErrors() {
    state = state.copyWith(error: null, fileErrors: [], fileWarnings: []);
  }

  /// Review a BORDERLINE OCR file: approve as-is or submit edited text.
  Future<void> reviewFile(String fileId,
      {required String action, String? editedText}) async {
    appLog.i('[Upload] Review file=$fileId action=$action');
    try {
      final dio = ref.read(dioProvider);
      await dio.patch<Map<String, dynamic>>(
        '/api/v1/avatars/$_avatarId/files/$fileId/review',
        data: {
          'action': action,
          if (editedText != null) 'editedText': editedText,
        },
      );
      appLog.i('[Upload] Review accepted for file=$fileId');
      // Clear review state
      state = state.copyWith(
        uploadQuality: null,
        uploadQualityReason: null,
        uploadExtractedText: null,
        reviewFileId: null,
      );
      ref.invalidate(libraryViewModelProvider);
      ref.invalidate(homeViewModelProvider);
    } on DioException catch (e, st) {
      appLog.e('[Upload] Review failed for file=$fileId',
          error: e, stackTrace: st);
      state = state.copyWith(
          error: 'Could not save your review. Please try again.');
    }
  }

  /// Clear the OCR review state (user dismissed without action).
  void clearOcrReview() {
    state = state.copyWith(
      uploadQuality: null,
      uploadQualityReason: null,
      uploadExtractedText: null,
      reviewFileId: null,
    );
  }
}
