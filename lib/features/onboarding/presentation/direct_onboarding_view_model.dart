import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/i18n/locale_controller.dart';
import 'package:pally/core/services/fcm_token_service.dart';
import 'package:pally/core/observability/observability.dart';
import 'package:pally/core/observability/observability_providers.dart';
import 'package:pally/core/utils/logger.dart';
import 'package:pally/core/utils/text_format.dart';
import 'package:pally/features/auth/auth_state.dart';
import 'package:pally/features/upload/presentation/upload_view_model.dart'
    show relevanceWarningFrom;

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

/// Global education stages sent as the `level` field to the backend.
const directOnboardingLevels = [
  'PRIMARY',
  'SECONDARY',
  'HIGH_SCHOOL',
  'UNIVERSITY',
];

// NOTE: subject/level DISPLAY labels resolve at the screen via the shared
// label_localizer.dart resolvers (localizedSubject/localizedLevel/
// localizedLevelSubtitle) — this file used to carry its own SECOND, dead copy
// (subjectLabel/levelLabel/levelSubtitle, called from nowhere) which has been
// deleted rather than localized. See DEFERRED.md for how this duplicate arose.

/// Typed onboarding failure. The view-model owns the error IDENTITY; the
/// screen resolves it to wording at render (see
/// direct_onboarding_error_localizer.dart), so the notifier never imports
/// AppLocalizations — the same PR-G3/PR-I/PR-K2 layering pattern used by every
/// other typed VM error in this app.
enum DirectOnboardingErrorKind {
  noInternet,
  wrongPassword,
  accountExists,
  invalidEmail,
  parentEmailInvalid, // server rejected the parent email itself
  parentEmailMissing, // client-side: submitted with no parent email at all
  consentPending,
  rateLimited,
  serverError,
  serverMessage, // backend's own message, passed through verbatim (detail)
  unknown, // catch-all; detail carries the backend message when present
  consentEmailFailed,
  signUpRequired,
  fileReadFailed,
  uploadFailed,
  resendRateLimited,
  resendFailed,
}

@immutable
class DirectOnboardingError {
  const DirectOnboardingError(this.kind, {this.detail});
  final DirectOnboardingErrorKind kind;

