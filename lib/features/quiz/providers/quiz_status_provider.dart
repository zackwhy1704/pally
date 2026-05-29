import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/utils/logger.dart';

@immutable
class QuizStatus {
  const QuizStatus({
    required this.takenToday,
    required this.totalTopics,
    required this.masteredTopics,
  });
  final bool takenToday;
  final int totalTopics;
  final int masteredTopics;

  double get coverage =>
      totalTopics > 0 ? (masteredTopics / totalTopics).clamp(0.0, 1.0) : 0.0;
}

/// Per-avatar daily-quiz journey state. Used by:
///  • Progress / Home to show "Today's quiz ✓" + a syllabus coverage ring.
///  • Quiz screen to avoid relaunching the same quiz a second time
///    (use-case still allows it for free play, but the UI hint matters).
final quizStatusProvider = FutureProvider.autoDispose
    .family<QuizStatus, String>((ref, avatarId) async {
  try {
    final dio = ref.read(dioProvider);
    final response =
        await dio.get<dynamic>('/api/v1/avatars/$avatarId/quiz/status');
    final data = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : const <String, dynamic>{};
    return QuizStatus(
      takenToday: data['takenToday'] == true,
      totalTopics: (data['totalTopics'] as num?)?.toInt() ?? 0,
      masteredTopics: (data['masteredTopics'] as num?)?.toInt() ?? 0,
    );
  } on DioException catch (e) {
    appLog.w('[QuizStatus] fetch failed avatar=$avatarId: ${e.message}');
    // Neutral state so the tile renders "available" rather than vanishing.
    return const QuizStatus(
        takenToday: false, totalTopics: 0, masteredTopics: 0);
  }
});
