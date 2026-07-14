import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/features/onboarding/presentation/tour_illustrations.dart';

// v3: positioning fix (card in the larger free region, never in the bottom strip),
// back navigation (button + swipe + tappable dots + system-back), and native motion
// (spotlight cutout + pulse, pointer, per-step illustrations). Bumped from v2 so
// testers see the improved tour once.
const _kSeenKey = 'seen_feature_tour_v3';

// ── Anchor GlobalKeys (home + shell — single-instance, safe) ─────────────────
final featureTourCreateMochiKey = GlobalKey(debugLabel: 'tour_create_mochi');
final featureTourLibraryTabKey  = GlobalKey(debugLabel: 'tour_library_tab');

// ── Tour step data ────────────────────────────────────────────────────────────

class _TourStep {
  const _TourStep({
    required this.emoji,
    required this.title,
    required this.body,
    required this.illustration,
    this.cta,
    this.anchorKey,
  });

  final String emoji;
  final String title;
  final String body;
  final TourIllustration illustration;
  final String? cta;
  final GlobalKey? anchorKey;
}

List<_TourStep> _buildSteps() => [
  const _TourStep(
    emoji: '👋',
    title: 'Hi, I\'m Mochi!',
    body: 'Let me show you 4 quick things that make Apalchi different from any other study app.',
    illustration: TourIllustration.mascot,
  ),
  _TourStep(
    emoji: '📚',
    title: 'A Mochi for every subject',
    body: 'Create one Mochi per subject — each one learns only YOUR notes, '
        'so every answer matches exactly what your teacher taught.',
    illustration: TourIllustration.notesToBrain,
    anchorKey: featureTourCreateMochiKey,
  ),
  _TourStep(
    emoji: '🎯',
    title: 'Learn it. Test it. Prove it.',
    body: 'Every topic becomes a mini-mission: quick cards to learn, '
        'hot-takes to test yourself, and a challenge to prove it — '
        'what you get wrong, I bring back until it sticks.',
    illustration: TourIllustration.learnTestProve,
    anchorKey: featureTourLibraryTabKey,
  ),
  _TourStep(
    emoji: '📈',
    title: 'I remember what you find hard',
    body: 'The Library tracks your mastery by topic. When you get something wrong, '
        'I bring it back — spaced and scheduled — until it sticks.',
    illustration: TourIllustration.mastery,
    anchorKey: featureTourLibraryTabKey,
  ),
  const _TourStep(
    emoji: '🚀',
    title: 'Not a generic AI — a Mochi that knows yours.',
    body: 'Upload your notes and every answer, quiz, and challenge comes from '
        'what YOUR teacher taught.',
    illustration: TourIllustration.mascot,
    // 'Start' — a single short word so the final CTA never wraps to two lines at
    // large text scale / on narrow devices (the equal-width Expandeds are fine).
    cta: 'Start',
  ),
];

// ── Public API ────────────────────────────────────────────────────────────────

class FeatureTour {
  /// Shows once after first home render; subsequent launches skip it.
  static Future<void> maybeShow(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_kSeenKey) ?? false) return;
    if (!context.mounted) return;
    await show(context);
    await prefs.setBool(_kSeenKey, true);
  }

  /// Always shows — called from Settings → "Replay tour".
  static Future<void> show(BuildContext context) async {
    await Navigator.of(context, rootNavigator: true).push<void>(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.transparent,
        pageBuilder: (_, __, ___) => const _FeatureTourPage(),
      ),
    );
  }
}

// ── Tour overlay ──────────────────────────────────────────────────────────────

class _FeatureTourPage extends StatefulWidget {
  const _FeatureTourPage();

  @override
  State<_FeatureTourPage> createState() => _FeatureTourPageState();
}

