import 'dart:ui' show Locale, TextDirection;

/// A language the app UI can render in.
///
/// One immutable value per supported UI language. This type is the SINGLE
/// SOURCE OF TRUTH for the client's language set — everything derives from
/// [AppLanguages.all]:
///   * `MaterialApp.supportedLocales` = [AppLanguages.locales]
///   * the language picker renders [AppLanguages.all] (never a hand-written list)
///   * persistence validates a stored code against the registry
///   * the geometry / CTA test harness iterates [AppLanguages.all]
///
/// Adding a language (say Malay) must be exactly: append one [AppLanguage] entry
/// here + add `app_ms.arb` + (backend) one reviewed prompt directive. If a new
/// language forces a change ANYWHERE else, the abstraction has leaked — treat
/// that as a bug in this file, not a reason to branch at the call site.
///
/// NOTE: [contentLanguage] (what the AI generates in, on the avatar) is a
/// SEPARATE axis and is NOT modelled here — this registry is UI chrome only.
class AppLanguage {
  const AppLanguage({
    required this.code,
    required this.endonym,
    required this.locale,
    this.textDirection = TextDirection.ltr,
  });

  /// BCP-47 primary subtag, e.g. `en`, `zh`. Matches the backend's
  /// `preferred_locale` values and the ARB file suffix (`app_<code>.arb`).
  final String code;

  /// The language's name IN that language ("English", "中文"). Shown in the
  /// picker so a speaker recognises their own language regardless of the
  /// current UI language. Deliberately NOT translated per-locale.
  final String endonym;

  /// The [Locale] handed to `MaterialApp.locale` / `supportedLocales`.
  final Locale locale;

  /// Carried as data (LTR for every language today) so that adding an RTL
  /// language later is a registry edit, not surgery at every layout site.
  final TextDirection textDirection;
}

/// The registry. Order is display order in the picker. `en` first = the
/// guaranteed fallback (see [resolve]).
class AppLanguages {
  AppLanguages._();

  static const AppLanguage english = AppLanguage(
    code: 'en',
    endonym: 'English',
    locale: Locale('en'),
  );

  static const AppLanguage chinese = AppLanguage(
    code: 'zh',
    endonym: '中文',
    locale: Locale('zh'),
  );

  /// Every supported UI language. Append here to add one.
  static const List<AppLanguage> all = [english, chinese];

  /// The guaranteed fallback — always present, always the last resort.
  static const AppLanguage fallback = english;

  /// `supportedLocales` for `MaterialApp`, derived — never hand-listed.
  static List<Locale> get locales => [for (final l in all) l.locale];

  /// The registry entry for [code], or null if unsupported. Case-insensitive
  /// on the primary subtag; ignores any region/script suffix (`zh-Hans-SG`
  /// still resolves to `zh`).
  static AppLanguage? byCode(String? code) {
    if (code == null) return null;
    final primary = code.split(RegExp('[-_]')).first.toLowerCase();
    for (final l in all) {
      if (l.code == primary) return l;
    }
    return null;
  }

  /// Fallback chain, explicit and total (mirrors the backend's fail-safe
  /// posture where an unknown language degrades rather than throws):
  ///   requested (if in registry) → device (if in registry) → [fallback].
  /// Never returns null; an unknown/garbage code degrades to English rather
  /// than crashing or half-localising a screen.
  static AppLanguage resolve({String? requested, String? device}) {
    return byCode(requested) ?? byCode(device) ?? fallback;
  }
}
