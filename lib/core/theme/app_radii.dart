/// Border-radius design tokens.
///
/// Never use a raw `BorderRadius.circular(N)` in widget code unless it is
/// a one-off interactive element (e.g. a custom pill). All card-style
/// containers should use [AppRadii.card].
abstract class AppRadii {
  /// Standard card / sheet / dialog corner radius.
  static const double card = 16;

  /// Small chip / badge / pill.
  static const double chip = 8;

  /// Full-pill (e.g. segmented controls, large rounded buttons).
  static const double full = 100;
}