class _FeatureTourPageState extends State<_FeatureTourPage>
    with TickerProviderStateMixin {
  int _step = 0;
  late final List<_TourStep> _steps;
  late final AnimationController _fadeCtrl;   // overlay entrance/exit (finite)
  late final AnimationController _pulseCtrl;  // spotlight + pointer loop (gated)

  @override
  void initState() {
    super.initState();
    _steps = _buildSteps();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250))
      ..forward();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1600));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reduced-motion: never start the repeating loop when the platform asks for
    // no animations — otherwise the spotlight/pointer would animate forever AND
    // pumpAndSettle in tests would time out. Static frame instead.
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduce) {
      _pulseCtrl.stop();
      _pulseCtrl.value = 0;
    } else if (!_pulseCtrl.isAnimating) {
      _pulseCtrl.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  bool get _isFirst => _step == 0;
  bool get _isLast => _step == _steps.length - 1;

  void _next() {
    if (!_isLast) {
      setState(() => _step++);
    } else {
      _dismiss();
    }
  }

  void _back() {
    if (!_isFirst) setState(() => _step--);
  }

  void _jumpTo(int i) {
    if (i >= 0 && i < _steps.length && i != _step) setState(() => _step = i);
  }

  void _dismiss() {
    _fadeCtrl.reverse().then((_) {
      if (mounted) Navigator.of(context).pop();
    });
  }

  Rect? _anchorRect(_TourStep step) {
    final obj = step.anchorKey?.currentContext?.findRenderObject();
    if (obj is! RenderBox || !obj.hasSize) return null;
    return obj.localToGlobal(Offset.zero) & obj.size;
  }

  /// Place the card in the LARGER free region relative to the anchor, never hugging
  /// it (the pointer carries the connection). Anchor in the bottom half → card in the
  /// upper zone, capped at 60% of the height so its buttons stay well clear of the
  /// bottom-nav / gesture bar (the v2 squeeze). Anchor in the top half → card below
  /// it. Null anchor → centered. Returns (top, maxHeight, pointsDown).
  _CardSlot _cardSlot(Rect? anchorRect, Size size, EdgeInsets safe) {
    final bandTop = safe.top + 24;
    final bandBottom = size.height - safe.bottom - 24;
    if (anchorRect == null) {
      return _CardSlot(top: bandTop, maxHeight: bandBottom - bandTop, pointsDown: false, centered: true);
    }
    final anchorInBottomHalf = anchorRect.center.dy > size.height / 2;
    if (anchorInBottomHalf) {
      // Upper zone; cap the bottom at 60% height so buttons never sit in the strip.
      final maxBottom = size.height * 0.60;
      return _CardSlot(
        top: bandTop,
        maxHeight: (maxBottom - bandTop).clamp(160.0, bandBottom - bandTop),
        pointsDown: true,
        centered: false,
      );
    }
    // Anchor in top half → card below it.
    final top = (anchorRect.bottom + 24).clamp(bandTop, bandBottom - 160);
    return _CardSlot(
      top: top,
      maxHeight: bandBottom - top,
      pointsDown: false,
      centered: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_step];
    final mq = MediaQuery.of(context);
    final size = mq.size;
    final reduce = mq.disableAnimations;
    final anchorRect = _anchorRect(step);
    final slot = _cardSlot(anchorRect, size, mq.padding);

    return PopScope(
      // System back = go to the previous step; only pop the route on step 1.
      canPop: _isFirst,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: FadeTransition(
        opacity: CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut),
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            // Swipe left = next, swipe right = back. Whole overlay.
            onHorizontalDragEnd: (d) {
              final v = d.primaryVelocity ?? 0;
              if (v < -200) {
                _next();
              } else if (v > 200) {
                _back();
              }
            },
            child: Stack(
              children: [
                // Spotlight: dimmed overlay with a real cutout around the anchor,
                // gently pulsing. Tap outside dismisses.
                Positioned.fill(
                  child: GestureDetector(
                    onTap: _dismiss,
                    child: AnimatedBuilder(
                      animation: _pulseCtrl,
                      builder: (_, __) => CustomPaint(
                        painter: _SpotlightPainter(
                          anchor: anchorRect,
                          pulse: reduce ? 0.0 : _pulseCtrl.value,
                        ),
                      ),
                    ),
                  ),
                ),

                // Animated pointer from the card toward the cutout (skipped when null).
                if (anchorRect != null)
                  AnimatedBuilder(
                    animation: _pulseCtrl,
                    builder: (_, __) => CustomPaint(
                      size: size,
                      painter: _PointerPainter(
                        anchor: anchorRect,
                        cardTop: slot.top,
                        cardMaxHeight: slot.maxHeight,
                        pointsDown: slot.pointsDown,
                        t: reduce ? 0.5 : _pulseCtrl.value,
                      ),
                    ),
                  ),

                // Step card — position + content animate between steps.
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  left: AppSpacing.lg,
                  right: AppSpacing.lg,
                  top: slot.centered ? null : slot.top,
                  bottom: null,
                  child: slot.centered
                      ? const SizedBox.shrink()
                      : ConstrainedBox(
                          constraints: BoxConstraints(maxHeight: slot.maxHeight),
                          child: _cardSwitcher(step, reduce),
                        ),
                ),
                if (slot.centered)
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: slot.maxHeight),
                        child: _cardSwitcher(step, reduce),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _cardSwitcher(_TourStep step, bool reduce) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: reduce ? 0 : 200),
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween(begin: const Offset(0, 0.04), end: Offset.zero).animate(anim),
          child: child,
        ),
      ),
      child: _StepCard(
        key: ValueKey(_step),
        step: step,
        stepIndex: _step,
        total: _steps.length,
        isFirst: _isFirst,
        isLast: _isLast,
        animate: !reduce,
        onNext: _next,
        onBack: _back,
        onSkip: _dismiss,
        onDot: _jumpTo,
      ),
    );
  }
}

class _CardSlot {
  const _CardSlot({
    required this.top,
    required this.maxHeight,
    required this.pointsDown,
    required this.centered,
  });
  final double top;
  final double maxHeight;
  final bool pointsDown;
  final bool centered;
}

