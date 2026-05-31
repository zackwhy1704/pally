import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

/// One catchphrase shown on the splash screen per launch.
class SplashLine {
  const SplashLine({required this.hero, required this.sub});
  final String hero;
  final String sub;
}

/// Central editable list. Add/remove lines here — no logic to change.
/// Line at index 1 is the FIRST-LAUNCH default (product truth, not a joke).
const List<SplashLine> kSplashLines = [
  SplashLine(
    hero: 'Learn with Mochi.',
    sub: "Don't just look it up. That's so lame.",
  ),
  // index 1 — first-ever-launch default: product truth, not a joke
  SplashLine(
    hero: 'Trained on your notes.',
    sub: 'Not the whole internet — so the answers are actually yours.',
  ),
  SplashLine(
    hero: 'One subject. One Mochi.',
    sub: 'Each one goes deep, so nothing gets fuzzy.',
  ),
  SplashLine(
    hero: 'I remember how you learn.',
    sub: "Get it wrong once, and I'll bring it back till it clicks.",
  ),
  SplashLine(
    hero: 'Looking it up is so last season.',
    sub: 'Mochi saw nothing. 🫣',
  ),
  SplashLine(
    hero: 'Your notes, now with a brain.',
    sub: "Feed me a little, and I'll quiz you a lot.",
  ),
];

const _kHasLaunchedKey = 'pally_has_launched_before';

/// Returns the line to display this launch:
/// • First-ever launch → index 1 (product truth).
/// • Subsequent launches → random from the full list.
Future<SplashLine> pickSplashLine() async {
  final prefs = await SharedPreferences.getInstance();
  final hasLaunched = prefs.getBool(_kHasLaunchedKey) ?? false;
  if (!hasLaunched) {
    await prefs.setBool(_kHasLaunchedKey, true);
    return kSplashLines[1];
  }
  return kSplashLines[Random().nextInt(kSplashLines.length)];
}
