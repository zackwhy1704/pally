import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/services/notification_service.dart';
import 'package:pally/core/utils/logger.dart';
import 'package:pally/shared/models/flash_card.dart';

part 'flashcard_view_model.g.dart';

enum FlashCardFilter { all, due, weak, done }

@immutable
class FlashCardState {
  const FlashCardState({
    this.cards = const [],
    this.currentIndex = 0,
    this.isFlipped = false,
    this.filter = FlashCardFilter.all,
    this.isLoading = false,
    this.isGenerating = false,
    this.isRating = false,
    this.hasWikiPages,
    this.needsCardConfirmation = false,
    this.cardPageCount = 0,
    this.error,
  });

  final List<FlashCard> cards;
  final int currentIndex;
  final bool isFlipped;
  final FlashCardFilter filter;
  final bool isLoading;
  /// True while the on-demand generate call is running.
  final bool isGenerating;
  final bool isRating;
  /// null = unknown (not yet checked); true = avatar has wiki pages;
  /// false = no notes uploaded yet.
  final bool? hasWikiPages;

  /// True when the corpus is large enough that auto-generate was deferred to an
  /// explicit CTA (avoids the synchronous all-pages hang).
  final bool needsCardConfirmation;

  /// Number of wiki pages the "Generate cards (~N pages)" CTA would process.
  final int cardPageCount;
  final String? error;

  List<FlashCard> get filteredCards {
    final now = DateTime.now();
    switch (filter) {
      case FlashCardFilter.all:
        return cards;
      case FlashCardFilter.due:
        return cards
            .where((c) => c.nextReview == null || c.nextReview!.isBefore(now))
            .toList();
      case FlashCardFilter.weak:
        return cards.where((c) => c.lastRating == CardRating.hard).toList();
      case FlashCardFilter.done:
        return cards.where((c) => c.lastRating == CardRating.easy).toList();
    }
  }

  FlashCard? get currentCard =>
      filteredCards.isEmpty ? null : filteredCards[currentIndex];

  bool get hasCards => filteredCards.isNotEmpty;
  int get totalFiltered => filteredCards.length;
  bool get isLastCard => currentIndex >= totalFiltered - 1;

  FlashCardState copyWith({
    List<FlashCard>? cards,
    int? currentIndex,
    bool? isFlipped,
    FlashCardFilter? filter,
    bool? isLoading,
    bool? isGenerating,
    bool? isRating,
    Object? hasWikiPages = _sentinel,
    bool? needsCardConfirmation,
    int? cardPageCount,
    Object? error = _sentinel,
  }) {
    return FlashCardState(
      cards: cards ?? this.cards,
      currentIndex: currentIndex ?? this.currentIndex,
      isFlipped: isFlipped ?? this.isFlipped,
      filter: filter ?? this.filter,
      isLoading: isLoading ?? this.isLoading,
      isGenerating: isGenerating ?? this.isGenerating,
      isRating: isRating ?? this.isRating,
      hasWikiPages: hasWikiPages == _sentinel
          ? this.hasWikiPages
          : hasWikiPages as bool?,
      needsCardConfirmation: needsCardConfirmation ?? this.needsCardConfirmation,
      cardPageCount: cardPageCount ?? this.cardPageCount,
      error: error == _sentinel ? this.error : error as String?,
    );
  }
}

const _sentinel = Object();

@riverpod
class FlashCardViewModel extends _$FlashCardViewModel {
  late String _avatarId;

  @override
  FlashCardState build(String avatarId) {
    _avatarId = avatarId;
    _loadCards();
    return const FlashCardState(isLoading: true);
  }

