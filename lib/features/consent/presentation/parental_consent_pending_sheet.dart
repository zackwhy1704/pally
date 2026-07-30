import 'dart:async';
import 'package:pally/l10n/app_localizations.dart';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/ui/pally_toast.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_sizing.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/utils/text_format.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/features/auth/auth_state.dart';
import 'package:pally/features/consent/data/consent_unlock.dart';

/// Small stateful dialog that owns its own TextEditingController lifecycle
/// (created in initState, disposed in dispose) — pops the entered email.
class _ChangeEmailDialog extends StatefulWidget {
  const _ChangeEmailDialog();

  @override
  State<_ChangeEmailDialog> createState() => _ChangeEmailDialogState();
}

class _ChangeEmailDialogState extends State<_ChangeEmailDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l.consentPendingEmailLabel),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.emailAddress,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'grownup@email.com',
          helperText: l.consentPendingHelperText,
        ),
        onSubmitted: (v) => Navigator.of(context).pop(v.trim()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.commonCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
          child: Text(l.consentPendingSend),
        ),
      ],
    );
  }
}

/// The outcome of a single `/consent/resend` attempt, mapped from the backend.
enum ResendOutcome { sent, cooldown, failed }

/// Result of a resend attempt. [cooldownSeconds] is how long until the next
/// resend is allowed (0 when unknown); [maskedEmail] echoes the masked parent
/// email on success so the UI can confirm where the mail went.
class ResendResult {
  const ResendResult(this.outcome, {this.cooldownSeconds = 0, this.maskedEmail});
  final ResendOutcome outcome;
  final int cooldownSeconds;
  final String? maskedEmail;
}

/// Shared resend call used by every surface that raises PARENTAL_CONSENT_PENDING
/// (the Dio interceptor for upload/photo-question, and the chat SSE path).
///
/// Maps the backend contract to a [ResendResult]:
/// - 200 → [ResendOutcome.sent] (cooldown from `resendAvailableInSeconds`).
/// - 429 → [ResendOutcome.cooldown] (seconds parsed from the wait message).
/// - anything else → [ResendOutcome.failed].
Future<ResendResult> resendParentConsent(Ref ref) async {
  final dio = ref.read(dioProvider);
  try {
    // _ApiResponseInterceptor unwraps the envelope, so `data` is the inner map.
    // NB: path MUST include /api/v1 (the backend is @RequestMapping /api/v1/consent);
    // the bare '/consent/resend' was 404-ing, so the resend button never worked.
    final res = await dio.post<dynamic>('/api/v1/consent/resend');
    final body = res.data;
    String? masked;
    int cooldown = 60;
    if (body is Map) {
      masked = body['parentEmailMasked']?.toString();
      final secs = body['resendAvailableInSeconds'];
      if (secs is num) cooldown = secs.toInt();
    }
    return ResendResult(ResendOutcome.sent,
        cooldownSeconds: cooldown, maskedEmail: masked);
  } on DioException catch (e) {
    if (e.response?.statusCode == 429) {
      return ResendResult(ResendOutcome.cooldown,
          cooldownSeconds: _parseWaitSeconds(e.response?.data));
    }
    return const ResendResult(ResendOutcome.failed);
  } catch (_) {
    return const ResendResult(ResendOutcome.failed);
  }
}

/// Re-points the pending consent request at a NEW parent email — the recovery
/// path when a child typo'd the address (otherwise a permanent lockout, since
/// resend only ever re-sends to the same wrong inbox). POSTs request-parent with
/// the new address, which creates a fresh pending request + emails it. Returns
/// [ResendOutcome.sent] with the new masked email on success.
Future<ResendResult> changeParentEmail(Ref ref, String newEmail) async {
  final dio = ref.read(dioProvider);
  final email = newEmail.trim();
  if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
    return const ResendResult(ResendOutcome.failed);
  }
  try {
    final res = await dio.post<dynamic>(
      '/api/v1/consent/request-parent',
      data: {'parentEmail': email},
    );
    final body = res.data;
    String? masked;
    if (body is Map) {
      masked = (body['parentEmailMasked'] ?? body['parentEmail'])?.toString();
    }
    // Fresh request → resend cooldown restarts.
    return ResendResult(ResendOutcome.sent,
        cooldownSeconds: 60, maskedEmail: masked ?? maskEmail(email));
  } on DioException {
    return const ResendResult(ResendOutcome.failed);
  } catch (_) {
    return const ResendResult(ResendOutcome.failed);
  }
}

/// Pulls the first integer out of a "Please wait 42s before resending" message,
/// falling back to a 60s cooldown when no number is present.
int _parseWaitSeconds(dynamic body) {
  String? message;
  if (body is Map) {
    message = (body['error'] ?? body['message'])?.toString();
  } else if (body != null) {
    message = body.toString();
  }
  if (message == null) return 60;
  final match = RegExp(r'\d+').firstMatch(message);
  return match == null ? 60 : int.parse(match.group(0)!);
}

