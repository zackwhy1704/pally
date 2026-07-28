import 'dart:typed_data';
import 'dart:ui' show Locale;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pally/app/api_client.dart';
import 'package:pally/core/i18n/app_languages.dart';
import 'package:pally/core/i18n/locale_controller.dart';

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
}
