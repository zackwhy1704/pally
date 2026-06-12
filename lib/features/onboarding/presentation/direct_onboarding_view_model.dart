import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/observability/observability.dart';
import 'package:pally/core/observability/observability_providers.dart';
import 'package:pally/core/utils/logger.dart';
import 'package:pally/features/auth/auth_state.dart';

part 'direct_onboarding_view_model.g.dart';

/// Subjects the backend recognises (sent as UPPER_CASE).
const directOnboardingSubjects = [
  'MATHS',
  'SCIENCE',
  'ENGLISH',
  'HISTORY',
  'CODING',
  'GEOGRAPHY',
  'LITERATURE',
  'ART',
  'MUSIC',
  'LANGUAGES',
  'GENERAL',
];

/// Display-friendly labels for subjects.
String subjectLabel(String subject) => switch (subject) {
      'MATHS' => 'Maths',
      'SCIENCE' => 'Science',
      'ENGLISH' => 'English',
      'HISTORY' => 'History',
      'CODING' => 'Coding',
      'GEOGRAPHY' => 'Geography',
      'LITERATURE' => 'Literature',
      'ART' => 'Art',
      'MUSIC' => 'Music',
      'LANGUAGES' => 'Languages',
      'GENERAL' => 'General',
      _ => subject,
    };

/// Singapore-specific level options.
const directOnboardingLevels = [
  'P3',
  'P4',
  'P5',
  'P6',
  'Sec 1',
  'Sec 2',
  'Sec 3',
  'Sec 4',
  'JC1',
  'JC2',
];

@immutable
class DirectOnboardingState {
  const DirectOnboardingState({
    this.step = 1,
    this.isLoading = false,
    this.error,
    this.avatarId,
    this.selectedSubject,
    this.selectedLevel,
    this.uploadStage = DirectUploadStage.idle,
    this.firstModuleId,
    this.firstModuleTitle,
  });

  final int step;
  final bool isLoading;
  final String? error;
  final String? avatarId;
  final String? selectedSubject;
  final String? selectedLevel;
  final DirectUploadStage uploadStage;
  final String? firstModuleId;
  final String? firstModuleTitle;

  DirectOnboardingState copyWith({
    int? step,
    bool? isLoading,
    Object? error = _sentinel,
    Object? avatarId = _sentinel,
    String? selectedSubject,
    String? selectedLevel,
    DirectUploadStage? uploadStage,
    Object? firstModuleId = _sentinel,
    Object? firstModuleTitle = _sentinel,
  }) {
    return DirectOnboardingState(
      step: step ?? this.step,
      isLoading: isLoading ?? this.isLoading,
      error: error == _sentinel ? this.error : error as String?,
      avatarId: avatarId == _sentinel ? this.avatarId : avatarId as String?,
      selectedSubject: selectedSubject ?? this.selectedSubject,
      selectedLevel: selectedLevel ?? this.selectedLevel,
      uploadStage: uploadStage ?? this.uploadStage,
      firstModuleId: firstModuleId == _sentinel
          ? this.firstModuleId
          : firstModuleId as String?,
      firstModuleTitle: firstModuleTitle == _sentinel
          ? this.firstModuleTitle
          : firstModuleTitle as String?,
    );
  }
}

const _sentinel = Object();

enum DirectUploadStage {
  idle,
  uploading,
  compiling,
  generatingModules,
  ready,
  failed,
}

@riverpod
class DirectOnboardingViewModel extends _$DirectOnboardingViewModel {
  Timer? _poller;

  @override
  DirectOnboardingState build() {
    ref.onDispose(() {
      _poller?.cancel();
      _poller = null;
    });
    return const DirectOnboardingState();
  }

  void goToStep(int step) {
    state = state.copyWith(step: step);
  }

  void setSubject(String subject) {
    state = state.copyWith(selectedSubject: subject);
  }

  void setLevel(String level) {
    state = state.copyWith(selectedLevel: level);
  }

