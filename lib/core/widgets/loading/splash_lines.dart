import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pally/l10n/app_localizations.dart';

/// One catchphrase shown on the splash screen per launch.
class SplashLine {
  const SplashLine({required this.hero, required this.sub});
  final String hero;
  final String sub;
}

/// Central editable list. Add/remove lines here — no logic to change.
/// Line at index 1 is the FIRST-LAUNCH default (product truth, not a joke).
List<SplashLine> splashLines(AppLocalizations l) => [
      SplashLine(hero: l.splashHero1, sub: l.splashSub1),
      // index 1 — first-ever-launch default: product truth, not a joke
      SplashLine(hero: l.splashHero2, sub: l.splashSub2),
      SplashLine(hero: l.splashHero3, sub: l.splashSub3),
      SplashLine(hero: l.splashHero4, sub: l.splashSub4),
      SplashLine(hero: l.splashHero5, sub: l.splashSub5),
      SplashLine(hero: l.splashHero6, sub: l.splashSub6(l.mascotName)),
      SplashLine(hero: l.splashHero7, sub: l.splashSub7),
      SplashLine(hero: l.splashHero8, sub: l.splashSub8(l.mascotName)),
    ];

/// Length of [splashLines] — a plain constant since the count never varies
/// by locale, so callers don't need an AppLocalizations just to modulo an index.
const kSplashLineCount = 8;

const _kFirstLaunchIndex = 1;
const _kHasLaunchedKey = 'pally_has_launched_before';

/// Returns the INDEX of the line to display this launch (not the content —
/// that needs AppLocalizations, resolved later at render time):
/// • First-ever launch → index 1 (product truth).
/// • Subsequent launches → random from the full list.
Future<int> pickSplashLineIndex() async {
  final prefs = await SharedPreferences.getInstance();
  final hasLaunched = prefs.getBool(_kHasLaunchedKey) ?? false;
  if (!hasLaunched) {
    await prefs.setBool(_kHasLaunchedKey, true);
    return _kFirstLaunchIndex;
  }
  return Random().nextInt(kSplashLineCount);
}
