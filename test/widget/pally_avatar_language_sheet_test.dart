import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/ui/pally_avatar_language_sheet.dart';
import 'package:pally/l10n/app_localizations.dart';
import 'package:pally/shared/models/avatar.dart';
import 'package:pally/shared/models/mochi_character.dart';

/// The mobile equivalent of memoly's EditClassModal language control — a
/// per-avatar settings sheet so an avatar STUCK on 'en' (every avatar created
/// before the create-tutor wizard gained a language step) has a path to
/// Chinese content. Pins the API-call UX contract: disabled until changed,
/// disabled while saving, persistent inline error + Retry on failure, pop(true)
/// on success (never a silent no-op either way).

Avatar _avatar({String? contentLanguage}) => Avatar(
      id: 'av-1',
      name: 'Fluffy',
      character: MochiCharacter.pencil,
      subject: 'Maths',
      contentLanguage: contentLanguage,
    );

class _PatchAdapter implements HttpClientAdapter {
  _PatchAdapter({this.fail = false});
  final bool fail;
  Map<String, dynamic>? lastBody;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.path.contains('/content-language')) {
      lastBody = options.data as Map<String, dynamic>;
    }
    if (fail) {
      return ResponseBody.fromString('{"error":"server error"}', 500,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType]
          });
    }
    if (options.method == 'GET') {
      return ResponseBody.fromString(jsonEncode({'avatars': []}), 200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType]
          });
    }
    return ResponseBody.fromString(
      jsonEncode({
        'id': 'av-1',
        'name': 'Fluffy',
        'characterType': 'PENCIL',
        'subject': 'MATHS',
        'contentLanguage': lastBody?['contentLanguage'],
      }),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType]
      },
    );
  }
}

Widget _harness(Avatar avatar, Dio dio) => ProviderScope(
      overrides: [dioProvider.overrideWithValue(dio)],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: Builder(builder: (context) {
          return Center(
            child: ElevatedButton(
              onPressed: () => PallyAvatarLanguageSheet.show(
                  context: context, avatar: avatar),
              child: const Text('open'),
            ),
          );
        })),
      ),
    );

void main() {
  testWidgets('shows the en default selected when the avatar has no '
      'contentLanguage yet (an avatar created before this fix)', (t) async {
    final adapter = _PatchAdapter();
    final dio = Dio()..httpClientAdapter = adapter;
    await t.pumpWidget(_harness(_avatar(), dio));
    await t.tap(find.text('open'));
    await t.pumpAndSettle();

    final englishChip =
        t.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'English'));
    expect(englishChip.selected, isTrue);
    final chineseChip =
        t.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, '中文'));
    expect(chineseChip.selected, isFalse);
  });

  testWidgets('Save is disabled until a DIFFERENT language is picked',
      (t) async {
    final adapter = _PatchAdapter();
    final dio = Dio()..httpClientAdapter = adapter;
    await t.pumpWidget(_harness(_avatar(contentLanguage: 'en'), dio));
    await t.tap(find.text('open'));
    await t.pumpAndSettle();

    final saveButton =
        t.widget<FilledButton>(find.widgetWithText(FilledButton, 'Save'));
    expect(saveButton.onPressed, isNull,
        reason: 'no change yet — Save must not fire a no-op PATCH');

    await t.tap(find.widgetWithText(ChoiceChip, '中文'));
    await t.pumpAndSettle();
    final saveButtonAfter =
        t.widget<FilledButton>(find.widgetWithText(FilledButton, 'Save'));
    expect(saveButtonAfter.onPressed, isNotNull);
  });

  testWidgets('picking 中文 + Save PATCHes contentLanguage:"zh" and pops true',
      (t) async {
    final adapter = _PatchAdapter();
    final dio = Dio()..httpClientAdapter = adapter;
    await t.pumpWidget(_harness(_avatar(contentLanguage: 'en'), dio));
    await t.tap(find.text('open'));
    await t.pumpAndSettle();

    await t.tap(find.widgetWithText(ChoiceChip, '中文'));
    await t.pumpAndSettle();
    await t.tap(find.widgetWithText(FilledButton, 'Save'));
    await t.pumpAndSettle();

    expect(adapter.lastBody, isNotNull);
    expect(adapter.lastBody!['contentLanguage'], 'zh');
    // The sheet closed (popped true) — its content no longer on screen.
    expect(find.text('Teaching language'), findsNothing);
  });

  testWidgets('a PATCH failure shows a PERSISTENT inline error + Retry — '
      'never a silent no-op or toast-only', (t) async {
    final adapter = _PatchAdapter(fail: true);
    final dio = Dio()..httpClientAdapter = adapter;
    await t.pumpWidget(_harness(_avatar(contentLanguage: 'en'), dio));
    await t.tap(find.text('open'));
    await t.pumpAndSettle();

    await t.tap(find.widgetWithText(ChoiceChip, '中文'));
    await t.pumpAndSettle();
    await t.tap(find.widgetWithText(FilledButton, 'Save'));
    await t.pumpAndSettle();

    expect(find.text('Could not save the teaching language. Please try again.'),
        findsOneWidget);
    // Sheet stays open — the failure must not silently discard the pick.
    expect(find.text('Teaching language'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Retry'), findsOneWidget);
  });
}
