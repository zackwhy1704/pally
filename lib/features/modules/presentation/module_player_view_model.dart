import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/error/pally_error.dart';
import 'package:pally/core/utils/logger.dart';
import 'package:pally/shared/models/learning_module.dart';

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
    this.results,
    this.error,
    this.answers = const {},
    this.revealedItems = const {},
  });

  final LearningModule? module;
  final List<ModuleContentItem> items;
  final int currentIndex;
  final String stage;
  final bool isLoading;
  final bool isSubmitting;
  final bool isComplete;
  final ModuleResults? results;
  final PallyError? error;

  /// Accumulated answers: itemId -> response string.
  final Map<String, String> answers;

  /// Items whose answer has been revealed (for TEST stage feedback).
  final Set<String> revealedItems;

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
    Object? results = _sentinel,
    Object? error = _sentinel,
    Map<String, String>? answers,
    Set<String>? revealedItems,
  }) {
    return ModulePlayerState(
      module: module ?? this.module,
      items: items ?? this.items,
      currentIndex: currentIndex ?? this.currentIndex,
      stage: stage ?? this.stage,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isComplete: isComplete ?? this.isComplete,
      results:
          results == _sentinel ? this.results : results as ModuleResults?,
      error: error == _sentinel ? this.error : error as PallyError?,
      answers: answers ?? this.answers,
      revealedItems: revealedItems ?? this.revealedItems,
    );
  }
}

const _sentinel = Object();

@riverpod
class ModulePlayerViewModel extends _$ModulePlayerViewModel {
  late String _avatarId;
  late String _moduleId;

  @override
  ModulePlayerState build(String avatarId, String moduleId) {
    _avatarId = avatarId;
    _moduleId = moduleId;
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

      appLog.i('[ModulePlayer] Loaded ${items.length} items for ${state.stage}');
      state = state.copyWith(
        items: items,
        currentIndex: 0,
        isLoading: false,
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

      final res = await dio.post<dynamic>(
        '/api/v1/avatars/$_avatarId/modules/$_moduleId/submit',
        data: submissions,
      );

      final data = res.data;
      final nextStage = _extractNextStage(data);
      appLog.i('[ModulePlayer] Submission complete, next stage: $nextStage');

      if (nextStage == 'COMPLETE') {
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
}
