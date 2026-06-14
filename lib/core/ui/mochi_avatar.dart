import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pally/shared/models/mochi_config.dart';

/// Renders a centre-designed class Mochi from a [MochiConfig], matching the web
/// customiser (`memoly-web` `MochiAvatar.tsx`).
///
/// Layers (bottom → top), all sized to [size] inside a [Stack]:
///  1. Aura glow + ring (only when `aura != 'none'`).
///  2. The pale-yellow base PNG (`assets/images/mochi_base_transparent.png`),
///     recoloured via a [ColorFilter.matrix] that replicates the web's CSS
///     `filter: hue-rotate() saturate() brightness()` for the chosen body.
///  3. An accessory + aura overlay drawn on a 170×170 logical canvas (matching
///     the web SVG viewBox) and scaled to [size].
///
/// Eyes and cheeks are baked into the base art, so this widget never draws
/// them — it only controls body colour, accessory and aura.
class MochiAvatar extends StatefulWidget {
  const MochiAvatar({
    super.key,
    required this.config,
    this.size = 120,
    this.animate = false,
  });

  final MochiConfig config;
  final double size;

  /// Subtle "breathing" scale animation. Default off so static contexts
  /// (lists, golden tests) render deterministically.
  final bool animate;

  @override
  State<MochiAvatar> createState() => _MochiAvatarState();
}

