import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/utils/logger.dart';

part 'parent_view_model.g.dart';

@immutable
class SubjectStat {
  const SubjectStat({required this.subject, required this.mastery});
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
class ParentStats {
  const ParentStats({
    this.sessionsThisWeek = 0,
    this.minutesThisWeek = 0,
    this.xpThisWeek = 0,
    this.level = 1,
    this.streakDays = 0,
    this.subjects = const [],
    this.weekMinutes = const [],
    this.weakAreas = const [],
    this.screenTimeLimitEnabled = false,
    this.screenTimeLimitMinutes = 60,
    this.reviewTopics = const [],
  });

  final int sessionsThisWeek;
  final int minutesThisWeek;
  final int xpThisWeek;
  final int level;
  final int streakDays;
  final List<SubjectStat> subjects;
  final List<int> weekMinutes;
  final List<WeakArea> weakAreas;
  final bool screenTimeLimitEnabled;
  final int screenTimeLimitMinutes;
  // R8 — page titles the quiz feedback loop flagged for review, aggregated
  // across the user's avatars. Surfaced on the parent dashboard.
  final List<String> reviewTopics;

  ParentStats copyWith({
    int? sessionsThisWeek,
    int? minutesThisWeek,
    int? xpThisWeek,
    int? level,
    int? streakDays,
    List<SubjectStat>? subjects,
    List<int>? weekMinutes,
    List<WeakArea>? weakAreas,
    bool? screenTimeLimitEnabled,
    int? screenTimeLimitMinutes,
    List<String>? reviewTopics,
  }) {
    return ParentStats(
      sessionsThisWeek: sessionsThisWeek ?? this.sessionsThisWeek,
      minutesThisWeek: minutesThisWeek ?? this.minutesThisWeek,
      xpThisWeek: xpThisWeek ?? this.xpThisWeek,
      level: level ?? this.level,
      streakDays: streakDays ?? this.streakDays,
      subjects: subjects ?? this.subjects,
      weekMinutes: weekMinutes ?? this.weekMinutes,
      weakAreas: weakAreas ?? this.weakAreas,
      screenTimeLimitEnabled:
          screenTimeLimitEnabled ?? this.screenTimeLimitEnabled,
      screenTimeLimitMinutes:
          screenTimeLimitMinutes ?? this.screenTimeLimitMinutes,
      reviewTopics: reviewTopics ?? this.reviewTopics,
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
    this.firstTimeSetup = false,
    this.hasExistingPin,
  });

  final bool isPinVerified;
  final String? pinError;
  final ParentStats? stats;
  final bool isLoading;
  final bool firstTimeSetup;
  // null = unknown (still checking), false = first-time setup, true = returning user
  final bool? hasExistingPin;

  ParentState copyWith({
    bool? isPinVerified,
    Object? pinError = _sentinel,
    ParentStats? stats,
    bool? isLoading,
    bool? firstTimeSetup,
    Object? hasExistingPin = _sentinel,
  }) {
    return ParentState(
      isPinVerified: isPinVerified ?? this.isPinVerified,
      pinError: pinError == _sentinel ? this.pinError : pinError as String?,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      firstTimeSetup: firstTimeSetup ?? this.firstTimeSetup,
      hasExistingPin: hasExistingPin == _sentinel
          ? this.hasExistingPin
          : hasExistingPin as bool?,
    );
  }
}

const _sentinel = Object();

@riverpod
class ParentViewModel extends _$ParentViewModel {
  @override
  ParentState build() {
    // Kick off a PIN status check so the gate can show the correct copy
    // ("Create a Parent PIN" vs "Enter your Parent PIN"). Non-blocking.
    Future.microtask(_loadPinStatus);
    return const ParentState();
  }

