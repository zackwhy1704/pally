import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/error/pally_error.dart';
import 'package:pally/core/utils/logger.dart';
import 'package:pally/shared/models/homework_submission.dart';

part 'homework_list_view_model.g.dart';

/// Loads the student's OWN homework submissions for a centre class avatar.
/// Read-only list; the submit flow lives in [HomeworkSubmitViewModel].
@riverpod
class HomeworkListViewModel extends _$HomeworkListViewModel {
  late String _avatarId;

  @override
  Future<List<HomeworkSubmission>> build(String avatarId) async {
    _avatarId = avatarId;
    return _fetch();
  }

  Future<List<HomeworkSubmission>> _fetch() async {
    appLog.d('[Homework] Fetching submissions for avatar $_avatarId');
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get<dynamic>(
        '/api/v1/avatars/$_avatarId/homework',
      );
      final data = response.data;
      final List<dynamic> list = data is List
          ? data
          : (data is Map && data['submissions'] is List
              ? data['submissions'] as List<dynamic>
              : const <dynamic>[]);
      final out = <HomeworkSubmission>[];
      for (final e in list) {
        try {
          out.add(
            HomeworkSubmission.fromJson(Map<String, dynamic>.from(e as Map)),
          );
        } catch (err, st) {
          appLog.e('[Homework] failed to parse submission (raw=$e)',
              error: err, stackTrace: st);
        }
      }
      appLog.i('[Homework] Loaded ${out.length} submissions');
      return out;
    } on DioException catch (e, st) {
      if (e.response?.statusCode == 404) {
        appLog.d('[Homework] No submissions found (404)');
        return const [];
      }
      appLog.e('[Homework] list failed statusCode=${e.response?.statusCode}',
          error: e, stackTrace: st);
      throw PallyError.from(e);
    } catch (e, st) {
      appLog.e('[Homework] unexpected error listing submissions',
          error: e, stackTrace: st);
      throw PallyError.unknown;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}
