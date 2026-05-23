import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/app/api_client.dart';

part 'parent_view_model.g.dart';

@immutable
class SubjectStat {
  const SubjectStat({required this.subject, required this.mastery});
  final String subject;
  final double mastery;
}

@immutable
class ParentStats {
  const ParentStats({
    this.sessionsThisWeek = 0,
    this.minutesThisWeek = 0,
    this.xpThisWeek = 0,
    this.subjects = const [],
    this.screenTimeLimitEnabled = false,
    this.screenTimeLimitMinutes = 60,
  });

  final int sessionsThisWeek;
  final int minutesThisWeek;
  final int xpThisWeek;
  final List<SubjectStat> subjects;
  final bool screenTimeLimitEnabled;
  final int screenTimeLimitMinutes;

  ParentStats copyWith({
    int? sessionsThisWeek,
    int? minutesThisWeek,
    int? xpThisWeek,
    List<SubjectStat>? subjects,
    bool? screenTimeLimitEnabled,
    int? screenTimeLimitMinutes,
  }) {
    return ParentStats(
      sessionsThisWeek: sessionsThisWeek ?? this.sessionsThisWeek,
      minutesThisWeek: minutesThisWeek ?? this.minutesThisWeek,
      xpThisWeek: xpThisWeek ?? this.xpThisWeek,
      subjects: subjects ?? this.subjects,
      screenTimeLimitEnabled:
          screenTimeLimitEnabled ?? this.screenTimeLimitEnabled,
      screenTimeLimitMinutes:
          screenTimeLimitMinutes ?? this.screenTimeLimitMinutes,
    );
  }
}

@immutable
class ParentState {
  const ParentState({
    this.isPinVerified = false,
    this.pinError,
    this.stats,
    this.isLoading = false,
  });

  final bool isPinVerified;
  final String? pinError;
  final ParentStats? stats;
  final bool isLoading;

  ParentState copyWith({
    bool? isPinVerified,
    Object? pinError = _sentinel,
    ParentStats? stats,
    bool? isLoading,
  }) {
    return ParentState(
      isPinVerified: isPinVerified ?? this.isPinVerified,
      pinError: pinError == _sentinel ? this.pinError : pinError as String?,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

const _sentinel = Object();

// MVP: hardcoded PIN "1234"
const _correctPin = '1234';

@riverpod
class ParentViewModel extends _$ParentViewModel {
  @override
  ParentState build() {
    return const ParentState();
  }

  void verifyPin(String pin) {
    if (pin == _correctPin) {
      state = state.copyWith(isPinVerified: true, pinError: null);
      _loadStats();
    } else {
      state = state.copyWith(pinError: 'Incorrect PIN. Try again.');
    }
  }

  Future<void> _loadStats() async {
    state = state.copyWith(isLoading: true);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get<Map<String, dynamic>>('/api/v1/progress');
      final data = response.data ?? {};
      state = state.copyWith(
        stats: ParentStats(
          sessionsThisWeek: (data['sessionsThisWeek'] as int?) ?? 0,
          minutesThisWeek: (data['minutesThisWeek'] as int?) ?? 0,
          xpThisWeek: (data['xpThisWeek'] as int?) ?? 0,
          subjects: _stubStats.subjects,
        ),
        isLoading: false,
      );
    } on DioException catch (_) {
      state = state.copyWith(stats: _stubStats, isLoading: false);
    }
  }

  void toggleScreenTimeLimit(bool enabled) {
    state = state.copyWith(
      stats: state.stats?.copyWith(screenTimeLimitEnabled: enabled),
    );
  }

  void lock() {
    state = const ParentState();
  }
}

const _stubStats = ParentStats(
  sessionsThisWeek: 12,
  minutesThisWeek: 87,
  xpThisWeek: 320,
  subjects: [
    SubjectStat(subject: 'Science', mastery: 0.72),
    SubjectStat(subject: 'Maths', mastery: 0.58),
    SubjectStat(subject: 'English', mastery: 0.84),
  ],
  screenTimeLimitEnabled: true,
  screenTimeLimitMinutes: 60,
);