  /// Backend's own message when present (serverMessage/unknown), shown
  /// verbatim — never re-translated, mirrors UploadError/CreateTutorError.
  final String? detail;
}

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
    this.irrelevantReason,
  });

  final int step;
  final bool isLoading;
  final DirectOnboardingError? error;
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
  final DirectOnboardingError? consentResendError;

  /// Fires once after a successful under-13 registration; the screen listens
  /// and navigates to the dashboard. Resets to false on rebuild.
  final bool goHome;

  /// Server's irrelevance reason when [uploadStage] == irrelevant (drives the
  /// "doesn't look like <subject> material — use anyway?" question).
  final String? irrelevantReason;

  DirectOnboardingState copyWith({
    int? step,
    bool? isLoading,
    Object? error = _sentinel,
    Object? consentResendError = _sentinel,
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
    bool? goHome,
    Object? irrelevantReason = _sentinel,
  }) {
    return DirectOnboardingState(
      step: step ?? this.step,
      isLoading: isLoading ?? this.isLoading,
      error: error == _sentinel ? this.error : error as DirectOnboardingError?,
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
          : consentResendError as DirectOnboardingError?,
      goHome: goHome ?? this.goHome,
      irrelevantReason: irrelevantReason == _sentinel
          ? this.irrelevantReason
          : irrelevantReason as String?,
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
  // Server accepted the upload (200) but scored the content IRRELEVANT to the chosen
  // subject — do NOT proceed to a fake success screen; ask "use anyway?" (the same
  // override the main upload path offers) so the student isn't left with empty Modules.
  irrelevant,
  // A large doc (150+ pages) was SEGMENTED into pickable chapters and NOT compiled —
  // show the chapter picker instead of polling for a compile that never comes (which
  // timed out into a fake-success + empty Modules). Mirrors the main upload path.
  awaitingChapterPick,
}

/// Builds the `/api/v1/onboard/quick` request body. Extracted to a pure
/// function (no Dio, no network) so the request SHAPE — in particular that
/// `contentLanguage` is actually present and correctly sourced — is directly
/// unit-testable without needing to intercept the unauthenticated Dio
/// instance `quickOnboard` constructs inline.
Map<String, dynamic> quickOnboardRequestBody({
  required String email,
  required String password,
  required String displayName,
  required String subject,
  required String level,
  required int birthYear,
  required String? parentEmail,
  required String contentLanguage,
}) =>
    {
      'email': email,
      'password': password,
      'displayName': displayName,
      'subject': subject,
      'level': level,
      'birthYear': birthYear,
      // Required by the backend when birthYear implies under-13.
      if (parentEmail != null) 'parentEmail': parentEmail,
      'contentLanguage': contentLanguage,
    };

@riverpod
class DirectOnboardingViewModel extends _$DirectOnboardingViewModel {
  Timer? _poller;
  // Held so an "use anyway" override can re-upload the SAME file with skipRelevance.
  PlatformFile? _pendingFile;

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
      final kind = status == 429
          ? DirectOnboardingErrorKind.resendRateLimited
          : DirectOnboardingErrorKind.resendFailed;
      state = state.copyWith(
          isLoading: false,
          consentResendError: DirectOnboardingError(kind));
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        consentResendError:
            const DirectOnboardingError(DirectOnboardingErrorKind.resendFailed),
      );
    }
  }

  Future<void> signOutFromConsentScreen() async {
    _poller?.cancel();
    _poller = null;
    await AuthNotifier.instance.signOut();
  }

  /// Clears any pre-existing session so a fresh account can be created. Used by
  /// the "already signed in" interstitial shown when a logged-in user enters the
  /// signup flow — never silently switch accounts, always an explicit logout.
  Future<void> logOutForNewSignup() async {
    if (state.isLoading) return;
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
        error: const DirectOnboardingError(
            DirectOnboardingErrorKind.parentEmailMissing),
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
        data: quickOnboardRequestBody(
          email: email,
          password: password,
          displayName: displayName,
          subject: subject,
          level: level,
          birthYear: birthYear,
          parentEmail: isUnder13 ? state.parentEmail : null,
          // Whichever UI language the user is signing up in is the sensible
          // default for the FIRST avatar's content — same source as the
          // create_tutor wizard's contentLanguage default (Workstream 1).
          // This is the primary signup path virtually every user takes; it
          // never sent a language at all before this, so the default avatar
          // was always English regardless of the signup UI's language.
          contentLanguage: ref.read(localeControllerProvider).languageCode,
        ),
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
      // Register the push token for THIS (possibly under-13) account — the
      // sign-in screen isn't traversed on the onboarding path, so without this
      // the child never gets a push address and parental-approval push can't
      // reach them. Fire-and-forget; no-ops if Firebase isn't ready.
      FcmTokenService(ref.read(dioProvider)).registerToken();
      // Mirror the UI language chosen pre-auth to preferred_locale now that a
      // token exists. /onboard/quick does NOT accept preferredLocale (backend
      // never added it there — sending it would be a silent no-op), so the
      // honest mirror is this authenticated PATCH. Best-effort, never blocks.
      unawaited(ref.read(localeControllerProvider.notifier).reconcileToServer());

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
      state = state.copyWith(isLoading: false, error: friendlyError(e));
    } catch (e, st) {
      appLog.e('[DirectOnboard] Unexpected error', error: e, stackTrace: st);
      state = state.copyWith(
        isLoading: false,
        error: const DirectOnboardingError(DirectOnboardingErrorKind.unknown),
      );
    }
  }

  Future<void> _requestParentalConsent({required Dio authenticatedDio}) async {
    final parentEmail = state.parentEmail;
    if (parentEmail == null || parentEmail.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        error: const DirectOnboardingError(
            DirectOnboardingErrorKind.parentEmailMissing),
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
        error: friendlyError(e),
      );
    } catch (e, st) {
      appLog.e('[DirectOnboard] Consent request unexpected error',
          error: e, stackTrace: st);
      state = state.copyWith(
        isLoading: false,
        error: const DirectOnboardingError(
            DirectOnboardingErrorKind.consentEmailFailed),
      );
    }
  }

  /// Step 3: Upload file, poll for compile, generate modules.
  Future<void> uploadFile(PlatformFile file, {bool skipRelevance = false}) async {
    _pendingFile = file;
    final avatarId = state.avatarId;
    if (avatarId == null || avatarId.isEmpty) {
      state = state.copyWith(
          error: const DirectOnboardingError(
              DirectOnboardingErrorKind.signUpRequired));
      return;
    }

    if (file.path == null) {
      state = state.copyWith(
          error: const DirectOnboardingError(
              DirectOnboardingErrorKind.fileReadFailed));
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
        if (skipRelevance) 'skipRelevance': 'true',
      });
      final response = await dio.post<Map<String, dynamic>>(
        '/api/v1/avatars/$avatarId/files',
        data: formData,
        // A 19MB book cannot finish a SEND in the global BaseOptions sendTimeout (15s),
        // so the onboarding upload died at 15s while the main+homework upload paths (which
        // DO override) succeeded — the "manual always fails" root cause. Match the siblings.
        options: Options(
          receiveTimeout: const Duration(minutes: 3),
          sendTimeout: const Duration(minutes: 2),
        ),
      );

      // A 200 can still be a server IRRELEVANT verdict (bare reason+score) — the SAME
      // marker the main upload path detects. Do NOT march on to a fake success screen;
      // surface the "use anyway?" override so the student isn't left with empty Modules.
      final data = response.data ?? const <String, dynamic>{};

      final warning = relevanceWarningFrom(data);
      if (warning != null && !skipRelevance) {
        appLog.i('[DirectOnboard] Server marked upload IRRELEVANT '
            '(score=${warning.score}) — offering use-anyway override');
        state = state.copyWith(
          uploadStage: DirectUploadStage.irrelevant,
          irrelevantReason: warning.reason,
        );
        return;
      }

      // SEGMENTED (150+ pages): the server split the doc into pickable chapters and
      // compiled NOTHING. Polling for a compiled brain here would time out into a
      // fake-success screen with empty Modules (the 150+ page sign-up bug). Show the
      // chapter picker instead — same contract the main upload path consumes.
      final chunks = data['chunks'];
      if (chunks is List && chunks.isNotEmpty) {
        appLog.i('[DirectOnboard] SEGMENTED: ${chunks.length} chapters — show picker');
        state = state.copyWith(uploadStage: DirectUploadStage.awaitingChapterPick);
        return;
      }

      appLog.i('[DirectOnboard] Upload complete, polling for compile');
      state = state.copyWith(uploadStage: DirectUploadStage.compiling);

      // Poll until brain is READY.
      await _pollUntilCompiled(avatarId);
    } on DioException catch (e, st) {
      appLog.e('[DirectOnboard] Upload failed', error: e, stackTrace: st);
      state = state.copyWith(
        uploadStage: DirectUploadStage.failed,
        error: friendlyError(e),
      );
    } catch (e, st) {
      appLog.e('[DirectOnboard] Unexpected upload error',
          error: e, stackTrace: st);
      state = state.copyWith(
        uploadStage: DirectUploadStage.failed,
        error: const DirectOnboardingError(
            DirectOnboardingErrorKind.uploadFailed),
      );
    }
  }

  /// "Use anyway" from the irrelevant-verdict question: re-upload the same file with
  /// skipRelevance so the server ingests it despite the low subject-match score.
  Future<void> useUploadedFileAnyway() async {
    final file = _pendingFile;
    if (file == null) return;
    await uploadFile(file, skipRelevance: true);
  }

  /// "Choose a different file" from the irrelevant question — back to the idle upload state.
  void dismissIrrelevant() {
    _pendingFile = null;
    state = state.copyWith(
        uploadStage: DirectUploadStage.idle, irrelevantReason: null);
  }

  /// Called after the chapter picker has compiled at least one chapter — resume the
  /// onboarding compile/generate flow (now there's real content, so the poll succeeds).
  Future<void> proceedAfterChapters(String avatarId) async {
    state = state.copyWith(uploadStage: DirectUploadStage.compiling);
    await _pollUntilCompiled(avatarId);
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

  /// Public (not `_friendlyError`) so the status-code → KIND mapping is unit-
  /// testable directly, mirroring UploadViewModel.friendlyUploadError.
  DirectOnboardingError friendlyError(DioException e) {
    final status = e.response?.statusCode;
    final body = e.response?.data;
    final serverMsg = body is Map ? body['error'] as String? : null;
    final msgLow = serverMsg?.toLowerCase() ?? '';

    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return const DirectOnboardingError(DirectOnboardingErrorKind.noInternet);
    }

    return switch (status) {
      401 => const DirectOnboardingError(DirectOnboardingErrorKind.wrongPassword),
      409 => const DirectOnboardingError(DirectOnboardingErrorKind.accountExists),
      400 when msgLow.contains('valid address') ||
              msgLow.contains('valid email') =>
        const DirectOnboardingError(DirectOnboardingErrorKind.invalidEmail),
      400 when msgLow.contains('parent') || msgLow.contains('guardian') =>
        const DirectOnboardingError(
            DirectOnboardingErrorKind.parentEmailInvalid),
      403 =>
        const DirectOnboardingError(DirectOnboardingErrorKind.consentPending),
      422 => DirectOnboardingError(DirectOnboardingErrorKind.serverMessage,
          detail: serverMsg),
      429 => const DirectOnboardingError(DirectOnboardingErrorKind.rateLimited),
      500 => const DirectOnboardingError(DirectOnboardingErrorKind.serverError),
      _ when msgLow.contains('pending') ||
              msgLow.contains('consent') ||
              msgLow.contains('elevation') =>
        const DirectOnboardingError(DirectOnboardingErrorKind.consentPending),
      _ => DirectOnboardingError(DirectOnboardingErrorKind.unknown,
          detail: serverMsg),
    };
  }
}
