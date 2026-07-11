import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_sizing.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/ui/pally_toast.dart';
import 'package:pally/core/utils/logger.dart';
import 'package:pally/features/consent/data/consent_gate_guard.dart';
import 'package:pally/features/consent/presentation/parental_consent_pending_sheet.dart';
import 'package:pally/features/auth/auth_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'api_client.g.dart';

/// Set by `main.dart` so Dio interceptors can reach a `BuildContext` for
/// global toasts (e.g. unhandled 5xx errors). Defaults to no-op if not
/// overridden, so unit tests still work.
final globalNavigatorKeyProvider =
    Provider<GlobalKey<NavigatorState>?>((ref) => null);

const _baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://pallybackend-production.up.railway.app',
);

@riverpod
Dio dio(Ref ref) {
  final auth = ref.watch(authStateProvider);
  final token = auth.token;

  final client = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 15),
      // 90s: quiz generation (Haiku, 5 MCQs) takes 3-15s normally but can
      // spike to 30-45s under Anthropic load. The old 30s killed every quiz
      // request when the backend used Sonnet. SSE streaming uses its own
      // per-chunk idle timeout so this ceiling doesn't affect chat.
      receiveTimeout: const Duration(seconds: 90),
      sendTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (auth.userId != null) 'X-User-Id': auth.userId!,
        if (token != null && token.isNotEmpty)
          'Authorization': 'Bearer $token',
      },
    ),
  );

  client.interceptors.addAll([
    _PallyLoggingInterceptor(),
    _ServerErrorInterceptor(ref),
    _ApiResponseInterceptor(),
    _SessionExpiredInterceptor(),
  ]);

  return client;
}

// ── Logging interceptor — logs every request, response, and failure ──────────
class _PallyLoggingInterceptor extends Interceptor {
  static const _tag = 'PallyAPI';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    appLog.i(
      '[$_tag] ──► ${options.method} ${options.baseUrl}${options.path}\n'
      '  Headers: ${_sanitiseHeaders(options.headers)}\n'
      '  Body   : ${_truncate(options.data?.toString())}',
    );
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    appLog.i(
      '[$_tag] ◄── ${response.statusCode} ${response.statusMessage}'
      ' ${response.requestOptions.method} ${response.requestOptions.path}\n'
      '  Body: ${_truncate(response.data?.toString())}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final req = err.requestOptions;
    final reason = _describeError(err);

    appLog.e(
      '[$_tag] ✗✗✗ FAILURE ${req.method} ${req.path}\n  $reason',
      error: err.error,
      stackTrace: err.stackTrace,
    );
    handler.next(err);
  }

  String _describeError(DioException err) {
    final req = err.requestOptions;
    return switch (err.type) {
      DioExceptionType.connectionTimeout =>
        'CONNECTION TIMEOUT — backend unreachable or too slow\n'
        '  Tried  : ${req.baseUrl}${req.path}\n'
        '  Timeout: ${req.connectTimeout?.inSeconds}s\n'
        '  Fix    : Is backend running? Correct host:port?',
      DioExceptionType.receiveTimeout =>
        'RECEIVE TIMEOUT — backend connected but response too slow\n'
        '  URL    : ${req.baseUrl}${req.path}\n'
        '  Timeout: ${req.receiveTimeout?.inSeconds}s\n'
        '  Fix    : Check for slow DB queries or Claude API latency',
      DioExceptionType.sendTimeout =>
        'SEND TIMEOUT — request body took too long to upload\n'
        '  URL    : ${req.baseUrl}${req.path}',
      DioExceptionType.connectionError =>
        'CONNECTION ERROR — network unreachable or backend down\n'
        '  URL    : ${req.baseUrl}${req.path}\n'
        '  Error  : ${err.error}\n'
        '  Fix    : Is backend running? Correct IP/port? Emulator vs device?',
      DioExceptionType.badResponse =>
        'BAD RESPONSE — server returned HTTP error\n'
        '  Status : ${err.response?.statusCode} ${err.response?.statusMessage}\n'
        '  URL    : ${req.baseUrl}${req.path}\n'
        '  Body   : ${_truncate(err.response?.data?.toString())}',
      DioExceptionType.cancel => 'REQUEST CANCELLED\n  URL: ${req.baseUrl}${req.path}',
      DioExceptionType.badCertificate =>
        'BAD SSL CERTIFICATE\n'
        '  URL: ${req.baseUrl}${req.path}\n'
        '  Fix: Use HTTP for local dev',
      DioExceptionType.unknown =>
        'UNKNOWN ERROR\n'
        '  URL    : ${req.baseUrl}${req.path}\n'
        '  Error  : ${err.error}\n'
        '  Message: ${err.message}',
    };
  }

