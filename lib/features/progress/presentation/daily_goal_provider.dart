import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/utils/logger.dart';
import 'package:pally/shared/models/daily_goal.dart';

part 'daily_goal_provider.g.dart';

@riverpod
class DailyGoalVm extends _$DailyGoalVm {
  @override
  Future<DailyGoal> build() async => _fetch();

  Future<DailyGoal> _fetch() async {
    try {
      final dio = ref.read(dioProvider);
      final res = await dio.get<dynamic>('/api/v1/progress/today');
      final data = res.data;
      final body = (data is Map && data['data'] is Map)
          ? Map<String, dynamic>.from(data['data'] as Map)
          : Map<String, dynamic>.from(data as Map);
      return DailyGoal.fromJson(body);
    } on DioException catch (e) {
      appLog.w('[DailyGoal] /today failed: ${e.message}');
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> setGoal(String goalType, int goalTarget) async {
    final dio = ref.read(dioProvider);
    await dio.post<dynamic>('/api/v1/progress/daily-goal', data: {
      'goalType': goalType,
      'goalTarget': goalTarget,
    });
    await refresh();
  }
}