class _MochiAvatarState extends State<MochiAvatar>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.animate) _startAnimation();
  }

  void _startAnimation() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant MochiAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && _controller == null) {
      _startAnimation();
    } else if (!widget.animate && _controller != null) {
      _controller!.dispose();
      _controller = null;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final config = widget.config;
    final hasAura = config.aura != 'none';

    final variant = bodyVariantAt(config.body);
    final matrix = cssFilterColorMatrix(
      hueDegrees: variant.hue,
      saturate: variant.saturate,
      brightness: variant.brightness,
    );

    Widget base = Image.asset(
      'assets/images/mochi_base_transparent.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );

    // Body recolour. Variant 0 is identity (avatar unchanged) but we still
    // apply the filter uniformly — an identity matrix is a no-op visually.
    base = ColorFiltered(
      colorFilter: ColorFilter.matrix(matrix),
      child: base,
    );

    if (_controller != null) {
      base = ScaleTransition(
        // Breathe between 0.98 and 1.02 around the bottom centre.
        scale: Tween<double>(begin: 0.98, end: 1.02).animate(
          CurvedAnimation(parent: _controller!, curve: Curves.easeInOut),
        ),
        alignment: Alignment.bottomCenter,
        child: base,
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (hasAura) ...[
            // 1a. Soft radial glow behind everything.
            Positioned(
              left: -size * 0.06,
              top: -size * 0.06,
              right: -size * 0.06,
              bottom: -size * 0.06,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _auraGlowColor(config.aura),
                      _auraGlowColor(config.aura).withValues(alpha: 0),
                    ],
                    stops: const [0.0, 0.7],
                  ),
                ),
              ),
            ),
            // 1b. Aura ring.
            Positioned(
              left: size * 0.02,
              top: size * 0.02,
              right: size * 0.02,
              bottom: size * 0.02,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _auraRingColor(config.aura),
                    width: math.max(1.5, size * 0.015),
                  ),
                ),
              ),
            ),
          ],
          // 2. Recoloured base PNG.
          Positioned.fill(child: base),
          // 3. Accessory + aura overlay.
          Positioned.fill(
            child: CustomPaint(
              painter: _MochiOverlayPainter(
                accessory: config.accessory,
                aura: config.aura,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Aura colours ──────────────────────────────────────────────────────────
//
// The web uses a single warm-yellow glow for every aura, plus a translucent
// white ring (see MochiAvatar.tsx). We keep the white ring tinted per-aura so
// the aura reads at a glance even in small list contexts, per the task brief
// (sparkle=amber, fire=orange-red, chill=cyan, electric=lime, bloom=pink).

Color _auraRingColor(String aura) {
  switch (aura) {
    case 'sparkle':
      return const Color(0xFFFFB81A); // amber
    case 'fire':
      return const Color(0xFFFF5A2C); // orange-red
    case 'chill':
      return const Color(0xFF4DD0E1); // cyan
    case 'electric':
      return const Color(0xFFC6FF00); // lime
    case 'bloom':
      return const Color(0xFFFF6BAE); // pink
    default:
      return const Color(0x59FFFFFF); // translucent white (web default)
  }
}

Color _auraGlowColor(String aura) {
  switch (aura) {
    case 'sparkle':
      return const Color(0x59FFB81A);
    case 'fire':
      return const Color(0x59FF5A2C);
    case 'chill':
      return const Color(0x594DD0E1);
    case 'electric':
      return const Color(0x59C6FF00);
    case 'bloom':
      return const Color(0x59FF6BAE);
    default:
      return const Color(0x59FFD65E); // web warm-yellow glow rgba(255,214,94,.35)
  }
}

// ── Body variants (mirror web BODY_VARIANTS in src/lib/api.ts) ──────────────

/// A CSS-filter recipe that recolours the pale-yellow base PNG.
class MochiBodyVariant {
  const MochiBodyVariant(this.name, this.hue, this.saturate, this.brightness);
  final String name;

  /// hue-rotate(deg)
  final double hue;

  /// saturate(x)
  final double saturate;

  /// brightness(x)
  final double brightness;
}

/// 12 body colour variants, 1:1 with the web `BODY_VARIANTS` table.
const List<MochiBodyVariant> kMochiBodyVariants = [
  MochiBodyVariant('Butter', 0, 1, 1),
  MochiBodyVariant('Peach', -22, 1.25, 1.02),
  MochiBodyVariant('Coral', -38, 1.6, 0.98),
  MochiBodyVariant('Rose', -60, 1.4, 1),
  MochiBodyVariant('Bubblegum', -85, 1.5, 1.04),
  MochiBodyVariant('Lilac', 220, 1.2, 1.02),
  MochiBodyVariant('Periwinkle', 190, 1.3, 1),
  MochiBodyVariant('Sky', 160, 1.35, 1.02),
  MochiBodyVariant('Mint', 95, 1.2, 1.02),
  MochiBodyVariant('Matcha', 60, 1.25, 0.98),
  MochiBodyVariant('Sand', 18, 0.8, 1),
  MochiBodyVariant('Slate', 200, 0.4, 0.92),
];

/// Clamped lookup into [kMochiBodyVariants].
MochiBodyVariant bodyVariantAt(int index) {
  if (index < 0) return kMochiBodyVariants.first;
  if (index >= kMochiBodyVariants.length) return kMochiBodyVariants.last;
  return kMochiBodyVariants[index];
}

// ── CSS filter → ColorFilter.matrix ─────────────────────────────────────────

/// W3C luminance coefficients used by both hue-rotate and saturate.
const double _lr = 0.213;
const double _lg = 0.715;
const double _lb = 0.072;

/// Builds the 4×5 (20-element, row-major) colour matrix for Flutter's
/// [ColorFilter.matrix] that replicates the CSS pipeline
/// `filter: hue-rotate(Hdeg) saturate(S) brightness(B)`.
///
/// CSS applies filters left-to-right, so the colour `c` flows through
/// hue-rotate first, then saturate, then brightness:
///   out = brightness( saturate( hueRotate(c) ) )
/// As matrices that means `M = B · S · H` (later transform multiplies on the
/// left). We compose 5×5 affine matrices then drop the constant row.
///
/// Variant 0 (hue 0, saturate 1, brightness 1) yields the identity matrix, so
/// the base art renders unchanged.
List<double> cssFilterColorMatrix({
  required double hueDegrees,
  required double saturate,
  required double brightness,
}) {
  final h = _hueRotateMatrix(hueDegrees);
  final s = _saturateMatrix(saturate);
  final b = _brightnessMatrix(brightness);

  // out = B(S(H(c)))  →  M = B · S · H
  final m = _multiply(b, _multiply(s, h));
  return _to4x5(m);
}

/// 5×5 row-major hue-rotate matrix (SVG feColorMatrix type="hueRotate").
List<double> _hueRotateMatrix(double degrees) {
  final rad = degrees * math.pi / 180.0;
  final cos = math.cos(rad);
  final sin = math.sin(rad);

  // Per the W3C formula, each RGB output is luminance + cos·(c-luminance)
  // + sin·(rotation term). Expanded into a 3×3 then padded to 5×5 affine.
  final m = <double>[
    // R row
    _lr + cos * (1 - _lr) + sin * (-_lr),
    _lg + cos * (-_lg) + sin * (-_lg),
    _lb + cos * (-_lb) + sin * (1 - _lb),
    0, 0,
    // G row
    _lr + cos * (-_lr) + sin * (0.143),
    _lg + cos * (1 - _lg) + sin * (0.140),
    _lb + cos * (-_lb) + sin * (-0.283),
    0, 0,
    // B row
    _lr + cos * (-_lr) + sin * (-(1 - _lr)),
    _lg + cos * (-_lg) + sin * (_lg),
    _lb + cos * (1 - _lb) + sin * (_lb),
    0, 0,
    // A row
    0, 0, 0, 1, 0,
    // constant row
    0, 0, 0, 0, 1,
  ];
  return m;
}

/// 5×5 row-major saturate matrix (W3C saturate, same luminance coeffs).
List<double> _saturateMatrix(double s) {
  return <double>[
    _lr + s * (1 - _lr), _lg * (1 - s), _lb * (1 - s), 0, 0,
    _lr * (1 - s), _lg + s * (1 - _lg), _lb * (1 - s), 0, 0,
    _lr * (1 - s), _lg * (1 - s), _lb + s * (1 - _lb), 0, 0,
    0, 0, 0, 1, 0,
    0, 0, 0, 0, 1,
  ];
}

/// 5×5 row-major brightness matrix (scale R,G,B by b).
List<double> _brightnessMatrix(double b) {
  return <double>[
    b, 0, 0, 0, 0,
    0, b, 0, 0, 0,
    0, 0, b, 0, 0,
    0, 0, 0, 1, 0,
    0, 0, 0, 0, 1,
  ];
}

/// Multiplies two 5×5 row-major matrices: returns `a · b`.
List<double> _multiply(List<double> a, List<double> b) {
  final out = List<double>.filled(25, 0);
  for (var r = 0; r < 5; r++) {
    for (var c = 0; c < 5; c++) {
      var sum = 0.0;
      for (var k = 0; k < 5; k++) {
        sum += a[r * 5 + k] * b[k * 5 + c];
      }
      out[r * 5 + c] = sum;
    }
  }
  return out;
}

/// Drops the constant (5th) row of a 5×5 matrix to produce the 4×5 form
/// Flutter's [ColorFilter.matrix] expects (constant term scaled to 0-255).
List<double> _to4x5(List<double> m) {
  final out = List<double>.filled(20, 0);
  for (var r = 0; r < 4; r++) {
    for (var c = 0; c < 5; c++) {
      var v = m[r * 5 + c];
      // The 5th column is a constant offset; CSS works in 0-1, Flutter's
      // matrix offset column is in 0-255, so scale it up.
      if (c == 4) v *= 255.0;
      out[r * 5 + c] = v;
    }
  }
  return out;
}

// ── Accessory + aura overlay painter ────────────────────────────────────────

/// Draws the accessory and aura overlay on a 170×170 logical canvas (matching
/// the web SVG viewBox) scaled to the widget size. Shapes are ported from
/// `accessorySVG`/`auraSVG` in the web `MochiAvatar.tsx`.
class _MochiOverlayPainter extends CustomPainter {
  const _MochiOverlayPainter({required this.accessory, required this.aura});

  final String accessory;
  final String aura;

  // Baked-in eye coords (measured from base art, 170 viewBox).
  static const double _lx = 65; // left eye centre x
  static const double _rx = 104; // right eye centre x
  static const double _ey = 89; // eye centre y

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 170.0;
    canvas.save();
    canvas.scale(scale, scale);

    _paintAccessory(canvas);
    _paintAura(canvas);

    canvas.restore();
  }

  // ── Accessories ──────────────────────────────────────────────────────────
  void _paintAccessory(Canvas canvas) {
    switch (accessory) {
      case 'bow':
        _paintBow(canvas);
        break;
      case 'cap':
        _paintCap(canvas);
        break;
      case 'glasses':
        _paintGlasses(canvas);
        break;
      case 'crown':
        _paintCrown(canvas);
        break;
      case 'headband':
        _paintHeadband(canvas);
        break;
      default:
        break;
    }
  }

  void _paintBow(Canvas canvas) {
    const cx = 50.0, cy = 30.0;
    final fill = Paint()..color = const Color(0xFFFF6F9C);
    final left = Path()
      ..moveTo(cx, cy)
      ..lineTo(cx - 16, cy - 9)
      ..lineTo(cx - 16, cy + 9)
      ..close();
    final right = Path()
      ..moveTo(cx, cy)
      ..lineTo(cx + 16, cy - 9)
      ..lineTo(cx + 16, cy + 9)
      ..close();
    canvas.drawPath(left, fill);
    canvas.drawPath(right, fill);
    canvas.drawCircle(
        const Offset(cx, cy), 5, Paint()..color = const Color(0xFFE84F86));
  }

  void _paintCap(Canvas canvas) {
    const cx = 85.0, y = 30.0;
    final dark = Paint()..color = const Color(0xFF2C2C3A);
    final mortar = Path()
      ..moveTo(cx - 26, y + 4)
      ..lineTo(cx, y - 6)
      ..lineTo(cx + 26, y + 4)
      ..lineTo(cx, y + 14)
      ..close();
    canvas.drawPath(mortar, dark);
    final band = RRect.fromRectAndRadius(
      const Rect.fromLTWH(cx - 12, y + 8, 24, 9),
      const Radius.circular(2),
    );
    canvas.drawRRect(band, dark);
    final gold = Paint()
      ..color = const Color(0xFFFFD44D)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(cx + 22, y + 2), const Offset(cx + 22, y + 18),
        gold);
    canvas.drawCircle(
        const Offset(cx + 22, y + 19), 3, Paint()..color = const Color(0xFFFFD44D));
  }

  void _paintGlasses(Canvas canvas) {
    const r = 13.0;
    final stroke = Paint()
      ..color = const Color(0xFF2C2C3A)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(const Offset(_lx, _ey), r, stroke);
    canvas.drawCircle(const Offset(_rx, _ey), r, stroke);
    canvas.drawLine(
        const Offset(_lx + r, _ey), const Offset(_rx - r, _ey), stroke);
  }

  void _paintCrown(Canvas canvas) {
    const cx = 85.0, base = 36.0, top = 18.0;
    final crown = Path()
      ..moveTo(cx - 26, base)
      ..lineTo(cx - 26, top + 6)
      ..lineTo(cx - 13, base - 6)
      ..lineTo(cx, top)
      ..lineTo(cx + 13, base - 6)
      ..lineTo(cx + 26, top + 6)
      ..lineTo(cx + 26, base)
      ..close();
    canvas.drawPath(crown, Paint()..color = const Color(0xFFFFCE3A));
    canvas.drawPath(
      crown,
      Paint()
        ..color = const Color(0xFFE0A800)
        ..strokeWidth = 1.5
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke,
    );
    canvas.drawCircle(const Offset(cx - 18, top + 8), 2.4,
        Paint()..color = const Color(0xFFE0533F));
    canvas.drawCircle(
        const Offset(cx, top + 2), 2.4, Paint()..color = const Color(0xFF3FA0E0));
    canvas.drawCircle(const Offset(cx + 18, top + 8), 2.4,
        Paint()..color = const Color(0xFF3FC06A));
  }

  void _paintHeadband(Canvas canvas) {
    const y = 38.0;
    final band = Path()
      ..moveTo(56, y)
      ..quadraticBezierTo(85, y - 12, 114, y);
    canvas.drawPath(
      band,
      Paint()
        ..color = const Color(0xFF5B8DF0)
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
    canvas.drawCircle(
        const Offset(110, y - 3), 4.5, Paint()..color = const Color(0xFFFFCE3A));
  }

  // ── Auras ──────────────────────────────────────────────────────────────
  void _paintAura(Canvas canvas) {
    switch (aura) {
      case 'sparkle':
        _sparkle(canvas, 24, 40, 5, const Color(0xFFFFD75E));
        _sparkle(canvas, 146, 52, 6, const Color(0xFFFFF0A8));
        _sparkle(canvas, 30, 120, 4, const Color(0xFFFFD75E));
        _sparkle(canvas, 140, 118, 5, const Color(0xFFFFF0A8));
        _sparkle(canvas, 90, 18, 4, const Color(0xFFFFE680));
        break;
      case 'fire':
        _flame(canvas, 60, 150, const Color(0xFFFF7A3C));
        _flame(canvas, 85, 156, const Color(0xFFFF5A2C));
        _flame(canvas, 110, 150, const Color(0xFFFF9A4C));
        break;
      case 'chill':
        _snowflake(canvas, 28, 46, 7);
        _snowflake(canvas, 142, 60, 8);
        _snowflake(canvas, 36, 124, 6);
        _snowflake(canvas, 132, 122, 7);
        break;
      case 'electric':
        _bolt(canvas, 26, 56);
        _bolt(canvas, 140, 70);
        break;
      case 'bloom':
        _flower(canvas, 26, 50, const Color(0xFFFF9EC4));
        _flower(canvas, 146, 60, const Color(0xFFFFC46A));
        _flower(canvas, 34, 124, const Color(0xFFB794F6));
        break;
      default:
        break;
    }
  }

  void _sparkle(Canvas canvas, double cx, double cy, double r, Color fill) {
    final p = Path()
      ..moveTo(cx, cy - r)
      ..quadraticBezierTo(cx, cy, cx + r, cy)
      ..quadraticBezierTo(cx, cy, cx, cy + r)
      ..quadraticBezierTo(cx, cy, cx - r, cy)
      ..quadraticBezierTo(cx, cy, cx, cy - r)
      ..close();
    canvas.drawPath(p, Paint()..color = fill);
  }

  void _flame(Canvas canvas, double cx, double cy, Color fill) {
    final p = Path()
      ..moveTo(cx, cy)
      ..cubicTo(cx - 8, cy - 8, cx - 6, cy - 18, cx, cy - 24)
      ..cubicTo(cx + 6, cy - 18, cx + 8, cy - 8, cx, cy)
      ..close();
    canvas.drawPath(p, Paint()..color = fill.withValues(alpha: 0.9));
  }

  void _snowflake(Canvas canvas, double cx, double cy, double r) {
    const c = Color(0xFF9FD8FF);
    final stroke = Paint()
      ..color = c
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(cx - r, cy), Offset(cx + r, cy), stroke);
    canvas.drawLine(Offset(cx, cy - r), Offset(cx, cy + r), stroke);
    canvas.drawLine(Offset(cx - r * 0.7, cy - r * 0.7),
        Offset(cx + r * 0.7, cy + r * 0.7), stroke);
    canvas.drawLine(Offset(cx - r * 0.7, cy + r * 0.7),
        Offset(cx + r * 0.7, cy - r * 0.7), stroke);
  }

  void _bolt(Canvas canvas, double cx, double cy) {
    final p = Path()
      ..moveTo(cx, cy)
      ..lineTo(cx + 8, cy)
      ..lineTo(cx + 2, cy + 9)
      ..lineTo(cx + 11, cy + 9)
      ..lineTo(cx - 2, cy + 24)
      ..lineTo(cx + 3, cy + 12)
      ..lineTo(cx - 4, cy + 12)
      ..close();
    canvas.drawPath(p, Paint()..color = const Color(0xFFFFE14D));
    canvas.drawPath(
      p,
      Paint()
        ..color = const Color(0xFFF0B400)
        ..strokeWidth = 0.8
        ..style = PaintingStyle.stroke,
    );
  }

  void _flower(Canvas canvas, double cx, double cy, Color fill) {
    final petal = Paint()..color = fill;
    for (final deg in const [0, 72, 144, 216, 288]) {
      final rad = deg * math.pi / 180.0;
      final px = cx + math.cos(rad) * 5;
      final py = cy + math.sin(rad) * 5;
      canvas.drawCircle(Offset(px, py), 3, petal);
    }
    canvas.drawCircle(
        Offset(cx, cy), 2.4, Paint()..color = const Color(0xFFFFF2A8));
  }

  @override
  bool shouldRepaint(covariant _MochiOverlayPainter old) =>
      old.accessory != accessory || old.aura != aura;
}