  Map<String, dynamic> _sanitiseHeaders(Map<String, dynamic> headers) {
    final copy = Map<String, dynamic>.from(headers);
    if (copy.containsKey('Authorization')) copy['Authorization'] = 'Bearer [REDACTED]';
    if (copy.containsKey('x-api-key')) copy['x-api-key'] = '[REDACTED]';
    return copy;
  }

  String _truncate(String? s, {int max = 500}) {
    if (s == null) return 'null';
    return s.length > max ? '${s.substring(0, max)}... [+${s.length - max} chars]' : s;
  }
}

// ── Unwraps the Spring Boot ApiResponse<T> envelope ──────────────────────────
class _ApiResponseInterceptor extends Interceptor {
  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    final body = response.data;
    if (body is Map<String, dynamic> && body.containsKey('data')) {
      response.data = body['data'];
    }
    handler.next(response);
  }
}

/// Shows a toast for any 5xx error that individual view-models don't handle.
/// Users see "something is wrong" instead of a silent blank screen — much
/// better than failing silently while the UI keeps spinning.
///
/// Suppressed for auth endpoints so we don't double-toast on the dedicated
/// sign-in error screen, and rate-limited to one toast per 3 seconds to
/// avoid spam from a refresh storm.
class _ServerErrorInterceptor extends Interceptor {
  _ServerErrorInterceptor(this._ref);
  final Ref _ref;
  static DateTime? _lastShown;
  static DateTime? _lastPaywallRoute;
  static DateTime? _lastParentLinkRoute;
  static DateTime? _lastProfileCompletionRoute;
  // One shared guard so exactly one consent modal is ever visible.
  // CONSENT_REQUIRED and PARENTAL_CONSENT_PENDING are the same conceptual gate;
  // the dashboard fans out several parallel calls that each 403, so without this
  // every 403 stacked another modal barrier — the flicker / swallowed-taps glitch.
  static final ConsentGateGuard _consentGate = ConsentGateGuard();

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final status = err.response?.statusCode;
    final path = err.requestOptions.path;

    // 402 UPGRADE_REQUIRED → route to /paywall once per second to avoid
    // a refresh loop stacking N paywalls on top of each other.
    if (status == 402) {
      final body = err.response?.data;
      String? code;
      String? feature;
      if (body is Map) {
        final dataNode = body['data'];
        if (dataNode is Map) {
          code = dataNode['code']?.toString();
          feature = dataNode['feature']?.toString();
        }
      }
      if (code == 'UPGRADE_REQUIRED') {
        final now = DateTime.now();
        final allowed = _lastPaywallRoute == null ||
            now.difference(_lastPaywallRoute!) > const Duration(seconds: 1);
        if (allowed) {
          _lastPaywallRoute = now;
          final ctx = _ref.read(globalNavigatorKeyProvider)?.currentContext;
          if (ctx != null && ctx.mounted) {
            // Use go_router string nav so this file doesn't depend on the
            // generated typed-route classes.
            final qs = feature == null || feature.isEmpty
                ? ''
                : '?feature=$feature';
            try {
              ctx.go('/paywall$qs');
            } catch (_) {
              // Fall through; the view model will surface the error.
            }
          }
        }
      }
    }