  Future<void> _loadPinStatus() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get<Map<String, dynamic>>(
        '/api/v1/parent/pin/status',
      );
      final data = (response.data?['data'] is Map
              ? response.data!['data']
              : response.data) as Map<String, dynamic>;
      state = state.copyWith(hasExistingPin: data['hasPin'] == true);
    } catch (e) {
      appLog.w('[Parent] pin/status failed: $e');
      // Leave hasExistingPin null so the UI shows a neutral message
    }
  }

  /// Verifies the PIN against the backend. On first ever use (no PIN
  /// stored), the backend stores whatever the user enters as the new PIN
  /// and reports firstTimeSetup=true.
  Future<void> verifyPin(String pin) async {
    state = state.copyWith(isLoading: true, pinError: null);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post<Map<String, dynamic>>(
        '/api/v1/parent/pin/verify',
        data: {'pin': pin},
      );
      final data = (response.data?['data'] is Map
              ? response.data!['data']
              : response.data) as Map<String, dynamic>;
      final verified = data['verified'] == true;
      final firstTime = data['firstTimeSetup'] == true;

      if (verified) {
        state = state.copyWith(
          isPinVerified: true,
          firstTimeSetup: firstTime,
          // After a successful set, future verifications must match an
          // existing PIN — flip the flag so the gate copy is correct on
          // re-entry.
          hasExistingPin: true,
          isLoading: false,
        );
        await _loadStats();
      } else {
        // Surface lockout messaging from the backend throttle so the user
        // knows to wait instead of mashing keys harder.
        final locked = data['lockedOut'] == true;
        final retryAfter = (data['retryAfterSeconds'] as num?)?.toInt() ?? 0;
        final attemptsLeft = (data['attemptsRemaining'] as num?)?.toInt();
        final msg = locked
            ? 'Too many wrong PINs. Try again in $retryAfter seconds.'
            : attemptsLeft != null && attemptsLeft <= 2
                ? 'Incorrect PIN. $attemptsLeft attempt'
                    '${attemptsLeft == 1 ? '' : 's'} left.'
                : 'Incorrect PIN. Try again.';
        state = state.copyWith(
          pinError: msg,
          isLoading: false,
        );
      }
    } on DioException catch (e, st) {
      appLog.w('[Parent] PIN verify failed', error: e, stackTrace: st);
      state = state.copyWith(
        pinError: 'Could not verify PIN. Check your connection.',
        isLoading: false,
      );
    }
  }

  Future<void> _loadStats() async {
    state = state.copyWith(isLoading: true);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get<Map<String, dynamic>>(
        '/api/v1/parent/dashboard',
      );
      final data = (response.data?['data'] is Map
              ? response.data!['data']
              : response.data) as Map<String, dynamic>;

      final subjects = ((data['subjects'] as List?) ?? [])
          .whereType<Map<String, dynamic>>()
          .map((s) => SubjectStat(
                subject: (s['subject'] as String?) ?? '',
                mastery: ((s['mastery'] as num?) ?? 0).toDouble(),
              ))
          .toList();
      final weekMinutes = ((data['weekMinutes'] as List?) ?? [])
          .map((e) => (e as num).toInt())
          .toList();
      final weakAreas = ((data['weakAreas'] as List?) ?? [])
          .whereType<Map<String, dynamic>>()
          .map((w) => WeakArea(
                topic: (w['topic'] as String?) ?? '',
                mastery: ((w['mastery'] as num?) ?? 0).toDouble(),
              ))
          .toList();

      final reviewTopics = ((data['reviewTopics'] as List?) ?? const [])
          .whereType<String>()
          .toList();

      state = state.copyWith(
        stats: ParentStats(
          sessionsThisWeek: (data['sessionsThisWeek'] as num?)?.toInt() ?? 0,
          minutesThisWeek: (data['minutesThisWeek'] as num?)?.toInt() ?? 0,
          xpThisWeek: (data['xpThisWeek'] as num?)?.toInt() ?? 0,
          level: (data['level'] as num?)?.toInt() ?? 1,
          streakDays: (data['streakDays'] as num?)?.toInt() ?? 0,
          subjects: subjects,
          weekMinutes: weekMinutes,
          weakAreas: weakAreas,
          screenTimeLimitEnabled: data['screenTimeEnabled'] == true,
          screenTimeLimitMinutes:
              (data['screenTimeMinutes'] as num?)?.toInt() ?? 60,
          reviewTopics: reviewTopics,
        ),
        isLoading: false,
      );
    } on DioException catch (e, st) {
      appLog.w('[Parent] dashboard load failed', error: e, stackTrace: st);
      // Empty stats, not stub data, so the user sees real (zero) state.
      state = state.copyWith(
        stats: const ParentStats(),
        isLoading: false,
      );
    }
  }

  Future<void> toggleScreenTimeLimit(bool enabled) async {
    final next = state.stats?.copyWith(screenTimeLimitEnabled: enabled);
    if (next != null) state = state.copyWith(stats: next);
    try {
      final dio = ref.read(dioProvider);
      await dio.post<void>(
        '/api/v1/parent/screen-time',
        data: {
          'enabled': enabled,
          'minutes': state.stats?.screenTimeLimitMinutes ?? 60,
        },
      );
    } catch (e) {
      appLog.w('[Parent] screen-time persist failed: $e');
    }
  }

  /// Resets PIN. Requires the account password — prevents children from
  /// changing the gate.
  Future<bool> changePin({
    required String password,
    required String newPin,
  }) async {
    try {
      final dio = ref.read(dioProvider);
      await dio.post<void>(
        '/api/v1/parent/pin/reset',
        data: {'password': password, 'newPin': newPin},
      );
      return true;
    } on DioException catch (e) {
      appLog.w('[Parent] PIN reset failed: ${e.response?.statusCode}');
      return false;
    }
  }

  void lock() {
    state = const ParentState();
  }
}
