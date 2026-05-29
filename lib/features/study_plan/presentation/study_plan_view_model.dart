import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/utils/logger.dart';
import 'package:pally/shared/models/study_plan_item.dart';

part 'study_plan_view_model.g.dart';

@riverpod
class StudyPlanViewModel extends _$StudyPlanViewModel {
  @override
  Future<List<StudyPlanItem>> build() async {
    return _fetchPlan();
  }

  Future<List<StudyPlanItem>> _fetchPlan() async {
    try {
      final dio = ref.read(dioProvider);
      final response =
          await dio.get<Map<String, dynamic>>('/api/v1/progress/study-plan');
      final list = (response.data?['items'] as List<dynamic>?) ??
          (response.data is List ? response.data as List<dynamic> : []);
      return list
          .map((e) => StudyPlanItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      // Never fabricate study-plan items on failure. Empty list lets the
      // screen render the real "all done" / offline empty state instead
      // of pretending the user has photosynthesis homework they don't.
      appLog.w('[StudyPlan] load failed: ${e.message}');
      return const [];
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchPlan);
  }

  void markDone(String itemId) {
    state.whenData((items) {
      state = AsyncData(
        items
            .map((i) => i.id == itemId ? i.copyWith(isDone: true) : i)
            .toList(),
      );
    });
  }
}
