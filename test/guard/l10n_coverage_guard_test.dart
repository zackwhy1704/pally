import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// zh COVERAGE GUARD — the completeness metric, enforced.
///
/// "Complete" used to mean "every surface on a scope list was localized". A
/// human walk then found ~750 hardcoded strings the list never named. This guard
/// replaces scope-counting with coverage-counting: it walks the widget-tree
/// SOURCE for every user-facing string literal still hardcoded in a localized
/// directory, and fails on any that is not in the frozen baseline.
///
/// The baseline (`l10n_coverage_baseline.txt`) is SHRINK-ONLY, like
/// `layering_guard`: localize a string and you delete its line; you never add a
/// line to silence a new hardcoded string unless it is legitimately English
/// (identifier/debug/illustrative) — and then with a comment saying why. When the
/// baseline reaches zero, coverage is 100% and stays there: a new hardcoded
/// user-facing string fails CI, so the next walk cannot find a new surprise.
///
/// Regenerate the baseline after a localization PR:
///   UPDATE_L10N_BASELINE=1 flutter test test/guard/l10n_coverage_guard_test.dart
/// (only ever run this to SHRINK it; review the diff — it must not grow.)
void main() {
  final baselineFile = File('test/guard/l10n_coverage_baseline.txt');

  test('no new hardcoded user-facing string enters a localized directory', () {
    final current = _scan();

    if (Platform.environment['UPDATE_L10N_BASELINE'] == '1') {
      final sorted = current.toList()..sort();
      baselineFile.writeAsStringSync(
          '# zh coverage baseline — SHRINK ONLY. Each line: <relpath>\\t<string>.\n'
          '# Remove a line by localizing that string. Adding a line = an explicit\n'
          '# "legitimately English" allow; include a reason in the PR.\n'
          '${sorted.join('\n')}\n');
      // ignore: avoid_print
      print('Wrote ${sorted.length} baseline entries.');
      return;
    }

    final baseline = baselineFile
        .readAsLinesSync()
        .where((l) => l.isNotEmpty && !l.startsWith('#'))
        .toSet();

    final novel = current.difference(baseline).toList()..sort();
    expect(novel, isEmpty,
        reason: '${novel.length} hardcoded user-facing string(s) are not in the '
            'coverage baseline. Localize them (route through AppLocalizations), '
            'or — only if legitimately English — add the line(s) to '
            'test/guard/l10n_coverage_baseline.txt with a reason:\n'
            '${novel.take(40).join('\n')}');

    // Report (do not fail on) stale baseline lines so a shrink is visible.
    final stale = baseline.difference(current);
    if (stale.isNotEmpty) {
      // ignore: avoid_print
      print('NOTE: ${stale.length} baseline entries are stale (localized or '
          'removed). Regenerate the baseline to drop them.');
    }
  });
}

/// Set of "relpath\tstring" for every hardcoded user-facing string in lib/.
/// Keyed on (file, string) — line-independent, so refactors that move a line
/// don't churn the baseline; a NEW string in an already-listed file still fails.
Set<String> _scan() {
  final hits = <String>{};
  for (final f in Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))) {
    final p = f.path.replaceAll(r'\', '/');
    if (p.endsWith('.g.dart') || p.endsWith('.freezed.dart')) continue;
    if (p.contains('/l10n/')) continue; // ARB-generated string tables
    if (p.contains('/features/debug/')) continue; // dev-only gallery
    final src = f.readAsStringSync();
    for (final m in _sink.allMatches(src)) {
      final s = _stringAt(src, m.end - 1);
      if (s == null || !_natural(s)) continue;
      hits.add('${p.replaceFirst('lib/', '')}\t$s');
    }
  }
  return hits;
}

/// UI text sinks: a string literal in one of these positions is user-facing.
final _sink = RegExp(
  r'''(?:\bText\(\s*|\bText\.rich\(\s*|\b(?:label|title|subtitle|hintText|labelText|helperText|errorText|content|message|tooltip|semanticLabel|prefixText|suffixText|counterText|heroTitle|heroSubtitle|header|placeholder|caption)\s*:\s*|PallyToast\.\w+\(\s*[^,\n]+,\s*|\breturn\s+)(['"])''',
);

/// Extract the string literal beginning at [quoteIndex] (handling escapes).
/// Returns null if it is not a simple single-line literal.
String? _stringAt(String src, int quoteIndex) {
  if (quoteIndex < 0 || quoteIndex >= src.length) return null;
  final q = src[quoteIndex];
  if (q != "'" && q != '"') return null;
  final b = StringBuffer();
  var i = quoteIndex + 1;
  while (i < src.length) {
    final c = src[i];
    if (c == r'\') {
      if (i + 1 < src.length) b.write(src[i + 1]);
      i += 2;
      continue;
    }
    if (c == q) return b.toString();
    if (c == '\n') return null;
    b.write(c);
    i++;
  }
  return null;
}

final _hasLetter = RegExp(r'[A-Za-z一-鿿]');
final _allCaps = RegExp(r'^[A-Z0-9_]+$');
final _allLowerId = RegExp(r'^[a-z0-9_]+$');
final _camel = RegExp(r'^[a-z]+([A-Z][a-z0-9]*)+$');
final _cjk = RegExp(r'[一-鿿]');

/// Prose/label heuristic: excludes identifiers, paths, urls, enum keys, snake keys.
bool _natural(String s) {
  if (!_hasLetter.hasMatch(s)) return false;
  for (final pre in const ['/', 'assets/', 'http', 'mailto:', 'package:', 'pally://']) {
    if (s.startsWith(pre)) return false;
  }
  if (_allCaps.hasMatch(s)) return false;
  if (_allLowerId.hasMatch(s)) return false;
  if (_camel.hasMatch(s)) return false;
  if (s.contains('.') &&
      !s.contains(' ') &&
      !_cjk.hasMatch(s) &&
      !(s.endsWith('.') || s.endsWith('!') || s.endsWith('?'))) {
    return false;
  }
  return s.length >= 2;
}
