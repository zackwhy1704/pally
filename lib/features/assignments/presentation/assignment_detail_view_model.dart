import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/utils/logger.dart';
import 'package:pally/shared/models/assignment_detail.dart';

part 'assignment_detail_view_model.g.dart';

/// A2 — loads a single student assignment so the UI can render the per-question
/// answer-compare view. The `modelAnswer` field only appears in the response
/// when the teacher has released answers; we never synthesise one client-side.
@riverpod
class AssignmentDetailViewModel extends _$AssignmentDetailViewModel {
  @override
  Future<AssignmentDetail> build(String avatarId, String assignmentId) async {
    appLog.d('[Assignments] Fetching detail $assignmentId for avatar $avatarId');
    final dio = ref.read(dioProvider);
    final response = await dio.get<dynamic>(
      '/api/v1/avatars/$avatarId/assignments/$assignmentId',
    );
    final data = response.data is Map
        ? Map<String, dynamic>.from(response.data as Map)
        : <String, dynamic>{};
    final detail = AssignmentDetail.fromJson(data);
    appLog.i('[Assignments] Detail loaded released=${detail.answersReleased} '
        'questions=${detail.questions.length}');
    return detail;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build(avatarId, assignmentId));
  }
}
