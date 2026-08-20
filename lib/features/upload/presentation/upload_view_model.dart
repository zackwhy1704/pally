import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/shared/models/avatar.dart';
import 'package:pally/shared/models/upload_result.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/observability/observability.dart';
import 'package:pally/core/observability/observability_providers.dart';
import 'package:pally/core/services/document_scanner_service.dart';
import 'package:pally/core/utils/logger.dart';
import 'package:pally/features/library/presentation/library_view_model.dart';
import 'package:pally/features/home/presentation/home_view_model.dart';

part 'upload_view_model.g.dart';

// ── Typed upload errors/warnings ─────────────────────────────────────────────
// Error IDENTITY is state; error WORDING is presentation. The view-model returns
// a typed kind (+ any dynamic detail as fields); the widget localizes it at RENDER
// time via localizedUploadError (upload_error_localizer.dart). This keeps the
// notifier free of AppLocalizations (layering) and re-localizes for free after a
// live locale switch — a string baked into state at error-time would stay in the
// old language. Mirrors the backend FailureKind idiom: the enum crosses the
// boundary, the surface owns the words.

/// Every distinct upload failure the UI can render. serverMessage carries the
/// backend's own honest message verbatim (already localized by content_language).
enum UploadErrorKind {
  couldNotRead, empty, tooLargeClient, unsupportedType,
  corrupted400, sessionExpired, planLimit, noPermission,
  duplicate, similar, tooLarge413, unsupported415, tooMany,
  processing500, serverBusy502, mochiBusy503, stillWorking504,
  timeout, noInternet, failed, unexpected, serverMessage,
}

class UploadError {
  const UploadError(this.kind, {this.fileName, this.detail});
  final UploadErrorKind kind;

  /// The file the error is about (most kinds carry one).
  final String? fileName;

  /// Dynamic detail whose meaning depends on kind: size in MB (tooLargeClient),
  /// the extension (unsupportedType), the existing file name (duplicate/similar),
  /// or the raw backend message (serverMessage).
  final String? detail;
}

/// Non-error info notes shown alongside a file (e.g. degraded fallback reader).
enum UploadWarningKind { backupReader, lowText }

/// Rough processing-time estimate shown before a large upload.
enum UploadEstimate { short, medium, long }

// ── Per-file upload error/warning (shown alongside the file, not as a toast) ──

class FileUploadError {
  const FileUploadError({required this.fileName, required this.error});
  final String fileName;
  final UploadError error;
}

class FileUploadWarning {
  const FileUploadWarning({required this.fileName, required this.kind});
  final String fileName;
  final UploadWarningKind kind;
}

@immutable
/// Which processing stage is actively running for a file.
enum UploadStage {
  idle,
  scanning,         // ML Kit document scanner open
  checkingSize,     // local validation
  awaitingLargeFileConfirm, // large file — preflight confirm before committing
  awaitingChapterPick, // large doc segmented into chapters — show the picker
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
  final UploadError? error;
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

