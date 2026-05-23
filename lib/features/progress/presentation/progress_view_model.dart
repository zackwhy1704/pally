import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/shared/models/progress_summary.dart';

part 'progress_view_model.g.dart';

@riverpod
class ProgressViewModel extends _$ProgressViewModel {
  @override
  Future<ProgressSummary> build() async {
    return _fetchProgress();
  }

  Future<ProgressSummary> _fetchProgress() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get<Map<String, dynamic>>('/api/v1/progress');
      return ProgressSummary.fromJson(response.data!);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown) {
        return _stubProgress;
      }
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchProgress);
  }
}

const _stubProgress = ProgressSummary(
  level: 4,
  xp: 680,
  xpToNextLevel: 900,
  streakDays: 7,
  weekMinutes: [12, 25, 8, 30, 15, 22, 18],
  weakTopics: [
    WeakTopic(topic: 'Photosynthesis', mastery: 0.35),
    WeakTopic(topic: 'Cell Division', mastery: 0.52),
    WeakTopic(topic: 'Chemical Bonds', mastery: 0.41),
  ],
  badges: ['🔥', '⭐', '📚', '🏆', '💡'],
);
