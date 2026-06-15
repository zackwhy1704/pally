import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/error/pally_error.dart';
import 'package:pally/core/observability/observability.dart';
import 'package:pally/core/observability/observability_providers.dart';
import 'package:pally/core/utils/logger.dart';
import 'package:pally/shared/models/assignment.dart';

part 'assignment_view_model.g.dart';

@riverpod
class AssignmentViewModel extends _$AssignmentViewModel {
  late String _avatarId;

  @override
  Future<List<Assignment>> build(String avatarId) async {
    _avatarId = avatarId;
    return _fetchAssignments();
  }

  Future<List<Assignment>> _fetchAssignments() async {
    appLog.d('[Assignments] Fetching assignments for avatar $_avatarId');
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get<dynamic>(
        '/api/v1/avatars/$_avatarId/assignments',
      );
      final data = response.data;
      final List<dynamic> list = data is List
          ? data
          : (data is Map && data['assignments'] is List
              ? data['assignments'] as List<dynamic>
              : const <dynamic>[]);
      int parseFailures = 0;
      final assignments = <Assignment>[];
      for (final e in list) {
        try {
          assignments.add(
            Assignment.fromJson(Map<String, dynamic>.from(e as Map)),
          );
        } catch (err, st) {
          parseFailures++;
          appLog.e('[Assignments] Failed to parse assignment (raw=$e)',
              error: err, stackTrace: st);
        }
      }
      if (parseFailures > 0) {
        appLog.w('[Assignments] $parseFailures assignment(s) failed to parse');
      }
      appLog.i('[Assignments] Loaded ${assignments.length} assignments');
      return assignments;
    } on DioException catch (e, st) {
      if (e.response?.statusCode == 404) {
        appLog.d('[Assignments] No assignments found (404)');
        return const [];
      }
      appLog.e('[Assignments] fetchAssignments failed statusCode=${e.response?.statusCode}',
          error: e, stackTrace: st);
      throw PallyError.from(e);
    } catch (e, st) {
      appLog.e('[Assignments] unexpected error fetching assignments',
          error: e, stackTrace: st);
      throw PallyError.unknown;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchAssignments);
  }

  Future<bool> startAssignment(String assignmentId) async {
    appLog.i(
        '[Assignments] Starting assignment $assignmentId for $_avatarId');
    try {
      final dio = ref.read(dioProvider);
      await dio.post<dynamic>(
        '/api/v1/avatars/$_avatarId/assignments/$assignmentId/start',
      );
      appLog.i('[Assignments] Assignment started, refreshing');
      ref.read(analyticsProvider).event(
        AnalyticsEvents.assignmentStarted,
        props: {
          'assignment_id': assignmentId,
          'avatar_id': _avatarId,
        },
      );
      await refresh();
      return true;
    } on DioException catch (e, st) {
      appLog.e('[Assignments] Start assignment failed',
          error: e, stackTrace: st);
      return false;
    }
  }
}