  /// Estimated compile time bucket based on file size (localized at display).
  UploadEstimate get estimatedCompileTime {
    if (pendingFilePageCount > 50 || pendingFileSizeBytes > 15 * 1024 * 1024) {
      return UploadEstimate.long;
    }
    if (pendingFilePageCount > 20 || pendingFileSizeBytes > 5 * 1024 * 1024) {
      return UploadEstimate.medium;
    }
    return UploadEstimate.short;
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
      error: error == _sentinel ? this.error : error as UploadError?,
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
/// Above this, warn the user UP FRONT that building the brain is slow (the compile
/// is genuinely minutes for a big doc). Matches [UploadState.isLargeFile]'s size
/// threshold so the preflight and the in-progress "large" copy agree.
const _largeFileWarnBytes = 5 * 1024 * 1024;

@riverpod
class UploadViewModel extends _$UploadViewModel {
  late String _avatarId;
  Timer? _compilePoller;
  DateTime? _compileStartedAt;
  // Progress-aware polling: the last page count the backend reported + when it
  // last advanced. We keep polling while pages are still being ADDED (a large doc
  // compiles for 5-7 min in the background) and only give up on a genuine stall or
  // an absolute ceiling — never on a fixed wall-clock (which false-failed big
  // files at 5 min even though the backend was still working).
  int _lastCompileProgress = 0;
  DateTime? _lastCompileProgressAt;
  // Module-generation phase progress (backend now reports modulesCompleted/
  // modulesTotal on the avatar-status response — see ModuleGenerationProgressStore
  // on the backend). Tracked separately from _lastCompileProgress: wikiPageCount
  // is already at its final value by the time module-gen starts, so a plain max()
  // of the two signals would never detect module-gen advancing.
  int _lastModulesCompleted = 0;

  // Absolute backstop, far above the real worst case (~5-7 min for ~170 pages) —
  // only trips if the job is truly wedged or status keeps erroring.
  static const _compileHardCeiling = Duration(minutes: 15);
  // Give up (show "still working, come back later") only when NEITHER wiki-page
  // extraction NOR module generation has produced anything new for this long.
  //
  // SUPERSEDES an earlier version of this fix that used a flat 90s-since-compile-
  // START threshold. That was wrong, proven by real Railway production data (37
  // module-completion events across the full log retention window, clustered into
  // 6 real compile sessions): 4 of 6 real CENTRE-tier sessions ran 3.5-6 minutes
  // total, so a flat 90s elapsed-since-start threshold fired mid-compile on a
  // healthy, actively-progressing job in the MAJORITY of real cases — not a rare
  // edge case. The real fix is this: key off "no module has completed recently",
  // not "how long since compile started". Max observed inter-module gap in that
  // sample was 86s (kestrel-method-overview → wind-reading session, 8/19).
  //
  // 180s is a DELIBERATELY GENEROUS placeholder (~2.1x that 86s max), not a tuned
  // final number — 6 sessions is too small a sample to lock a threshold in on.
  // Revisit once there's more production data; don't defend this number as final.
  static const _moduleProgressStallGrace = Duration(seconds: 180);
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

  /// Returns a typed error if the file is invalid, or null. Wording is resolved
  /// at display via localizedUploadError.
  UploadError? _validateFile(PlatformFile file) {
    if (file.path == null) {
      return UploadError(UploadErrorKind.couldNotRead, fileName: file.name);
    }
    if (file.size == 0) {
      return UploadError(UploadErrorKind.empty, fileName: file.name);
    }
    if (file.size > _maxFileSizeBytes) {
      final mb = (file.size / (1024 * 1024)).toStringAsFixed(1);
      return UploadError(UploadErrorKind.tooLargeClient,
          fileName: file.name, detail: mb);
    }
    final ext = file.name.split('.').last.toLowerCase();
    const allowed = {'pdf', 'jpg', 'jpeg', 'png', 'heic', 'webp', 'txt'};
    if (!allowed.contains(ext)) {
      return UploadError(UploadErrorKind.unsupportedType,
          fileName: file.name, detail: ext);
    }
    return null;
  }

  // ── Specific server-error messages ─────────────────────────────────────────

  /// Maps HTTP status codes + response bodies to actionable user messages.
  @visibleForTesting
  UploadError friendlyUploadError(DioException e, String fileName) {
    final status = e.response?.statusCode;
    final body = e.response?.data;
    final serverMsg = body is Map
        ? (body['error'] as String?)?.trim()
        : null;
    final hasServerMsg = serverMsg != null && serverMsg.isNotEmpty;

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

    // A backend message (400/500/default with a body) is the server's own honest,
    // already-localized wording — pass it through verbatim, never re-translate.
    UploadError serverOr(UploadErrorKind fallback) => hasServerMsg
        ? UploadError(UploadErrorKind.serverMessage, detail: serverMsg)
        : UploadError(fallback, fileName: fileName);

    return switch (status) {
      400 => serverOr(UploadErrorKind.corrupted400),
      401 => const UploadError(UploadErrorKind.sessionExpired),
      // Neutral, iOS-safe: no price, no purchase CTA (App Store anti-steering).
      402 => const UploadError(UploadErrorKind.planLimit),
      403 => const UploadError(UploadErrorKind.noPermission),
      409 when dupCode == 'DUPLICATE_FILE' =>
            UploadError(UploadErrorKind.duplicate,
                fileName: fileName, detail: dupExisting),
      409 when dupCode == 'SIMILAR_CONTENT' =>
            UploadError(UploadErrorKind.similar,
                fileName: fileName, detail: dupExisting),
      413 => UploadError(UploadErrorKind.tooLarge413, fileName: fileName),
      415 => UploadError(UploadErrorKind.unsupported415, fileName: fileName),
      429 => const UploadError(UploadErrorKind.tooMany),
      500 => serverOr(UploadErrorKind.processing500),
      502 => UploadError(UploadErrorKind.serverBusy502, fileName: fileName),
      503 => const UploadError(UploadErrorKind.mochiBusy503),
      504 => const UploadError(UploadErrorKind.stillWorking504),
      _ when e.type == DioExceptionType.connectionTimeout ||
             e.type == DioExceptionType.receiveTimeout ||
             e.type == DioExceptionType.sendTimeout =>
            UploadError(UploadErrorKind.timeout, fileName: fileName),
      _ when e.type == DioExceptionType.connectionError =>
            const UploadError(UploadErrorKind.noInternet),
      _ => serverOr(UploadErrorKind.failed),
    };
  }

  // ── Pick & upload flows ────────────────────────────────────────────────────

  /// Launches the native document scanner (auto-crop + deskew + brightness),
  /// falling back to a plain camera capture if it's unavailable.
  Future<void> pickFromCamera() async {
    final scanned = await DocumentScannerService.scan(logTag: 'Upload');
    if (scanned == null) return;
    final file = File(scanned.path);
    final platformFile = PlatformFile(
      name: scanned.originalName ??
          '${DateTime.now().millisecondsSinceEpoch}_scan.jpg',
      path: scanned.path,
      size: await file.length(),
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
        newErrors.add(FileUploadError(fileName: file.name, error: err));
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

  Future<void> _checkRelevanceAndUpload(PlatformFile file,
      {bool confirmedLarge = false}) async {
    // PREFLIGHT (pre-empt the slow compile): a big file takes minutes to build
    // into a brain, so set expectations BEFORE committing — and before we spend a
    // relevance Claude call on a file the user may cancel. The screen watches this
    // stage, shows a confirm dialog, and calls confirmLargeFileUpload / cancel.
    if (!confirmedLarge && needsLargeFilePreflight(file.size)) {
      appLog.i('[Upload] Large file preflight: ${file.name} size=${file.size}B');
      state = state.copyWith(
        isCheckingRelevance: false,
        isUploading: false,
        uploadStage: UploadStage.awaitingLargeFileConfirm,
        pendingFile: file,
        pendingFileSizeBytes: file.size,
        pendingRelevance: null,
        error: null,
      );
      return;
    }

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
      // Either way the client has adjudicated relevance, so proceed with
      // skipServerRelevance so the server does NOT re-run its (divergent) check.
      final plan = planAfterRelevance(relevance);
      if (plan.uploadNow) {
        await uploadFile(file, skipRelevance: plan.skipServerRelevance);
      }
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
      appLog.w('[Upload] Null path for file: ${file.name}');
      _appendFileError(FileUploadError(fileName: file.name,
          error: UploadError(UploadErrorKind.couldNotRead, fileName: file.name)));
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

      // Defect #2: a 200 can still be a RelevanceWarning (fail-open path — the client's
      // own /relevance errored so the server re-checked and scored it off-topic). Surface
      // the actionable add-anyway dialog instead of parsing it as a silent 0-page success.
      final warning = relevanceWarningFrom(data);
      if (warning != null) {
        appLog.i('[Upload] Server relevance warning score=${warning.score} '
            '— prompting add-anyway instead of silent 0-page success');
        state = state.copyWith(
          isUploading: false,
          isCheckingRelevance: false,
          uploadStage: UploadStage.checkingRelevance,
          pendingFile: file,
          pendingFileSizeBytes: file.size,
          pendingRelevance: warning,
        );
        return;
      }

      // Segmented upload: a large doc was split into pickable chapters and NOT
      // compiled. Show the chapter picker instead of the compile overlay — nothing
      // compiles until the student picks a chapter (the money rule). Same contract
      // the memoly web client consumes; keep the two in lockstep.
      final chunksRaw = data['chunks'];
      if (chunksRaw is List && chunksRaw.isNotEmpty) {
        appLog.i('[Upload] SEGMENTED: ${chunksRaw.length} chapters — showing picker');
        state = state.copyWith(
          isUploading: false,
          isCheckingRelevance: false,
          uploadStage: UploadStage.awaitingChapterPick,
        );
        ref.invalidate(libraryViewModelProvider);
        return;
      }

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
      // file_type only — never the raw file_name. A child can name a photo
      // after themselves or their school (e.g. "sarah_tanjongkatong_p3.jpg"),
      // and that's PII sent to a US third party the same as the identify()
      // email/display_name issue.
      ref.read(analyticsProvider).event(
        AnalyticsEvents.uploadNote,
        props: {
          'avatar_id': _avatarId,
          'file_type': file.extension,
          'file_size_bytes': file.size,
          'page_count': result.pageCount,
        },
      );
      final isLarge = file.size > 5 * 1024 * 1024 || result.pageCount > 20;

      // If the backend used a fallback reader, surface a friendly info note.
      final warnings = [...state.fileWarnings];
      if (degraded) {
        warnings.add(FileUploadWarning(
          fileName: file.name, kind: UploadWarningKind.backupReader,
        ));
      }
      // Extraction-quality guard: a file that read as almost no text won't train
      // well. -1 means the field is absent (older backend) → don't warn.
      final extractedChars = (data['extractedChars'] as num?)?.toInt() ?? -1;
      if (extractedChars >= 0 && extractedChars < 200) {
        warnings.add(FileUploadWarning(
          fileName: file.name, kind: UploadWarningKind.lowText,
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

      final msg = friendlyUploadError(e, file.name);
      _appendFileError(FileUploadError(fileName: file.name, error: msg));
      // Reset the stage: a failed POST left uploadStage==uploading, so the UI read a stuck
      // "uploading" spinner behind the error. Back to idle — the error surface carries the state.
      state = state.copyWith(
          isUploading: false, uploadStage: UploadStage.idle, error: msg);
    } catch (e, st) {
      appLog.e('[Upload] Unexpected error: ${file.name}', error: e, stackTrace: st);
      final msg = UploadError(UploadErrorKind.unexpected, fileName: file.name);
      _appendFileError(FileUploadError(fileName: file.name, error: msg));
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
    _lastCompileProgress = 0;
    _lastModulesCompleted = 0;
    _lastCompileProgressAt = DateTime.now();
    appLog.d('[Upload] Compile poller started '
        '(stallGrace=${_moduleProgressStallGrace.inSeconds}s '
        'ceiling=${_compileHardCeiling.inSeconds}s)');
    _compilePoller = Timer.periodic(_pollInterval, (_) => _pollCompileStatus());
  }

  Future<void> _pollCompileStatus() async {
    final now = DateTime.now();
    final elapsed = now.difference(_compileStartedAt ?? now);
    // Absolute backstop only. We NO LONGER give up on a fixed wall-clock while the
    // backend is still adding pages (that false-failed large files at 5 min) — the
    // stall + READY checks below own the give-up decision.
    if (elapsed >= _compileHardCeiling) {
      _stopPollingStillWorking(elapsed);
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
      // Module-generation phase — the poll's former blind spot. Null (not 0) when
      // no generation batch is in flight; a real 0 means "batch just started".
      final modulesCompleted = (data['modulesCompleted'] as num?)?.toInt();
      final modulesTotal = (data['modulesTotal'] as num?)?.toInt();
      appLog.d('[Upload] Poll: brainState=$brainState wikiPageCount=$wikiPageCount'
          ' pagesCompiled=$pagesCompiled pagesTotal=$pagesTotal'
          ' modulesCompleted=$modulesCompleted modulesTotal=$modulesTotal'
          ' elapsed=${elapsed.inSeconds}s');

      // Track real progress on BOTH phases — wiki-page extraction AND module
      // generation are separate signals (wikiPageCount is already at its final
      // value by the time module-gen starts, so a plain max() across both would
      // never see module-gen advancing). The stall clock resets whenever EITHER
      // phase produces something new; that's what lets a multi-minute, multi-
      // module compile keep polling instead of a flat elapsed-since-start timer
      // firing mid-compile on a job that is actively, healthily progressing.
      final pageProgress = pagesCompiled > wikiPageCount ? pagesCompiled : wikiPageCount;
      bool progressed = false;
      if (pageProgress > _lastCompileProgress) {
        _lastCompileProgress = pageProgress;
        progressed = true;
      }
      if (modulesCompleted != null && modulesCompleted > _lastModulesCompleted) {
        _lastModulesCompleted = modulesCompleted;
        progressed = true;
      }
      if (progressed) {
        _lastCompileProgressAt = now;
      }
      // Progress display: prefer the module-generation phase once it starts —
      // it's the later, longer-running phase and the more relevant "how much
      // further" signal once wiki-page extraction has already finished.
      if (modulesCompleted != null && modulesTotal != null && modulesCompleted < modulesTotal) {
        state = state.copyWith(
          compileProgress: '$modulesCompleted of $modulesTotal modules built',
        );
      } else if (pagesCompiled > 0 && pagesTotal != null && pagesCompiled < pagesTotal) {
        state = state.copyWith(
          compileProgress: '$pagesCompiled of $pagesTotal pages added',
        );
      }

      final sinceProgress =
          now.difference(_lastCompileProgressAt ?? _compileStartedAt ?? now);
      final action = decideCompilePoll(
        brainState: brainState,
        wikiPageCount: wikiPageCount,
        elapsed: elapsed,
        sinceLastProgress: sinceProgress,
        hardCeiling: _compileHardCeiling,
        stallGrace: _moduleProgressStallGrace,
      );
      if (action == CompilePollAction.success) {
        _compilePoller?.cancel();
        _compilePoller = null;
        appLog.i('[Upload] Compile SUCCESS: $wikiPageCount pages for avatar=$_avatarId');
        state = state.copyWith(
          uploadStage: UploadStage.compileSuccess,
          compilingFileCount: 0,
        );
        ref.invalidate(libraryViewModelProvider);
        ref.invalidate(homeViewModelProvider);
      } else if (action == CompilePollAction.emptyFailed) {
        // brainState == READY but 0 pages — compile ran and produced nothing
        // (parse error, empty extract, etc.). Show error so user can retry.
        _compilePoller?.cancel();
        _compilePoller = null;
        appLog.w('[Upload] Compile finished but produced 0 pages for avatar=$_avatarId');
        state = state.copyWith(
          uploadStage: UploadStage.compileFailed,
          compilingFileCount: 0,
          error: 'Mochi couldn\'t process your notes. '
              'Try uploading again — if the problem persists, '
              'try a smaller file or a different format.',
        );
      } else if (action == CompilePollAction.stillWorkingBackground) {
        _stopPollingStillWorking(elapsed);
      }
      // else keepPolling — still building AND advancing, do nothing.
    } catch (e) {
      appLog.w('[Upload] Compile poll failed (non-fatal): $e');
      // Keep polling; the hard ceiling is the backstop for persistent errors.
    }
  }

  /// Stops the poller when the compile is still running past our client wait
  /// (stall grace or hard ceiling). NOT a failure — the backend keeps compiling
  /// in the background; framed as still-working, not an error.
  void _stopPollingStillWorking(Duration elapsed) {
    _compilePoller?.cancel();
    _compilePoller = null;
    appLog.w('[Upload] Compile poll stopped after ${elapsed.inSeconds}s — still '
        'running in the background for avatar=$_avatarId');
    state = state.copyWith(
      uploadStage: UploadStage.compileTimeout,
      compilingFileCount: 0,
      error: 'Mochi is still building your brain — big files can take a few '
          'minutes. It keeps going in the background; check back shortly.',
    );
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

  /// User confirmed the large-file preflight → proceed with the pending file
  /// (relevance check + upload), skipping the preflight this time.
  Future<void> confirmLargeFileUpload() async {
    final file = state.pendingFile;
    if (file == null) return;
    await _checkRelevanceAndUpload(file, confirmedLarge: true);
  }

  /// User backed out of the large-file preflight → return to the idle pick state.
  void cancelLargeFileUpload() {
    state = state.copyWith(
      uploadStage: UploadStage.idle,
      isUploading: false,
      isCheckingRelevance: false,
      pendingFile: null,
      pendingFileSizeBytes: 0,
      pendingRelevance: null,
    );
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

  /// Return the upload flow to idle (e.g. after the chapter picker closes).
  void resetToIdle() {
    state = state.copyWith(uploadStage: UploadStage.idle, isUploading: false);
  }
}

/// What the compile poller should do given the latest status. Extracted as a pure
/// function so the give-up policy is unit-testable without driving real Timers.
enum CompilePollAction { keepPolling, success, emptyFailed, stillWorkingBackground }

/// Decide the poller's next action.
///
/// The key fix: while the brain is still compiling, we keep polling as long as
/// pages are still being added — we give up ONLY on a genuine stall (no new pages
/// for [stallGrace]) or an absolute [hardCeiling]. The old code gave up on a fixed
/// 5-minute wall-clock, which false-failed large files that legitimately take 5-7
/// minutes in the background.
@visibleForTesting
CompilePollAction decideCompilePoll({
  required String brainState,
  required int wikiPageCount,
  required Duration elapsed,
  required Duration sinceLastProgress,
  Duration hardCeiling = const Duration(minutes: 15),
  Duration stallGrace = const Duration(minutes: 4),
}) {
  if (brainState == 'READY') {
    return wikiPageCount > 0
        ? CompilePollAction.success
        : CompilePollAction.emptyFailed;
  }
  if (elapsed >= hardCeiling || sinceLastProgress >= stallGrace) {
    return CompilePollAction.stillWorkingBackground;
  }
  return CompilePollAction.keepPolling;
}

/// After the client's OWN `/relevance` check, decide what to do next. The client owns
/// the relevance decision, so on EVERY path where we then proceed to upload we tell the
/// server to skip its relevance re-check (`skipServerRelevance: true`). A server re-check
/// is a second, non-deterministic Claude call that can diverge from the one we just ran:
/// an on-topic file the client passed gets re-scored off-topic, marked IRRELEVANT, and
/// silently never compiled (the sales-book false-block that showed "something went wrong").
/// Whether a file is large enough to warrant a PRE-UPLOAD confirm (the compile is
/// genuinely slow for big docs, so we set expectations before the user commits).
/// Pure + testable; the threshold matches [UploadState.isLargeFile]'s size cutoff.
@visibleForTesting
bool needsLargeFilePreflight(int sizeBytes) => sizeBytes > _largeFileWarnBytes;

@visibleForTesting
({bool uploadNow, bool skipServerRelevance, bool askAddAnyway}) planAfterRelevance(
    RelevanceCheckResponse r) {
  final passed = r.isRelevant && r.studyMaterial;
  return (uploadNow: passed, skipServerRelevance: true, askAddAnyway: !passed);
}

/// A `POST /files` 200 body can be a Success OR a RelevanceWarning — the latter only when
/// the server actually re-checked (the fail-open path: the client's own `/relevance` call
/// errored, so the upload re-adjudicated). The warning uniquely carries (`reason`, `score`);
/// a Success uses `qualityReason`/`pageCount`/`wikiPageTitles` and never a bare `reason`.
/// Returns a warning-shaped [RelevanceCheckResponse] to drive the add-anyway dialog, or
/// null for a normal Success — so a warning is NEVER parsed as a silent 0-page upload.
/// SHARED: both the main upload path and the onboarding path use this to detect a 200+
/// irrelevant verdict (keep the two in lockstep — a divergence re-opens the fiction bug).
RelevanceCheckResponse? relevanceWarningFrom(Map<String, dynamic> data) {
  final reason = data['reason'];
  final score = data['score'];
  if (reason is! String || reason.isEmpty || score is! num) return null;
  return RelevanceCheckResponse(
    isRelevant: false,
    studyMaterial: false,
    score: score.toDouble(),
    reason: reason,
  );
}
