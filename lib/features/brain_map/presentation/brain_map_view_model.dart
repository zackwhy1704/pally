import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/utils/logger.dart';
import 'package:pally/shared/models/wiki_page.dart';

part 'brain_map_view_model.g.dart';

@immutable
class TopicNode {
  const TopicNode({
    required this.slug,
    required this.title,
    required this.mastery,
    required this.attempts,
    this.reviewRequired = false,
  });
  final String slug;
  final String title;
  final double mastery; // 0.0–1.0; -1 = no data
  final int attempts;
  // R8 — true when the backend's quiz feedback loop flagged this page
  // for review. The painter draws a pulsing outline so the user can see
  // which topics the system thinks they got wrong.
  final bool reviewRequired;

  bool get isUntouched => attempts == 0;
}

@immutable
class BrainMapState {
  const BrainMapState({
    this.nodes = const [],
    this.subject = '',
    this.isLoading = true,
    this.error,
  });
  final List<TopicNode> nodes;
  final String subject;
  final bool isLoading;
  final String? error;
}

@riverpod
class BrainMapViewModel extends _$BrainMapViewModel {
  @override
  Future<BrainMapState> build(String avatarId) async {
    return _fetch(avatarId);
  }

  Future<BrainMapState> _fetch(String avatarId) async {
    try {
      final dio = ref.read(dioProvider);
      // Topics from wiki pages + mastery from quiz results + avatar subject
      // in parallel — keeps the screen snappy. Use dynamic since
      // /topic-mastery returns a List, not a Map, and the global
      // _ApiResponseInterceptor already unwraps the {data:…} envelope.
      final results = await Future.wait([
        dio.get<dynamic>('/api/v1/avatars/$avatarId/wiki/pages'),
        dio.get<dynamic>('/api/v1/avatars/$avatarId/topic-mastery'),
        dio.get<dynamic>('/api/v1/avatars/$avatarId'),
      ]);

      // The global interceptor strips the {data: X} envelope, so
      // results[N].data IS already X. The `_unwrap` helper is robust to
      // either form (in case the interceptor is disabled in tests).
      final pagesData = _unwrapMap(results[0].data) ?? const {};
      final pageList = (pagesData['pages'] as List?) ?? const [];
      final pages = pageList
          .whereType<Map<String, dynamic>>()
          .map(WikiPage.fromJson)
          .toList();

      // PREVIOUS BUG: this did `results[1].data?['data']` which threw
      // NoSuchMethodError when the interceptor had already unwrapped to a
      // List (calling `[]` on List with a String key blows up). Caught
      // silently → "No topics yet" even with pages and quiz history.
      final masteryData = _unwrapList(results[1].data) ?? const [];
      final masteryBySlug = <String, _MasteryRow>{};
      for (final row in masteryData.whereType<Map<String, dynamic>>()) {
        final slug = row['topicSlug'] as String?;
        if (slug == null) continue;
        masteryBySlug[slug] = _MasteryRow(
          ((row['mastery'] as num?) ?? 0).toDouble(),
          ((row['attempts'] as num?) ?? 0).toInt(),
          row['reviewRequired'] == true,
        );
      }

      final avatarData = _unwrapMap(results[2].data) ?? const {};
      final subject = (avatarData['subject'] as String?) ?? '';

      appLog.i('[BrainMap] avatar=$avatarId pages=${pages.length} '
          'mastery=${masteryBySlug.length} subject=$subject');

      final nodes = pages.map((p) {
        final m = masteryBySlug[p.slug];
        return TopicNode(
          slug: p.slug ?? p.id,
          title: p.title,
          mastery: m?.ratio ?? 0,
          attempts: m?.attempts ?? 0,
          reviewRequired: m?.reviewRequired ?? false,
        );
      }).toList();

      return BrainMapState(
        nodes: nodes,
        subject: subject,
        isLoading: false,
      );
    } catch (e, st) {
      appLog.w('[BrainMap] fetch failed', error: e, stackTrace: st);
      return const BrainMapState(
        nodes: [],
        isLoading: false,
        error: 'Could not load brain map',
      );
    }
  }

  Future<void> refresh(String avatarId) async {
    state = const AsyncLoading();
    state = AsyncValue.data(await _fetch(avatarId));
  }

  /// Returns the inner Map whether the response is `{data: {...}}` or
  /// already-unwrapped `{...}`. Never indexes into a non-Map (the bug
  /// that previously blanked the brain map).
  static Map<String, dynamic>? _unwrapMap(Object? raw) {
    if (raw is Map<String, dynamic>) {
      final inner = raw['data'];
      if (inner is Map<String, dynamic>) return inner;
      return raw;
    }
    return null;
  }

  /// Returns the inner List whether the response is `{data: [...]}` or
  /// already-unwrapped `[...]`.
  static List<dynamic>? _unwrapList(Object? raw) {
    if (raw is List) return raw;
    if (raw is Map<String, dynamic>) {
      final inner = raw['data'];
      if (inner is List) return inner;
    }
    return null;
  }
}

class _MasteryRow {
  const _MasteryRow(this.ratio, this.attempts, this.reviewRequired);
  final double ratio;
  final int attempts;
  final bool reviewRequired;
}
