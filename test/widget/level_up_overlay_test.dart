import 'package:flutter/material.dart';
import 'package:pally/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/progress/presentation/level_up_overlay.dart';

Widget _wrap(Widget Function(BuildContext) buttonBuilder) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(builder: buttonBuilder),
      ),
    );

void main() {
  group('LevelUpOverlay', () {
    testWidgets('shows the level number, no reward chip when rewardLabel is null',
        (tester) async {
      await tester.pumpWidget(_wrap((ctx) => ElevatedButton(
            onPressed: () => LevelUpOverlay.show(ctx, 7),
            child: const Text('open'),
          )));

      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('7'), findsOneWidget);
      // No reward chip renders — 🎁 only appears when a rewardLabel is passed.
      expect(find.text('🎁'), findsNothing);

      // LevelUpOverlow auto-dismisses after 4s — run the timer to completion
      // so no pending Timer trips the test framework's teardown invariant.
      await tester.pumpAndSettle(const Duration(seconds: 5));
    });

    testWidgets('shows the reward chip verbatim when rewardLabel is set',
        (tester) async {
      await tester.pumpWidget(_wrap((ctx) => ElevatedButton(
            onPressed: () => LevelUpOverlay.show(ctx, 5,
                rewardLabel: 'Extra free Mochi slot'),
            child: const Text('open'),
          )));

      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('5'), findsOneWidget);
      expect(find.text('🎁'), findsOneWidget);
      // Rendered verbatim — already locale-resolved server-side, no client
      // translation/formatting applied.
      expect(find.text('Extra free Mochi slot'), findsOneWidget);

      await tester.pumpAndSettle(const Duration(seconds: 5));
    });

    testWidgets('renders a zh reward label verbatim too (no client re-translation)',
        (tester) async {
      await tester.pumpWidget(_wrap((ctx) => ElevatedButton(
            onPressed: () => LevelUpOverlay.show(ctx, 5,
                rewardLabel: '全新小伴配色'),
            child: const Text('open'),
          )));

      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('全新小伴配色'), findsOneWidget);

      await tester.pumpAndSettle(const Duration(seconds: 5));
    });
  });
}
