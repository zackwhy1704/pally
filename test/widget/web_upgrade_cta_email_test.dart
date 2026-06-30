import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/subscription/subscription_service.dart';
import 'package:pally/features/subscription/widgets/web_upgrade_cta.dart';

// Fake sender so the "Email me the link" button never hits the network.
class _FakeSender extends UpgradeLinkSender {
  _FakeSender({this.result, this.error}) : super(Dio());
  final UpgradeLinkResult? result;
  final Object? error;

  @override
  Future<UpgradeLinkResult> send() async {
    if (error != null) throw error!;
    return result!;
  }
}

Widget _wrap(_FakeSender sender) => ProviderScope(
      overrides: [
        upgradeLinkSenderProvider.overrideWith((ref) => sender),
      ],
      // No Scaffold needed; the CTA is a plain Column.
      child: const MaterialApp(
        home: Scaffold(body: SingleChildScrollView(child: WebUpgradeCta())),
      ),
    );

void main() {
  group('WebUpgradeCta — "Email me the link"', () {
    testWidgets('both channels dispatched → green success message', (tester) async {
      await tester.pumpWidget(_wrap(_FakeSender(
        result: const UpgradeLinkResult(emailSent: true, pushSent: true),
      )));
      await tester.pumpAndSettle();

      expect(find.text('Email me the link'), findsOneWidget);
      await tester.tap(find.text('Email me the link'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Check your email'),
        findsOneWidget,
        reason: 'success confirmation must persist inline (not a toast)',
      );
    });

    testWidgets('429 rate-limit → friendly "try again later" message',
        (tester) async {
      final dioErr = DioException(
        requestOptions: RequestOptions(path: '/upgrade-link'),
        response: Response(
          requestOptions: RequestOptions(path: '/upgrade-link'),
          statusCode: 429,
        ),
      );
      await tester.pumpWidget(_wrap(_FakeSender(error: dioErr)));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Email me the link'));
      await tester.pumpAndSettle();

      expect(find.textContaining('try again'), findsOneWidget);
    });

    testWidgets('generic failure → persistent retryable error, not a crash',
        (tester) async {
      final dioErr = DioException(
        requestOptions: RequestOptions(path: '/upgrade-link'),
        type: DioExceptionType.connectionError,
      );
      await tester.pumpWidget(_wrap(_FakeSender(error: dioErr)));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Email me the link'));
      await tester.pumpAndSettle();

      expect(find.textContaining("Couldn't send the link"), findsOneWidget);
      // Button is re-enabled so the user can retry.
      expect(find.text('Email me the link'), findsOneWidget);
    });
  });
}
