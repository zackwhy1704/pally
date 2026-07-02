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
import 'package:pally/core/utils/text_format.dart';
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

/// Global education stages sent as the `level` field to the backend.
const directOnboardingLevels = [
  'PRIMARY',
  'SECONDARY',
  'HIGH_SCHOOL',
  'UNIVERSITY',
];

/// Human-readable label for a level value.
String levelLabel(String level) => switch (level) {
      'PRIMARY' => 'Primary School',
      'SECONDARY' => 'Secondary School',
      'HIGH_SCHOOL' => 'High School',
      'UNIVERSITY' => 'University / Adult',
      _ => level,
    };

/// Age-range hint shown under each stage tile.
String levelSubtitle(String level) => switch (level) {
      'PRIMARY' => 'Ages ~6–11',
      'SECONDARY' => 'Ages ~11–16',
      'HIGH_SCHOOL' => 'Ages ~16–18',
      'UNIVERSITY' => 'Ages 18+',
      _ => '',
    };

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
    this.isUnder13,
    this.parentEmail,
    this.awaitingConsent = false,
    this.maskedParentEmail,
    this.consentResendError,
    this.goHome = false,
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

  /// null = not yet selected; true = under 13; false = 13+.
  final bool? isUnder13;

  /// Parent email entered by an under-13 user before account creation.
  final String? parentEmail;

  /// True when account was created and we're waiting for parental consent.
  final bool awaitingConsent;

  /// Masked parent email returned by the backend (e.g. "j***@gmail.com").
  final String? maskedParentEmail;

  /// Inline error shown only on the consent-pending screen.
  final String? consentResendError;

  /// Fires once after a successful under-13 registration; the screen listens
  /// and navigates to the dashboard. Resets to false on rebuild.
  final bool goHome;

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
    Object? isUnder13 = _sentinel,
    Object? parentEmail = _sentinel,
    bool? awaitingConsent,
    Object? maskedParentEmail = _sentinel,
    Object? consentResendError = _sentinel,
    bool? goHome,
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
      isUnder13: isUnder13 == _sentinel ? this.isUnder13 : isUnder13 as bool?,
      parentEmail:
          parentEmail == _sentinel ? this.parentEmail : parentEmail as String?,
      awaitingConsent: awaitingConsent ?? this.awaitingConsent,
      maskedParentEmail: maskedParentEmail == _sentinel
          ? this.maskedParentEmail
          : maskedParentEmail as String?,
      consentResendError: consentResendError == _sentinel
          ? this.consentResendError
          : consentResendError as String?,
      goHome: goHome ?? this.goHome,
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

  void setAgeGroup({required bool isUnder13}) {
    state = state.copyWith(isUnder13: isUnder13);
  }

  void setParentEmail(String email) {
    state = state.copyWith(parentEmail: email);
  }

  Future<void> resendParentConsent() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, consentResendError: null);
    try {
      final dio = ref.read(dioProvider);
      await dio.post<dynamic>('/api/v1/consent/resend');
      state = state.copyWith(isLoading: false);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final msg = status == 429
          ? 'Please wait 60 seconds before resending.'
          : 'Could not resend. Try again shortly.';
      state = state.copyWith(isLoading: false, consentResendError: msg);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        consentResendError: 'Could not resend. Try again shortly.',
      );
    }
  }

  Future<void> signOutFromConsentScreen() async {
    _poller?.cancel();
    _poller = null;
    await AuthNotifier.instance.signOut();
  }

  /// Step 1+2: Quick onboard — create account + avatar in one call.
  /// If the user is under 13, also fires the parental consent request.
  Future<void> quickOnboard({
    required String email,
    required String password,
    required String displayName,
    required String subject,
    required String level,
  }) async {
    if (state.isLoading) return;
    appLog.i('[DirectOnboard] Starting quick onboard for $email');
    state = state.copyWith(isLoading: true, error: null);

    final isUnder13 = state.isUnder13 == true;

    // Guard: parentEmail must be set before we hit the network.
    if (isUnder13 && (state.parentEmail == null || state.parentEmail!.trim().isEmpty)) {
      state = state.copyWith(
        isLoading: false,
        error: "Please enter your parent's email address.",
      );
      return;
    }

    // Pass birth year so the backend knows to mark account PENDING_CONSENT.
    // Under-13: use current year - 12 (safely under the threshold).
    // 13+: pass current year - 13 so the backend confirms they are 13+.
    final birthYear =
        isUnder13 ? DateTime.now().year - 12 : DateTime.now().year - 13;

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
          'birthYear': birthYear,
          // Required by the backend when birthYear implies under-13.
          if (isUnder13) 'parentEmail': state.parentEmail,
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
          '[DirectOnboard] Quick onboard success: userId=$userId avatarId=$avatarId under13=$isUnder13');

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

      // Under-13: request parental consent (persists to AuthNotifier) then go
      // to the dashboard. The home screen shows a dismissible consent banner.
      if (isUnder13) {
        await _requestParentalConsent(authenticatedDio: ref.read(dioProvider));
        // Only navigate home when the consent request succeeded (no error set).
        if (state.error == null) {
          state = state.copyWith(isLoading: false, goHome: true);
        }
        return;
      }

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

  Future<void> _requestParentalConsent({required Dio authenticatedDio}) async {
    final parentEmail = state.parentEmail;
    if (parentEmail == null || parentEmail.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        error: 'Please enter your parent\'s email address.',
      );
      return;
    }
    try {
      final res = await authenticatedDio.post<Map<String, dynamic>>(
        '/api/v1/consent/request-parent',
        data: {'parentEmail': parentEmail},
        options: Options(receiveTimeout: const Duration(seconds: 15)),
      );
      final body = res.data ?? {};
      final inner =
          body['data'] is Map ? body['data'] as Map<String, dynamic> : body;
      final masked =
          inner['maskedParentEmail'] as String? ?? maskEmail(parentEmail);

      await AuthNotifier.instance
          .setAwaitingConsent(maskedParentEmail: masked);

      appLog.i('[DirectOnboard] Parental consent requested; masked=$masked');
      state = state.copyWith(
        isLoading: false,
        awaitingConsent: true,
        maskedParentEmail: masked,
      );
    } on DioException catch (e, st) {
      appLog.e('[DirectOnboard] Consent request failed', error: e, stackTrace: st);
      state = state.copyWith(
        isLoading: false,
        error: _friendlyError(e),
      );
    } catch (e, st) {
      appLog.e('[DirectOnboard] Consent request unexpected error',
          error: e, stackTrace: st);
      state = state.copyWith(
        isLoading: false,
        error:
            'Could not send the parental consent email. Please ask your parent to check their inbox for a confirmation link.',
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
    final msgLow = serverMsg?.toLowerCase() ?? '';

    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return 'No internet connection. Check your WiFi and try again.';
    }

    return switch (status) {
      401 =>
        "Wrong password. Already have an account? Tap 'Already have an account? Sign in' below.",
      409 =>
        'An account with this email already exists. Try signing in instead.',
      400 when msgLow.contains('valid address') ||
              msgLow.contains('valid email') =>
        'Please enter a valid email address.',
      400 when msgLow.contains('parent') || msgLow.contains('guardian') =>
        'A valid parent email is required. Please go back and correct it.',
      403 =>
        'Your account is pending parental approval. Ask your parent to check their email.',
      422 => serverMsg ?? 'Please check your details and try again.',
      429 => 'Too many requests. Wait a moment and try again.',
      500 =>
        'Account setup hit a temporary error. If you already have an account, please try signing in instead.',
      _ when msgLow.contains('pending') ||
              msgLow.contains('consent') ||
              msgLow.contains('elevation') =>
        'Your account is pending parental approval. Ask your parent to check their email.',
      _ => serverMsg ?? 'Something went wrong. Please try again.',
    };
  }
}
