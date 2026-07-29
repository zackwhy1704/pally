import 'dart:typed_data';
import 'dart:ui' show Locale;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pally/app/api_client.dart';
import 'package:pally/core/i18n/locale_controller.dart';
import 'package:pally/features/auth/auth_state.dart';
import 'package:pally/features/auth/screens/sign_in_screen.dart';
import 'package:pally/l10n/app_localizations.dart';

/// Proves the sign-in screen actually renders the selected language end-to-end
/// (ARB → generated getter → widget), and that the B4 language selector is on it.
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const secureChannel =
      MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  final store = <String, String>{};

  setUp(() {
    store.clear();
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureChannel, (call) async {
      final args = (call.arguments as Map?) ?? {};
      switch (call.method) {
        case 'read':
          return store[args['key']];
        case 'write':
          store[args['key'] as String] = args['value'] as String;
          return null;
        case 'readAll':
          return Map<String, String>.from(store);
        case 'containsKey':
          return store.containsKey(args['key']);
        case 'delete':
          store.remove(args['key']);
          return null;
        case 'deleteAll':
          store.clear();
          return null;
      }
      return null;
    });
  });

  tearDown(() async => AuthNotifier.instance.signOut());

  Future<void> pump(WidgetTester tester, Locale locale) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        dioProvider.overrideWithValue(Dio()..httpClientAdapter = _StubAdapter()),
        initialLocaleProvider.overrideWithValue(locale),
      ],
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const SignInScreen(),
      ),
    ));
    await tester.pump(); // settle initState biometric check
  }

  testWidgets('renders Chinese strings at zh locale', (tester) async {
    await pump(tester, const Locale('zh'));
    expect(find.text('登录'), findsOneWidget); // Sign In button
    expect(find.text('欢迎回来！👋'), findsOneWidget); // welcome
    expect(find.text('创建账户 ✨'), findsOneWidget); // Create Account footer
  });

  testWidgets('renders English strings at en locale', (tester) async {
    await pump(tester, const Locale('en'));
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Create Account ✨'), findsOneWidget);
  });

  testWidgets('the B4 language selector is present (both endonyms)',
      (tester) async {
    await pump(tester, const Locale('en'));
    // Endonyms are NOT translated — the selector shows them regardless of locale.
    expect(find.text('English'), findsWidgets);
    expect(find.text('中文'), findsOneWidget);
  });
}
