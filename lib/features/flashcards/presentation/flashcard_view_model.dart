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
    this.isRating = false,
    this.error,
  });

  final List<FlashCard> cards;
  final int currentIndex;
  final bool isFlipped;
  final FlashCardFilter filter;
  final bool isLoading;
  final bool isRating;
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
    bool? isRating,
    Object? error = _sentinel,
  }) {
    return FlashCardState(
      cards: cards ?? this.cards,
      currentIndex: currentIndex ?? this.currentIndex,
      isFlipped: isFlipped ?? this.isFlipped,
      filter: filter ?? this.filter,
      isLoading: isLoading ?? this.isLoading,
      isRating: isRating ?? this.isRating,
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

  Future<void> _loadCards() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio
          .get<Map<String, dynamic>>('/api/v1/avatars/$_avatarId/flashcards');
      final list = (response.data?['cards'] as List<dynamic>?) ??
          (response.data is List ? response.data as List<dynamic> : []);
      final cards = list
          .map((e) => FlashCard.fromJson(e as Map<String, dynamic>))
          .toList();
      state = state.copyWith(cards: cards, isLoading: false);
      unawaited(_rescheduleSrs());
    } on DioException catch (e) {
      if (e.response?.statusCode == 404 || e.response?.statusCode == 500) {
        state = state.copyWith(cards: [], isLoading: false);
        return;
      }
      state = state.copyWith(cards: _stubCards, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

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

      final earliest = due.isNotEmpty ? now : upcoming.first.nextReview!;
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
      return (data['name'] as String?) ?? 'your tutor';
    } catch (_) {
      return 'your tutor';
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

const _stubCards = [
  FlashCard(
    id: 'fc-1',
    front: 'What is photosynthesis?',
    back:
        'The process by which plants use sunlight, water and CO₂ to produce glucose and oxygen.',
    sourceFile: 'Biology Notes.pdf',
  ),
  FlashCard(
    id: 'fc-2',
    front: 'What is the powerhouse of the cell?',
    back: 'The mitochondria — it produces ATP through cellular respiration.',
    sourceFile: 'Cell Biology.pdf',
  ),
  FlashCard(
    id: 'fc-3',
    front: 'Define an ecosystem',
    back:
        'All living organisms in an area together with their non-living environment, interacting as a system.',
    sourceFile: 'Ecosystems.pdf',
  ),
];
