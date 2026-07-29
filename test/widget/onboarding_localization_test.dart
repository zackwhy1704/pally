import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pally/features/onboarding/presentation/onboarding_screen.dart';
import 'package:pally/l10n/app_localizations.dart';

/// The onboarding tour renders in the selected language end-to-end (ARB → widget),
/// including the ICU placeholder progress line "{current} of {total}".
void main() {
  Future<void> pump(WidgetTester tester, Locale locale) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const OnboardingScreen(),
    ));
    await tester.pump();
  }

  testWidgets('renders Chinese page-1 title + ICU progress at zh', (tester) async {
    await pump(tester, const Locale('zh'));
    expect(find.textContaining('我学习你的材料'), findsOneWidget);   // page-1 title
    expect(find.text('1 / 3'), findsOneWidget);                    // ICU {current}/{total}
  });

  testWidgets('renders English page-1 title + progress at en', (tester) async {
    await pump(tester, const Locale('en'));
    expect(find.textContaining('I learn from your material'), findsOneWidget);
    expect(find.text('1 of 3'), findsOneWidget);
  });
}
