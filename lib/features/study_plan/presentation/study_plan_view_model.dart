import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/utils/logger.dart';
import 'package:pally/shared/models/study_plan_item.dart';

part 'study_plan_view_model.g.dart';

@riverpod
class StudyPlanViewModel extends _$StudyPlanViewModel {
  @override
  Future<List<StudyPlanItem>> build() async => _fetchPlan();

  Future<List<StudyPlanItem>> _fetchPlan() async {
    try {
      final dio = ref.read(dioProvider);
      final response =
          await dio.get<Map<String, dynamic>>('/api/v1/progress/study-plan');

      // Unwrap ApiResponse envelope: { "data": { "items": [...] } }
      final body = response.data ?? {};
      final data = (body['data'] is Map)
          ? Map<String, dynamic>.from(body['data'] as Map)
          : body;

      final list = (data['items'] as List<dynamic>?) ?? const [];
      return list
          .whereType<Map<String, dynamic>>()
          .map(StudyPlanItem.fromJson)
          .toList();
    } catch (e) {
      appLog.w('[StudyPlan] load failed: $e');
      return const [];
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchPlan);
  }

  /// Optimistically mark a task done, then persist to the backend.
  /// Reverts on failure so the UI never lies about completion state.
  Future<void> markDone(String itemId) async {
    final previous = state.valueOrNull ?? [];
    // Optimistic update
    state = AsyncData(
      previous
          .map((i) => i.id == itemId ? i.copyWith(isDone: true) : i)
          .toList(),
    );
    try {
      final dio = ref.read(dioProvider);
      await dio.post<void>('/api/v1/progress/study-plan/$itemId/done');
      appLog.d('[StudyPlan] task $itemId marked done');
    } on DioException catch (e) {
      appLog.w('[StudyPlan] mark-done failed, reverting: ${e.message}');
      // Revert to previous state
      state = AsyncData(previous);
      rethrow;
    }
  }

  bool get isAllDone {
    final items = state.valueOrNull;
    if (items == null || items.isEmpty) return false;
    final todayItems = items.where((i) => i.scheduledDate == null ||
        _isSameDay(i.scheduledDate!, DateTime.now())).toList();
    return todayItems.isNotEmpty && todayItems.every((i) => i.isDone);
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
