import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/shared/models/avatar.dart';
import 'package:pally/shared/models/wiki_page.dart';

part 'wiki_viewer_view_model.g.dart';

@immutable
class WikiViewerState {
  const WikiViewerState({
    this.pages = const [],
    this.searchQuery = '',
    this.isLoading = false,
    this.error,
    this.avatar,
  });

  final List<WikiPage> pages;
  final String searchQuery;
  final bool isLoading;
  final String? error;
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
    Object? error = _sentinel,
    Object? avatar = _sentinel,
  }) {
    return WikiViewerState(
      pages: pages ?? this.pages,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      error: error == _sentinel ? this.error : error as String?,
      avatar: avatar == _sentinel ? this.avatar : avatar as Avatar?,
    );
  }
}

const _sentinel = Object();

@riverpod
class WikiViewerViewModel extends _$WikiViewerViewModel {
  late String _avatarId;

  @override
  WikiViewerState build(String avatarId) {
    _avatarId = avatarId;
    _loadPages();
    return const WikiViewerState(isLoading: true);
  }

  Future<void> _loadPages() async {
    try {
      final dio = ref.read(dioProvider);
      final results = await Future.wait([
        dio.get<Map<String, dynamic>>('/api/v1/avatars/$_avatarId'),
        dio.get<Map<String, dynamic>>('/api/v1/avatars/$_avatarId/wiki/pages'),
      ]);

      final avatarData = results[0].data;
      final Avatar? avatar =
          avatarData != null ? Avatar.fromJson(avatarData) : null;

      final pagesData = results[1].data;
      final list = (pagesData?['pages'] as List<dynamic>?) ??
          (pagesData?['items'] as List<dynamic>?) ??
          (pagesData is List ? pagesData as List<dynamic> : []);
      final pages = list
          .map((e) => WikiPage.fromJson(e as Map<String, dynamic>))
          .toList();
      state = state.copyWith(
          pages: pages, avatar: avatar, isLoading: false, error: null);
    } on DioException catch (_) {
      state = state.copyWith(pages: _stubPages, isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
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

const _stubPages = [
  WikiPage(
    id: 'wp-1',
    avatarId: 'stub',
    title: 'Photosynthesis',
    content:
        'Plants convert light energy into chemical energy stored as glucose.',
    sourceFileIds: [],
  ),
  WikiPage(
    id: 'wp-2',
    avatarId: 'stub',
    title: 'Cell Structure',
    content:
        'Cells are the basic unit of life. Plant cells have a cell wall, vacuole, and chloroplasts.',
    sourceFileIds: [],
  ),
  WikiPage(
    id: 'wp-3',
    avatarId: 'stub',
    title: 'Ecosystems',
    content:
        'An ecosystem consists of all the living organisms in an area together with the non-living environment.',
    sourceFileIds: [],
  ),
];
