import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/utils/logger.dart';
import 'package:pally/features/home/presentation/home_view_model.dart';
import 'package:pally/shared/models/avatar.dart';
import 'package:pally/shared/models/learning_module.dart';

part 'module_list_view_model.g.dart';

/// Outcome of a module-generation attempt, so the UI can route deterministically
/// instead of dead-ending on a generic snackbar.
enum ModuleGenResult { success, noNotes, error }

/// Avatar facts the module empty state needs to pick exactly one honest CTA:
/// whether it has compiled notes, and whether it's a centre class (students
/// can't upload to those — the centre owns the content).
class ModuleAvatarInfo {
  const ModuleAvatarInfo({required this.hasNotes, required this.isCentreClass});
  final bool hasNotes;
  final bool isCentreClass;
}

/// Reads avatar info (notes presence + centre/personal kind) reactively from
/// the home cache so the module-list empty state renders correctly and updates
/// when the home list refreshes. Returns null while loading or on error so the
/// empty state never flashes an incorrect centre/personal guess.
@riverpod
ModuleAvatarInfo? moduleAvatarInfo(Ref ref, String avatarId) {
  // watch (not read) so this updates reactively when home provider refreshes.
  final homeState = ref.watch(homeViewModelProvider);

  // While loading or errored, return null — the empty state's null guard waits
  // rather than guessing, preventing the "Upload" button flashing to a centre
  // student.
  if (!homeState.hasValue) return null;

  final avatar =
      homeState.valueOrNull?.where((a) => a.id == avatarId).firstOrNull;
  if (avatar == null) return null;
  return ModuleAvatarInfo(
    hasNotes: avatar.hasKnowledge,
    isCentreClass: avatar.isCentreClass,
  );
}

@riverpod
class ModuleListViewModel extends _$ModuleListViewModel {
  late String _avatarId;

  @override
  Future<List<LearningModule>> build(String avatarId) async {
    _avatarId = avatarId;
    return _fetchModules();
  }

  Future<List<LearningModule>> _fetchModules() async {
    appLog.d('[Modules] Fetching modules for avatar $_avatarId');
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get<dynamic>(
        '/api/v1/avatars/$_avatarId/modules',
      );
      final data = response.data;
      final List<dynamic> list = data is List
          ? data
          : (data is Map && data['modules'] is List
              ? data['modules'] as List<dynamic>
              : const <dynamic>[]);
      int parseFailures = 0;
      final modules = <LearningModule>[];
      for (final e in list) {
        try {
          modules.add(
            LearningModule.fromJson(Map<String, dynamic>.from(e as Map)),
          );
        } catch (err, st) {
          parseFailures++;
          appLog.e('[Modules] Failed to parse module (raw=$e)',
              error: err, stackTrace: st);
        }
      }
      if (parseFailures > 0) {
        appLog.w('[Modules] $parseFailures module(s) failed to parse');
      }
      appLog.i('[Modules] Loaded ${modules.length} modules');
      return modules;
    } on DioException catch (e, st) {
      if (e.response?.statusCode == 404) {
        appLog.d('[Modules] No modules found (404)');
        return const [];
      }
      appLog.e('[Modules] fetchModules failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchModules);
  }

  Future<ModuleGenResult> generateModules() async {
    appLog.i('[Modules] Requesting module generation for $_avatarId');
    try {
      final dio = ref.read(dioProvider);
      await dio.post<dynamic>(
        '/api/v1/avatars/$_avatarId/modules/generate',
      );
      appLog.i('[Modules] Generation triggered, refreshing list');
      await refresh();
      return ModuleGenResult.success;
    } on DioException catch (e, st) {
      // Backend signals "no notes to build from" with a structured 409 (NO_NOTES)
      // so we can route the user to upload instead of stranding them.
      final body = e.response?.data;
      final isNoNotes = e.response?.statusCode == 409 ||
          (body is Map && body['error']?.toString().contains('NO_NOTES') == true);
      if (isNoNotes) {
        appLog.i('[Modules] No notes yet — routing user to upload');
        return ModuleGenResult.noNotes;
      }
      appLog.e('[Modules] Module generation failed',
          error: e, stackTrace: st);
      return ModuleGenResult.error;
    }
  }
}
