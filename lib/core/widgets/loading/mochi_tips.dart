import 'dart:math';

import 'package:pally/l10n/app_localizations.dart';

/// Short warm/teaching tips shown during AI waits (Pattern C + E).
/// NOT the spicy splash jokes — these are informational, ≤90 chars.
/// One central list: add/remove here, no logic change needed.
List<String> mochiTips(AppLocalizations l) => [
      l.mochiTip1,
      l.mochiTip2,
      l.mochiTip3,
      l.mochiTip4(l.mascotName),
      l.mochiTip5(l.mascotName),
      l.mochiTip6,
      l.mochiTip7,
      l.mochiTip8,
      l.mochiTip9,
      l.mochiTip10,
    ];

/// Picks a random tip. Call once at widget init to stay stable during rotation.
String randomMochiTip(AppLocalizations l) {
  final tips = mochiTips(l);
  return tips[Random().nextInt(tips.length)];
}

/// Picks a DIFFERENT tip from the given one (for 4s+ rotation).
String nextMochiTip(String current, AppLocalizations l) {
  final tips = mochiTips(l);
  if (tips.length <= 1) return current;
  final candidates = tips.where((t) => t != current).toList();
  return candidates[Random().nextInt(candidates.length)];
}
