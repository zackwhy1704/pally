import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
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
  });

  final List<WikiPage> pages;
  final List<SourceFile> files;
  final String searchQuery;
  final bool isLoading;
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
    );
  }
}

const _sentinel = Object();

@riverpod
class WikiViewerViewModel extends _$WikiViewerViewModel {
  late String _avatarId;
  Timer? _compilationPoller;

  @override
  WikiViewerState build(String avatarId) {
    _avatarId = avatarId;
    _loadPages();
    // Cancel any active poller when the provider is disposed.
    ref.onDispose(() => _compilationPoller?.cancel());
    return const WikiViewerState(isLoading: true);
  }

  Future<void> _loadPages() async {
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

      state = state.copyWith(
        pages: pages,
        files: files,
        avatar: avatar,
        isLoading: false,
        isCompiling: isCompiling,
        error: null,
      );

      // While compilation is in progress, poll every 5 s so the brain
      // view populates automatically without requiring a manual refresh.
      if (isCompiling) {
        _startCompilationPoller();
      } else {
        _compilationPoller?.cancel();
        _compilationPoller = null;
      }
    } catch (e) {
      // Never fall back to fabricated wiki pages — a child must never
      // study invented notes. Surface a real error + retry instead.
      state = state.copyWith(
          pages: const [], isLoading: false, error: PallyError.from(e));
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

