/// Vendor-neutral observability seam.
///
/// All call sites import ONLY this file — never Sentry directly.
/// Swap the concrete impl in the provider without touching screens.
library observability;

// ── Analytics interface ───────────────────────────────────────────────────────

abstract class Analytics {
  void event(String name, {Map<String, Object?> props = const {}});
  void screen(String name, {Map<String, Object?> props = const {}});
  void identify(String uid, {Map<String, Object?> props = const {}});
  void reset();
}

// ── Performance monitor interface ─────────────────────────────────────────────

abstract class PerfSpan {
  void finish({int? statusCode});
  void setTag(String key, String value);
  void setData(String key, Object? value);
}

abstract class PerfMonitor {
  PerfSpan startSpan(String name, {String? operation, String? description});
}

// ── Event name constants ──────────────────────────────────────────────────────
/// Centralised event names so typos are caught at compile time.
abstract class AnalyticsEvents {
  static const appOpen            = 'app_open';
  static const signIn             = 'sign_in';
  static const signUp             = 'sign_up';
  static const signOut            = 'sign_out';
  static const createMochi        = 'create_mochi';
  static const uploadNote         = 'upload_note';
  static const uploadDuplicate    = 'upload_duplicate';
  static const firstChat          = 'first_chat';
  static const messageSent        = 'message_sent';
  static const quizSubmit         = 'quiz_submit';
  static const quizComplete       = 'quiz_complete';
  static const flashcardRated     = 'flashcard_rated';
  static const paywallView        = 'paywall_view';
  static const subscribe          = 'subscribe';
  static const trialStart         = 'trial_start';
  static const errorShown         = 'error_shown';
  static const retryTapped        = 'retry_tapped';
  static const guideModeToggle    = 'guide_mode_toggle';
  static const brainMapView       = 'brain_map_view';
  static const photoQuestion      = 'photo_question';
}
