import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/error/pally_error.dart';
import 'package:pally/shared/models/avatar.dart';
import 'package:pally/shared/models/wiki_page.dart';

part 'wiki_viewer_view_model.g.dart';

// Simple model for a source document shown in the Brain screen.
@immutable
class SourceFile {
  const SourceFile({
    required this.id,
    required this.fileName,
    required this.status,
    this.pageCount = 0,
  });

  final String id;
  final String fileName;
  final String status; // PROCESSING | READY | FAILED | IRRELEVANT
  final int pageCount;

  bool get isProcessing => status.toUpperCase() == 'PROCESSING';
  bool get isFailed => status.toUpperCase() == 'FAILED';

  factory SourceFile.fromJson(Map<String, dynamic> json) => SourceFile(
        id: json['id'] as String? ?? '',
        fileName: json['fileName'] as String? ?? json['file_name'] as String? ?? 'Unknown',
        status: json['status'] as String? ?? 'PROCESSING',
        pageCount: (json['pageCount'] as num?)?.toInt() ?? 0,
      );
}

@immutable
class WikiViewerState {
  const WikiViewerState({
    this.pages = const [],
    this.files = const [],
    this.searchQuery = '',
    this.isLoading = false,
    this.isCompiling = false,
    this.isDeletingFile = false,
    this.error,
    this.avatar,
    this.newlyVerified = const [],
  });

  final List<WikiPage> pages;
  final List<SourceFile> files;
  final String searchQuery;
  final bool isLoading;

  /// Pages that flipped to VERIFIED since the last load and haven't yet been
  /// celebrated. The screen consumes these via ref.listen to fire a one-time
  /// snackbar, then calls [WikiViewerViewModel.acknowledgeVerified] to clear
  /// them and persist the shown-once flag so they never repeat.
  final List<WikiPage> newlyVerified;
  /// True while at least one knowledge file is still in PROCESSING state —
  /// compilation is async and may not be done yet. Shows a banner so the
  /// user knows to wait rather than thinking the upload was lost.
  final bool isCompiling;
  final bool isDeletingFile;
  final PallyError? error;
  final Avatar? avatar;

  List<WikiPage> get filteredPages {
    if (searchQuery.isEmpty) return pages;
    final q = searchQuery.toLowerCase();
    return pages
        .where((p) =>
            p.title.toLowerCase().contains(q) ||
            p.content.toLowerCase().contains(q))
        .toList();
  }

  int get pageCount => pages.length;

  WikiViewerState copyWith({
    List<WikiPage>? pages,
    List<SourceFile>? files,
    String? searchQuery,
    bool? isLoading,
    bool? isCompiling,
    bool? isDeletingFile,
    Object? error = _sentinel,
    Object? avatar = _sentinel,
    List<WikiPage>? newlyVerified,
  }) {
    return WikiViewerState(
      pages: pages ?? this.pages,
      files: files ?? this.files,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      isCompiling: isCompiling ?? this.isCompiling,
      isDeletingFile: isDeletingFile ?? this.isDeletingFile,
      error: error == _sentinel ? this.error : error as PallyError?,
      avatar: avatar == _sentinel ? this.avatar : avatar as Avatar?,
      newlyVerified: newlyVerified ?? this.newlyVerified,
    );
  }
}

const _sentinel = Object();

@riverpod
class WikiViewerViewModel extends _$WikiViewerViewModel {
  late String _avatarId;
  Timer? _compilationPoller;
  // Guard: prevents concurrent _loadPages() calls from racing each other.
  // Without this, build() + the poller both fire _loadPages() and the
  // one that finishes LAST wins — which may be an older in-flight request
  // that returns stale or empty data, wiping out the pages the user sees.
  bool _loadInFlight = false;

  // Page IDs whose VERIFIED state has already been celebrated. Loaded from
  // prefs once on build so the snackbar fires at most once per page, even
  // across app restarts and the 4s poller.
  Set<String> _celebrated = {};

  static const _celebratedPrefsKey = 'wiki_verified_celebrated';

  @override
  WikiViewerState build(String avatarId) {
    _avatarId = avatarId;
    _loadCelebrated().then((_) => _loadPages());
    ref.onDispose(() {
      _compilationPoller?.cancel();
      _loadInFlight = false;
    });
    return const WikiViewerState(isLoading: true);
  }

