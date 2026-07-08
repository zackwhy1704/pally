import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/error/pally_error.dart';
import 'package:pally/core/observability/observability.dart';
import 'package:pally/core/observability/observability_providers.dart';
import 'package:pally/core/utils/logger.dart';
import 'package:pally/shared/models/learning_module.dart';

part 'module_player_view_model.g.dart';

/// One open-ended PROVE item awaiting the student's self-assessment. The server
/// never asserts correctness for these; the student compares their answer to the
/// reference and self-reports (recorded as a low-trust SELF_REPORT signal).
@immutable
class SelfAssessItem {
  const SelfAssessItem({
    required this.itemId,
    required this.question,
    required this.yourAnswer,
    required this.reference,
    this.feedback,
  });

  final String itemId;
  final String question;
  final String yourAnswer;

  /// The reference answer / expected key points, for the student to compare.
  final String reference;
  final String? feedback;
}

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
    this.selfAssessItems = const [],
    this.selfReports = const {},
    this.selfAssessDone = false,
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

  /// Open-ended PROVE items awaiting self-assessment (populated from the PROVE
  /// submit response). Shown once, after PROVE, before the completion screen.
  final List<SelfAssessItem> selfAssessItems;

  /// itemId -> self-report (YES/PARTLY/NO) already submitted this session.
  final Map<String, String> selfReports;

  /// True once the student has finished (or skipped) self-assessment, so the
  /// overlay shows once and the completion flow follows.
  final bool selfAssessDone;

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
    List<SelfAssessItem>? selfAssessItems,
    Map<String, String>? selfReports,
    bool? selfAssessDone,
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
      selfAssessItems: selfAssessItems ?? this.selfAssessItems,
      selfReports: selfReports ?? this.selfReports,
      selfAssessDone: selfAssessDone ?? this.selfAssessDone,
    );
  }
}

const _sentinel = Object();

@riverpod
class ModulePlayerViewModel extends _$ModulePlayerViewModel {
  late String _avatarId;
  late String _moduleId;

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

