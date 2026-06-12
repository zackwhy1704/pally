import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/consent/data/consent_service.dart';
import 'package:pally/features/consent/presentation/ai_disclosure_screen.dart';

/// A ConsentService whose grantAiConsent never touches the network.
class _FakeConsentService extends ConsentService {
  _FakeConsentService() : super(Dio());
  int grantCalls = 0;

  @override
  Future<void> grantAiConsent() async {
    grantCalls++;
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
  group('AiDisclosureScreen — standard (13+ self-consent)', () {
    testWidgets('renders child-readable copy naming Anthropic and Google',
        (tester) async {
      await tester.pumpWidget(
        _wrap(const AiDisclosureScreen(), service: _FakeConsentService()),
      );
      await tester.pump();

      expect(find.textContaining('Anthropic'), findsWidgets);
      expect(find.textContaining('Google'), findsWidgets);
      // Plain-language phrase from the new Year-7 copy.
      expect(find.textContaining('outside Singapore'), findsWidgets);
      // Self-consenting users get the consent button + a Read more link.
      expect(find.text('I agree'), findsOneWidget);
      expect(find.text('Not now'), findsOneWidget);
      expect(find.text('Read more'), findsOneWidget);
    });

    testWidgets('tapping I agree records consent', (tester) async {
      final fake = _FakeConsentService();
      await tester.pumpWidget(_wrap(const AiDisclosureScreen(), service: fake));
      await tester.pump();

      await tester.tap(find.text('I agree'));
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
          child: const MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(1.3)),
              child: AiDisclosureScreen(),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('I agree'), findsOneWidget);
    });
  });

  group('AiDisclosureScreen — informational (under-13)', () {
    testWidgets('shows same disclosure copy but no "I agree" button',
        (tester) async {
      await tester.pumpWidget(
        _wrap(const AiDisclosureScreen(informationOnly: true),
            service: _FakeConsentService()),
      );
      await tester.pump();

      // Same plain-language disclosure naming both providers.
      expect(find.textContaining('Anthropic'), findsWidgets);
      expect(find.textContaining('Google'), findsWidgets);
      // The child cannot self-consent — no "I agree", just an OK dismiss.
      expect(find.text('I agree'), findsNothing);
      expect(find.text('Not now'), findsNothing);
      expect(find.text('OK'), findsOneWidget);
    });

    testWidgets('tapping OK never records consent', (tester) async {
      final fake = _FakeConsentService();
      await tester.pumpWidget(
        _wrap(const AiDisclosureScreen(informationOnly: true), service: fake),
      );
      await tester.pump();

      await tester.tap(find.text('OK'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(fake.grantCalls, 0);
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
          child: const MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(1.3)),
              child: AiDisclosureScreen(informationOnly: true),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('OK'), findsOneWidget);
    });
  });
}