/// Shows the half-elevated (under-13 awaiting parent) gate sheet centrally.
/// Rate-limited by the caller; this just renders the actionable panel with a
/// working resend wired to [resendParentConsent].
Future<void> showParentalConsentPendingSheet({
  required BuildContext context,
  required Ref ref,
  required String? maskedEmail,
  required int cooldownSeconds,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ParentalConsentPendingSheet(
      maskedEmail: maskedEmail,
      initialCooldownSeconds: cooldownSeconds,
      onResend: () => resendParentConsent(ref),
      onRefresh: () => ref.read(consentUnlockProvider).reconcile(),
      onChangeEmail: (email) => changeParentEmail(ref, email),
    ),
  );
}

/// Actionable "waiting for your parent — resend" panel. Stateful so the resend
/// button can move through idle → sending → sent/cooldown/failed and run a live
/// countdown, never a silent no-op.
class ParentalConsentPendingSheet extends ConsumerStatefulWidget {
  const ParentalConsentPendingSheet({
    super.key,
    required this.maskedEmail,
    required this.initialCooldownSeconds,
    required this.onResend,
    this.onRefresh,
    this.onChangeEmail,
  });

  /// Masked parent email to display. Null/empty → the sheet renders the
  /// localized "your grown-up" fallback at build time (never a pre-rendered
  /// English literal from a context-less caller).
  final String? maskedEmail;
  final int initialCooldownSeconds;
  final Future<ResendResult> Function() onResend;

  /// Manual "I've approved — refresh" fallback: fires a SINGLE consent re-check
  /// and returns true if the account is now approved. Optional so existing
  /// callers/tests without the unlock wiring still work.
  final Future<bool> Function()? onRefresh;

  /// "Wrong grown-up's email? Change it" recovery — re-points the request at a
  /// new address. Optional so existing callers/tests still work.
  final Future<ResendResult> Function(String newEmail)? onChangeEmail;

  @override
  ConsumerState<ParentalConsentPendingSheet> createState() =>
      _ParentalConsentPendingSheetState();
}

enum _ResendUi { idle, sending, sent, failed }

