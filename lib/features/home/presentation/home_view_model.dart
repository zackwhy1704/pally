import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/shared/models/avatar.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/local_db/pally_database.dart';
import 'package:pally/core/utils/logger.dart';
import 'package:pally/features/chat/data/local/chat_local_data_source.dart';

part 'home_view_model.g.dart';

@riverpod
class HomeViewModel extends _$HomeViewModel {
  @override
  Future<List<Avatar>> build() async {
    return _fetchAvatars();
  }

  Future<List<Avatar>> _fetchAvatars() async {
    appLog.d('[Home] Fetching avatars');
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get<Map<String, dynamic>>('/api/v1/avatars');
      final list = (response.data?['avatars'] as List<dynamic>?) ?? [];
      final avatars = list
          .map((e) => Avatar.fromJson(e as Map<String, dynamic>))
          .toList();
      appLog.i('[Home] Loaded ${avatars.length} avatars');
      return avatars;
    } on DioException catch (e, st) {
      // Never fabricate Pencil/Science/Art Mochi tutors on a network blip —
      // users would see avatars they never created. Surface the failure
      // through AsyncError so the screen can render its empty / retry UI.
      appLog.w('[Home] fetchAvatars failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchAvatars);
  }

  Future<bool> deleteAvatar(String avatarId) async {
    try {
      final dio = ref.read(dioProvider);
      await dio.delete('/api/v1/avatars/$avatarId');
      appLog.i('[Home] Avatar deleted: $avatarId');

      // Local-DB cleanup (best-effort — backend already cascades)
      try {
        final localDb = ChatLocalDataSource(ref.read(pallyDatabaseProvider));
        await localDb.deleteAllForAvatar(avatarId);
      } catch (e) {
        appLog.w('[Home] Local chat cleanup failed: $e');
      }

      await refresh();
      return true;
    } on DioException catch (e, st) {
      appLog.e('[Home] Delete avatar failed', error: e, stackTrace: st);
      return false;
    }
  }

  // Computed getters used by UI — no logic in build()
  List<Avatar> filteredAvatars(List<Avatar> avatars, String query) {
    if (query.isEmpty) return avatars;
    final q = query.toLowerCase();
    return avatars
        .where((a) =>
            a.name.toLowerCase().contains(q) ||
            a.subject.toLowerCase().contains(q))
        .toList();
  }
}

