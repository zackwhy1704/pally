import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/utils/logger.dart';

part 'child_dashboard_view_model.g.dart';

@immutable
class ChildDashboard {
  const ChildDashboard({
    required this.childName,
    required this.sessionsThisWeek,
    required this.minutesThisWeek,
    required this.xpThisWeek,
    required this.streakDays,
    required this.subjects,
    required this.weakAreas,
    required this.modulesCompleted,
    required this.modulesTotal,
  });

  final String childName;
  final int sessionsThisWeek;
  final int minutesThisWeek;
  final int xpThisWeek;
  final int streakDays;
  final List<Map<String, dynamic>> subjects;
  final List<Map<String, dynamic>> weakAreas;
  final int modulesCompleted;
  final int modulesTotal;

  static ChildDashboard fromJson(Map<String, dynamic> json) => ChildDashboard(
        childName: (json['childName'] as String?) ?? 'Child',
        sessionsThisWeek: (json['sessionsThisWeek'] as num?)?.toInt() ?? 0,
        minutesThisWeek: (json['minutesThisWeek'] as num?)?.toInt() ?? 0,
        xpThisWeek: (json['xpThisWeek'] as num?)?.toInt() ?? 0,
        streakDays: (json['streakDays'] as num?)?.toInt() ?? 0,
        subjects: ((json['subjects'] as List?) ?? const [])
            .whereType<Map<String, dynamic>>()
            .toList(),
        weakAreas: ((json['weakAreas'] as List?) ?? const [])
            .whereType<Map<String, dynamic>>()
            .toList(),
        modulesCompleted: (json['modulesCompleted'] as num?)?.toInt() ?? 0,
        modulesTotal: (json['modulesTotal'] as num?)?.toInt() ?? 0,
      );
}

@riverpod
Future<ChildDashboard> childDashboard(Ref ref, String childId) async {
  final dio = ref.read(dioProvider);
  try {
    final res = await dio.get<dynamic>(
      '/api/v1/parent/children/$childId/dashboard',
    );
    final data = res.data;
    final map = data is Map<String, dynamic>
        ? data
        : <String, dynamic>{};
    return ChildDashboard.fromJson(map);
  } catch (e, st) {
    appLog.e('[ChildDashboard] failed to load for $childId',
        error: e, stackTrace: st);
    rethrow;
  }
}
