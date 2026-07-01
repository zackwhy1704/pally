/// Ensures only ONE consent modal is ever open at a time.
///
/// The dashboard fans out several API calls; for a gated child each returns a
/// 403 (CONSENT_REQUIRED / PARENTAL_CONSENT_PENDING) and, without this guard,
/// each spawned another modal on top of the last — stacked transparent barriers
/// that flickered and swallowed taps. CONSENT_REQUIRED and the pending sheet are
/// the same conceptual gate, so ONE shared guard covers both.
///
/// [runOnce] invokes [show] only when no gate is currently open, and treats the
/// returned future's completion (the sheet closing) as the reset — so a later
/// genuine gate can show again.
class ConsentGateGuard {
  bool _open = false;

  bool get isOpen => _open;

  void runOnce(Future<void> Function() show) {
    if (_open) return;
    _open = true;
    try {
      show().whenComplete(() => _open = false);
    } catch (_) {
      // Never wedge the gate shut if showing throws synchronously.
      _open = false;
    }
  }
}
