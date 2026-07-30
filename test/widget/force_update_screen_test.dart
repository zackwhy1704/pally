import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/l10n/app_localizations.dart';
import 'package:pally/features/app_update/force_update_screen.dart';

void main() {
  testWidgets('ForceUpdateScreen shows the update prompt and an Update button',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,home: ForceUpdateScreen()));

    expect(find.text('Time to update!'), findsOneWidget);
    expect(find.text('Update now'), findsOneWidget);
    expect(find.byType(FilledButton), findsOneWidget);
  });
}
