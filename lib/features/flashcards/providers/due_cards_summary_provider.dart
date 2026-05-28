import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/utils/logger.dart';
import 'package:pally/features/home/presentation/home_view_model.dart';
import 'package:pally/shared/models/avatar.dart';
import 'package:pally/shared/models/flash_card.dart';

/// Aggregated count of currently-due flashcards across every avatar the user
/// owns. Used by the Home screen banner ("3 cards due — quick review!").
///
/// One round-trip per avatar; cheap enough for a pilot user base (typically
/// 1-3 tutors). Cached for the session — a manual refresh comes from the
/// pull-to-refresh on Home invalidating this provider.
class DueCardsSummary {
  const DueCardsSummary({
    required this.totalDue,
    required this.byAvatar,
    required this.firstDueAvatar,
  });

  final int totalDue;
  final Map<String, int> byAvatar; // avatarId → due count
  final Avatar? firstDueAvatar;

  bool get isEmpty => totalDue == 0;
}

final dueCardsSummaryProvider =
    FutureProvider.autoDispose<DueCardsSummary>((ref) async {
  final avatarsAsync = ref.watch(homeViewModelProvider);
  final avatars = avatarsAsync.maybeWhen(
    data: (list) => list,
    orElse: () => const <Avatar>[],
  );
  if (avatars.isEmpty) {
    return const DueCardsSummary(
        totalDue: 0, byAvatar: {}, firstDueAvatar: null);
  }

  final dio = ref.read(dioProvider);
  final now = DateTime.now();
  final counts = <String, int>{};
  Avatar? firstDue;

  await Future.wait(avatars.map((avatar) async {
    try {
      final response = await dio.get<Map<String, dynamic>>(
        '/api/v1/avatars/${avatar.id}/flashcards',
      );
      final list = (response.data?['cards'] as List<dynamic>?) ??
          (response.data is List
              ? response.data as List<dynamic>
              : const <dynamic>[]);
      final dueCount = list
          .map((e) => FlashCard.fromJson(e as Map<String, dynamic>))
          .where((c) =>
              c.nextReview != null && !c.nextReview!.isAfter(now))
          .length;
      if (dueCount > 0) {
        counts[avatar.id] = dueCount;
        firstDue ??= avatar;
      }
    } catch (e) {
      appLog.w('[DueCards] /flashcards failed avatar=${avatar.id}: $e');
    }
  }));

  final total = counts.values.fold<int>(0, (a, b) => a + b);
  return DueCardsSummary(
      totalDue: total, byAvatar: counts, firstDueAvatar: firstDue);
});
