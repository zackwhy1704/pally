import 'package:flutter/material.dart';

/// Centers content and caps its width on large screens (iPad / desktop / web) so
/// a phone-first layout doesn't stretch edge-to-edge and look "blown up". On a
/// phone (viewport ≤ [maxWidth]) it's a no-op — the child fills the width as
/// before. On an iPad it sits in a comfortable centred column.
///
/// This is the lightweight half of multiplatform layout. The heavier options,
/// for when you want to USE the extra space rather than just not stretch:
///   • Responsive breakpoints via LayoutBuilder/MediaQuery (phone vs tablet).
///   • Two-pane master–detail on wide screens (Material 3 canonical layouts /
///     `flutter_adaptive_scaffold`).
///   • Adaptive navigation (bottom bar → navigation rail on wide screens).
/// Start by wrapping form/reading screens' bodies in [AdaptiveBody]; reach for
/// the heavier patterns only where a two-pane view actually helps.
class AdaptiveBody extends StatelessWidget {
  const AdaptiveBody({super.key, required this.child, this.maxWidth = 560});

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
