import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_sizing.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/features/auth/auth_state.dart';
import 'package:pally/features/consent/data/consent_unlock.dart';

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
    final res = await dio.post<dynamic>('/consent/resend');
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
void showParentalConsentPendingSheet({
  required BuildContext context,
  required Ref ref,
  required String maskedEmail,
  required int cooldownSeconds,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ParentalConsentPendingSheet(
      maskedEmail: maskedEmail,
      initialCooldownSeconds: cooldownSeconds,
      onResend: () => resendParentConsent(ref),
      onRefresh: () => ref.read(consentUnlockProvider).checkAndUnlock(),
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
  });

  final String maskedEmail;
  final int initialCooldownSeconds;
  final Future<ResendResult> Function() onResend;

  /// Manual "I've approved — refresh" fallback: fires a SINGLE consent re-check
  /// and returns true if the account is now approved. Optional so existing
  /// callers/tests without the unlock wiring still work.
  final Future<bool> Function()? onRefresh;

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
  late String _maskedEmail = widget.maskedEmail;

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
    _dismissed = true;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("You're all set! 🎉")),
    );
    Navigator.of(context).maybePop();
  }

  String get _statusLine => switch (_ui) {
        _ResendUi.sent =>
          'Approval email re-sent to $_maskedEmail — check inbox and spam.',
        _ResendUi.failed => "Couldn't resend just now — try again shortly.",
        _ => '',
      };

  Color get _statusColor =>
      _ui == _ResendUi.failed ? AppColors.coral : AppColors.teal;

  bool get _buttonEnabled => _ui != _ResendUi.sending && _cooldown <= 0;

  String get _buttonLabel {
    if (_ui == _ResendUi.sending) return 'Sending…';
    if (_cooldown > 0) return 'Resend in ${_cooldown}s';
    return 'Resend email';
  }

  @override
  Widget build(BuildContext context) {
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
            const Text('⏳', style: TextStyle(fontSize: 40)),
            const SizedBox(height: AppSpacing.sm),
            Text('Waiting for your grown-up',
                style: AppTextStyles.heading1.copyWith(fontSize: 20)),
            const SizedBox(height: AppSpacing.xs),
            Text.rich(
              TextSpan(
                style: AppTextStyles.body.copyWith(color: AppColors.text2),
                children: [
                  const TextSpan(
                      text:
                          'Your account is waiting for a grown-up to approve it. '
                          'Ask them to check their email at '),
                  TextSpan(
                    text: _maskedEmail,
                    style: AppTextStyles.body.copyWith(
                        color: AppColors.text1, fontWeight: FontWeight.w700),
                  ),
                  const TextSpan(text: ' and tap the approval link.'),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              "We'll unlock automatically the moment they do — you can close the "
              "app, it'll be ready when you're back.",
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.text3),
            ),
            if (_notYet) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Not approved yet — ask your grown-up to tap the link, then try again.',
                style: AppTextStyles.body
                    .copyWith(color: AppColors.text2, fontWeight: FontWeight.w600),
              ),
            ],
            if (_statusLine.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                _statusLine,
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
                    : const Text("I've approved — refresh"),
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
                  : Text(_buttonLabel),
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
