import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/error/pally_error.dart';
import 'package:pally/core/observability/observability.dart';
import 'package:pally/core/observability/observability_providers.dart';
import 'package:pally/core/utils/logger.dart';
import 'package:pally/shared/models/learning_module.dart';
import 'package:pally/shared/models/narration.dart';

part 'module_player_view_model.g.dart';

@immutable
class ModulePlayerState {
  const ModulePlayerState({
    this.module,
    this.items = const [],
    this.currentIndex = 0,
    this.stage = 'LEARN',
    this.isLoading = false,
    this.isSubmitting = false,
    this.isComplete = false,
    this.muddiestSubmitted = false,
    this.isRevision = false,
    this.results,
    this.error,
    this.answers = const {},
    this.revealedItems = const {},
    this.narration,
    this.narrationLoading = false,
    this.isPlaying = false,
    this.isPlayingAll = false,
    this.currentPlayingCard = -1,
  });

  final LearningModule? module;
  final List<ModuleContentItem> items;
  final int currentIndex;
  final String stage;
  final bool isLoading;
  final bool isSubmitting;
  final bool isComplete;

  /// True once the post-PROVE "muddiest point" prompt has been answered or
  /// skipped. Gates the one-tap muddiest screen so it only shows once and the
  /// completion screen follows.
  final bool muddiestSubmitted;
  final bool isRevision;
  final ModuleResults? results;
  final PallyError? error;

  /// Accumulated answers: itemId -> response string.
  final Map<String, String> answers;

  /// Items whose answer has been revealed (for TEST stage feedback).
  final Set<String> revealedItems;

  /// Narration data for the current module (null if not fetched yet).
  final Narration? narration;

  /// True while narration is being fetched or generated.
  final bool narrationLoading;

  /// True when audio is actively playing.
  final bool isPlaying;

  /// True when playing all cards sequentially.
  final bool isPlayingAll;

  /// Index of the card whose narration is currently playing (-1 = none).
  final int currentPlayingCard;

  ModuleContentItem? get currentItem =>
      items.isEmpty || currentIndex >= items.length
          ? null
          : items[currentIndex];

  int get totalItems => items.length;
  bool get isLastItem => currentIndex >= totalItems - 1;

  ModulePlayerState copyWith({
    LearningModule? module,
    List<ModuleContentItem>? items,
    int? currentIndex,
    String? stage,
    bool? isLoading,
    bool? isSubmitting,
    bool? isComplete,
    bool? muddiestSubmitted,
    bool? isRevision,
    Object? results = _sentinel,
    Object? error = _sentinel,
    Map<String, String>? answers,
    Set<String>? revealedItems,
    Object? narration = _sentinel,
    bool? narrationLoading,
    bool? isPlaying,
    bool? isPlayingAll,
    int? currentPlayingCard,
  }) {
    return ModulePlayerState(
      module: module ?? this.module,
      items: items ?? this.items,
      currentIndex: currentIndex ?? this.currentIndex,
      stage: stage ?? this.stage,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isComplete: isComplete ?? this.isComplete,
      muddiestSubmitted: muddiestSubmitted ?? this.muddiestSubmitted,
      isRevision: isRevision ?? this.isRevision,
      results: results == _sentinel ? this.results : results as ModuleResults?,
      error: error == _sentinel ? this.error : error as PallyError?,
      answers: answers ?? this.answers,
      revealedItems: revealedItems ?? this.revealedItems,
      narration:
          narration == _sentinel ? this.narration : narration as Narration?,
      narrationLoading: narrationLoading ?? this.narrationLoading,
      isPlaying: isPlaying ?? this.isPlaying,
      isPlayingAll: isPlayingAll ?? this.isPlayingAll,
      currentPlayingCard: currentPlayingCard ?? this.currentPlayingCard,
    );
  }
}

const _sentinel = Object();

@riverpod
class ModulePlayerViewModel extends _$ModulePlayerViewModel {
  late String _avatarId;
  late String _moduleId;
  AudioPlayer? _audioPlayer;

  /// Wall-clock the current stage's items rendered, read again on submit to
  /// report real active time. Reset on every [startStage].
  DateTime? _stageStartedAt;

  /// Per-stage active-time cap (1h) so a backgrounded stage can't inflate
  /// study minutes. Backend clamps too.
  static const int _maxStageSeconds = 3600;

  int get _stageDurationSeconds {
    final started = _stageStartedAt;
    if (started == null) return 0;
    return DateTime.now()
        .difference(started)
        .inSeconds
        .clamp(0, _maxStageSeconds);
  }

