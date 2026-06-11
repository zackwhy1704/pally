import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/utils/logger.dart';
import 'package:pally/shared/models/learning_module.dart';

part 'module_list_view_model.g.dart';

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

  Future<bool> generateModules() async {
    appLog.i('[Modules] Requesting module generation for $_avatarId');
    try {
      final dio = ref.read(dioProvider);
      await dio.post<dynamic>(
        '/api/v1/avatars/$_avatarId/modules/generate',
      );
      appLog.i('[Modules] Generation triggered, refreshing list');
      await refresh();
      return true;
    } on DioException catch (e, st) {
      appLog.e('[Modules] Module generation failed',
          error: e, stackTrace: st);
      return false;
    }
  }
}
