import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';

/// Renders a string that may contain LaTeX math alongside plain text.
///
/// Supports both display math `$$...$$` / `\[...\]` and inline math
/// `$...$` / `\(...\)`. Segments without math markers are rendered as
/// normal text. The whole widget respects the passed [style] and
/// [textColor] so it blends into any bubble background.
///
/// Examples Claude produces that this handles:
///   "The equation is $6CO_2 + 6H_2O + \text{light} = C_6H_{12}O_6$"
///   "$$\frac{d}{dx}(x^2) = 2x$$"
///   "Roots: \( x = \frac{-b \pm \sqrt{b^2-4ac}}{2a} \)"
class MathText extends StatelessWidget {
  const MathText({
    super.key,
    required this.text,
    this.style,
    this.textColor,
  });

  final String text;
  final TextStyle? style;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = (style ?? AppTextStyles.body).copyWith(
      color: textColor,
    );
    final segments = _parse(text);
    if (segments.length == 1 && segments.first is _TextSegment) {
      // Fast path: no math — plain Text widget (same as before)
      return Text(
        (segments.first as _TextSegment).content,
        style: effectiveStyle,
      );
    }
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: segments.map((seg) => _buildSegment(seg, effectiveStyle)).toList(),
    );
  }

  Widget _buildSegment(_Segment seg, TextStyle textStyle) {
    if (seg is _TextSegment) {
      return Text(seg.content, style: textStyle);
    }
    if (seg is _MathSegment) {
      return _SafeMath(
        tex: seg.tex,
        display: seg.display,
        textColor: textStyle.color ?? AppColors.text1,
      );
    }
    return const SizedBox.shrink();
  }

  /// Splits the text into alternating plain-text and math segments.
  static List<_Segment> _parse(String raw) {
    // Order matters: check display math first (longer delimiters win)
    final displayPattern = RegExp(
      r'\$\$(.+?)\$\$|\\\[(.+?)\\\]',
      dotAll: true,
    );
    final inlinePattern = RegExp(
      r'\$(?!\$)(.+?)(?<!\$)\$|\\\((.+?)\\\)',
      dotAll: true,
    );

    final segments = <_Segment>[];
    var remaining = raw;

    while (remaining.isNotEmpty) {
      final dm = displayPattern.firstMatch(remaining);
      final im = inlinePattern.firstMatch(remaining);

      // Pick whichever match comes first
      final match = _earlierMatch(dm, im);
      if (match == null) {
        segments.add(_TextSegment(remaining));
        break;
      }
      // Text before the match
      if (match.start > 0) {
        segments.add(_TextSegment(remaining.substring(0, match.start)));
      }
      final tex = match.group(1) ?? match.group(2) ?? '';
      final isDisplay = identical(match.pattern, displayPattern);
      segments.add(_MathSegment(tex.trim(), display: isDisplay));
      remaining = remaining.substring(match.end);
    }
    return segments.isEmpty ? [_TextSegment(raw)] : segments;
  }

  static RegExpMatch? _earlierMatch(RegExpMatch? a, RegExpMatch? b) {
    if (a == null) return b;
    if (b == null) return a;
    return a.start <= b.start ? a : b;
  }
}

// ── Segments ─────────────────────────────────────────────────────────────────
sealed class _Segment {}
class _TextSegment extends _Segment { _TextSegment(this.content); final String content; }
class _MathSegment extends _Segment {
  _MathSegment(this.tex, {required this.display});
  final String tex;
  final bool display;
}

/// Renders a single LaTeX expression, falling back to plain text if the
/// expression is invalid (so a bad equation never crashes the chat).
class _SafeMath extends StatelessWidget {
  const _SafeMath({
    required this.tex,
    required this.display,
    required this.textColor,
  });

  final String tex;
  final bool display;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Math.tex(
      tex,
      textStyle: TextStyle(color: textColor, fontSize: 14),
      mathStyle: display ? MathStyle.display : MathStyle.text,
      onErrorFallback: (e) => Text(
        display ? r'$$' + tex + r'$$' : r'$' + tex + r'$',
        style: TextStyle(color: textColor, fontSize: 14),
      ),
    );
  }
}
