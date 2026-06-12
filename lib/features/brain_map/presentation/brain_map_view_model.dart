import 'dart:math' as math;

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
    this.certainty = 'inferred',
    this.certaintyScore = 0.0,
    this.quizUseCount = 0,
    this.hasConflict = false,
    this.conflictNote,
    this.prerequisiteSlugs = const [],
  });
  final String slug;
  final String title;
  final double mastery; // 0.0–1.0; -1 = no data
  final int attempts;
  // R8 — true when the backend's quiz feedback loop flagged this page
  // for review. The painter draws a pulsing outline so the user can see
  // which topics the system thinks they got wrong.
  final bool reviewRequired;

  // Knowledge-graph fields (IMPROVEMENT 2). Mirror the wiki-page DTO so the
  // graph view can colour by certainty, size by usage, and draw prereq edges.
  final String certainty; // INFERRED / VERIFIED / UNCERTAIN (lower-cased)
  final double certaintyScore; // 0.0–1.0 → node border weight
  final int quizUseCount; // → node size
  final bool hasConflict; // → pulsing node
  final String? conflictNote; // shown in the topic sheet (IMPROVEMENT 3)
  final List<String> prerequisiteSlugs; // graph edges: these → this node

  bool get isUntouched => attempts == 0;

  /// Node diameter, 40–72px: base 40 + 4px per quiz use, capped at 8 uses.
  double get nodeDiameter => 40.0 + math.min(quizUseCount, 8) * 4.0;

  /// Border stroke weight: 1 + certaintyScore*3 → 1.0–4.0px.
  double get borderWeight => 1.0 + certaintyScore.clamp(0.0, 1.0) * 3.0;
}

@immutable
class BrainMapState {
  const BrainMapState({
    this.nodes = const [],
    this.subject = '',
    this.isLoading = true,
    this.error,
    this.newSlugs = const {},
    this.newTitles = const {},
  });
  final List<TopicNode> nodes;
  final String subject;
  final bool isLoading;
  final String? error;

  // IMPROVEMENT 6 — slugs/titles compiled during this app session. The graph
  // and list animate these nodes in (fade+scale, staggered). In-memory only:
  // reset on app restart. A node is "new" if its slug OR title matches.
  final Set<String> newSlugs;
  final Set<String> newTitles;

  bool isNew(TopicNode n) =>
      newSlugs.contains(n.slug) || newTitles.contains(n.title);
}

@riverpod
class BrainMapViewModel extends _$BrainMapViewModel {
  // IMPROVEMENT 6 — slugs/titles seen so far this session, and the subset that
  // appeared since the first load (i.e. compiled this session). In-memory only,
  // resets on app restart / provider dispose. No backend change.
  final Set<String> _seenSlugs = <String>{};
  final Set<String> _newSlugs = <String>{};
  final Set<String> _newTitles = <String>{};
  bool _hadFirstLoad = false;

  @override
  Future<BrainMapState> build(String avatarId) async {
    return _fetch(avatarId);
  }

  /// Explicitly mark pages compiled this session so the graph/list animate them
  /// in. Optional hook for the compile-complete handler; the provider also
  /// auto-detects new slugs on refresh (see [_fetch]).
  void markNewlyCompiled({
    Iterable<String> slugs = const [],
    Iterable<String> titles = const [],
  }) {
    _newSlugs.addAll(slugs);
    _newTitles.addAll(titles);
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncValue.data(BrainMapState(
        nodes: current.nodes,
        subject: current.subject,
        isLoading: current.isLoading,
        error: current.error,
        newSlugs: Set.of(_newSlugs),
        newTitles: Set.of(_newTitles),
      ));
    }
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
          certainty: p.certainty,
          certaintyScore: p.certaintyScore,
          quizUseCount: p.quizUseCount,
          hasConflict: p.hasConflict,
          conflictNote: p.conflictNote,
          prerequisiteSlugs: p.prerequisiteSlugs,
        );
      }).toList();

      // IMPROVEMENT 6 — auto-detect pages that appeared after the first load.
      // On the very first fetch we only seed the baseline (nothing is "new").
      // On later refreshes (e.g. returning from an upload+compile), any slug
      // not previously seen is animated in.
      if (_hadFirstLoad) {
        for (final n in nodes) {
          if (!_seenSlugs.contains(n.slug)) {
            _newSlugs.add(n.slug);
            _newTitles.add(n.title);
          }
        }
      }
      for (final n in nodes) {
        _seenSlugs.add(n.slug);
      }
      _hadFirstLoad = true;

      return BrainMapState(
        nodes: nodes,
        subject: subject,
        isLoading: false,
        newSlugs: Set.of(_newSlugs),
        newTitles: Set.of(_newTitles),
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