  @override
  ModulePlayerState build(String avatarId, String moduleId) {
    _avatarId = avatarId;
    _moduleId = moduleId;
    ref.onDispose(() {
      _audioPlayer?.dispose();
      _audioPlayer = null;
    });
    _loadModule();
    return const ModulePlayerState(isLoading: true);
  }

  Future<void> _loadModule() async {
    appLog.d('[ModulePlayer] Loading module $_moduleId for avatar $_avatarId');
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get<dynamic>(
        '/api/v1/avatars/$_avatarId/modules/$_moduleId',
      );
      final data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};

      final module = LearningModule.fromJson(
        Map<String, dynamic>.from(data['module'] as Map? ?? data),
      );

      state = state.copyWith(
        module: module,
        stage: module.stage,
        isLoading: false,
      );

      // Auto-start the current stage
      await startStage();
    } on DioException catch (e, st) {
      appLog.e('[ModulePlayer] Load failed', error: e, stackTrace: st);
      state = state.copyWith(isLoading: false, error: PallyError.from(e));
    } catch (e, st) {
      appLog.e('[ModulePlayer] Unexpected error loading module',
          error: e, stackTrace: st);
      state = state.copyWith(isLoading: false, error: PallyError.from(e));
    }
  }

  Future<void> startStage() async {
    appLog.i('[ModulePlayer] Starting stage ${state.stage} for $_moduleId');
    state = state.copyWith(isLoading: true, error: null);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post<dynamic>(
        '/api/v1/avatars/$_avatarId/modules/$_moduleId/start',
      );
      final data = response.data;
      final List<dynamic> rawItems = data is List
          ? data
          : (data is Map && data['items'] is List
              ? data['items'] as List<dynamic>
              : const <dynamic>[]);

      final items = <ModuleContentItem>[];
      for (final e in rawItems) {
        try {
          items.add(ModuleContentItem.fromJson(
            Map<String, dynamic>.from(e as Map),
          ));
        } catch (err, st) {
          appLog.e('[ModulePlayer] Failed to parse item',
              error: err, stackTrace: st);
        }
      }

      // Sort by sortOrder
      items.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

      // Detect revision mode from backend response
      final isRevision =
          (data is Map && data['revision'] == true) || state.isRevision;

      // Start the active-time clock for this stage now that items are visible.
      _stageStartedAt = DateTime.now();

      appLog.i('[ModulePlayer] Loaded ${items.length} items for ${state.stage}'
          '${isRevision ? ' (revision mode)' : ''}');
      ref.read(analyticsProvider).event(
        AnalyticsEvents.moduleStarted,
        props: {
          'module_id': _moduleId,
          'avatar_id': _avatarId,
          'stage': state.stage,
          'is_revision': isRevision,
          'item_count': items.length,
        },
      );
      state = state.copyWith(
        items: items,
        currentIndex: 0,
        isLoading: false,
        isRevision: isRevision,
        answers: const {},
        revealedItems: const {},
      );
    } on DioException catch (e, st) {
      appLog.e('[ModulePlayer] Start stage failed', error: e, stackTrace: st);
      state = state.copyWith(isLoading: false, error: PallyError.from(e));
    } catch (e, st) {
      appLog.e('[ModulePlayer] Unexpected error starting stage',
          error: e, stackTrace: st);
      state = state.copyWith(isLoading: false, error: PallyError.from(e));
    }
  }

  void nextItem() {
    if (state.currentIndex < state.totalItems - 1) {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
    }
  }

  void previousItem() {
    if (state.currentIndex > 0) {
      state = state.copyWith(currentIndex: state.currentIndex - 1);
    }
  }

  void setAnswer(String itemId, String response) {
    final updated = Map<String, String>.from(state.answers);
    updated[itemId] = response;
    state = state.copyWith(answers: updated);
  }

  void revealItem(String itemId) {
    final updated = Set<String>.from(state.revealedItems);
    updated.add(itemId);
    state = state.copyWith(revealedItems: updated);
  }

  Future<void> submitStage() async {
    appLog.i('[ModulePlayer] Submitting ${state.stage} answers for $_moduleId');
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      final dio = ref.read(dioProvider);
      final submissions = state.items.map((item) {
        String response;
        if (state.stage == 'LEARN') {
          response = 'viewed:true';
        } else {
          response = state.answers[item.id] ?? '';
        }
        return {'itemId': item.id, 'response': response};
      }).toList();

      // Body is a bare submissions list, so the active-time measurement rides
      // as a query parameter. Backend reads + clamps durationSeconds to credit
      // real study minutes for this stage.
      final res = await dio.post<dynamic>(
        '/api/v1/avatars/$_avatarId/modules/$_moduleId/submit',
        data: submissions,
        queryParameters: {'durationSeconds': _stageDurationSeconds},
      );

      final data = res.data;
      final nextStage = _extractNextStage(data);
      appLog.i('[ModulePlayer] Submission complete, next stage: $nextStage');
      ref.read(analyticsProvider).event(
        AnalyticsEvents.moduleStageCompleted,
        props: {
          'module_id': _moduleId,
          'avatar_id': _avatarId,
          'stage': state.stage,
          'next_stage': nextStage,
        },
      );

      if (nextStage == 'COMPLETE') {
        ref.read(analyticsProvider).event(
          AnalyticsEvents.moduleCompleted,
          props: {
            'module_id': _moduleId,
            'avatar_id': _avatarId,
          },
        );
        await _loadResults();
      } else {
        state = state.copyWith(
          stage: nextStage,
          isSubmitting: false,
          currentIndex: 0,
          answers: const {},
          revealedItems: const {},
        );
        await startStage();
      }
    } on DioException catch (e, st) {
      appLog.e('[ModulePlayer] Submit failed', error: e, stackTrace: st);
      state = state.copyWith(isSubmitting: false, error: PallyError.from(e));
    } catch (e, st) {
      appLog.e('[ModulePlayer] Unexpected error submitting',
          error: e, stackTrace: st);
      state = state.copyWith(isSubmitting: false, error: PallyError.from(e));
    }
  }

  String _extractNextStage(dynamic data) {
    if (data is Map) {
      final stage = data['nextStage'] ?? data['stage'];
      if (stage is String) return stage;
    }
    // Infer next stage from current
    return switch (state.stage) {
      'LEARN' => 'TEST',
      'TEST' => 'PROVE',
      'PROVE' => 'COMPLETE',
      _ => 'COMPLETE',
    };
  }

  Future<void> _loadResults() async {
    appLog.d('[ModulePlayer] Loading results for $_moduleId');
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get<dynamic>(
        '/api/v1/avatars/$_avatarId/modules/$_moduleId/results',
      );
      final data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};

      final results = ModuleResults.fromJson(data);
      state = state.copyWith(
        isSubmitting: false,
        isComplete: true,
        stage: 'COMPLETE',
        results: results,
      );
    } catch (e, st) {
      appLog.e('[ModulePlayer] Results load failed', error: e, stackTrace: st);
      state = state.copyWith(
        isSubmitting: false,
        isComplete: true,
        stage: 'COMPLETE',
      );
    }
  }

  // ── Muddiest point ────────────────────────────────────────────────────────

  /// Records the concept the child found hardest after PROVE, then advances to
  /// the completion screen. One tap, fire-and-proceed: a failed POST must never
  /// trap the child on this screen, so we mark it done regardless of the result.
  Future<void> submitMuddiest(String conceptId) async {
    appLog.i('[ModulePlayer] Muddiest point conceptId=$conceptId '
        'module=$_moduleId');
    // Optimistically advance — the survey is a soft signal, not a gate.
    state = state.copyWith(muddiestSubmitted: true);
    try {
      final dio = ref.read(dioProvider);
      await dio.post<dynamic>(
        '/api/v1/modules/$_moduleId/muddiest',
        data: {'conceptId': conceptId},
      );
      ref.read(analyticsProvider).event(
        AnalyticsEvents.moduleStageCompleted,
        props: {
          'module_id': _moduleId,
          'avatar_id': _avatarId,
          'stage': 'MUDDIEST',
          'concept_id': conceptId,
        },
      );
    } catch (e, st) {
      // Soft-fail: the child has already moved on; just log it.
      appLog.w('[ModulePlayer] Muddiest POST failed', error: e, stackTrace: st);
    }
  }

  /// Skips the muddiest-point prompt and proceeds to the completion screen.
  void skipMuddiest() {
    appLog.d('[ModulePlayer] Muddiest point skipped for $_moduleId');
    state = state.copyWith(muddiestSubmitted: true);
  }

  // ── Narration ─────────────────────────────────────────────────────────────

  /// Fetch narration data for this module. If not ready, trigger generation.
  Future<void> fetchNarration() async {
    if (state.narrationLoading) return;
    if (state.narration != null && state.narration!.status == 'READY') return;

    appLog.i('[ModulePlayer] Fetching narration for $_moduleId');
    state = state.copyWith(narrationLoading: true);

    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get<dynamic>(
        '/api/v1/avatars/$_avatarId/modules/$_moduleId/narration',
      );
      final data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};

      final narration = Narration.fromJson(data);
      appLog.i('[ModulePlayer] Narration status=${narration.status} '
          'segments=${narration.segments.length}');

      if (narration.status == 'READY' && narration.segments.isNotEmpty) {
        state = state.copyWith(narration: narration, narrationLoading: false);
      } else {
        // Trigger generation and mark as loading.
        await _triggerNarrationGeneration();
      }
    } on DioException catch (e, st) {
      if (e.response?.statusCode == 404) {
        // No narration exists yet — trigger generation.
        appLog.d('[ModulePlayer] No narration yet, generating');
        await _triggerNarrationGeneration();
      } else {
        appLog.e('[ModulePlayer] Narration fetch failed',
            error: e, stackTrace: st);
        state = state.copyWith(narrationLoading: false);
      }
    } catch (e, st) {
      appLog.e('[ModulePlayer] Narration fetch error',
          error: e, stackTrace: st);
      state = state.copyWith(narrationLoading: false);
    }
  }

  Future<void> _triggerNarrationGeneration() async {
    try {
      final dio = ref.read(dioProvider);
      await dio.post<dynamic>(
        '/api/v1/avatars/$_avatarId/modules/$_moduleId/narration/generate',
      );
      appLog.i('[ModulePlayer] Narration generation triggered');
      state = state.copyWith(narrationLoading: false);
    } catch (e, st) {
      appLog.w('[ModulePlayer] Narration generation failed',
          error: e, stackTrace: st);
      state = state.copyWith(narrationLoading: false);
    }
  }

  /// Play narration for a single card by index.
  Future<void> playCard(int cardIndex) async {
    final narration = state.narration;
    if (narration == null || narration.status != 'READY') {
      await fetchNarration();
      if (state.narration == null || state.narration!.status != 'READY') return;
    }

    final segments = state.narration!.segments;
    final segment = segments.where((s) => s.cardIndex == cardIndex).firstOrNull;
    if (segment == null || segment.audioUrl.isEmpty) {
      appLog.w('[ModulePlayer] No narration segment for card $cardIndex');
      return;
    }

    appLog.i('[ModulePlayer] Playing narration for card $cardIndex');
    ref.read(analyticsProvider).event(
      AnalyticsEvents.narrationPlayed,
      props: {
        'module_id': _moduleId,
        'avatar_id': _avatarId,
        'card_index': cardIndex,
      },
    );
    _audioPlayer ??= AudioPlayer();

    try {
      await _audioPlayer!.setUrl(segment.audioUrl);
      state = state.copyWith(
        isPlaying: true,
        currentPlayingCard: cardIndex,
      );
      _audioPlayer!.play();

      // Wait for completion.
      await _audioPlayer!.playerStateStream.firstWhere(
        (s) => s.processingState == ProcessingState.completed,
      );

      state = state.copyWith(isPlaying: false, currentPlayingCard: -1);
    } catch (e, st) {
      appLog.e('[ModulePlayer] Audio playback error', error: e, stackTrace: st);
      state = state.copyWith(isPlaying: false, currentPlayingCard: -1);
    }
  }

  /// Play all cards sequentially.
  Future<void> playAll() async {
    final narration = state.narration;
    if (narration == null || narration.status != 'READY') {
      await fetchNarration();
      if (state.narration == null || state.narration!.status != 'READY') return;
    }

    final segments = List<NarrationSegment>.from(state.narration!.segments);
    segments.sort((a, b) => a.cardIndex.compareTo(b.cardIndex));

    if (segments.isEmpty) return;

    appLog
        .i('[ModulePlayer] Playing all ${segments.length} narration segments');
    state = state.copyWith(isPlayingAll: true, isPlaying: true);
    _audioPlayer ??= AudioPlayer();

    for (final segment in segments) {
      if (!state.isPlayingAll) break; // User paused or navigated away.
      if (segment.audioUrl.isEmpty) continue;

      try {
        state = state.copyWith(currentPlayingCard: segment.cardIndex);
        await _audioPlayer!.setUrl(segment.audioUrl);
        _audioPlayer!.play();

        await _audioPlayer!.playerStateStream.firstWhere(
          (s) => s.processingState == ProcessingState.completed,
        );
      } catch (e) {
        appLog.w('[ModulePlayer] Skipping segment ${segment.cardIndex}: $e');
      }
    }

    state = state.copyWith(
      isPlaying: false,
      isPlayingAll: false,
      currentPlayingCard: -1,
    );
  }

  /// Pause playback.
  Future<void> pauseNarration() async {
    appLog.d('[ModulePlayer] Pausing narration');
    await _audioPlayer?.pause();
    state = state.copyWith(
      isPlaying: false,
      isPlayingAll: false,
      currentPlayingCard: -1,
    );
  }
}