    // 403 AI_CONSENT_REQUIRED → show the AI data-transfer disclosure, then
    // retry the original request once if the user agrees. Handled before the
    // parental CONSENT_REQUIRED branch because it has its own gate UI.
    if (status == 403) {
      final body = err.response?.data;
      String? aiCode;
      if (body is Map) {
        final dataNode = body['data'];
        if (dataNode is Map) {
          aiCode = dataNode['code']?.toString();
        }
      }
      if (aiCode == 'AI_CONSENT_REQUIRED') {
        _handleAiConsentRequired(err, handler);
        return; // _handleAiConsentRequired owns the handler from here on.
      }

      // SSE chat requests send Accept: text/event-stream. Even though the
      // backend now writes JSON directly to HttpServletResponse, Dio keeps
      // the 403 body as a raw ResponseBody (stream) because the request
      // used ResponseType.stream — body is never Map for SSE errors.
      // Fall back to path-based detection: the only non-session 403 on
      // the /chat SSE endpoint is AI_DATA_TRANSFER consent.
      final path = err.requestOptions.path;
      final isConsentlessSSE = (body == null || body is ResponseBody) &&
          path.contains('/chat') &&
          !path.contains('/chat/session-');
      if (isConsentlessSSE) {
        _handleAiConsentRequired(err, handler);
        return;
      }
    }

    // 403 PARENTAL_CONSENT_PENDING → an under-13 user whose parent has been
    // emailed but hasn't approved yet tried a gated ingress (upload / photo /
    // chat). Show the actionable "waiting for your grown-up" sheet with the
    // masked parent email + a working resend, instead of a dead-end error.
    if (status == 403) {
      final body = err.response?.data;
      if (body is Map) {
        final dataNode = body['data'];
        if (dataNode is Map &&
            dataNode['code']?.toString() == 'PARENTAL_CONSENT_PENDING') {
          _handleParentalConsentPending(dataNode);
          // Still propagate so the calling view-model clears its loading state.
          handler.next(err);
          return;
        }
      }
    }

    // 403 PARENT_LINK_REQUIRED → an under-13 user tried a gated action (chat /
    // upload) with no parent linked. Route them to the existing "link a
    // grown-up" code screen as a blocking step instead of a raw error toast.
    // No auto-retry: once a parent links, the next attempt passes server-side.
    if (status == 403) {
      final body = err.response?.data;
      String? linkCode;
      String? linkReason;
      if (body is Map) {
        final dataNode = body['data'];
        if (dataNode is Map) {
          linkCode = dataNode['code']?.toString();
          linkReason = dataNode['reason']?.toString();
        }
      }
      if (linkCode == 'PARENT_LINK_REQUIRED') {
        // GuardianRequiredException collapses two cases into one code; the reason splits them.
        // AGE_DECLARATION_REQUIRED = the account never declared a birth year (very often an
        // ADULT who was simply never asked — e.g. a legacy account). Send them to the
        // lightweight "what's your birth year?" prompt, NOT full re-onboarding (which reads
        // as data loss for an established account with a streak). A real parent-link case
        // keeps the onboarding/link route.
        if (linkReason == 'AGE_DECLARATION_REQUIRED') {
          _handleProfileCompletionRequired();
        } else {
          _handleParentLinkRequired();
        }
        // Still propagate the original error so the calling view-model can
        // clear its loading state; the routing above is the user-facing action.
        handler.next(err);
        return;
      }
    }

    // 403 PROFILE_COMPLETION_REQUIRED → a social/legacy account missing a birth
    // year hit a consent-gated action. Route to the birth-year collection step;
    // once completed the account is re-tokenised and the next attempt passes.
    if (status == 403) {
      final body = err.response?.data;
      String? profileCode;
      if (body is Map) {
        final dataNode = body['data'];
        if (dataNode is Map) {
          profileCode = dataNode['code']?.toString();
        }
      }
      if (profileCode == 'PROFILE_COMPLETION_REQUIRED') {
        _handleProfileCompletionRequired();
        // Propagate so the calling view-model clears its loading state; the
        // routing above is the user-facing action.
        handler.next(err);
        return;
      }
    }

