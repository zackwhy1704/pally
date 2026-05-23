import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/app/api_client.dart';
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
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown) {
        return _stubAvatars;
      }
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchAvatars);
  }
}

const _stubAvatars = [
  Avatar(
    id: 'stub-1',
    name: 'Zap',
    character: AvatarCharacter.zap,
    subject: 'Maths',
    hasKnowledge: true,
    fileCount: 3,
  ),
  Avatar(
    id: 'stub-2',
    name: 'Mochi',
    character: AvatarCharacter.mochi,
    subject: 'Science',
    hasKnowledge: false,
    fileCount: 0,
  ),
];
