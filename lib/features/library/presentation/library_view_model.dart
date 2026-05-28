import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/shared/models/avatar.dart';
import 'package:pally/shared/models/mochi_character.dart';

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
    name: 'Pencil Mochi',
    character: MochiCharacter.pencil,
    subject: 'English',
    wikiPageCount: 3,
    fileCount: 3,
  ),
  Avatar(
    id: 'stub-2',
    name: 'Science Mochi',
    character: MochiCharacter.science,
    subject: 'Science',
    wikiPageCount: 0,
    fileCount: 0,
  ),
];
