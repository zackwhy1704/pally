import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/error/pally_error.dart';
import 'package:pally/shared/models/avatar.dart';
import 'package:pally/shared/models/wiki_page.dart';

part 'wiki_viewer_view_model.g.dart';

@immutable
class WikiViewerState {
  const WikiViewerState({
    this.pages = const [],
    this.searchQuery = '',
    this.isLoading = false,
    this.isCompiling = false,
    this.error,
    this.avatar,
  });

  final List<WikiPage> pages;
  final String searchQuery;
  final bool isLoading;
  /// True while at least one knowledge file is still in PROCESSING state —
  /// compilation is async and may not be done yet. Shows a banner so the
  /// user knows to wait rather than thinking the upload was lost.
  final bool isCompiling;
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
    String? searchQuery,
    bool? isLoading,
    bool? isCompiling,
    Object? error = _sentinel,
    Object? avatar = _sentinel,
  }) {
    return WikiViewerState(
      pages: pages ?? this.pages,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      isCompiling: isCompiling ?? this.isCompiling,
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

      // Check if any file is still being compiled (PROCESSING status).
      // The backend runs wiki compilation async, so pages may appear over
      // the next 30–120 s after an upload.
      final filesData = results[2].data;
      final List<dynamic> fileList = filesData is List
          ? filesData
          : (filesData is Map
              ? (filesData['files'] as List<dynamic>? ?? [])
              : const <dynamic>[]);
      final isCompiling = fileList.any((f) {
        final status = (f as Map)['status']?.toString().toUpperCase() ?? '';
        return status == 'PROCESSING';
      });

      state = state.copyWith(
        pages: pages,
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
    _compilationPoller = Timer.periodic(const Duration(seconds: 5), (_) {
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

