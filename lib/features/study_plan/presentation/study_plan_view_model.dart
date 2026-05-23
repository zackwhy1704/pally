import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/app/api_client.dart';
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
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown) {
        return _stubPlan;
      }
      rethrow;
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

final _now = DateTime.now();

final _stubPlan = [
  StudyPlanItem(
    id: 'sp-1',
    title: 'Review Photosynthesis flashcards',
    type: StudyPlanItemType.flashcard,
    isDone: true,
    scheduledDate: _now,
  ),
  StudyPlanItem(
    id: 'sp-2',
    title: 'Daily quiz — Science',
    type: StudyPlanItemType.quiz,
    isDone: false,
    scheduledDate: _now,
  ),
  StudyPlanItem(
    id: 'sp-3',
    title: 'Read Cell Division notes',
    type: StudyPlanItemType.reading,
    isDone: false,
    scheduledDate: _now,
  ),
  StudyPlanItem(
    id: 'sp-4',
    title: 'Practice Ecosystems quiz',
    type: StudyPlanItemType.practice,
    isDone: false,
    scheduledDate: _now.add(const Duration(days: 1)),
  ),
  StudyPlanItem(
    id: 'sp-5',
    title: 'Review Chemical Bonds',
    type: StudyPlanItemType.flashcard,
    isDone: false,
    scheduledDate: _now.add(const Duration(days: 2)),
  ),
];
