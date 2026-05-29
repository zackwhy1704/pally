import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/utils/logger.dart';
import 'package:pally/shared/models/avatar.dart';

part 'library_view_model.g.dart';

@riverpod
class LibraryViewModel extends _$LibraryViewModel {
  @override
  Future<List<Avatar>> build() async {
    return _fetchAvatars();
  }

  Future<List<Avatar>> _fetchAvatars() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get<Map<String, dynamic>>('/api/v1/avatars');
      final list = (response.data?['avatars'] as List<dynamic>?) ?? [];
      return list
          .map((e) => Avatar.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e, st) {
      // Never fabricate Pencil/Science Mochi tutors on a network blip —
      // the user would see "tutors" they never made. Surface the error
      // through AsyncError so the screen can render its empty / retry UI.
      appLog.w('[Library] fetchAvatars failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchAvatars);
  }
}
