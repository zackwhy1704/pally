import 'dart:convert';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/i18n/locale_controller.dart';
import 'package:pally/features/create_tutor/presentation/create_tutor_view_model.dart';
import 'package:pally/shared/models/mochi_character.dart';

/// Pins the root-cause fix: mobile's create-tutor wizard sends NO
/// content_language at all, so every mobile-created avatar silently defaults
/// to the backend's 'en' regardless of the device/app locale. This test file
/// asserts (a) the wizard defaults to the app's CURRENTLY RESOLVED UI locale,
/// not a hardcoded 'en', and (b) the create request actually carries
/// contentLanguage — the fields a bug in either place would leave silently
/// wrong with no test failure.

/// Captures the outgoing request body so we can assert on it directly, rather
/// than trusting a mocked return value — the fix under test IS the request
/// body, so the test must inspect the real serialized JSON that would hit the
/// wire (mirrors the _ParentLinkAdapter pattern already used for this API).
class _CapturingAdapter implements HttpClientAdapter {
  Map<String, dynamic>? lastBody;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastBody = options.data as Map<String, dynamic>;
    return ResponseBody.fromString(
      jsonEncode({
        'id': 'av-1',
        'name': lastBody!['name'],
        'characterType': lastBody!['characterType'],
        'subject': lastBody!['subject'],
      }),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

ProviderContainer _container({required String uiLanguageCode}) {
  final dio = Dio()..httpClientAdapter = _CapturingAdapter();
  final container = ProviderContainer(overrides: [
    dioProvider.overrideWithValue(dio),
    localeControllerProvider
        .overrideWith(() => _FixedLocaleController(uiLanguageCode)),
  ]);
  addTearDown(container.dispose);
  return container;
}

class _FixedLocaleController extends LocaleController {
  _FixedLocaleController(this.code);
  final String code;
  @override
  Locale build() => Locale(code);
}

void main() {
  test('defaults contentLanguage to the app\'s CURRENTLY RESOLVED UI locale, '
      'not a hardcoded "en"', () {
    final c = _container(uiLanguageCode: 'zh');
    final state = c.read(createTutorViewModelProvider);
    expect(state.contentLanguage, 'zh',
        reason: 'a phone already showing 中文 should default new Mochis to '
            'Chinese content, not silently to English');
  });

  test('defaults to en when the UI is already in English', () {
    final c = _container(uiLanguageCode: 'en');
    final state = c.read(createTutorViewModelProvider);
    expect(state.contentLanguage, 'en');
  });

  test('setContentLanguage overrides the default', () {
    final c = _container(uiLanguageCode: 'en');
    final notifier = c.read(createTutorViewModelProvider.notifier);
    notifier.setContentLanguage('zh');
    expect(c.read(createTutorViewModelProvider).contentLanguage, 'zh');
  });

  test('createAvatar() SENDS contentLanguage:"zh" in the POST body — '
      'the actual root-cause fix, not just VM state', () async {
    final adapter = _CapturingAdapter();
    final dio = Dio()..httpClientAdapter = adapter;
    final container = ProviderContainer(overrides: [
      dioProvider.overrideWithValue(dio),
      localeControllerProvider
          .overrideWith(() => _FixedLocaleController('zh')),
    ]);
    addTearDown(container.dispose);

    final notifier = container.read(createTutorViewModelProvider.notifier);
    notifier
      ..selectCharacter(MochiCharacter.pencil)
      ..setName('Fluffy')
      ..setSubject('Maths');

    final id = await notifier.createAvatar();

    expect(id, isNotNull);
    expect(adapter.lastBody, isNotNull,
        reason: 'no request reached the adapter — createAvatar() bailed out');
    expect(adapter.lastBody!['contentLanguage'], 'zh',
        reason: 'this is the exact field the pipeline reads to generate zh '
            'content; if this is null/absent, the backend silently falls '
            'back to en regardless of the device locale');
  });

  test('createAvatar() sends contentLanguage:"en" when the default was never '
      'overridden', () async {
    final adapter = _CapturingAdapter();
    final dio = Dio()..httpClientAdapter = adapter;
    final container = ProviderContainer(overrides: [
      dioProvider.overrideWithValue(dio),
      localeControllerProvider
          .overrideWith(() => _FixedLocaleController('en')),
    ]);
    addTearDown(container.dispose);

    final notifier = container.read(createTutorViewModelProvider.notifier);
    notifier
      ..selectCharacter(MochiCharacter.pencil)
      ..setName('Rex')
      ..setSubject('Science');

    await notifier.createAvatar();

    expect(adapter.lastBody!['contentLanguage'], 'en');
  });
}
