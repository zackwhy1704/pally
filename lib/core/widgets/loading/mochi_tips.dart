import 'dart:math';

/// Short warm/teaching tips shown during AI waits (Pattern C + E).
/// NOT the spicy splash jokes — these are informational, ≤90 chars.
/// One central list: add/remove here, no logic change needed.
const List<String> kMochiTips = [
  'I only learn from what YOU give me — so my answers match your syllabus.',
  'The more you study, the better I fit you.',
  'Get one wrong? I bring it back till it clicks.',
  'One subject per Mochi keeps my answers sharp.',
  'Your notes → your Mochi. Nothing generic here.',
  'Hard topics come back. Easy ones get spaced out. No wasted time.',
  'I track what trips you up — so we can fix it together.',
  'Every note you upload makes my answers more yours.',
  'No random internet stuff. Just your material.',
  'Upload once, study smarter forever.',
];

/// Picks a random tip. Call once at widget init to stay stable during rotation.
String randomMochiTip() =>
    kMochiTips[Random().nextInt(kMochiTips.length)];

/// Picks a DIFFERENT tip from the given one (for 4s+ rotation).
String nextMochiTip(String current) {
  if (kMochiTips.length <= 1) return current;
  final candidates = kMochiTips.where((t) => t != current).toList();
  return candidates[Random().nextInt(candidates.length)];
}
