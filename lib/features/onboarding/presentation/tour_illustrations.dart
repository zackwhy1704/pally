import 'package:flutter/material.dart';
import 'package:pally/core/theme/app_colors.dart';

/// Per-step tour illustrations — compact (~96dp), hand-built with stock Flutter
/// animation only (no gif/Lottie/asset pipeline). Each animates on a soft loop when
/// [animate] is true and shows a representative STATIC frame when false (reduced
/// motion), so the widget renders complete either way and never keeps a test's
/// pumpAndSettle spinning.
enum TourIllustration { mascot, notesToBrain, learnTestProve, mastery }

class TourIllustrationWidget extends StatefulWidget {
  const TourIllustrationWidget({super.key, required this.kind, required this.animate});
  final TourIllustration kind;
  final bool animate;

  @override
  State<TourIllustrationWidget> createState() => _TourIllustrationWidgetState();
}

class _TourIllustrationWidgetState extends State<TourIllustrationWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 4));
    _apply();
  }

  @override
  void didUpdateWidget(TourIllustrationWidget old) {
    super.didUpdateWidget(old);
    if (old.animate != widget.animate || old.kind != widget.kind) _apply();
  }

  void _apply() {
    if (widget.animate) {
      if (!_c.isAnimating) _c.repeat();
    } else {
      _c.stop();
      _c.value = 0.5; // representative static frame
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 92,
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, __) => CustomPaint(
          painter: _IllustrationPainter(widget.kind, _c.value),
          child: widget.kind == TourIllustration.mascot
              ? Center(child: _mascot(_c.value))
              : const SizedBox.expand(),
        ),
      ),
    );
  }

  Widget _mascot(double t) {
    final pulse = 0.95 + 0.05 * (0.5 - (t - 0.5).abs()) * 2; // gentle scale
    return Transform.scale(
      scale: pulse,
      child: Image.asset('assets/images/splash_mochi.png',
          height: 72, errorBuilder: (_, __, ___) => _sparkle(t)),
    );
  }

  Widget _sparkle(double t) => Icon(Icons.auto_awesome,
      size: 56, color: AppColors.gold.withValues(alpha: 0.7 + 0.3 * t));
}

class _IllustrationPainter extends CustomPainter {
  _IllustrationPainter(this.kind, this.t);
  final TourIllustration kind;
  final double t; // 0..1

  @override
  void paint(Canvas canvas, Size size) {
    switch (kind) {
      case TourIllustration.mascot:
        break; // drawn as a child widget
      case TourIllustration.notesToBrain:
        _notesToBrain(canvas, size);
      case TourIllustration.learnTestProve:
        _learnTestProve(canvas, size);
      case TourIllustration.mastery:
        _mastery(canvas, size);
    }
  }

  // A page slides from the left into a rounded "brain" bubble on the right.
  void _notesToBrain(Canvas canvas, Size size) {
    final cy = size.height / 2;
    final brainC = Offset(size.width * 0.72, cy);
    canvas.drawCircle(brainC, 26, Paint()..color = AppColors.purpleL);
    final tp = _text('🧠', 30);
    tp.paint(canvas, brainC - Offset(tp.width / 2, tp.height / 2));
    // travelling doc: 0.15 → 0.6 of width, fading as it arrives
    final dx = size.width * (0.18 + 0.42 * t);
    final fade = (1 - t).clamp(0.2, 1.0);
    final doc = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(dx, cy), width: 26, height: 34),
        const Radius.circular(4));
    canvas.drawRRect(doc, Paint()..color = AppColors.surface.withValues(alpha: fade));
    canvas.drawRRect(doc,
        Paint()..style = PaintingStyle.stroke..strokeWidth = 2..color = AppColors.purpleC.withValues(alpha: fade));
    for (var i = 0; i < 3; i++) {
      final ly = cy - 8 + i * 8.0;
      canvas.drawLine(Offset(dx - 8, ly), Offset(dx + 8, ly),
          Paint()..strokeWidth = 2..color = AppColors.text3.withValues(alpha: fade));
    }
  }

  // Three phases cycle: learn (book) → test (check) → prove (trophy).
  void _learnTestProve(Canvas canvas, Size size) {
    const icons = ['📖', '✅', '🏆'];
    final active = (t * 3).floor() % 3;
    final slot = size.width / 3;
    for (var i = 0; i < 3; i++) {
      final c = Offset(slot * (i + 0.5), size.height / 2);
      final on = i == active;
      canvas.drawCircle(c, on ? 26 : 22,
          Paint()..color = on ? AppColors.purpleL : AppColors.surf2);
      if (on) {
        canvas.drawCircle(c, 26,
            Paint()..style = PaintingStyle.stroke..strokeWidth = 2.5..color = AppColors.purple);
      }
      final tp = _text(icons[i], on ? 26 : 22);
      tp.paint(canvas, c - Offset(tp.width / 2, tp.height / 2));
    }
  }

  // A mastery bar fills; a red "wrong-answer" dot appears then cycles back in.
  void _mastery(Canvas canvas, Size size) {
    final cy = size.height / 2;
    final left = size.width * 0.12, right = size.width * 0.88;
    final track = Paint()..color = AppColors.surf2..strokeWidth = 12..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(left, cy), Offset(right, cy), track);
    final fillT = 0.25 + 0.6 * (0.5 - (t - 0.5).abs()) * 2; // fills then eases back
    final fill = Paint()..color = AppColors.green..strokeWidth = 12..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(left, cy), Offset(left + (right - left) * fillT, cy), fill);
    // wrong-answer dot re-entering from the right, cycling.
    final dotX = right - (right - left) * ((t * 1.0) % 1.0) * 0.5;
    canvas.drawCircle(Offset(dotX, cy - 22), 5, Paint()..color = AppColors.coral);
  }

  TextPainter _text(String s, double fontSize) {
    final tp = TextPainter(
      text: TextSpan(text: s, style: TextStyle(fontSize: fontSize)),
      textDirection: TextDirection.ltr,
    )..layout();
    return tp;
  }

  @override
  bool shouldRepaint(_IllustrationPainter old) => old.t != t || old.kind != kind;
}
