import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/shared/models/avatar.dart';
import 'package:pally/shared/models/mochi_character.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/utils/logger.dart';

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
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown) {
        appLog.w('[Home] Backend unreachable, using stub avatars', error: e, stackTrace: st);
        return _stubAvatars;
      }
      appLog.e('[Home] fetchAvatars failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchAvatars);
  }

  Future<void> deleteAvatar(String avatarId) async {
    final dio = ref.read(dioProvider);
    await dio.delete('/api/v1/avatars/$avatarId');
    await refresh();
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

// Stub data for offline / pre-backend development
const _stubAvatars = [
  Avatar(
    id: 'stub-1',
    name: 'Pencil Mochi',
    character: MochiCharacter.pencil,
    subject: 'English',
    hasKnowledge: true,
    fileCount: 3,
  ),
  Avatar(
    id: 'stub-2',
    name: 'Science Mochi',
    character: MochiCharacter.science,
    subject: 'Science',
    hasKnowledge: false,
    fileCount: 0,
  ),
  Avatar(
    id: 'stub-3',
    name: 'Art Mochi',
    character: MochiCharacter.art,
    subject: 'Art',
    hasKnowledge: true,
    fileCount: 5,
  ),
];
