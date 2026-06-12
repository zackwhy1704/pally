import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/utils/logger.dart';

part 'reading_time_reporter.g.dart';

/// Reports active reading/lesson time to the backend's study-minutes metric.
///
/// POSTs `/api/v1/progress/reading` `{avatarId, durationSeconds}` on demand —
/// callers (e.g. the wiki viewer) measure active time-on-screen, clamp it, and
/// fire-and-forget on screen exit. Both sides clamp: the client caps at 1h and
/// drops sub-[minReportSeconds] sessions (noise / accidental opens); the backend
/// clamps again so a forged client can't inflate minutes.
class ReadingTimeReporter {
  ReadingTimeReporter(this._dio);

  final Dio _dio;

  /// Don't bother the server with trivially short opens.
  static const int minReportSeconds = 5;

  /// Client-side upper bound; backend clamps independently.
  static const int maxReportSeconds = 3600;

  Future<void> report({
    required String avatarId,
    required int durationSeconds,
  }) async {
    final clamped = durationSeconds.clamp(0, maxReportSeconds);
    if (clamped < minReportSeconds) return;
    try {
      await _dio.post<dynamic>(
        '/api/v1/progress/reading',
        data: {'avatarId': avatarId, 'durationSeconds': clamped},
      );
      appLog.d('[Reading] reported ${clamped}s for avatar $avatarId');
    } on DioException catch (e) {
      // Best-effort metric — never surface to the user or block navigation.
      appLog.w('[Reading] report failed: ${e.message}');
    } catch (e) {
      appLog.w('[Reading] report failed: $e');
    }
  }
}

@riverpod
ReadingTimeReporter readingTimeReporter(Ref ref) {
  return ReadingTimeReporter(ref.read(dioProvider));
}
