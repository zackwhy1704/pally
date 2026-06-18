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
              child: IntrinsicHeight(child: child),
            ),
          ),
        ),
      );
}
