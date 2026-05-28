import 'dart:math';
import 'package:flutter/material.dart';

/// Device-adaptive sizing utilities.
///
/// Flutter equivalent of Kotlin's ConstraintLayout percentage-based sizing.
/// Use these instead of hardcoded pixel values so layouts work on phones
/// (360–393px), tablets (744px+), and foldables (884px+).
class Adaptive {
  Adaptive._();

  /// Returns [fraction] of screen width, capped at [max] if provided.
  static double width(BuildContext context, double fraction, {double? max}) {
    final w = MediaQuery.of(context).size.width * fraction;
    return max != null ? min(w, max) : w;
  }

  /// Returns [fraction] of screen height, capped at [max] if provided.
  static double height(BuildContext context, double fraction, {double? max}) {
    final h = MediaQuery.of(context).size.height * fraction;
    return max != null ? min(h, max) : h;
  }

  /// Returns true if the screen is tablet-sized (width > 600).
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width > 600;

  /// Returns padding that scales with screen width (min 16, max 32).
  static EdgeInsets responsivePadding(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = max(16.0, min(32.0, w * 0.04));
    return EdgeInsets.symmetric(horizontal: h, vertical: h * 0.75);
  }
}