      if (rawItems.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          error: const PallyError(
            PallyErrorKind.notFound,
            'No content yet — your teacher needs to upload notes for this topic.',
          ),
        );
        return;
      }

      final items = <ModuleContentItem>[];
      for (final e in rawItems) {
        try {
          final parsed = ModuleContentItem.fromJson(
            Map<String, dynamic>.from(e as Map),
          );
          // Blank-item client shield: a TEST item whose reveal content is
          // substantively blank (a slipped-through generation defect) is SKIPPED so
          // the student never sees an empty "The error:" / "Correct solution:" reveal.
          // It contributes no signal (stays UNGRADED) — the exact sibling of the PROVE
          // blank-reference guard below. The generation reaper owns fixing the item.
          if (isBlankTestItem(parsed)) {
            appLog.w('[ModulePlayer] TEST item ${parsed.id} (${parsed.type}) has a '
                'blank reveal — skipping (stays UNGRADED)');
            continue;
          }
          items.add(parsed);
        } catch (err, st) {
          appLog.e('[ModulePlayer] Failed to parse item',
              error: err, stackTrace: st);
        }
      }

      if (items.isEmpty) {
        ref.read(analyticsProvider).event(
          AnalyticsEvents.modulePlayerParseError,
          props: {
            'module_id': _moduleId,
            'avatar_id': _avatarId,
            'raw_count': rawItems.length,
          },
        );
        state = state.copyWith(
          isLoading: false,
          error: const PallyError(
            PallyErrorKind.server,
            'Something went wrong loading this lesson. Try again or contact support.',
          ),
        );
        return;
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

      // Backend binds @RequestBody SubmitModuleAnswersRequest{submissions, durationSeconds}
      // — an OBJECT — and reads durationSeconds from the BODY (there is NO @RequestParam
      // for it). A bare list 400s ("Cannot deserialize ... from Array value") and a query
      // param is ignored, so the stage never advances. Wrap the body.
      final res = await dio.post<dynamic>(
        '/api/v1/avatars/$_avatarId/modules/$_moduleId/submit',
        data: buildModuleSubmitBody(
          submissions: submissions,
          durationSeconds: _stageDurationSeconds,
        ),
      );

      final data = res.data;

      // Capture open-ended PROVE items for self-assessment. The server no longer
      // asserts a correctness score for these; the student compares to the
      // reference answer and self-reports. Populated BEFORE advancing so the
      // overlay renders in the completion flow.
      if (state.stage == 'PROVE') {
        final assessItems = _extractSelfAssessItems(data);
        if (assessItems.isNotEmpty) {
          state = state.copyWith(
            selfAssessItems: assessItems,
            selfReports: const {},
            selfAssessDone: false,
          );
        }
      }

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

  /// Builds the self-assessment list from a PROVE submit response. Each result
  /// carries `selfAssess:true`, a `referenceAnswer` (the answer_json), and
  /// `feedback`. The question + the student's own answer come from local state.
  List<SelfAssessItem> _extractSelfAssessItems(dynamic data) {
    if (data is! Map || data['results'] is! List) return const [];
    final out = <SelfAssessItem>[];
    for (final r in data['results'] as List) {
      if (r is! Map || r['selfAssess'] != true) continue;
      final itemId = r['itemId']?.toString();
      if (itemId == null) continue;
      final matches = state.items.where((i) => i.id == itemId);
      final item = matches.isEmpty ? null : matches.first;
      final question = item?.contentJson['question'];
      final reference = _readableReference(r['referenceAnswer']);
      // Blank/invalid reference (legacy blank-content items): do NOT ask the
      // student to self-grade against an empty model answer — skip self-assess so
      // the item stays UNGRADED. The generation reaper owns fixing the blank item.
      if (reference.trim().isEmpty) {
        appLog.w('[ModulePlayer] PROVE item $itemId has blank reference — '
            'skipping self-assess (stays UNGRADED)');
        continue;
      }
      out.add(SelfAssessItem(
        itemId: itemId,
        question: (question is String && question.isNotEmpty)
            ? question
            : 'Your answer',
        yourAnswer: state.answers[itemId] ?? '',
        reference: reference,
        feedback: r['feedback']?.toString(),
      ));
    }
    return out;
  }

  /// Turns the raw answer_json into a readable reference for the student. Falls
  /// back to the raw string if it isn't the expected shape.
  String _readableReference(dynamic raw) {
    if (raw is! String || raw.isEmpty) return '';
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        final kp = decoded['expectedKeyPoints'];
        if (kp is List && kp.isNotEmpty) {
          return kp.map((e) => '• $e').join('\n');
        }
        final answer = decoded['answer'];
        if (answer is String && answer.isNotEmpty) return answer;
      }
    } catch (_) {
      // not JSON — show as-is
    }
    return raw;
  }

  /// Records the student's self-assessment of one open-ended PROVE answer.
  /// Best-effort + non-blocking — the item already completed on submit, so a
  /// failure here never blocks the module. Re-entrancy: a re-tap replaces.
  Future<void> submitSelfReport(String itemId, String selfReport) async {
    // Optimistic: reflect the choice immediately.
    final optimistic = Map<String, String>.from(state.selfReports);
    optimistic[itemId] = selfReport;
    state = state.copyWith(selfReports: optimistic);

    final dio = ref.read(dioProvider);
    final path =
        '/api/v1/avatars/$_avatarId/modules/$_moduleId/items/$itemId/self-report';
    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        await dio.post<dynamic>(path, data: {'selfReport': selfReport});
        return; // recorded
      } catch (e, st) {
        if (attempt == 0) continue; // one retry before giving up
        // Don't SILENTLY drop: revert the optimistic selection so the UI shows it
        // as un-recorded (the choice de-highlights), and the student can re-tap.
        appLog.w('[ModulePlayer] Self-report failed after retry — reverting so it '
            'is not falsely shown as saved', error: e, stackTrace: st);
        final reverted = Map<String, String>.from(state.selfReports);
        reverted.remove(itemId);
        state = state.copyWith(selfReports: reverted);
      }
    }
  }

  /// Dismisses the self-assessment overlay so the completion flow proceeds.
  void finishSelfAssess() {
    state = state.copyWith(selfAssessDone: true);
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
}

/// Builds the module-submit request body. MUST be a JSON object (not a bare list):
/// the backend binds `@RequestBody SubmitModuleAnswersRequest{submissions, durationSeconds}`
/// and reads durationSeconds from the body. Extracted + pure so a test can pin the
/// object shape (a bare list 400s "Cannot deserialize ... from Array value").
@visibleForTesting
Map<String, dynamic> buildModuleSubmitBody({
  required List<Map<String, String>> submissions,
  required int durationSeconds,
}) {
  return {
    'submissions': submissions,
    'durationSeconds': durationSeconds,
  };
}

/// A TEST item whose reveal (answer) content is substantively blank — the same
/// fields RulesOutputValidator enforces server-side. The module player SKIPS these
/// (they stay UNGRADED, never render an empty reveal), mirroring the PROVE blank-
/// reference guard. Top-level so it's directly unit-testable.
bool isBlankTestItem(ModuleContentItem item) {
  final reveal = item.answerJson ?? const <String, dynamic>{};
  String field(String k) => (reveal[k] as String?)?.trim() ?? '';
  return switch (item.type) {
    'SPOT_MISTAKE' =>
      field('errorDescription').isEmpty && field('correctSolution').isEmpty,
    'HOT_TAKE' => field('explanation').isEmpty,
    'CHALLENGE' => field('explanation').isEmpty,
    _ => false, // LEARN micro-cards / PROVE handled elsewhere
  };
}
