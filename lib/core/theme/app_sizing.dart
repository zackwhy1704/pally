/// Design-constant sizes for UI components.
///
/// These are NOT hardcoded layout values — they are design-system tokens,
/// the same concept as Material Design's 48dp touch target or 56dp FAB.
/// Every component that needs a specific size references these tokens so
/// the system can be updated in one place.
///
/// For LAYOUT sizing that must adapt to screen dimensions, use
/// MediaQuery.of(context).size (with a fraction) or LayoutBuilder, never
/// a raw dp literal.
abstract class AppSizing {
  // ── Touch targets ────────────────────────────────────────────────────────
  /// Minimum touch target — Material Design spec (48 × 48 dp).
  static const double touchTarget = 48;

  // ── Button heights ───────────────────────────────────────────────────────
  /// Primary CTA button height.
  static const double buttonHeight = 52;
  /// Secondary / compact button height.
  static const double buttonHeightSm = 44;

  // ── Avatar / character circles ───────────────────────────────────────────
  /// Extra-small avatar: 28 dp (chat AppBar character widget inside circle).
  static const double avatarXs = 28;
  /// Small avatar: 32 dp (message bubbles, pickers).
  static const double avatarSm = 32;
  /// Medium avatar: 36 dp (card badge, nav, AppBar circle).
  static const double avatarMd = 36;
  /// Large avatar: 48 dp (profile row, collection card).
  static const double avatarLg = 48;
  /// Extra-large avatar: 56 dp (Mochi character in chat floating coach).
  static const double avatarXl = 56;

  // ── Selection indicators ─────────────────────────────────────────────────
  /// Checkbox / radio circle outer diameter.
  static const double checkboxSize = 22;
  /// Checkmark icon inside a selection circle.
  static const double checkIconSize = 18;
  /// Small selection tick (avatar picker overlay).
  static const double checkboxSizeSm = 18;

  // ── Bottom-sheet drag handle ─────────────────────────────────────────────
  static const double handleBarWidth = 40;
  static const double handleBarHeight = 4;

  // ── Loading / progress ───────────────────────────────────────────────────
  /// Tiny spinner inside a status pill or chip (12 dp).
  static const double spinnerXs = 12;
  /// Spinner inside a button or small loading slot (20 dp).
  static const double spinnerSm = 20;
  /// Typing-indicator dot diameter.
  static const double typingDot = 8;

  // ── Icon sizes (Material Design standard set) ────────────────────────────
  static const double iconXs = 14;
  static const double iconSm = 16;
  static const double icon18 = 18;
  static const double iconMd = 24;
  static const double iconLg = 32;

  // ── Decorative / illustration elements ──────────────────────────────────
  /// Brain-health / progress bar height.
  static const double progressBarHeight = 6;

  // ── Large icon / illustration containers ────────────────────────────────
  /// Error card icon container (64 × 64 dp).
  static const double iconContainer = 64;

  // ── Animation rings ─────────────────────────────────────────────────────
  /// Loading ring size (56 × 56 dp) — biometric sheet centre circle.
  static const double ringSize = 56;
  /// Medium ring size (34 × 34 dp) — biometric icon inner ring.
  static const double ringMd = 34;

  // ── Avatar picker ────────────────────────────────────────────────────────
  /// Selected-badge diameter in the avatar grid (18 dp).
  static const double avatarPickerBadge = 18;

  // ── AppBar / navigation ──────────────────────────────────────────────────
  /// Standard AppBar / top-bar height (56 dp).
  static const double appBarHeight = 56;

  // ── Skeleton / placeholder ───────────────────────────────────────────────
  /// Avatar skeleton placeholder (52 × 52 dp).
  static const double skeletonAvatar = 52;

  // ── Panel / hero heights ─────────────────────────────────────────────────
  /// Upload hero panel height (128 dp) — compact enough for small phones.
  /// Override with MediaQuery fraction on screen width < 360 dp.
  static const double heroPanelHeight = 128;

  // ── Icon containers ──────────────────────────────────────────────────────
  /// Small icon container (40 × 40 dp) — file-list status circle, etc.
  static const double iconContainerSm = 40;

  // ── Form fields ─────────────────────────────────────────────────────────
  /// Compact text field height (36 dp) — context-tag bar, inline search.
  static const double fieldHeightSm = 36;

  // ── Upload / mochi character sizing ─────────────────────────────────────
  /// Mochi character size inside the upload hero panel (80 dp).
  static const double heroMochiSize = 80;
}
