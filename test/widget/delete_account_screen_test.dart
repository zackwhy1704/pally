import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/features/account_deletion/presentation/delete_account_screen.dart';
import 'package:pally/features/account_deletion/presentation/restore_account_sheet.dart';

class _MockDio extends Mock implements Dio {}

Widget _harness(Dio dio) => ProviderScope(
      overrides: [dioProvider.overrideWithValue(dio)],
      child: const MaterialApp(home: DeleteAccountScreen()),
    );

void main() {
  setUpAll(() => registerFallbackValue(RequestOptions(path: '/')));

  testWidgets(
      'consequences copy contains no external link or price (iOS anti-steering)',
      (tester) async {
    await tester.pumpWidget(_harness(_MockDio()));

    expect(find.text('Delete your account?'), findsOneWidget);
    final allText = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data ?? '')
        .join(' ');
    expect(allText.contains('http'), isFalse);
    expect(allText.contains('www'), isFalse);
    expect(allText.contains(r'$'), isFalse);
    expect(allText.contains('£'), isFalse);
  });

  testWidgets('Continue advances to the re-auth step with a password field',
      (tester) async {
    await tester.pumpWidget(_harness(_MockDio()));

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text("Confirm it's you"), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('wrong password shows a PERSISTENT inline error (not a toast)',
      (tester) async {
    final dio = _MockDio();
    when(() => dio.post<dynamic>('/api/v1/account/delete',
        data: any(named: 'data'),
        options: any(named: 'options'))).thenThrow(DioException(
      requestOptions: RequestOptions(path: '/'),
      response: Response<dynamic>(
        requestOptions: RequestOptions(path: '/'),
        statusCode: 401,
        data: {'error': 'Incorrect password'},
      ),
      type: DioExceptionType.badResponse,
    ));

    await tester.pumpWidget(_harness(dio));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'wrong');
    await tester.tap(find.text('Delete my account'));
    await tester.pumpAndSettle();

    // Still on the screen with the error rendered inline — not a vanishing snackbar.
    expect(find.text('Incorrect password'), findsOneWidget);
    expect(find.text("Confirm it's you"), findsOneWidget);
  });

  testWidgets('restore surface renders the scheduled message + Restore action',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (ctx) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => showRestoreAccountSheet(
                ctx,
                email: 'a@b.com',
                password: 'x',
                graceEndsAt: DateTime(2026, 7, 23),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(
        find.text('This account is scheduled for deletion'), findsOneWidget);
    expect(find.text('Restore my account'), findsOneWidget);
  });

  testWidgets('no overflow at 320dp + 2.0x text scale', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(ProviderScope(
      overrides: [dioProvider.overrideWithValue(_MockDio())],
      child: const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(2.0)),
          child: DeleteAccountScreen(),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
