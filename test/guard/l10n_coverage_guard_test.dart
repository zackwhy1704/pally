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
/// (identifier/debug/illustrative). When the baseline reaches zero, coverage is
/// 100% and stays there: a new hardcoded user-facing string fails CI, so the
/// next walk cannot find a new surprise.
///
/// EACH BASELINE LINE IS `<relpath>\t<string>\t<reason>`. The reason is
/// ENFORCED, not advisory: a line with no third column fails the guard
/// ([unreasonedBaselineKeys]). This closes the escape hatch that a bare
/// allow-list opens — an allow without an in-file, auditable reason is the
/// guard lying in the polite direction (measured-looking, wrong in the visible
/// place). A reason in a merged PR description evaporates; a reason in the file
/// is auditable forever. Reason vocabulary: brand / format / nav-fallback /
/// backend-label / device-meta / emoji-escape / deferred-<owner>.
///
/// Regenerate the baseline after a localization PR:
///   UPDATE_L10N_BASELINE=1 flutter test test/guard/l10n_coverage_guard_test.dart
/// (only ever run this to SHRINK it; review the diff — it must not grow.)
/// Regeneration PRESERVES the reason on every surviving line; a newly-baselined
/// string gets `NEEDS_REASON`, which then fails the guard until justified.
const _reasonPlaceholder = 'NEEDS_REASON';

/// One baseline entry: the `<relpath>\t<string>` [key] plus its [reason].
class _Entry {
  const _Entry(this.key, this.reason);
  final String key;
  final String reason;
}

/// Parse non-comment baseline lines into (key, reason). relpath and the scanned
/// string never contain a tab (the scanner excludes tab/newline from extracted
/// literals — see [_stringAt]), so the FIRST TWO tabs delimit the key and
/// everything after the second tab is the reason. A line with no second tab has
/// no reason (empty) — which [unreasonedBaselineKeys] then flags.
List<_Entry> _parseBaseline(Iterable<String> lines) {
  final out = <_Entry>[];
  for (final l in lines) {
    if (l.isEmpty || l.startsWith('#')) continue;
    final t1 = l.indexOf('\t');
    final t2 = t1 < 0 ? -1 : l.indexOf('\t', t1 + 1);
    if (t2 < 0) {
      out.add(_Entry(l, ''));
    } else {
      out.add(_Entry(l.substring(0, t2), l.substring(t2 + 1).trim()));
    }
  }
  return out;
}

/// Keys of baseline entries carrying no defensible reason (empty or the
/// [_reasonPlaceholder]). Public so the enforcement is unit-testable without
/// the real file. THIS is the teeth: a bare allow is flagged here and fails.
List<String> unreasonedBaselineKeys(Iterable<String> lines) =>
    (_parseBaseline(lines)
          ..removeWhere((e) => e.reason.isNotEmpty && e.reason != _reasonPlaceholder))
        .map((e) => e.key)
        .toList()
      ..sort();

void main() {
  final baselineFile = File('test/guard/l10n_coverage_baseline.txt');

  test('every hardcoded string is localized, or an allow WITH a stated reason',
      () {
    final current = _scan();
    final rawLines = baselineFile.readAsLinesSync();

    if (Platform.environment['UPDATE_L10N_BASELINE'] == '1') {
      // Preserve reasons across regeneration: a surviving line keeps its reason;
      // a newly-baselined string gets the placeholder so the next (non-update)
      // run FAILS until a human justifies it — never a silent bare allow.
      final oldReason = {
        for (final e in _parseBaseline(rawLines)) e.key: e.reason
      };
      final sorted = current.toList()..sort();
      final body = sorted.map((k) {
        final r = oldReason[k];
        return '$k\t${(r == null || r.isEmpty) ? _reasonPlaceholder : r}';
      }).join('\n');
      baselineFile.writeAsStringSync(
          '# zh coverage baseline — SHRINK ONLY. Each line: <relpath>\\t<string>\\t<reason>.\n'
          '# Remove a line by LOCALIZING that string (delete the line). A line may exist ONLY\n'
          '# WITH a reason in the third column — a bare allow FAILS the guard (unreasonedBaselineKeys).\n'
          '# Reason vocabulary: brand / format / nav-fallback / backend-label / device-meta /\n'
          '# emoji-escape / deferred-<owner>. deferred-* = English-by-design debt with a named owner,\n'
          '# NOT a permanent allow. See DEFERRED.md for the ledger.\n'
          '$body\n');
      // ignore: avoid_print
      print('Wrote ${sorted.length} baseline entries (reasons preserved).');
      return;
    }

    final entries = _parseBaseline(rawLines);
    final baselineKeys = {for (final e in entries) e.key};

    // (1) Shrink-only invariant: no NEW hardcoded string may enter.
    final novel = current.difference(baselineKeys).toList()..sort();
    expect(novel, isEmpty,
        reason: '${novel.length} hardcoded user-facing string(s) are not in the '
            'coverage baseline. Localize them (route through AppLocalizations), '
            'or — only if legitimately English — add the line(s) to '
            'test/guard/l10n_coverage_baseline.txt as '
            '"<relpath>\\t<string>\\t<reason>":\n${novel.take(40).join('\n')}');

    // (2) Enforcement: every allow carries an auditable reason. A bare allow is
    // the escape hatch that turns a measured baseline back into a scope list.
    final unreasoned = unreasonedBaselineKeys(rawLines);
    expect(unreasoned, isEmpty,
        reason: '${unreasoned.length} allow-list entr(ies) have no reason in the '
            'third column. State WHY each is not localized (brand / format / '
            'nav-fallback / backend-label / device-meta / emoji-escape / '
            'deferred-<owner>) as "<relpath>\\t<string>\\t<reason>":\n'
            '${unreasoned.take(40).join('\n')}');

    // (3) Report (do not fail on) stale baseline lines so a shrink is visible.
    final stale = baselineKeys.difference(current);
    if (stale.isNotEmpty) {
      // ignore: avoid_print
      print('NOTE: ${stale.length} baseline entries are stale (localized or '
          'removed). Regenerate the baseline to drop them.');
    }
  });

  test('the reason-enforcement detects a bare allow (fail-without-fix proof)',
      () {
    // A line with no reason column is flagged; the same line WITH a reason is
    // not; the NEEDS_REASON placeholder is treated as unreasoned.
    expect(unreasonedBaselineKeys(['features/x_screen.dart\tHello']),
        equals(['features/x_screen.dart\tHello']));
    expect(
        unreasonedBaselineKeys(
            ['features/x_screen.dart\tHello\tformat: numerals only']),
        isEmpty);
    expect(
        unreasonedBaselineKeys(['features/x_screen.dart\tHello\t$_reasonPlaceholder']),
        equals(['features/x_screen.dart\tHello']));
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
