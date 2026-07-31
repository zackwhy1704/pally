import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' show Locale;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pally/app/api_client.dart';
import 'package:pally/core/i18n/app_languages.dart';
import 'package:pally/core/i18n/locale_controller.dart';
import 'package:pally/features/progress/presentation/achievements_provider.dart';
import 'package:pally/features/progress/presentation/level_roadmap_provider.dart';
import 'package:pally/features/progress/presentation/progress_view_model.dart';

/// Swallows the best-effort server sync so a unit test never touches the network.
class _StubAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(RequestOptions options,
          Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async =>
      ResponseBody.fromString('{}', 200, headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      });
  @override
  void close({bool force = false}) {}
}

/// Records the requests the controller makes so the mirror can be asserted.
class _RecordingAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];
  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    requests.add(options);
    return ResponseBody.fromString('{}', 200, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }

  @override
  void close({bool force = false}) {}
}

ProviderContainer _container({Locale? initial}) => ProviderContainer(
      overrides: [
        dioProvider.overrideWithValue(Dio()..httpClientAdapter = _StubAdapter()),
        if (initial != null) initialLocaleProvider.overrideWithValue(initial),
      ],
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('starts at the injected initial locale (bootstrap override)', () {
    final c = _container(initial: const Locale('zh'));
    addTearDown(c.dispose);
    expect(c.read(localeControllerProvider), const Locale('zh'));
    expect(c.read(localeControllerProvider.notifier).selected,
        AppLanguages.chinese);
  });

  test('defaults to English when no initial locale is overridden', () {
    final c = _container();
    addTearDown(c.dispose);
    expect(c.read(localeControllerProvider), AppLanguages.fallback.locale);
  });

  test('setLanguage updates state live AND persists locally', () async {
    final c = _container();
    addTearDown(c.dispose);

    await c.read(localeControllerProvider.notifier)
        .setLanguage(AppLanguages.chinese);

    expect(c.read(localeControllerProvider).languageCode, 'zh');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(localePrefsKey), 'zh',
        reason: 'local write wins immediately (offline-first)');
  });

  test('re-entry guard: setting the current language does not re-persist',
      () async {
    final c = _container(initial: const Locale('en'));
    addTearDown(c.dispose);

    // Pre-seed a DIFFERENT persisted value; a no-op setLanguage must not touch it.
    SharedPreferences.setMockInitialValues({localePrefsKey: 'sentinel'});

    await c.read(localeControllerProvider.notifier)
        .setLanguage(AppLanguages.english); // == current state → early return

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(localePrefsKey), 'sentinel',
        reason: 'unchanged language must short-circuit before persisting');
  });

  test('switching back and forth ends on the last choice', () async {
    final c = _container();
    addTearDown(c.dispose);
    final ctrl = c.read(localeControllerProvider.notifier);

    await ctrl.setLanguage(AppLanguages.chinese);
    await ctrl.setLanguage(AppLanguages.english);

    expect(c.read(localeControllerProvider), AppLanguages.english.locale);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(localePrefsKey), 'en');
  });

  test('reconcileToServer PATCHes preferred_locale with the current language',
      () async {
    // The mirror called after account creation: a language chosen pre-auth (zh)
    // must reach PATCH /auth/settings/locale once a token exists.
    final rec = _RecordingAdapter();
    final c = ProviderContainer(overrides: [
      dioProvider.overrideWithValue(Dio()..httpClientAdapter = rec),
      initialLocaleProvider.overrideWithValue(const Locale('zh')),
    ]);
    addTearDown(c.dispose);

    await c.read(localeControllerProvider.notifier).reconcileToServer();

    expect(rec.requests, hasLength(1));
    expect(rec.requests.single.path, '/api/v1/auth/settings/locale');
    expect(rec.requests.single.method, 'PATCH');
    expect(rec.requests.single.data, {'preferredLocale': 'zh'});
  });

  // ── zh audit round 4, Phase B: provider invalidation on language switch ──

  group('locale-dependent provider invalidation', () {
    test(
        'a locale switch invalidates achievements/level-roadmap/progress '
        'WITHOUT pull-to-refresh — the fail-without-fix case', () async {
      final adapter = _LocaleAwareAdapter();
      final c = ProviderContainer(overrides: [
        dioProvider.overrideWithValue(Dio()..httpClientAdapter = adapter),
        initialLocaleProvider.overrideWithValue(const Locale('en')),
      ]);
      addTearDown(c.dispose);

      // Hold each provider ALIVE across the switch — these are AutoDispose
      // providers; without an active listener they'd tear down and refetch
      // on every read regardless of whether setLanguage ever invalidates
      // anything, which would make this test pass for the wrong reason.
      // This mirrors the real scenario: the screen stayed mounted/cached,
      // it wasn't pull-to-refreshed.
      c.listen(achievementsProvider, (_, __) {});
      c.listen(levelRoadmapProvider, (_, __) {});
      c.listen(progressViewModelProvider, (_, __) {});

      // Warm the cache in en (simulates "visited these screens once").
      expect((await c.read(achievementsProvider.future)).achievements.first.name,
          'On a Roll');
      expect((await c.read(levelRoadmapProvider.future)).rewards.first.label,
          'New Mochi colour');
      expect((await c.read(progressViewModelProvider.future)).nextUnlockLabel,
          'New Mochi colour');

      // Switch language — no manual invalidate, no pull-to-refresh call.
      await c.read(localeControllerProvider.notifier)
          .setLanguage(AppLanguages.chinese);
      // setLanguage's server sync (and the invalidation inside it) is
      // fire-and-forget (unawaited) — flush the event queue so it lands
      // before asserting, exactly like the real (tiny, real-world) delay
      // between the PATCH firing and its completion.
      await pumpEventQueue();

      expect((await c.read(achievementsProvider.future)).achievements.first.name,
          '势头正好',
          reason: 'today, without the fix, this would still read "On a Roll" '
              '— the cached en response, never invalidated');
      expect((await c.read(levelRoadmapProvider.future)).rewards.first.label,
          '全新小伴配色');
      expect((await c.read(progressViewModelProvider.future)).nextUnlockLabel,
          '全新小伴配色');
    });

    test('switching en→zh→en returns cleanly to en content, not stale zh '
        '(the inverse does not regress)', () async {
      final adapter = _LocaleAwareAdapter();
      final c = ProviderContainer(overrides: [
        dioProvider.overrideWithValue(Dio()..httpClientAdapter = adapter),
        initialLocaleProvider.overrideWithValue(const Locale('en')),
      ]);
      addTearDown(c.dispose);
      c.listen(achievementsProvider, (_, __) {});

      expect((await c.read(achievementsProvider.future)).achievements.first.name,
          'On a Roll');

      await c.read(localeControllerProvider.notifier)
          .setLanguage(AppLanguages.chinese);
      await pumpEventQueue();
      expect((await c.read(achievementsProvider.future)).achievements.first.name,
          '势头正好');

      await c.read(localeControllerProvider.notifier)
          .setLanguage(AppLanguages.english);
      await pumpEventQueue();
      expect((await c.read(achievementsProvider.future)).achievements.first.name,
          'On a Roll',
          reason: 'switching back to en must re-fetch en content, not leave '
              'the zh response from the previous switch cached');
    });

    test('a failed server sync does not invalidate — no worse than today, '
        'and avoids invalidating into a re-fetch the server would still '
        'answer in the OLD language', () async {
      final adapter = _FailingPatchAdapter();
      final c = ProviderContainer(overrides: [
        dioProvider.overrideWithValue(Dio()..httpClientAdapter = adapter),
        initialLocaleProvider.overrideWithValue(const Locale('en')),
      ]);
      addTearDown(c.dispose);
      c.listen(achievementsProvider, (_, __) {});

      expect((await c.read(achievementsProvider.future)).achievements.first.name,
          'On a Roll');
      expect(adapter.achievementsCalls, 1);

      await c.read(localeControllerProvider.notifier)
          .setLanguage(AppLanguages.chinese);
      await pumpEventQueue();

      // The local UI language still switches (offline-first) even though the
      // server sync failed.
      expect(c.read(localeControllerProvider).languageCode, 'zh');
      // But achievements was never invalidated — no second network call.
      await c.read(achievementsProvider.future);
      expect(adapter.achievementsCalls, 1,
          reason: 'a failed PATCH must not trigger an invalidate/re-fetch — '
              'the server still doesn\'t know preferred_locale changed');
    });
  });
}