    // 403 CONSENT_REQUIRED → show the consent-gate sheet / remind-grown-up flow.
    if (status == 403) {
      final body = err.response?.data;
      String? code;
      String? reason;
      if (body is Map) {
        final dataNode = body['data'];
        if (dataNode is Map) {
          code = dataNode['code']?.toString();
          reason = dataNode['reason']?.toString();
        }
      }
      if (code == 'CONSENT_REQUIRED') {
        final ctx = _ref.read(globalNavigatorKeyProvider)?.currentContext;
        if (ctx != null && ctx.mounted) {
          // Show a friendly bottom sheet instead of a raw error. "Remind my
          // grown-up" opens the working resend affordance (the old
          // /consent/waiting route was never registered — a dead-end).
          _showConsentGateOnce(() => showModalBottomSheet<void>(
                context: ctx,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => _ConsentGateSheet(
                  reason: reason ?? 'general',
                  onRemind: () {
                    final c =
                        _ref.read(globalNavigatorKeyProvider)?.currentContext;
                    if (c == null || !c.mounted) return;
                    // Replace this gate with the pending sheet — never stack.
                    // A deliberate single tap (not the parallel-403 storm), so
                    // it shows directly; popping the gate resets the flag.
                    Navigator.of(c).pop();
                    final c2 =
                        _ref.read(globalNavigatorKeyProvider)?.currentContext;
                    if (c2 == null || !c2.mounted) return;
                    showParentalConsentPendingSheet(
                      context: c2,
                      ref: _ref,
                      maskedEmail: 'your grown-up',
                      cooldownSeconds: 0,
                    );
                  },
                ),
              ));
        }
      }
    }

    if (status != null &&
        status >= 500 &&
        !path.contains('/auth/')) {
      final now = DateTime.now();
      if (_lastShown == null ||
          now.difference(_lastShown!) > const Duration(seconds: 3)) {
        _lastShown = now;
        final ctx = _ref.read(globalNavigatorKeyProvider)?.currentContext;
        if (ctx != null && ctx.mounted) {
          PallyToast.error(
              ctx, 'Server error ($status) — please try again');
        }
      }
    }
    handler.next(err);
  }

  /// Shows a consent modal at most ONCE. Parallel 403s from the dashboard's
  /// fan-out must not stack barriers, and CONSENT_REQUIRED + the pending sheet
  /// (the same conceptual gate) must not both be open. The flag resets when the
  /// sheet closes, so a later genuine gate can show again.
  void _showConsentGateOnce(Future<void> Function() show) =>
      _consentGate.runOnce(show);

  /// Shows the half-elevated consent-pending sheet (masked email + working
  /// resend) on a 403 `PARENTAL_CONSENT_PENDING`, guarded by the shared
  /// consent-gate flag so a refresh storm can't stack the sheet.
  void _handleParentalConsentPending(Map<dynamic, dynamic> data) {
    final ctx = _ref.read(globalNavigatorKeyProvider)?.currentContext;
    if (ctx == null || !ctx.mounted) return;

    final masked = data['parentEmailMasked']?.toString();
    final secs = data['resendAvailableInSeconds'];
    final cooldown = secs is num ? secs.toInt() : 0;
    _showConsentGateOnce(() => showParentalConsentPendingSheet(
          context: ctx,
          ref: _ref,
          maskedEmail: (masked == null || masked.isEmpty)
              ? 'your grown-up'
              : masked,
          cooldownSeconds: cooldown,
        ));
  }

  /// Routes a user to the direct onboarding screen on a 403
  /// `PARENT_LINK_REQUIRED` / `AGE_DECLARATION_REQUIRED`. Both indicate that
  /// the user needs to complete or retry the age + consent step, which now
  /// lives in `/onboarding/direct`. Rate-limited to once per second.
  void _handleParentLinkRequired() {
    final now = DateTime.now();
    final allowed = _lastParentLinkRoute == null ||
        now.difference(_lastParentLinkRoute!) > const Duration(seconds: 1);
    if (!allowed) return;
    _lastParentLinkRoute = now;

    final ctx = _ref.read(globalNavigatorKeyProvider)?.currentContext;
    if (ctx == null || !ctx.mounted) return;
    try {
      PallyToast.success(
        ctx,
        "Let's finish setting up your account so you can start learning",
      );
      ctx.go('/onboarding/direct');
    } catch (_) {
      // Fall through; the view model will surface the original error.
    }
  }

  /// Routes a social/legacy account with a missing birth year to the birth-year
  /// collection step on a 403 `PROFILE_COMPLETION_REQUIRED`. Rate-limited to
  /// once per second so a fan-out of parallel gated calls can't stack routes.
  void _handleProfileCompletionRequired() {
    final now = DateTime.now();
    final allowed = _lastProfileCompletionRoute == null ||
        now.difference(_lastProfileCompletionRoute!) >
            const Duration(seconds: 1);
    if (!allowed) return;
    _lastProfileCompletionRoute = now;

    final ctx = _ref.read(globalNavigatorKeyProvider)?.currentContext;
    if (ctx == null || !ctx.mounted) return;
    try {
      ctx.go('/profile/complete-birth-year');
    } catch (_) {
      // Fall through; the view model will surface the original error.
    }
  }

  /// Shows the AI-disclosure screen for a 403 `AI_CONSENT_REQUIRED`. When the
  /// user agrees (and consent is recorded server-side), the original request
  /// is retried once and its response resolves the pending call. Otherwise the
  /// original 403 is propagated so the caller can surface it.
  Future<void> _handleAiConsentRequired(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final ctx = _ref.read(globalNavigatorKeyProvider)?.currentContext;
    if (ctx == null || !ctx.mounted) {
      handler.next(err);
      return;
    }

    bool? agreed;
    try {
      // String nav so this file stays independent of the generated typed
      // routes. push() awaits the AiDisclosureScreen's pop result.
      agreed = await ctx.push<bool>('/consent/ai-disclosure');
    } catch (_) {
      agreed = null;
    }

    if (agreed != true) {
      handler.next(err);
      return;
    }

    // Retry the original request once on a fresh Dio (now that consent exists).
    try {
      final dio = _ref.read(dioProvider);
      final req = err.requestOptions;
      final retried = await dio.fetch<dynamic>(req);
      handler.resolve(retried);
    } on DioException catch (retryErr) {
      handler.next(retryErr);
    } catch (_) {
      handler.next(err);
    }
  }
}

