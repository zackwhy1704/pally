import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/utils/logger.dart';
import 'package:pally/shared/models/streak_status.dart';

part 'streak_status_provider.g.dart';

/// Streak card data — separate from ProgressViewModel so a streak refresh
/// after activity doesn't force the whole dashboard to reload.
@riverpod
class StreakStatusVm extends _$StreakStatusVm {
  @override
  Future<StreakStatus> build() async => _fetch();

  Future<StreakStatus> _fetch() async {
    try {
      final dio = ref.read(dioProvider);
      final res = await dio.get<dynamic>('/api/v1/progress/streak');
      final data = res.data;
      // The Dio interceptor already unwraps {data: …}; double-unwrap defensively
      // in case a future caller bypasses the interceptor.
      final body = (data is Map && data['data'] is Map)
          ? Map<String, dynamic>.from(data['data'] as Map)
          : Map<String, dynamic>.from(data as Map);
      return StreakStatus.fromJson(body);
    } on DioException catch (e) {
      appLog.w('[Streak] /streak failed: ${e.message}');
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}
