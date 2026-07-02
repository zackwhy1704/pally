import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/core/utils/logger.dart';
import 'package:pally/core/utils/text_format.dart';
import 'package:pally/features/auth/auth_state.dart';
import 'package:pally/features/consent/data/consent_service.dart';
import 'package:pally/features/subscription/entitlement_provider.dart';

/// Event-driven parental-consent unlock — NO polling. Exactly ONE status check
/// per trigger (push on approval, app resume/launch, manual "I've approved"
/// button). If the parent has approved, it flips the app out of the
/// awaiting-consent gate and re-reads the freshly-granted 7-day trial.
///
/// Idempotent: a re-entry guard means push + resume can't double-run it, and it
/// no-ops when the user isn't awaiting consent. A failed check is silent — the
/// next trigger simply tries again; if none fire, the next app open unlocks it.
final consentUnlockProvider =
    Provider<ConsentUnlock>((ref) => ConsentUnlock(ref));

class ConsentUnlock {
  ConsentUnlock(this._ref);
  final Ref _ref;
  bool _inFlight = false;

  Future<bool> checkAndUnlock() async {
    if (_inFlight) return false;
    // Fast path (resume / push): only meaningful while the child is locally
    // gated. The authoritative path is reconcile(), which does NOT depend on
    // this flag — so a desynced flag can never permanently suppress the unlock.
    if (!AuthNotifier.instance.state.awaitingConsent) return false;
    _inFlight = true;
    try {
      final active = await _ref.read(consentServiceProvider).isAccountActive();
      if (!active) return false;
      // Unlock: clearAwaitingConsent() notifies listeners, so the router
      // re-evaluates and the child lands in the normal app.
      await AuthNotifier.instance.clearAwaitingConsent();
      // Re-read the 7-day trial/entitlement granted at approval time.
      _ref.read(entitlementVmProvider.notifier).reconcile();
      appLog.i('[Consent] Approved — app unlocked.');
      return true;
    } catch (e) {
      appLog.w('[Consent] unlock check failed (retry on next trigger): $e');
      return false;
    } finally {
      _inFlight = false;
    }
  }

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
