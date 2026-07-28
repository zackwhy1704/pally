import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pally/app/api_client.dart';
import 'package:pally/core/i18n/app_languages.dart';
import 'package:pally/core/i18n/locale_controller.dart';
import 'package:pally/features/settings/widgets/language_picker_sheet.dart';
import 'package:pally/l10n/app_localizations.dart';

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

Future<ProviderContainer> _open(WidgetTester tester) async {
  final container = ProviderContainer(overrides: [
    dioProvider.overrideWithValue(Dio()..httpClientAdapter = _StubAdapter()),
    initialLocaleProvider.overrideWithValue(const Locale('en')),
  ]);
  addTearDown(container.dispose);

  await tester.pumpWidget(UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (ctx) => Center(
            child: ElevatedButton(
              onPressed: () => LanguagePickerSheet.show(ctx),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  ));

  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return container;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('lists every registry language by its endonym', (tester) async {
    await _open(tester);
    for (final lang in AppLanguages.all) {
      expect(find.text(lang.endonym), findsWidgets,
          reason: '${lang.code} (${lang.endonym}) must appear in the picker');
    }
  });

  testWidgets('picking a language updates the controller and persists',
      (tester) async {
    final container = await _open(tester);
    expect(container.read(localeControllerProvider).languageCode, 'en');

    await tester.tap(find.text(AppLanguages.chinese.endonym));
    await tester.pumpAndSettle();

    // Applied live…
    expect(container.read(localeControllerProvider).languageCode, 'zh');
    // …and the sheet dismissed itself.
    expect(find.text(AppLanguages.chinese.endonym), findsNothing);
    // …and persisted locally.
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(localePrefsKey), 'zh');
  });

  testWidgets('shows the two-axes subtitle (UI ≠ teaching language)',
      (tester) async {
    await _open(tester);
    // English template copy makes the distinction explicit; assert the key
    // clause is present so the reassurance can't silently regress.
    expect(find.textContaining('does not change'), findsOneWidget);
  });
}
