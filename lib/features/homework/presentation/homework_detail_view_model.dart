import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/error/pally_error.dart';
import 'package:pally/core/utils/logger.dart';
import 'package:pally/shared/models/homework_submission.dart';

part 'homework_detail_view_model.g.dart';

/// Loads a single homework submission so the student can read the teacher's
/// RELEASED feedback. The teacher feedback/grade only appear in the response
/// once the teacher releases — we never synthesise them client-side.
@riverpod
class HomeworkDetailViewModel extends _$HomeworkDetailViewModel {
  @override
  Future<HomeworkSubmission> build(String avatarId, String submissionId) async {
    appLog.d('[Homework] Fetching detail $submissionId for avatar $avatarId');
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get<dynamic>(
        '/api/v1/avatars/$avatarId/homework/$submissionId',
      );
      final data = response.data is Map
          ? Map<String, dynamic>.from(response.data as Map)
          : <String, dynamic>{};
      final detail = HomeworkSubmission.fromJson(data);
      appLog.i('[Homework] Detail loaded status=${detail.status}');
      return detail;
    } on DioException catch (e, st) {
      appLog.e('[Homework] detail load failed avatarId=$avatarId '
          'submissionId=$submissionId statusCode=${e.response?.statusCode}',
          error: e, stackTrace: st);
      throw PallyError.from(e);
    } catch (e, st) {
      appLog.e('[Homework] unexpected error loading detail',
          error: e, stackTrace: st);
      throw PallyError.unknown;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build(avatarId, submissionId));
  }
}