  /// Step 1+2: Quick onboard — create account + avatar in one call.
  Future<void> quickOnboard({
    required String email,
    required String password,
    required String displayName,
    required String subject,
    required String level,
    int? birthYear,
  }) async {
    appLog.i('[DirectOnboard] Starting quick onboard for $email');
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Use the unauthenticated Dio since user isn't signed in yet.
      final dio = Dio(BaseOptions(
        baseUrl: const String.fromEnvironment(
          'API_BASE_URL',
          defaultValue: 'https://pallybackend-production.up.railway.app',
        ),
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ));

      final res = await dio.post<Map<String, dynamic>>(
        '/api/v1/onboard/quick',
        data: {
          'email': email,
          'password': password,
          'displayName': displayName,
          'subject': subject,
          'level': level,
          // Optional student birth year (year only); backend derives under-13.
          if (birthYear != null) 'birthYear': birthYear,
        },
      );

      final data = res.data ?? {};
      final inner =
          (data['data'] is Map ? data['data'] as Map<String, dynamic> : data);
      final token = inner['token'] as String? ?? '';
      final userId = inner['userId'] as String? ?? '';
      final avatarId = inner['avatarId'] as String? ?? '';

      // Sign in via AuthNotifier so Dio interceptor picks up the token.
      await AuthNotifier.instance.signIn(
        userId: userId,
        token: token,
        setupComplete: true,
        onboardingComplete: true,
      );

      appLog.i(
          '[DirectOnboard] Quick onboard success: userId=$userId avatarId=$avatarId');

      ref.read(analyticsProvider).identify(userId, props: {
        'email': email,
        'display_name': displayName,
        'subject': subject,
        'level': level,
      });
      ref.read(analyticsProvider).event(
        AnalyticsEvents.onboardingCompleted,
        props: {
          'avatar_id': avatarId,
          'subject': subject,
          'level': level,
        },
      );

      state = state.copyWith(
        isLoading: false,
        step: 3,
        avatarId: avatarId,
      );
    } on DioException catch (e, st) {
      appLog.e('[DirectOnboard] Quick onboard failed',
          error: e, stackTrace: st);
      final msg = _friendlyError(e);
      state = state.copyWith(isLoading: false, error: msg);
    } catch (e, st) {
      appLog.e('[DirectOnboard] Unexpected error', error: e, stackTrace: st);
      state = state.copyWith(
        isLoading: false,
        error: 'Something went wrong. Please try again.',
      );
    }
  }

  /// Step 3: Upload file, poll for compile, generate modules.
  Future<void> uploadFile(PlatformFile file) async {
    final avatarId = state.avatarId;
    if (avatarId == null || avatarId.isEmpty) {
      state = state.copyWith(error: 'Please complete sign-up first.');
      return;
    }

    if (file.path == null) {
      state = state.copyWith(error: 'Could not read the file. Try again.');
      return;
    }

    appLog.i(
        '[DirectOnboard] Uploading file: ${file.name} (${file.size}B) to avatar $avatarId');
    state = state.copyWith(
      uploadStage: DirectUploadStage.uploading,
      error: null,
    );

    try {
      final dio = ref.read(dioProvider);
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path!, filename: file.name),
      });
      await dio.post<dynamic>(
        '/api/v1/avatars/$avatarId/files',
        data: formData,
      );

      appLog.i('[DirectOnboard] Upload complete, polling for compile');
      state = state.copyWith(uploadStage: DirectUploadStage.compiling);

      // Poll until brain is READY.
      await _pollUntilCompiled(avatarId);
    } on DioException catch (e, st) {
      appLog.e('[DirectOnboard] Upload failed', error: e, stackTrace: st);
      state = state.copyWith(
        uploadStage: DirectUploadStage.failed,
        error: _friendlyError(e),
      );
    } catch (e, st) {
      appLog.e('[DirectOnboard] Unexpected upload error',
          error: e, stackTrace: st);
      state = state.copyWith(
        uploadStage: DirectUploadStage.failed,
        error: 'Upload failed. Please try again.',
      );
    }
  }

  Future<void> uploadFromCamera(String path) async {
    final file = File(path);
    final platformFile = PlatformFile(
      name: '${DateTime.now().millisecondsSinceEpoch}_scan.jpg',
      path: path,
      size: await file.length(),
    );
    await uploadFile(platformFile);
  }

  Future<void> _pollUntilCompiled(String avatarId) async {
    const pollInterval = Duration(seconds: 4);
    const timeout = Duration(minutes: 4);
    final start = DateTime.now();

    while (DateTime.now().difference(start) < timeout) {
      try {
        final dio = ref.read(dioProvider);
        final resp = await dio.get<dynamic>('/api/v1/avatars/$avatarId');
        final data = resp.data is Map ? resp.data as Map : {};
        final brainState = data['brainState']?.toString() ?? 'READY';

        if (brainState == 'READY') {
          appLog.i('[DirectOnboard] Brain compiled, generating modules');
          state = state.copyWith(
              uploadStage: DirectUploadStage.generatingModules);
          await _generateModules(avatarId);
          return;
        }
      } catch (e) {
        appLog.w('[DirectOnboard] Poll error (non-fatal): $e');
      }
      await Future<void>.delayed(pollInterval);
    }

    // Timed out but may still be compiling in background.
    appLog.w('[DirectOnboard] Compile poll timed out');
    state = state.copyWith(
      uploadStage: DirectUploadStage.generatingModules,
    );
    await _generateModules(avatarId);
  }

  Future<void> _generateModules(String avatarId) async {
    try {
      final dio = ref.read(dioProvider);
      await dio.post<dynamic>(
        '/api/v1/avatars/$avatarId/modules/generate',
      );
      appLog.i('[DirectOnboard] Module generation triggered');

      // Poll for the first module to appear.
      await _pollForFirstModule(avatarId);
    } on DioException catch (e, st) {
      appLog.e('[DirectOnboard] Module generation failed',
          error: e, stackTrace: st);
      // Even if generation fails, the user can still go to home.
      state = state.copyWith(uploadStage: DirectUploadStage.ready);
    }
  }

  Future<void> _pollForFirstModule(String avatarId) async {
    const pollInterval = Duration(seconds: 3);
    const timeout = Duration(minutes: 2);
    final start = DateTime.now();

    while (DateTime.now().difference(start) < timeout) {
      try {
        final dio = ref.read(dioProvider);
        final resp = await dio.get<dynamic>(
          '/api/v1/avatars/$avatarId/modules',
        );
        final data = resp.data;
        final List<dynamic> modules =
            data is List ? data : (data is Map && data['modules'] is List ? data['modules'] as List : []);

        if (modules.isNotEmpty) {
          final first = modules.first as Map;
          final moduleId = first['id']?.toString() ?? '';
          final moduleTitle = first['title']?.toString() ?? 'Your first module';
          appLog.i('[DirectOnboard] First module ready: $moduleId');
          state = state.copyWith(
            uploadStage: DirectUploadStage.ready,
            firstModuleId: moduleId,
            firstModuleTitle: moduleTitle,
          );
          return;
        }
      } catch (e) {
        appLog.w('[DirectOnboard] Module poll error (non-fatal): $e');
      }
      await Future<void>.delayed(pollInterval);
    }

    // Timeout — let user proceed anyway.
    state = state.copyWith(uploadStage: DirectUploadStage.ready);
  }

  String _friendlyError(DioException e) {
    final status = e.response?.statusCode;
    final body = e.response?.data;
    final serverMsg = body is Map ? body['error'] as String? : null;

    return switch (status) {
      409 =>
        'An account with this email already exists. Try signing in instead.',
      422 => serverMsg ?? 'Please check your details and try again.',
      429 => 'Too many requests. Wait a moment and try again.',
      _ when e.type == DioExceptionType.connectionError ||
              e.type == DioExceptionType.connectionTimeout =>
        'No internet connection. Check your WiFi and try again.',
      _ => serverMsg ?? 'Something went wrong. Please try again.',
    };
  }
}
