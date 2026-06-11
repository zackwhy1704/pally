import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/consent/data/consent_service.dart';
import 'package:pally/features/consent/presentation/ai_disclosure_screen.dart';

/// A ConsentService whose grantAiConsent never touches the network.
class _FakeConsentService extends ConsentService {
  _FakeConsentService({this.shouldThrow = false}) : super(Dio());
  final bool shouldThrow;
  int grantCalls = 0;

  @override
  Future<void> grantAiConsent() async {
    grantCalls++;
    if (shouldThrow) {
      throw DioException(requestOptions: RequestOptions(path: '/x'));
    }
  }
}

Widget _wrap(Widget child, {ConsentService? service}) => ProviderScope(
      overrides: [
        if (service != null)
          consentServiceProvider.overrideWithValue(service),
      ],
      child: MaterialApp(home: child),
    );

void main() {
  group('AiDisclosureScreen', () {
    testWidgets('renders disclosure copy mentioning Anthropic and Google',
        (tester) async {
      await tester.pumpWidget(
        _wrap(const AiDisclosureScreen(), service: _FakeConsentService()),
      );
      await tester.pump();

      expect(find.textContaining('Anthropic'), findsWidgets);
      expect(find.textContaining('Google'), findsWidgets);
      expect(find.textContaining('overseas'), findsWidgets);
      expect(find.text('Agree'), findsOneWidget);
      expect(find.text('Not now'), findsOneWidget);
    });

    testWidgets('tapping Agree records consent', (tester) async {
      final fake = _FakeConsentService();
      await tester.pumpWidget(_wrap(const AiDisclosureScreen(), service: fake));
      await tester.pump();

      await tester.tap(find.text('Agree'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(fake.grantCalls, 1);
    });

    testWidgets('no overflow at 320x568 with 1.3 text scale',
        (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            consentServiceProvider
                .overrideWithValue(_FakeConsentService()),
          ],
          child: MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
              child: const AiDisclosureScreen(),
            ),
          ),
        ),
      );
      await tester.pump();

      // No render overflow exceptions thrown during layout.
      expect(tester.takeException(), isNull);
      expect(find.text('Agree'), findsOneWidget);
    });
  });
}
