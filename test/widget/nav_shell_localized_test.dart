import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/core/ui/scaffold_shell.dart';
import 'package:pally/l10n/app_localizations.dart';

/// Pins the bottom-nav labels to the LOCALE, end-to-end through the real
/// [ScaffoldShell]. This is the device-locale walk of the shell as a permanent
/// CI test, and it is also the standing evidence that the `Home/Library/Groups/
/// Me` literals in `buildTabs()` are unreachable `const` fallbacks: the shell
/// renders `_navLabel(l10n, tab)` (branchIndex → navHome/navLibrary/navGroups/
/// navMe), so a zh device shows 主页/学习库/小组/我的, never the English literals.
///
/// If someone regresses `label: _navLabel(l10n, tab)` back to `label: tab.label`
/// (the exact way the nav could silently ship English), the zh case fails.
Widget _harness(Locale locale) {
  final router = GoRouter(
    initialLocation: '/home',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navShell) =>
            ScaffoldShell(navigationShell: navShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/home', builder: (_, __) => const SizedBox.shrink()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/library', builder: (_, __) => const SizedBox.shrink()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/groups', builder: (_, __) => const SizedBox.shrink()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/me', builder: (_, __) => const SizedBox.shrink()),
          ]),
        ],
      ),
    ],
  );
  return MaterialApp.router(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    routerConfig: router,
  );
}

void main() {
  testWidgets('en: bottom nav renders the English labels', (tester) async {
    await tester.pumpWidget(_harness(const Locale('en')));
    await tester.pumpAndSettle();
    for (final label in const ['Home', 'Library', 'Groups', 'Me']) {
      expect(find.text(label), findsOneWidget, reason: 'en nav missing $label');
    }
  });

  testWidgets('zh: bottom nav renders 中文 labels, NOT the English fallbacks',
      (tester) async {
    await tester.pumpWidget(_harness(const Locale('zh')));
    await tester.pumpAndSettle();
    for (final label in const ['主页', '学习库', '小组', '我的']) {
      expect(find.text(label), findsOneWidget, reason: 'zh nav missing $label');
    }
    // The const TabSpec.label fallbacks must never surface on a zh device.
    for (final english in const ['Home', 'Library', 'Groups', 'Me']) {
      expect(find.text(english), findsNothing,
          reason: 'zh nav leaked the English fallback "$english"');
    }
  });
}
