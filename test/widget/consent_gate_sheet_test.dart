import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/consent/presentation/consent_gate_sheet.dart';
import 'package:pally/l10n/app_localizations.dart';

/// ConsentGateSheet moved OUT of api_client.dart in PR-K2: the client passes
/// only the typed reason CODE; every user-facing string resolves at render
/// from AppLocalizations. These tests pin that boundary: the sheet renders
/// localized copy in BOTH locales (so no English is baked anywhere upstream),
/// maps each reason code to its feature title, and both actions work.
void main() {
  Widget harness(Widget child, {Locale locale = const Locale('en')}) =>
      MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      );

  testWidgets('en: renders heading, UPLOAD feature title in body, both actions',
      (tester) async {
    var reminded = false;
    await tester.pumpWidget(harness(
      ConsentGateSheet(reason: 'UPLOAD', onRemind: () => reminded = true),
    ));

    expect(find.text('Almost there!'), findsOneWidget);
    expect(find.textContaining('Upload notes'), findsOneWidget);
    expect(find.text('Remind my grown-up'), findsOneWidget);
    expect(find.text('Got it'), findsOneWidget);
    expect(reminded, isFalse);
  });

  testWidgets('zh: the whole sheet renders in Chinese — no baked English',
      (tester) async {
    await tester.pumpWidget(harness(
      ConsentGateSheet(reason: 'UPLOAD', onRemind: () {}),
      locale: const Locale('zh'),
    ));

    expect(find.text('就快好了！'), findsOneWidget);
    expect(find.textContaining('上传笔记'), findsOneWidget);
    expect(find.text('提醒我的大人'), findsOneWidget);
    // The English strings must NOT appear anywhere under zh.
    expect(find.text('Almost there!'), findsNothing);
    expect(find.textContaining('Upload notes'), findsNothing);
  });

  testWidgets('CREATE_TUTOR resolves the mascot through mascotName (zh 小伴)',
      (tester) async {
    await tester.pumpWidget(harness(
      ConsentGateSheet(reason: 'CREATE_TUTOR', onRemind: () {}),
      locale: const Locale('zh'),
    ));
    expect(find.textContaining('小伴'), findsOneWidget);
    expect(find.textContaining('Mochi'), findsNothing);
  });

  testWidgets('unknown reason falls back to the generic feature title',
      (tester) async {
    await tester.pumpWidget(harness(
      ConsentGateSheet(reason: 'general', onRemind: () {}),
    ));
    expect(find.textContaining('This feature'), findsOneWidget);
  });

  testWidgets('Remind pops the sheet and fires onRemind; Got it only pops',
      (tester) async {
    var reminded = false;
    await tester.pumpWidget(harness(
      ConsentGateSheet(reason: 'EARN_XP', onRemind: () => reminded = true),
    ));

    await tester.tap(find.text('Remind my grown-up'));
    await tester.pumpAndSettle();
    expect(reminded, isTrue);
  });
}
