import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/features/auth/auth_state.dart';
import 'package:pally/features/settings/presentation/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// FIX B/C: the settings surface trim removes the (broken) 'Replay feature tour' row
/// and the half-built test-date editor/rows, while keeping every wired control. This
/// renders SettingsScreen and asserts the two removed surfaces are gone and neighbours
/// remain.
class _EmptyAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(RequestOptions options,
          Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async =>
      ResponseBody.fromString(jsonEncode(<String, dynamic>{}), 200, headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType]
      });
  @override
  void close({bool force = false}) {}
}

void main() {
  testWidgets('settings drops Replay-tour + Test-dates, keeps wired controls',
      (tester) async {
    // Swallow ONLY the pre-existing, benign "ListTile background/ink may be invisible"
    // debug lint (the app's _SettingsCard wraps ListTiles in a DecoratedBox) — it is
    // unrelated to this trim; any other error still fails the test.
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.exceptionAsString().contains('ink splashes may be invisible')) {
        return;
      }
      originalOnError?.call(details);
    };
    addTearDown(() => FlutterError.onError = originalOnError);

    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1200, 6000); // tall: build the whole column
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final dio = Dio()..httpClientAdapter = _EmptyAdapter();
    await tester.pumpWidget(ProviderScope(
      overrides: [
        dioProvider.overrideWithValue(dio),
        authStateProvider
            .overrideWith((ref) => const AuthState(childName: 'Test')),
      ],
      child: const MaterialApp(home: SettingsScreen()),
    ));
    // Let initState async loads settle without pumpAndSettle (subscription sections spin).
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Removed:
    expect(find.text('Replay feature tour'), findsNothing);
    expect(find.text('Test dates'), findsNothing);
    expect(find.text('Set date'), findsNothing);

    // Kept (proves the surrounding cards still render):
    expect(find.text('Why Apalchi is different'), findsOneWidget); // About card intact
    expect(find.text('Learning style'), findsOneWidget);
    expect(find.text('Biometric Login'), findsOneWidget);
  });
}
