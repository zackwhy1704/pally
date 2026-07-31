import 'dart:async';
import 'dart:ui' show Locale;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pally/app/api_client.dart';
import 'package:pally/core/i18n/app_languages.dart';
import 'package:pally/core/utils/logger.dart';
import 'package:pally/features/progress/presentation/achievements_provider.dart';
import 'package:pally/features/progress/presentation/level_roadmap_provider.dart';
import 'package:pally/features/progress/presentation/progress_view_model.dart';

/// shared_preferences key holding the user's chosen UI-language code
/// ('en', 'zh', …). Device-level, read ONCE at bootstrap (see main.dart) — the
/// same offline-first shape as the app's other device prefs. Absent until the
/// user picks a language.
const localePrefsKey = 'ui_locale_code_v1';

/// The persisted UI-language code, or null if the user has never chosen one.
/// Called at bootstrap; kept a plain function (not a provider) so main() can
/// resolve the start locale before the first frame without a provider read.
String? readPersistedLocaleCode(SharedPreferences prefs) =>
    prefs.getString(localePrefsKey);

/// The locale the app STARTS in, resolved once at bootstrap through the
/// registry's fallback chain (persisted → device → English) and injected via an
/// override in main(). The default here (English) covers widget tests and any
/// un-overridden [ProviderScope]. Kept separate from [LocaleController] so
/// [LocaleController.build] stays synchronous — no async prefs read on frame 1.
final initialLocaleProvider =
    Provider<Locale>((_) => AppLanguages.fallback.locale);

/// Drives `MaterialApp.locale`: the single writable home of the UI language.
///
/// * **Local write wins immediately** (offline-first): [setLanguage] updates
///   state and persists to shared_preferences before anything else.
/// * **Server sync is best-effort** and MUST NOT block or throw into the UI —
///   the choice is mirrored to the backend `preferred_locale` so it follows the
///   user across devices, but a failed PATCH never reverts the local choice.
/// * Only accepts languages in [AppLanguages]; an unknown code cannot be set.
///
/// This is UI chrome only. It is a DIFFERENT axis from an avatar's
/// `content_language` (what the AI generates in) — switching the UI language
/// never re-translates existing lessons.
class LocaleController extends Notifier<Locale> {
  @override
  Locale build() => ref.read(initialLocaleProvider);

  /// The currently selected [AppLanguage], resolved from state through the
  /// registry so it is always a known entry (falls back to English defensively).
  AppLanguage get selected =>
      AppLanguages.byCode(state.languageCode) ?? AppLanguages.fallback;

  /// Switch the UI language. Re-entrant no-op when unchanged. Applies live (a
  /// `MaterialApp.locale` rebuild) — no restart, no relaunch.
  Future<void> setLanguage(AppLanguage lang) async {
    if (state == lang.locale) return; // re-entry / no-op guard
    state = lang.locale; // live rebuild (synchronous — UI updates immediately)
    // Persist locally (offline-first). Wrapped so a rare prefs failure can never
    // throw out of here: callers fire-and-forget (the UI already reflects the
    // change), so an uncaught rejection would otherwise become async noise.
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(localePrefsKey, lang.code);
    } catch (e) {
      appLog.w('[locale] persist failed (non-fatal, applied for session): $e');
    }
    _syncToServer(lang.code); // best-effort, non-blocking
  }

  /// Mirror the choice to the server so it follows the user across devices.
  /// Fire-and-forget: never awaited, never surfaces an error to the UI (local
  /// prefs are the source of truth for the UI language).
  /// Push the CURRENT locale to the server. Call once auth is established (e.g.
  /// right after account creation) so a language chosen PRE-auth — when the
  /// best-effort sync in [setLanguage] would have 401'd with no token — is
  /// mirrored to `preferred_locale`. Best-effort, never throws, safe to ignore.
  Future<void> reconcileToServer() => _patchLocale(state.languageCode);

  void _syncToServer(String code) => unawaited(_patchLocale(code));

  Future<void> _patchLocale(String code) async {
    // Best-effort mirror to preferred_locale. Generic catch (not `on
    // DioException`): this is fire-and-forget background sync, so ANY failure —
    // timeout, socket, mapping — is swallowed and logged, never surfaced. It
    // maps nothing to a user message, so it stays out of the data-layer error
    // path the layering guard protects.
    try {
      final dio = ref.read(dioProvider);
      await dio.patch<void>(
        '/api/v1/auth/settings/locale',
        data: {'preferredLocale': code},
      );
      // The achievement/level-roadmap/progress endpoints resolve their TEXT
      // (achievement names, reward labels, nextUnlockLabel) from this SAME
      // preferred_locale server-side. If any of those screens were ever
      // fetched once before this switch, their cached response is now
      // stale-language — nothing else invalidates them (only pull-to-refresh,
      // retry-after-error, or an XP-earning action do), so a language switch
      // must. Invalidated AFTER the PATCH succeeds, not before: invalidating
      // first would race the re-fetch against the server not yet knowing the
      // new preferred_locale, returning the OLD language again.
      _invalidateLocaleDependentProviders();
    } catch (e) {
      appLog.w('[locale] server sync failed (non-fatal, local kept): $e');
    }
  }

  /// Every provider whose backing endpoint resolves text from the server's
  /// `preferred_locale` (as opposed to the client's own ARB, which rebuilds
  /// automatically on a `Locale` change, or an avatar's independent
  /// `content_language`, which this UI-chrome switch never touches).
  void _invalidateLocaleDependentProviders() {
    ref.invalidate(achievementsProvider);
    ref.invalidate(levelRoadmapProvider);
    ref.invalidate(progressViewModelProvider);
  }
}

/// The app's current UI [Locale]. Watch it to drive `MaterialApp.locale`;
/// read `.notifier` in a callback to change the language.
final localeControllerProvider =
    NotifierProvider<LocaleController, Locale>(LocaleController.new);
