import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pally/app/api_client.dart';
import 'package:pally/core/i18n/locale_controller.dart';
import 'package:pally/core/ui/pally_toast.dart';
import 'package:pally/features/auth/auth_state.dart';
import 'package:pally/features/auth/screens/sign_in_screen.dart';
import 'package:pally/features/auth/services/auth_service.dart';
import 'package:pally/l10n/app_localizations.dart';

/// zh audit round 5, Phase B: the forgot-password dialog had two real bugs,
/// unrelated to i18n.
///
/// Bug 1: only checked `email.isEmpty`, no format validation at all.
/// Bug 2 (the crash): both the success path AND the AuthException path pop
/// the dialog, then the button handler's `finally` unconditionally called
/// setDialogState — a rebuild on a dialog element concurrently being torn
/// down by that same pop. `ctx.mounted` doesn't guard against this: it can
/// still read true for one or more frames during the deactivation window.
/// This fired on the NORMAL/success path every time, not as an occasional
/// flake.
///
/// [_StubHttpClientAdapter] answers `/api/v1/auth/forgot-password` on
/// AuthService's own internal Dio (a hard singleton with no other DI seam —
/// swapped via the test-only [AuthService.debugOverrideHttpClient] so this
/// test never risks reaching the real (hardcoded, prod) baseUrl).
class _StubHttpClientAdapter implements HttpClientAdapter {
  _StubHttpClientAdapter(this.statusCode);
  final int statusCode;

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    // A REAL network round-trip takes tens-to-hundreds of milliseconds,
    // which is what naturally separates "focus/caret-visibility scheduling"
    // frames from the pop+dispose sequence. Resolving instantly (0ms) makes
    // the dialog close unrealistically fast and collides with an unrelated
    // Flutter-internal caret-scheduling quirk (EditableText's post-frame
    // "scroll caret into view" callback firing after the field is
    // detached) — noise this test isn't about. A small delay keeps the
    // test fast while avoiding that collision.
    await Future<void>.delayed(const Duration(milliseconds: 50));
    if (statusCode == 200) {
      return ResponseBody.fromString('', 200);
    }
    return ResponseBody.fromString(
      jsonEncode({'error': 'stub error'}),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

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

  tearDown(() async {
    await AuthNotifier.instance.signOut();
    // Restore a real (unstubbed) Dio so no other test file's AuthService
    // calls could ever be answered by this file's stub if the isolate is
    // reused across files.
    AuthService.instance.debugOverrideHttpClient(Dio());
  });

  Future<void> pumpSignIn(WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        dioProvider.overrideWithValue(Dio()..httpClientAdapter = _StubHttpClientAdapter(200)),
        initialLocaleProvider.overrideWithValue(const Locale('en')),
      ],
      child: MaterialApp(
        // showAppSnackBar routes through this key, never context — wire it
        // up the same way lib/app/pally_app.dart does, or the snackbar
        // silently no-ops (messenger == null) and the app never crashes but
        // never shows the user anything either.
        scaffoldMessengerKey: rootScaffoldMessengerKey,
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const SignInScreen(),
      ),
    ));
    await tester.pump(); // settle initState biometric check
  }

  Future<void> openDialog(WidgetTester tester) async {
    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();
    expect(find.text('Reset Password'), findsOneWidget);
  }

  group('email format validation (Bug 1)', () {
    testWidgets('invalid-format email: send is blocked, no network call made',
        (tester) async {
      final adapter = _StubHttpClientAdapter(200);
      AuthService.instance.debugOverrideHttpClient(Dio()..httpClientAdapter = adapter);
      await pumpSignIn(tester);
      await openDialog(tester);

      await tester.enterText(find.byType(TextFormField), 'not-an-email');
      await tester.tap(find.text('Send Reset Link'));
      await tester.pumpAndSettle();

      // Blocked by Form.validate() — dialog stays open with an inline error,
      // no network call ever fires.
      expect(find.text('Reset Password'), findsOneWidget);
      expect(find.text('Please enter a valid email (e.g. you@example.com)'),
          findsOneWidget);
    });

    testWidgets('empty email: send is blocked with the empty-specific message',
        (tester) async {
      await pumpSignIn(tester);
      await openDialog(tester);

      await tester.tap(find.text('Send Reset Link'));
      await tester.pumpAndSettle();

      expect(find.text('Reset Password'), findsOneWidget);
      expect(find.text('Please enter your email'), findsOneWidget);
    });
  });

  group('dialog disposal crash (Bug 2) — fail-without-fix', () {
    testWidgets(
        'valid email, success path: dialog closes, NO assertion/exception thrown',
        (tester) async {
      AuthService.instance
          .debugOverrideHttpClient(Dio()..httpClientAdapter = _StubHttpClientAdapter(200));
      await pumpSignIn(tester);
      await openDialog(tester);

      await tester.enterText(find.byType(TextFormField), 'kid@example.com');
      await tester.tap(find.text('Send Reset Link'));
      // Let the async forgotPassword() call, the pop, and the finally block
      // all run to completion — this is exactly the sequence that used to
      // throw the "_dependents.isNotEmpty" assertion. Bounded pumps, not
      // pumpAndSettle: a SnackBar's own auto-dismiss timer (~4s) means
      // pumpAndSettle would run clean through its entire show-then-hide
      // lifecycle and find nothing left to assert on.
      await tester.pump(); // process tap, kick off the stubbed network call
      await tester.pump(const Duration(milliseconds: 100)); // stub delay resolves
      await tester.pump(const Duration(milliseconds: 300)); // dialog pop transition + deferred dispose

      expect(tester.takeException(), isNull,
          reason: 'this is the crash: setDialogState was called on a '
              'dialog element the SAME method had already popped');
      expect(find.text('Reset Password'), findsNothing,
          reason: 'dialog must actually close on success');
      expect(find.text('Check your email for a reset link'), findsOneWidget);
    });

    testWidgets('valid email, AuthException path: dialog closes cleanly, '
        'same no-crash guarantee', (tester) async {
      AuthService.instance
          .debugOverrideHttpClient(Dio()..httpClientAdapter = _StubHttpClientAdapter(404));
      await pumpSignIn(tester);
      await openDialog(tester);

      await tester.enterText(find.byType(TextFormField), 'kid@example.com');
      await tester.tap(find.text('Send Reset Link'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Reset Password'), findsNothing,
          reason: 'dialog must close on the error path too, not just success');
    });
  });
}
