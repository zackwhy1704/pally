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
      // in parallel — keeps the screen snappy.
      final results = await Future.wait([
        dio.get<Map<String, dynamic>>('/api/v1/avatars/$avatarId/wiki/pages'),
        dio.get<Map<String, dynamic>>(
            '/api/v1/avatars/$avatarId/topic-mastery'),
        dio.get<Map<String, dynamic>>('/api/v1/avatars/$avatarId'),
      ]);

      final pagesData = (results[0].data?['data'] is Map
              ? results[0].data!['data']
              : results[0].data) as Map<String, dynamic>;
      final pageList = (pagesData['pages'] as List?) ?? const [];
      final pages = pageList
          .whereType<Map<String, dynamic>>()
          .map(WikiPage.fromJson)
          .toList();

      final masteryData = (results[1].data?['data'] is List
              ? results[1].data!['data']
              : results[1].data) as List?;
      final masteryBySlug = <String, _MasteryRow>{};
      for (final row in (masteryData ?? const []).whereType<Map<String, dynamic>>()) {
        final slug = row['topicSlug'] as String?;
        if (slug == null) continue;
        masteryBySlug[slug] = _MasteryRow(
          ((row['mastery'] as num?) ?? 0).toDouble(),
          ((row['attempts'] as num?) ?? 0).toInt(),
          row['reviewRequired'] == true,
        );
      }

      final avatarData = (results[2].data?['data'] is Map
              ? results[2].data!['data']
              : results[2].data) as Map<String, dynamic>;
      final subject = (avatarData['subject'] as String?) ?? '';

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
}

class _MasteryRow {
  const _MasteryRow(this.ratio, this.attempts, this.reviewRequired);
  final double ratio;
  final int attempts;
  final bool reviewRequired;
}
