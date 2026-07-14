import 'package:flutter/material.dart';

/// Centers [child] when there is room; scrolls it when there isn't.
/// Survives device rotation and large accessibility text scale.
/// Replaces SafeArea + Padding — do NOT add an extra SafeArea outside this widget.
class AdaptiveCenter extends StatelessWidget {
  const AdaptiveCenter({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) => SafeArea(
        child: LayoutBuilder(
          builder: (context, c) => SingleChildScrollView(
            padding: padding,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: c.maxHeight),
              // Center on BOTH axes within the min-height (viewport-tall) box, so
              // narrow content sits on the centre line instead of shrink-wrapping to
              // the top-left. A full-width child (width:infinity) still expands to
              // fill; padding stays owned by the scroll view, so there is no
              // c.maxWidth arithmetic that could overflow by the padding amount.
              child: IntrinsicHeight(child: Center(child: child)),
            ),
          ),
        ),
      );
}
