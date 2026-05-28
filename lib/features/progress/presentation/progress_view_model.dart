import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/utils/logger.dart';
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
      // Offline / unreachable backend: return an EMPTY summary so the UI
      // shows the user's actual unknown state (no fake "level 4" that
      // appears to regress when the real data loads after restart).
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown) {
        appLog.w('[Progress] Backend unreachable; showing empty stub');
        return _emptyProgress;
      }
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchProgress);
  }
}

/// Empty placeholder — shown only when the backend is unreachable.
/// We never show fabricated XP/level because users would mistake the stub
/// for real progress and report "my XP reset" after the real data loads.
const _emptyProgress = ProgressSummary(
  level: 1,
  xp: 0,
  xpToNextLevel: 100,
  streakDays: 0,
  weekMinutes: [0, 0, 0, 0, 0, 0, 0],
  weakTopics: [],
  badges: [],
);