  Future<void> _loadCards({bool autoGenerate = true}) async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio
          .get<dynamic>('/api/v1/avatars/$_avatarId/flashcards');
      final data = response.data;
      // Backend returns ApiResponse<List> → { "data": [...] }
      final List<dynamic> list = switch (data) {
        List<dynamic> l => l,
        Map m when m['data'] is List => m['data'] as List<dynamic>,
        Map m when m['cards'] is List => m['cards'] as List<dynamic>,
        _ => const <dynamic>[],
      };
      final cards = list
          .map((e) => FlashCard.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      state = state.copyWith(cards: cards, isLoading: false);

      // Auto-backfill: if the deck is empty on first load, try generating.
      // The generate endpoint returns hasWikiPages so we know which empty
      // state to show even when generation produces 0 cards.
      if (cards.isEmpty && autoGenerate) {
        await _generateCards(fromAutoBackfill: true);
        return;
      }
      unawaited(_rescheduleSrs());
    } on DioException catch (e, st) {
      appLog.w('[Flashcards] load failed', error: e, stackTrace: st);
      if (e.response?.statusCode == 404) {
        state = state.copyWith(cards: const [], isLoading: false);
        return;
      }
      final errorMsg = e.type == DioExceptionType.connectionError ||
              e.type == DioExceptionType.unknown
          ? 'No internet connection.'
          : 'Could not load flashcards.';
      state = state.copyWith(
          cards: const [], isLoading: false, error: errorMsg);
    } catch (e, st) {
      appLog.e('[Flashcards] unexpected error', error: e, stackTrace: st);
      state = state.copyWith(
          cards: const [], isLoading: false, error: 'Something went wrong.');
    }
  }

  /// Calls POST /flashcards/generate, updates hasWikiPages, then reloads.
  /// [fromAutoBackfill] prevents re-triggering generate after reload. When
  /// [confirmed] is false (an auto-backfill) and the corpus is large, the server
  /// returns needsConfirmation instead of running the synchronous all-pages loop
  /// — we surface a "Generate cards (~N pages)" CTA rather than hang the screen.
  Future<void> _generateCards({
    bool fromAutoBackfill = false,
    bool confirmed = false,
  }) async {
    state = state.copyWith(isGenerating: true, needsCardConfirmation: false);
    try {
      final dio = ref.read(dioProvider);
      final res = await dio.post<dynamic>(
          '/api/v1/avatars/$_avatarId/flashcards/generate',
          queryParameters: {'confirmed': confirmed});
      final body = res.data is Map ? res.data as Map : {};
      final inner = body['data'] is Map ? body['data'] as Map : body;
      final generated = (inner['generated'] as num?)?.toInt() ?? 0;
      final hasPages = (inner['hasWikiPages'] as bool?) ?? false;
      final needsConfirmation = (inner['needsConfirmation'] as bool?) ?? false;
      final pageCount = (inner['pageCount'] as num?)?.toInt() ?? 0;

      if (needsConfirmation) {
        // Big corpus — don't auto-run. Show the CTA with its scope.
        appLog.i('[Flashcards] deferring to CTA: $pageCount pages');
        state = state.copyWith(
          hasWikiPages: true,
          isGenerating: false,
          needsCardConfirmation: true,
          cardPageCount: pageCount,
        );
        return;
      }

      appLog.i('[Flashcards] generate result: $generated cards, hasPages=$hasPages');
      state = state.copyWith(hasWikiPages: hasPages, isGenerating: false);
      if (generated > 0) {
        // Real cards were created — reload to show them.
        state = state.copyWith(isLoading: true);
        await _loadCards(autoGenerate: false);
      }
    } catch (e) {
      appLog.w('[Flashcards] generate failed: $e');
      state = state.copyWith(isGenerating: false);
    }
  }

  /// The explicit "Generate cards" CTA — a confirmed run (bypasses the auto-gen
  /// threshold) so the large-corpus generation proceeds on the user's choice.
  Future<void> generateCards() => _generateCards(confirmed: true);

  /// Recomputes and re-arms the per-avatar SRS notification slot based on the
  /// current deck's `nextReview` dates. Best-effort — failures don't propagate.
  Future<void> _rescheduleSrs() async {
    try {
      final now = DateTime.now();
      final due = state.cards
          .where((c) => c.nextReview != null && !c.nextReview!.isAfter(now))
          .toList();
      final upcoming = state.cards
          .where((c) => c.nextReview != null && c.nextReview!.isAfter(now))
          .toList()
        ..sort((a, b) => a.nextReview!.compareTo(b.nextReview!));

      if (due.isEmpty && upcoming.isEmpty) {
        await NotificationService.cancelSrsReminder(_avatarId);
        return;
      }

      // Guard: upcoming is non-empty here because we checked both empty above
      final earliest = due.isNotEmpty
          ? now
          : (upcoming.first.nextReview ?? now);
      // For a future-scheduled reminder we want to count cards due on that
      // same calendar day, not the whole future deck.
      final count = due.isNotEmpty
          ? due.length
          : upcoming
              .where((c) => _isSameDay(c.nextReview!, earliest))
              .length;

      final name = await _fetchAvatarName();
      await NotificationService.scheduleSrsReminder(
        avatarId: _avatarId,
        avatarName: name,
        dueCount: count,
        earliestDue: earliest,
      );
    } catch (e) {
      appLog.w('[Flashcards] SRS reschedule failed: $e');
    }
  }

  Future<String> _fetchAvatarName() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio
          .get<Map<String, dynamic>>('/api/v1/avatars/$_avatarId');
      final data = (response.data?['data'] is Map
              ? response.data!['data']
              : response.data) as Map<String, dynamic>;
      return (data['name'] as String?) ?? 'your Mochi';
    } catch (_) {
      return 'your Mochi';
    }
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void flip() {
    state = state.copyWith(isFlipped: !state.isFlipped);
  }

  void setFilter(FlashCardFilter filter) {
    state = state.copyWith(filter: filter, currentIndex: 0, isFlipped: false);
  }

  Future<void> rate(CardRating rating) async {
    final card = state.currentCard;
    if (card == null) return;

    state = state.copyWith(isRating: true);
    try {
      final dio = ref.read(dioProvider);
      await dio.post(
        '/api/v1/avatars/$_avatarId/flashcards/${card.id}/rate',
        data: {'rating': rating.name.toUpperCase()},
      );
    } catch (_) {
      // Silently ignore network errors
    }

    // Update local state
    final updatedCards = state.cards
        .map((c) => c.id == card.id ? c.copyWith(lastRating: rating) : c)
        .toList();

    final nextIndex = state.isLastCard ? 0 : state.currentIndex + 1;
    state = state.copyWith(
      cards: updatedCards,
      currentIndex: nextIndex,
      isFlipped: false,
      isRating: false,
    );
    // A rating shifts nextReview via SM-2 server-side; refetch so the local
    // schedule reflects the new dates, then re-arm the notification.
    unawaited(refresh());
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    await _loadCards();
  }
}