class _SessionExpiredInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final path = err.requestOptions.path;
    final status = err.response?.statusCode;

    if (!path.contains('/auth/')) {
      if (status == 401) {
        // Only sign out when the body explicitly signals an invalid token.
        // Housekeeping 401s (session-end on an expired session), or transient
        // auth blips, must NOT force a sign-out while the user is actively
        // using the app — the JWT itself may still be valid.
        final body = err.response?.data;
        final isTokenInvalid = body is Map &&
            (body['error'] == 'Authentication required' ||
                body['status'] == 401);
        if (isTokenInvalid) {
          appLog.w('[Auth] 401 on $path — token invalid, signing out');
          Future.microtask(() => AuthNotifier.instance.signOut());
        }
      } else if (status == 403) {
        final body = err.response?.data;
        if (body is Map && body['data'] is Map) {
          final code = (body['data'] as Map)['code'] as String?;
          if (code == 'AI_CONSENT_REQUIRED' || code == 'CONSENT_REQUIRED') {
            appLog.w('[Auth] Consent required on $path: $code');
          }
        }
      }
    }
    handler.next(err);
  }
}

// ── Consent gate sheet ────────────────────────────────────────────────────────
// Shown instead of a raw 403 error when a PENDING account attempts a gated action.

class _ConsentGateSheet extends StatelessWidget {
  const _ConsentGateSheet({required this.reason, required this.onRemind});
  final String reason;

  /// Opens the working resend affordance. Replaces the old navigation to the
  /// never-registered `/consent/waiting` route, which dead-ended on the error
  /// screen — the exact failure this consent UX exists to kill.
  final VoidCallback onRemind;

  String get _title => switch (reason) {
        'UPLOAD' => 'Upload notes',
        'CREATE_TUTOR' => 'Create your own Mochi',
        'SHARE_NOTE' => 'Share notes',
        'PERSIST_CHAT' => 'Save conversations',
        'EARN_XP' => 'Earn rewards',
        _ => 'This feature',
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.lg + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: AppSizing.handleBarWidth,
                height: AppSizing.handleBarHeight,
                decoration: BoxDecoration(
                    color: AppColors.outline,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text('⏳', style: TextStyle(fontSize: 40)),
            const SizedBox(height: AppSpacing.sm),
            Text('Almost there!',
                style: AppTextStyles.heading1.copyWith(fontSize: 20)),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '$_title unlocks once a grown-up approves your account. '
              "We've already sent them an email — or tap below to send a reminder.",
              style: AppTextStyles.body.copyWith(color: AppColors.text2),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRemind();
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.purple,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Remind my grown-up'),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Got it',
                  style: AppTextStyles.body.copyWith(color: AppColors.text2)),
            ),
          ],
        ),
      ),
    );
  }
}
