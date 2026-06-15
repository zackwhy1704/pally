import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/utils/logger.dart';

part 'parent_home_view_model.g.dart';

@immutable
class ParentChildSummary {
  const ParentChildSummary({
    this.childId = '',
    this.name = '',
    this.subject = '',
    this.level = 1,
    this.streakDays = 0,
    this.minutesThisWeek = 0,
    this.modulesCompleted = 0,
    this.statusChip = 'on_track',
    this.lastActiveDate = '',
  });

  final String childId;
  final String name;
  final String subject;
  final int level;
  final int streakDays;
  final int minutesThisWeek;
  final int modulesCompleted;

  /// "on_track", "behind", or "needs_attention"
  final String statusChip;
  final String lastActiveDate;
}

@immutable
class ParentHomeState {
  const ParentHomeState({
    this.parentName,
    this.children = const [],
    this.isLoading = false,
    this.error,
  });

  final String? parentName;
  final List<ParentChildSummary> children;
  final bool isLoading;
  final String? error;

  ParentHomeState copyWith({
    String? parentName,
    List<ParentChildSummary>? children,
    bool? isLoading,
    Object? error = _sentinel,
  }) {
    return ParentHomeState(
      parentName: parentName ?? this.parentName,
      children: children ?? this.children,
      isLoading: isLoading ?? this.isLoading,
      error: error == _sentinel ? this.error : error as String?,
    );
  }
}

const _sentinel = Object();

@riverpod
class ParentHomeViewModel extends _$ParentHomeViewModel {
  @override
  ParentHomeState build() {
    Future.microtask(_load);
    return const ParentHomeState(isLoading: true);
  }

  Future<void> _load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final dio = ref.read(dioProvider);
      final res = await dio.get<Map<String, dynamic>>(
        '/api/v1/family/children',
      );
      final data = res.data ?? {};
      final parentName = data['parentName'] as String?;
      final rawChildren = (data['children'] as List?) ?? [];
      final children = rawChildren
          .whereType<Map<String, dynamic>>()
          .map(_parseChild)
          .toList();
      state = state.copyWith(
        parentName: parentName,
        children: children,
        isLoading: false,
      );
      appLog.i(
          '[ParentHome] Loaded ${children.length} children for parent');
    } on DioException catch (e, st) {
      appLog.e('[ParentHome] Failed to load children statusCode=${e.response?.statusCode}',
          error: e, stackTrace: st);
      state = state.copyWith(
        isLoading: false,
        error: 'Could not load children. Check your connection.',
      );
    } catch (e, st) {
      appLog.e('[ParentHome] Unexpected error loading children',
          error: e, stackTrace: st);
      state = state.copyWith(
        isLoading: false,
        error: 'Something went wrong. Please try again.',
      );
    }
  }

  ParentChildSummary _parseChild(Map<String, dynamic> c) {
    return ParentChildSummary(
      childId: (c['childId'] as String?) ?? '',
      name: (c['childName'] as String?) ??
          (c['displayName'] as String?) ??
          'Child',
      subject: (c['subject'] as String?) ?? '',
      level: (c['level'] as num?)?.toInt() ?? 1,
      streakDays: (c['streakDays'] as num?)?.toInt() ?? 0,
      minutesThisWeek: (c['minutesThisWeek'] as num?)?.toInt() ?? 0,
      modulesCompleted: (c['modulesCompleted'] as num?)?.toInt() ?? 0,
      statusChip: (c['statusChip'] as String?) ?? 'on_track',
      lastActiveDate: (c['lastActiveDate'] as String?) ?? '',
    );
  }

  Future<void> refresh() async {
    await _load();
  }
}
