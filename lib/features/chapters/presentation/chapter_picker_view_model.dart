import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:pally/app/api_client.dart';
import 'package:pally/features/chapters/domain/chapter.dart';

part 'chapter_picker_view_model.g.dart';

/// Loads an avatar's chapter chunks + the compile allowance, and picks chapters to
/// compile. Screens render this state; they never call the API themselves.
@riverpod
class ChapterPickerViewModel extends _$ChapterPickerViewModel {
  late String _avatarId;
  bool _compiling = false;

  /// Whether a compile request is in flight (drives the CTA's loading state).
  bool get isCompiling => _compiling;

  @override
  Future<ChaptersResult> build(String avatarId) async {
    _avatarId = avatarId;
    return _fetch();
  }

  Future<ChaptersResult> _fetch() async {
    final dio = ref.read(dioProvider);
    // The Dio interceptor unwraps ApiResponse<T>, so data is the ChaptersResult map.
    final resp =
        await dio.get<Map<String, dynamic>>('/api/v1/avatars/$_avatarId/chapters');
    return ChaptersResult.fromJson(resp.data ?? const {});
  }

  /// Compile the given chunks, sequentially (the backend serialises per-avatar, and
  /// a 402 must stop the run at the first over-limit pick rather than firing N
  /// doomed requests). Re-entry guarded. Error mapping stays centralised in the Dio
  /// interceptor — a 402 there routes to the gated paywall; any error propagates to
  /// the sheet, which shows an inline retry. This layer never inspects DioException.
  Future<void> compileSelected(List<String> chunkIds) async {
    if (_compiling || chunkIds.isEmpty) return;
    _compiling = true;
    final dio = ref.read(dioProvider);
    try {
      for (final id in chunkIds) {
        await dio.post<Map<String, dynamic>>(
          '/api/v1/avatars/$_avatarId/files/$id/compile',
          options: Options(
            receiveTimeout: const Duration(seconds: 30),
            sendTimeout: const Duration(seconds: 30),
          ),
        );
      }
    } finally {
      _compiling = false;
      // Refresh so the chunks that DID compile flip to COMPILING/COMPILED and the
      // counter updates (true even if the run stopped early at the allowance).
      ref.invalidateSelf();
    }
  }
}
