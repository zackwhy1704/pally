import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/utils/logger.dart';
import 'package:pally/shared/models/exam_prep.dart';

part 'exam_prep_view_model.g.dart';

@riverpod
class ExamPrepViewModel extends _$ExamPrepViewModel {
  late String _avatarId;

  @override
  Future<ExamPrep> build(String avatarId) async {
    _avatarId = avatarId;
    return _fetchExamPrep();
  }

  Future<ExamPrep> _fetchExamPrep() async {
    appLog.d('[ExamPrep] Fetching exam prep for avatar $_avatarId');
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get<dynamic>(
        '/api/v1/avatars/$_avatarId/exam-prep',
      );
      final data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};

      final examPrep = ExamPrep.fromJson(data);
      appLog.i('[ExamPrep] Loaded: ${examPrep.concepts.length} concepts, '
          'daysRemaining=${examPrep.daysRemaining}');
      return examPrep;
    } on DioException catch (e, st) {
      if (e.response?.statusCode == 404) {
        appLog.d('[ExamPrep] No exam prep data (404)');
        return const ExamPrep();
      }
      appLog.e('[ExamPrep] fetchExamPrep failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchExamPrep);
  }

  Future<bool> startRevision(String moduleId) async {
    appLog.i('[ExamPrep] Starting revision for module $moduleId');
    try {
      final dio = ref.read(dioProvider);
      await dio.post<dynamic>(
        '/api/v1/avatars/$_avatarId/modules/$moduleId/start',
      );
      return true;
    } on DioException catch (e, st) {
      appLog.e('[ExamPrep] Start revision failed',
          error: e, stackTrace: st);
      return false;
    }
  }
}
