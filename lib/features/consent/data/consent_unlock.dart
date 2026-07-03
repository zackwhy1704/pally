import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/core/utils/logger.dart';
import 'package:pally/core/utils/text_format.dart';
import 'package:pally/features/auth/auth_state.dart';
import 'package:pally/features/consent/data/consent_service.dart';
import 'package:pally/features/subscription/entitlement_provider.dart';

/// Event-driven parental-consent unlock — NO polling. Every trigger (push on
/// approval, app launch, app resume, manual "I've approved" button) funnels
/// through ONE authoritative entry: [reconcile]. It drives the gate from the
/// SERVER's accountStatus, so no trigger can silently no-op on a desynced local
/// flag (the "cold start works but resume doesn't" gap).
///
/// Idempotent: a re-entry guard means push + resume + launch can't double-run
/// it. A failed check is silent — the next trigger simply tries again; if none
/// fire, the next app open reconciles it.
final consentUnlockProvider =
    Provider<ConsentUnlock>((ref) => ConsentUnlock(ref));

class ConsentUnlock {
  ConsentUnlock(this._ref);
  final Ref _ref;
  bool _inFlight = false;

  /// AUTHORITATIVE reconcile — drives the gate from the SERVER's accountStatus,
  /// never from the local `awaitingConsent` flag. This is the fix for the desync
  /// where an approved child stayed gated (or a child who reinstalled / signed in
  /// via the normal path — never setting the local flag — was never re-checked).
  /// Run on launch and after any fresh auth. Returns true if the account is
  /// ACTIVE (unlocked) after reconciling.
  ///
  /// - ACTIVE  → clear the gate + re-read entitlement (unlock), regardless of
  ///   whatever the local flag said.
  /// - PENDING → ensure the gate is shown (in case the local flag was lost).
  /// No-ops when signed out. Cheap: one GET /consent/status.
  Future<bool> reconcile() async {
    if (_inFlight) return AuthNotifier.instance.state.awaitingConsent == false;
    final token = AuthNotifier.instance.state.token;
    if (token == null || token.isEmpty) return false; // not signed in
    _inFlight = true;
    try {
      final status = await _ref.read(consentServiceProvider).fetchStatus();
      final wasAwaiting = AuthNotifier.instance.state.awaitingConsent;
      if (status.active) {
        if (wasAwaiting) {
          await AuthNotifier.instance.clearAwaitingConsent();
          _ref.read(entitlementVmProvider.notifier).reconcile();
          appLog.i('[Consent] Reconciled ACTIVE — app unlocked.');
        }
        return true;
      }
      if (status.pending && !wasAwaiting) {
        // Local flag was lost (reinstall / other device / normal sign-in) but
        // the server still awaits a parent — restore the gate so the UX + AI
        // gating stay consistent with the server.
        await AuthNotifier.instance.setAwaitingConsent(
          maskedParentEmail:
              status.parentEmail != null ? maskEmail(status.parentEmail!) : '',
        );
        appLog.i('[Consent] Reconciled PENDING — gate restored.');
      }
      return false;
    } catch (e) {
      appLog.w('[Consent] reconcile failed (retry on next trigger): $e');
      return false;
    } finally {
      _inFlight = false;
    }
  }
}
