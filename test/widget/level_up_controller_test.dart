import 'package:flutter/material.dart';
import 'package:pally/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/progress/presentation/level_up_controller.dart';

Widget _wrap(Widget Function(BuildContext) buttonBuilder) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(builder: buttonBuilder),
      ),
    );

void main() {
  group('LevelUpController.maybeCelebrate', () {
    testWidgets('levelledUp=false never shows the overlay, regardless of rewardLabel',
        (tester) async {
      await tester.pumpWidget(_wrap((ctx) => ElevatedButton(
            onPressed: () => LevelUpController.maybeCelebrate(
              ctx,
              levelledUp: false,
              newLevel: 5,
              rewardLabel: 'New Mochi colour',
            ),
            child: const Text('open'),
          )));

      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('New Mochi colour'), findsNothing);
    });

    testWidgets('newLevel<=0 never shows the overlay, regardless of levelledUp',
        (tester) async {
      await tester.pumpWidget(_wrap((ctx) => ElevatedButton(
            onPressed: () => LevelUpController.maybeCelebrate(
              ctx,
              levelledUp: true,
              newLevel: 0,
              rewardLabel: 'New Mochi colour',
            ),
            child: const Text('open'),
          )));

      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('New Mochi colour'), findsNothing);
    });

    testWidgets('a real crossing forwards rewardLabel through to the overlay',
        (tester) async {
      await tester.pumpWidget(_wrap((ctx) => ElevatedButton(
            onPressed: () => LevelUpController.maybeCelebrate(
              ctx,
              levelledUp: true,
              newLevel: 10,
              rewardLabel: 'Mystery box + Level 10 badge',
            ),
            child: const Text('open'),
          )));

      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('10'), findsOneWidget);
      expect(find.text('Mystery box + Level 10 badge'), findsOneWidget);

      await tester.pumpAndSettle(const Duration(seconds: 5));
    });

    testWidgets('a real crossing with no reward tier shows no chip', (tester) async {
      await tester.pumpWidget(_wrap((ctx) => ElevatedButton(
            onPressed: () => LevelUpController.maybeCelebrate(
              ctx,
              levelledUp: true,
              newLevel: 6,
              rewardLabel: null,
            ),
            child: const Text('open'),
          )));

      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('6'), findsOneWidget);
      expect(find.text('🎁'), findsNothing);

      await tester.pumpAndSettle(const Duration(seconds: 5));
    });
  });
}
