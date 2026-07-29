import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pally/app/api_client.dart';
import 'package:pally/core/i18n/app_languages.dart';
import 'package:pally/core/i18n/locale_controller.dart';
import 'package:pally/shared/widgets/language_selector.dart';

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

Future<ProviderContainer> _pump(WidgetTester tester,
    {String initial = 'en'}) async {
  final container = ProviderContainer(overrides: [
    dioProvider.overrideWithValue(Dio()..httpClientAdapter = _StubAdapter()),
    initialLocaleProvider.overrideWithValue(Locale(initial)),
  ]);
  addTearDown(container.dispose);
  await tester.pumpWidget(UncontrolledProviderScope(
    container: container,
    child: const MaterialApp(home: Scaffold(body: Center(child: LanguageSelector()))),
  ));
  return container;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('renders one pill per registry language by endonym',
      (tester) async {
    await _pump(tester);
    for (final lang in AppLanguages.all) {
      expect(find.text(lang.endonym), findsOneWidget,
          reason: '${lang.code} pill (${lang.endonym}) must render');
    }
  });

  testWidgets('tapping a language applies it live and persists', (tester) async {
    final container = await _pump(tester, initial: 'en');
    expect(container.read(localeControllerProvider).languageCode, 'en');

    await tester.tap(find.text(AppLanguages.chinese.endonym));
    // Drain the pill animation + the fire-and-forget server-sync Timer that Dio
    // schedules, so no timer outlives the widget tree at teardown.
    await tester.pumpAndSettle();

    expect(container.read(localeControllerProvider).languageCode, 'zh');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(localePrefsKey), 'zh');
  });

  testWidgets('reflects the current language on load (device pre-select)',
      (tester) async {
    // Bootstrap resolved to zh (e.g. a zh device) → the zh pill starts selected.
    final container = await _pump(tester, initial: 'zh');
    expect(container.read(localeControllerProvider).languageCode, 'zh');
    // Both options remain visible and tappable (never auto-committed elsewhere).
    expect(find.text(AppLanguages.english.endonym), findsOneWidget);
  });
}
