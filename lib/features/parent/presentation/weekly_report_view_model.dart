import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/utils/logger.dart';

part 'weekly_report_view_model.g.dart';

@immutable
class WeeklyReportSummary {
  const WeeklyReportSummary({
    required this.weekId,
    required this.startDate,
    required this.endDate,
    required this.sessions,
    required this.minutes,
    required this.xpEarned,
  });

  final String weekId;
  final DateTime startDate;
  final DateTime endDate;
  final int sessions;
  final int minutes;
  final int xpEarned;

  static WeeklyReportSummary fromJson(Map<String, dynamic> json) =>
      WeeklyReportSummary(
        weekId: json['weekId'] as String,
        startDate: DateTime.parse(json['startDate'] as String),
        endDate: DateTime.parse(json['endDate'] as String),
        sessions: (json['sessions'] as num?)?.toInt() ?? 0,
        minutes: (json['minutes'] as num?)?.toInt() ?? 0,
        xpEarned: (json['xpEarned'] as num?)?.toInt() ?? 0,
      );
}

@immutable
class SubjectMastery {
  const SubjectMastery({required this.subject, required this.mastery});
  final String subject;
  final double mastery;
}

@immutable
class WeakArea {
  const WeakArea({required this.topic, required this.mastery});
  final String topic;
  final double mastery;
}

@immutable
class WeeklyReportDetail {
  const WeeklyReportDetail({
    required this.weekId,
    required this.startDate,
    required this.endDate,
    required this.sessions,
    required this.minutes,
    required this.xpEarned,
    required this.dailyMinutes,
    required this.subjects,
    required this.weakAreas,
    required this.headline,
    required this.narrative,
  });

  final String weekId;
  final DateTime startDate;
  final DateTime endDate;
  final int sessions;
  final int minutes;
  final int xpEarned;
  final List<int> dailyMinutes;
  final List<SubjectMastery> subjects;
  final List<WeakArea> weakAreas;
  final String headline;
  final String narrative;

  static WeeklyReportDetail fromJson(Map<String, dynamic> json) =>
      WeeklyReportDetail(
        weekId: json['weekId'] as String,
        startDate: DateTime.parse(json['startDate'] as String),
        endDate: DateTime.parse(json['endDate'] as String),
        sessions: (json['sessions'] as num?)?.toInt() ?? 0,
        minutes: (json['minutes'] as num?)?.toInt() ?? 0,
        xpEarned: (json['xpEarned'] as num?)?.toInt() ?? 0,
        dailyMinutes: ((json['dailyMinutes'] as List?) ?? const [])
            .map((e) => (e as num).toInt())
            .toList(),
        subjects: ((json['subjects'] as List?) ?? const [])
            .whereType<Map<String, dynamic>>()
            .map((s) => SubjectMastery(
                  subject: (s['subject'] as String?) ?? '',
                  mastery: ((s['mastery'] as num?) ?? 0).toDouble(),
                ))
            .toList(),
        weakAreas: ((json['weakAreas'] as List?) ?? const [])
            .whereType<Map<String, dynamic>>()
            .map((w) => WeakArea(
                  topic: (w['topic'] as String?) ?? '',
                  mastery: ((w['mastery'] as num?) ?? 0).toDouble(),
                ))
            .toList(),
        headline: (json['headline'] as String?) ?? '',
        narrative: (json['narrative'] as String?) ?? '',
      );
}

@riverpod
class WeeklyReportListViewModel extends _$WeeklyReportListViewModel {
  @override
  Future<List<WeeklyReportSummary>> build() async => _fetch();

  Future<List<WeeklyReportSummary>> _fetch() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio
          .get<Map<String, dynamic>>('/api/v1/parent/reports');
      final data = (response.data?['data'] is Map
              ? response.data!['data']
              : response.data) as Map<String, dynamic>;
      final list = (data['reports'] as List?) ?? const [];
      return list
          .whereType<Map<String, dynamic>>()
          .map(WeeklyReportSummary.fromJson)
          .toList();
    } on DioException catch (e, st) {
      appLog.w('[Parent] /reports failed', error: e, stackTrace: st);
      final isNetwork = e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown;
      // Propagate so the screen renders a retry UI instead of an
      // empty-looking list that's actually broken.
      throw Exception(
          isNetwork ? 'No internet connection' : 'Could not load reports');
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}

@riverpod
class WeeklyReportDetailViewModel extends _$WeeklyReportDetailViewModel {
  @override
  Future<WeeklyReportDetail> build(String weekId) async {
    final dio = ref.read(dioProvider);
    final response = await dio.get<Map<String, dynamic>>(
      '/api/v1/parent/reports/$weekId',
    );
    final data = (response.data?['data'] is Map
            ? response.data!['data']
            : response.data) as Map<String, dynamic>;
    return WeeklyReportDetail.fromJson(data);
  }
}