class _ParentalConsentPendingSheetState
    extends ConsumerState<ParentalConsentPendingSheet> {
  _ResendUi _ui = _ResendUi.idle;
  int _cooldown = 0;
  Timer? _timer;
  bool _refreshing = false;
  bool _dismissed = false;

  /// Mutable so a successful resend can reveal the real masked address when the
  /// caller only had a generic placeholder (e.g. the CONSENT_REQUIRED gate).
  late String? _maskedEmail = widget.maskedEmail;

  /// Render-time fallback: resolves in the CURRENT locale, so a context-less
  /// caller (the API client) never bakes English into this localized surface.
  String _displayEmail(AppLocalizations l) {
    final m = _maskedEmail;
    return (m == null || m.isEmpty) ? l.consentPendingYourGrownUp : m;
  }

  @override
  void initState() {
    super.initState();
    _startCooldown(widget.initialCooldownSeconds);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCooldown(int seconds) {
    _timer?.cancel();
    _cooldown = seconds.clamp(0, 24 * 3600);
    if (_cooldown <= 0) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _cooldown -= 1;
        if (_cooldown <= 0) t.cancel();
      });
    });
  }

  Future<void> _resend() async {
    if (_ui == _ResendUi.sending || _cooldown > 0) return;
    setState(() => _ui = _ResendUi.sending);
    final result = await widget.onResend();
    if (!mounted) return;
    switch (result.outcome) {
      case ResendOutcome.sent:
        setState(() {
          _ui = _ResendUi.sent;
          final m = result.maskedEmail;
          if (m != null && m.isNotEmpty) _maskedEmail = m;
        });
        _startCooldown(result.cooldownSeconds);
      case ResendOutcome.cooldown:
        setState(() => _ui = _ResendUi.idle);
        _startCooldown(result.cooldownSeconds);
      case ResendOutcome.failed:
        setState(() => _ui = _ResendUi.failed);
    }
  }

  Future<void> _refresh() async {
    if (_refreshing || widget.onRefresh == null) return;
    setState(() {
      _refreshing = true;
      _ui = _ResendUi.idle;
    });
    final unlocked = await widget.onRefresh!();
    if (!mounted) return;
    // On success the authState listener below dismisses the sheet; here we only
    // message the not-yet case so a watching child gets clear feedback.
    setState(() {
      _refreshing = false;
      if (!unlocked) _notYet = true;
    });
  }

  bool _notYet = false;

  /// Pops the sheet with a brief success cue once the parent's approval lands
  /// (via push, resume-check, or the manual refresh) — awaitingConsent flips
  /// false app-wide, so every unlock path dismisses this one sheet.
  void _onUnlocked() {
    if (_dismissed || !mounted) return;
    final l = AppLocalizations.of(context);
    _dismissed = true;
    showAppSnackBar(
      SnackBar(content: Text(l.consentApprovedAllSet)),
    );
    Navigator.of(context).maybePop();
  }

  /// Recovery for a typo'd parent email: ask for a new address and re-point the
  /// request. Without this a wrong email is a permanent lockout.
  Future<void> _changeEmail() async {
    if (widget.onChangeEmail == null) return;
    final newEmail = await showDialog<String>(
      context: context,
      builder: (ctx) => const _ChangeEmailDialog(),
    );
    if (newEmail == null || newEmail.isEmpty || !mounted) return;

    setState(() {
      _ui = _ResendUi.sending;
      _notYet = false;
    });
    final result = await widget.onChangeEmail!(newEmail);
    if (!mounted) return;
    switch (result.outcome) {
      case ResendOutcome.sent:
        setState(() {
          _ui = _ResendUi.sent;
          final m = result.maskedEmail;
          if (m != null && m.isNotEmpty) _maskedEmail = m;
        });
        _startCooldown(result.cooldownSeconds);
      case ResendOutcome.cooldown:
      case ResendOutcome.failed:
        setState(() => _ui = _ResendUi.failed);
    }
  }

  String _statusLine(AppLocalizations l) => switch (_ui) {
        _ResendUi.sent => l.consentPendingResent(_displayEmail(l)),
        _ResendUi.failed => l.consentPendingResendFailed,
        _ => '',
      };

  Color get _statusColor =>
      _ui == _ResendUi.failed ? AppColors.coral : AppColors.teal;

  bool get _buttonEnabled => _ui != _ResendUi.sending && _cooldown <= 0;

  String _buttonLabel(AppLocalizations l) {
    if (_ui == _ResendUi.sending) return l.consentPendingSending;
    if (_cooldown > 0) return l.consentPendingResendIn(_cooldown);
    return l.consentPendingResendEmail;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    // Any unlock path (push / resume / manual) flips awaitingConsent false —
    // dismiss this sheet the moment it does.
    ref.listen(authStateProvider, (prev, next) {
      if (!next.awaitingConsent) _onUnlocked();
    });
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
            Center(
              child: Image.asset('assets/images/mochi.png',
                  width: 72, height: 72),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(l.consentPendingTitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.heading1.copyWith(fontSize: 20)),
            const SizedBox(height: AppSpacing.xs),
            Text(l.consentPendingSubtitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(color: AppColors.text2)),
            const SizedBox(height: AppSpacing.sm),
            Text.rich(
              textAlign: TextAlign.center,
              TextSpan(
                style: AppTextStyles.body.copyWith(color: AppColors.text2),
                children: [
                  TextSpan(text: l.consentPendingAskEmailBefore),
                  TextSpan(
                    text: _displayEmail(l),
                    style: AppTextStyles.body.copyWith(
                        color: AppColors.text1, fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: l.consentPendingAskEmailAfter),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l.consentPendingSpamNote,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.text3),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l.consentPendingAutoUnlock,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.text3),
            ),
            if (_notYet) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                l.consentPendingNotApproved,
                style: AppTextStyles.body
                    .copyWith(color: AppColors.text2, fontWeight: FontWeight.w600),
              ),
            ],
            if (_statusLine(l).isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                _statusLine(l),
                style: AppTextStyles.body
                    .copyWith(color: _statusColor, fontWeight: FontWeight.w600),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            if (widget.onRefresh != null) ...[
              FilledButton(
                onPressed: _refreshing ? null : _refresh,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  disabledBackgroundColor: AppColors.outline,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _refreshing
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Text(l.consentPendingRefresh),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            FilledButton(
              onPressed: _buttonEnabled ? _resend : null,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.purple,
                disabledBackgroundColor: AppColors.outline,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _ui == _ResendUi.sending
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(_buttonLabel(l)),
            ),
            if (widget.onChangeEmail != null) ...[
              const SizedBox(height: AppSpacing.xs),
              TextButton(
                onPressed: _ui == _ResendUi.sending ? null : _changeEmail,
                child: Text(l.consentPendingChangeEmail,
                    style: AppTextStyles.body.copyWith(
                        color: AppColors.purple, fontWeight: FontWeight.w600)),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l.consentPendingGotIt,
                  style: AppTextStyles.body.copyWith(color: AppColors.text2)),
            ),
          ],
        ),
      ),
    );
  }
}