/// Serves per-endpoint responses that resolve from the SERVER'S OWN current
/// preferred_locale (tracked here as `serverLocale`, updated only when the
/// locale PATCH lands) — mirrors the real backend's SupportedLanguage.resolve
/// behavior, not a naive "first call vs the rest" counter (which would falsely
/// pass a test that returns zh forever after the first switch, regardless of
/// switching back to en).
class _LocaleAwareAdapter implements HttpClientAdapter {
  String serverLocale = 'en';
  int achievementsCalls = 0;
  int levelRoadmapCalls = 0;
  int progressCalls = 0;

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    if (options.path == '/api/v1/auth/settings/locale') {
      serverLocale = (options.data as Map)['preferredLocale'] as String;
      return _json({});
    }
    if (options.path == '/api/v1/achievements') {
      achievementsCalls++;
      final name = serverLocale == 'zh' ? '势头正好' : 'On a Roll';
      return _json({
        'achievements': [
          {
            'id': 'STREAK_3',
            'name': name,
            'description': '',
            'category': 'STREAK',
            'rarity': 'COMMON',
            'target': 3,
            'progress': 0,
            'earned': false,
          }
        ],
        'earnedCount': 0,
        'totalCount': 1,
      });
    }
    if (options.path == '/api/v1/progress/level-roadmap') {
      levelRoadmapCalls++;
      final label = serverLocale == 'zh' ? '全新小伴配色' : 'New Mochi colour';
      return _json({
        'currentLevel': 1,
        'maxLevel': 30,
        'rewards': [
          {'level': 2, 'label': label, 'kind': 'COSMETIC', 'unlocked': false}
        ],
      });
    }
    if (options.path == '/api/v1/progress') {
      progressCalls++;
      final label = serverLocale == 'zh' ? '全新小伴配色' : 'New Mochi colour';
      return _json({
        'level': 1,
        'xp': 0,
        'xpToNextLevel': 100,
        'nextUnlockLevel': 2,
        'nextUnlockLabel': label,
      });
    }
    throw StateError('unexpected path in test adapter: ${options.path}');
  }

  @override
  void close({bool force = false}) {}
}

/// Locale PATCH always fails (simulates offline/server error); achievements
/// always succeeds so the test can prove it was NOT invalidated.
class _FailingPatchAdapter implements HttpClientAdapter {
  int achievementsCalls = 0;

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    if (options.path == '/api/v1/auth/settings/locale') {
      throw DioException(requestOptions: options, type: DioExceptionType.connectionError);
    }
    if (options.path == '/api/v1/achievements') {
      achievementsCalls++;
      return _json({
        'achievements': [
          {
            'id': 'STREAK_3',
            'name': 'On a Roll',
            'description': '',
            'category': 'STREAK',
            'rarity': 'COMMON',
            'target': 3,
            'progress': 0,
            'earned': false,
          }
        ],
        'earnedCount': 0,
        'totalCount': 1,
      });
    }
    throw StateError('unexpected path in test adapter: ${options.path}');
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(Map<String, dynamic> body) => ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
