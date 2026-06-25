import 'package:flutter/material.dart';

/// Caps content width and centres it on large screens (iPad / desktop / web /
/// landscape) so a phone-first layout doesn't stretch edge-to-edge and look
/// "blown up". On a phone (available width ≤ [maxWidth]) it's a NO-OP — the child
/// fills the width exactly as before, so phone layouts stay pixel-identical.
///
/// Wrap a screen's **body content** with this — NOT the `Scaffold`. The Scaffold
/// background and `AppBar` then stay full-bleed (the side gutters show the page
/// background, not white bars); only the content column clamps. Width-based, not
/// device-based, on purpose: an iPad split-view can hand you a narrow window.
///
/// This is the lightweight half of multiplatform layout. The heavier options,
/// for when you want to USE the extra space rather than just not stretch:
///   • Responsive breakpoints via LayoutBuilder/MediaQuery (phone vs tablet).
///   • Two-pane master–detail on wide screens (Material 3 canonical layouts /
///     `flutter_adaptive_scaffold`).
///   • Adaptive navigation (bottom bar → navigation rail at ~600 dp) — would go
///     in the shell (`scaffold_shell.dart`). Deliberately deferred pre-PMF.
class AdaptiveContentWidth extends StatelessWidget {
  const AdaptiveContentWidth(
      {super.key, required this.child, this.maxWidth = 560});

  final Widget child;

  /// Comfortable single-column reading width. ~560 keeps line lengths sane.
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