// ── Spotlight (dim + cutout + pulse) ───────────────────────────────────────────

class _SpotlightPainter extends CustomPainter {
  _SpotlightPainter({required this.anchor, required this.pulse});
  final Rect? anchor;
  final double pulse; // 0..1

  @override
  void paint(Canvas canvas, Size size) {
    final full = Offset.zero & size;
    final dim = Paint()..color = Colors.black.withValues(alpha: 0.62);
    if (anchor == null) {
      canvas.drawRect(full, dim);
      return;
    }
    // Punch a rounded-rect hole around the anchor (radius/glow gently pulsing).
    final grow = 8.0 + pulse * 4.0;
    final hole = RRect.fromRectAndRadius(
      anchor!.inflate(grow),
      const Radius.circular(16),
    );
    canvas.saveLayer(full, Paint());
    canvas.drawRect(full, dim);
    canvas.drawRRect(hole, Paint()..blendMode = BlendMode.clear);
    canvas.restore();
    // Gold glow ring on the cutout edge.
    canvas.drawRRect(
      hole,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0 + pulse * 1.5
        ..color = AppColors.gold.withValues(alpha: 0.5 + pulse * 0.4),
    );
  }

  @override
  bool shouldRepaint(_SpotlightPainter old) =>
      old.anchor != anchor || old.pulse != pulse;
}

// ── Pointer (chevron travelling toward the cutout) ─────────────────────────────

class _PointerPainter extends CustomPainter {
  _PointerPainter({
    required this.anchor,
    required this.cardTop,
    required this.cardMaxHeight,
    required this.pointsDown,
    required this.t,
  });
  final Rect anchor;
  final double cardTop;
  final double cardMaxHeight;
  final bool pointsDown;
  final double t; // 0..1 loop

  @override
  void paint(Canvas canvas, Size size) {
    // A small chevron mid-way between the card and the anchor, bobbing toward it.
    final x = anchor.center.dx.clamp(40.0, size.width - 40.0);
    final travel = 10.0 * (0.5 - (t - 0.5).abs()) * 2; // 0..10..0
    final double y;
    final int dir; // +1 down, -1 up
    if (pointsDown) {
      final from = cardTop + cardMaxHeight + 8;
      y = (from + travel).clamp(0.0, anchor.top - 8);
      dir = 1;
    } else {
      final from = cardTop - 8;
      y = (from - travel).clamp(anchor.bottom + 8, size.height);
      dir = -1;
    }
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = AppColors.gold;
    final path = Path()
      ..moveTo(x - 9, y)
      ..lineTo(x, y + dir * 9)
      ..lineTo(x + 9, y);
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(_PointerPainter old) => old.t != t || old.anchor != anchor;
}

// ── Step card ─────────────────────────────────────────────────────────────────

class _StepCard extends StatelessWidget {
  const _StepCard({
    super.key,
    required this.step,
    required this.stepIndex,
    required this.total,
    required this.isFirst,
    required this.isLast,
    required this.animate,
    required this.onNext,
    required this.onBack,
    required this.onSkip,
    required this.onDot,
  });

  final _TourStep step;
  final int stepIndex;
  final int total;
  final bool isFirst;
  final bool isLast;
  final bool animate;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback onSkip;
  final ValueChanged<int> onDot;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('tour_card'),
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      // Scroll internally so tall content (large text scale) never overflows the
      // bounded card height — the no-overflow discipline from the picker work.
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Dots (tappable) + Skip
            Row(
              children: [
                ...List.generate(total, (i) => _Dot(
                      active: i == stepIndex,
                      onTap: () => onDot(i),
                    )),
                const Spacer(),
                if (!isLast)
                  TextButton(
                    onPressed: onSkip,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(48, 40),
                    ),
                    child: Text('Skip',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.text3)),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // Per-step illustration (native motion; static under reduced-motion).
            Center(child: TourIllustrationWidget(kind: step.illustration, animate: animate)),
            const SizedBox(height: AppSpacing.sm),

            Text(step.title,
                textAlign: TextAlign.center,
                style: AppTextStyles.title.copyWith(fontSize: 20)),
            const SizedBox(height: AppSpacing.xs),
            Text(step.body,
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(color: AppColors.text2)),
            const SizedBox(height: AppSpacing.lg),

            // Back + Next row (Back only on steps ≥ 2).
            Row(
              children: [
                if (!isFirst) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onBack,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.text2,
                        side: const BorderSide(color: AppColors.outline),
                        minimumSize: const Size(0, 48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('← Back'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Expanded(
                  flex: isFirst ? 1 : 1,
                  child: FilledButton(
                    onPressed: onNext,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.purple,
                      minimumSize: const Size(0, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      isLast ? (step.cta ?? 'Done!') : (isFirst ? 'Show me!' : 'Next →'),
                      style: AppTextStyles.body.copyWith(
                          color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.active, required this.onTap});
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 6, top: 10, bottom: 10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: active ? 20 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: active ? AppColors.purple : AppColors.outline,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