  Future<void> _loadCelebrated() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _celebrated =
          (prefs.getStringList(_celebratedPrefsKey) ?? const <String>[])
              .toSet();
    } catch (_) {
      _celebrated = {};
    }
  }

  Future<void> _loadPages() async {
    if (_loadInFlight) return;
    _loadInFlight = true;
    try {
      final dio = ref.read(dioProvider);
      final results = await Future.wait([
        dio.get<dynamic>('/api/v1/avatars/$_avatarId'),
        dio.get<dynamic>('/api/v1/avatars/$_avatarId/wiki/pages'),
        dio.get<dynamic>('/api/v1/avatars/$_avatarId/files'),
      ]);

      final avatarData = results[0].data;
      final Avatar? avatar = avatarData is Map<String, dynamic>
          ? Avatar.fromJson(avatarData)
          : (avatarData is Map
              ? Avatar.fromJson(Map<String, dynamic>.from(avatarData))
              : null);

      final pagesData = results[1].data;
      final List<dynamic> list = pagesData is List
          ? pagesData
          : (pagesData is Map
              ? (pagesData['pages'] is List
                  ? pagesData['pages'] as List<dynamic>
                  : (pagesData['items'] is List
                      ? pagesData['items'] as List<dynamic>
                      : const <dynamic>[]))
              : const <dynamic>[]);
      final pages = list
          .map((e) => WikiPage.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();

      // Check compilation state from avatar.brainState (READY / PENDING_RECOMPILE / COMPILING).
      // Also check file PROCESSING status as a secondary signal for older backends.
      final filesData = results[2].data;
      final List<dynamic> fileList = filesData is List
          ? filesData
          : (filesData is Map
              ? (filesData['files'] as List<dynamic>? ?? [])
              : const <dynamic>[]);
      final files = fileList
          .whereType<Map>()
          .map((f) => SourceFile.fromJson(Map<String, dynamic>.from(f)))
          .toList();
      final fileProcessing = files.any((f) => f.isProcessing);
      // Primary: use brainState from avatar DTO; fall back to file processing flag
      final isCompiling = (avatar?.isBrainCompiling ?? false) || fileProcessing;

      // Detect pages that are now VERIFIED and haven't been celebrated yet.
      // Empty IDs are skipped (can't track without a stable key).
      final newlyVerified = pages
          .where((p) =>
              p.reviewState == WikiReviewState.verified &&
              p.id.isNotEmpty &&
              !_celebrated.contains(p.id))
          .toList();

      state = state.copyWith(
        pages: pages,
        files: files,
        avatar: avatar,
        isLoading: false,
        isCompiling: isCompiling,
        error: null,
        newlyVerified: newlyVerified,
      );

      // While compilation is in progress, poll every 4 s so the brain
      // view populates automatically without requiring a manual refresh.
      if (isCompiling) {
        _startCompilationPoller();
      } else {
        _compilationPoller?.cancel();
        _compilationPoller = null;
      }
    } catch (e) {
      // On error: preserve the last-loaded pages so the user doesn't see a
      // blank brain every time the poller hits a transient network failure.
      // Only clear isLoading so the spinner stops. The error toast fires via
      // ref.listen in the screen so the user still sees the failure.
      state = state.copyWith(isLoading: false, error: PallyError.from(e));
    } finally {
      _loadInFlight = false;
    }
  }

  void _startCompilationPoller() {
    _compilationPoller?.cancel();
    _compilationPoller = Timer.periodic(const Duration(seconds: 4), (_) {
      // Stop polling once the provider is disposed or compilation is done.
      if (!state.isCompiling) {
        _compilationPoller?.cancel();
        _compilationPoller = null;
        return;
      }
      _loadPages();
    });
  }

  Future<void> refresh() => _loadPages();

  /// Deletes a source document from the avatar's knowledge base.
  /// The backend schedules a recompile so brain pages from this file
  /// are archived automatically.
  Future<void> deleteFile(String fileId) async {
    state = state.copyWith(isDeletingFile: true);
    try {
      final dio = ref.read(dioProvider);
      await dio.delete('/api/v1/avatars/$_avatarId/files/$fileId');
      // Remove optimistically and reload to get the updated compiling state
      state = state.copyWith(
        files: state.files.where((f) => f.id != fileId).toList(),
        isDeletingFile: false,
        isCompiling: true, // recompile just started
      );
      _startCompilationPoller();
    } catch (e) {
      state = state.copyWith(
        isDeletingFile: false,
        error: PallyError.from(e),
      );
    }
  }

  void updateSearch(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Marks [pageIds] as celebrated so their VERIFIED snackbar never fires
  /// again, persists the set, and clears [WikiViewerState.newlyVerified].
  /// Called by the screen right after it shows the one-time snackbar.
  Future<void> acknowledgeVerified(List<String> pageIds) async {
    if (pageIds.isEmpty) return;
    _celebrated = {..._celebrated, ...pageIds};
    state = state.copyWith(newlyVerified: const []);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_celebratedPrefsKey, _celebrated.toList());
    } catch (_) {
      // Best-effort persistence; the in-memory set still prevents repeats
      // within this session.
    }
  }

  Future<void> patchCorrection(String slug, String newContent) async {
    try {
      final dio = ref.read(dioProvider);
      await dio.patch<void>(
        '/api/v1/avatars/$_avatarId/wiki/pages/$slug/correction',
        data: {'content': newContent},
      );
      final updated = state.pages.map((p) {
        final pageSlug = p.slug ?? p.title.toLowerCase().replaceAll(' ', '-');
        return pageSlug == slug ? p.copyWith(content: newContent) : p;
      }).toList();
      state = state.copyWith(pages: updated);
    } catch (_) {
      // Optimistically update in-memory even if backend is unavailable
      final updated = state.pages.map((p) {
        final pageSlug = p.slug ?? p.title.toLowerCase().replaceAll(' ', '-');
        return pageSlug == slug ? p.copyWith(content: newContent) : p;
      }).toList();
      state = state.copyWith(pages: updated);
    }
  }
}

