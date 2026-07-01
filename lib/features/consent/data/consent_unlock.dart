import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/core/utils/logger.dart';
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
    // Only meaningful while the child is gated on a parent's approval.
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
}
