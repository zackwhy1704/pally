import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';

const _kSeenKey = 'seen_feature_tour_v1';

// ── Anchor GlobalKeys — add these to the real widgets in the app ─────────────
// The tour reads widget positions via RenderBox; if a key's widget isn't
// in the tree, the step defaults to a centered card (never crashes).

final featureTourCreateMochiKey = GlobalKey(debugLabel: 'tour_create_mochi');
final featureTourModeToggleKey  = GlobalKey(debugLabel: 'tour_mode_toggle');
final featureTourLibraryTabKey  = GlobalKey(debugLabel: 'tour_library_tab');

// ── Tour step data ────────────────────────────────────────────────────────────

class _TourStep {
  const _TourStep({
    required this.emoji,
    required this.title,
    required this.body,
    this.cta,
    this.anchorKey,
    this.anchorPosition = _AnchorPos.center,
  });

  final String emoji;
  final String title;
  final String body;
  final String? cta;
  final GlobalKey? anchorKey;
  final _AnchorPos anchorPosition;
}

enum _AnchorPos { above, center }

List<_TourStep> _buildSteps() => [
  const _TourStep(
    emoji: '👋',
    title: 'Hi, I\'m Mochi!',
    body: 'Let me show you 4 quick things that make Pally different from any other study app.',
  ),
  _TourStep(
    emoji: '📚',
    title: 'A Mochi for every subject',
    body: 'Create one Mochi per subject — each one learns only YOUR notes, '
        'so every answer matches exactly what your teacher taught.',
    anchorKey: featureTourCreateMochiKey,
    anchorPosition: _AnchorPos.above,
  ),
  _TourStep(
    emoji: '🧭',
    title: 'Pick how I help',
    body: 'Guide Me walks you through the answer Socratically — '
        'you figure it out, you remember more.\n'
        'Just answer gives you the worked solution for checking your work.',
    anchorKey: featureTourModeToggleKey,
    anchorPosition: _AnchorPos.above,
  ),
  _TourStep(
    emoji: '📈',
    title: 'I remember what you find hard',
    body: 'The Library tracks your mastery by topic. When you get something wrong, '
        'I bring it back — spaced and scheduled — until it sticks.',
    anchorKey: featureTourLibraryTabKey,
    anchorPosition: _AnchorPos.above,
  ),
  const _TourStep(
    emoji: '🚀',
    title: 'Not a tutor that knows the textbook.',
    body: 'A Mochi that knows yours.',
    cta: 'Make my first Mochi',
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
    with SingleTickerProviderStateMixin {
  int _step = 0;
  late final List<_TourStep> _steps;
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _steps = _buildSteps();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250))
      ..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_step < _steps.length - 1) {
      setState(() => _step++);
    } else {
      _dismiss();
    }
  }

  void _dismiss() {
    _fadeCtrl.reverse().then((_) {
      if (mounted) Navigator.of(context).pop();
    });
  }

  // Find the screen-space rect of an anchored widget, or null if not in tree.
  Rect? _anchorRect(GlobalKey? key) {
    if (key == null) return null;
    final obj = key.currentContext?.findRenderObject();
    if (obj is! RenderBox || !obj.hasSize) return null;
    final pos = obj.localToGlobal(Offset.zero);
    return pos & obj.size;
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_step];
    final size = MediaQuery.of(context).size;
    final anchorRect = _anchorRect(step.anchorKey);

    // Card vertical placement
    double cardTop;
    if (anchorRect != null) {
      if (step.anchorPosition == _AnchorPos.above) {
        cardTop = (anchorRect.top - 220).clamp(60.0, size.height - 280);
      } else {
        cardTop = (anchorRect.bottom + 16).clamp(60.0, size.height - 280);
      }
    } else {
      // No anchor — center on screen
      cardTop = (size.height - 260) / 2;
    }

    final isLast = _step == _steps.length - 1;

    return FadeTransition(
      opacity: _fadeAnim,
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            // Dim backdrop with blur
            Positioned.fill(
              child: GestureDetector(
                onTap: _dismiss,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.55),
                  ),
                ),
              ),
            ),

            // Anchor highlight (if anchored)
            if (anchorRect != null)
              Positioned(
                left: anchorRect.left - 8,
                top: anchorRect.top - 8,
                child: Container(
                  width: anchorRect.width + 16,
                  height: anchorRect.height + 16,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppColors.gold, width: 2.5),
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),

            // Step card
            Positioned(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              top: cardTop,
              child: _StepCard(
                step: step,
                stepIndex: _step,
                total: _steps.length,
                isLast: isLast,
                onNext: _next,
                onSkip: _dismiss,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.step,
    required this.stepIndex,
    required this.total,
    required this.isLast,
    required this.onNext,
    required this.onSkip,
  });

  final _TourStep step;
  final int stepIndex;
  final int total;
  final bool isLast;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Dots + skip
          Row(
            children: [
              ...List.generate(total, (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 6),
                    width: i == stepIndex ? 20 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: i == stepIndex
                          ? AppColors.purple
                          : AppColors.outline,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  )),
              const Spacer(),
              if (!isLast)
                TextButton(
                  onPressed: onSkip,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(44, 32),
                  ),
                  child: Text('Skip',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.text3)),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Emoji + title
          Text(step.emoji, style: const TextStyle(fontSize: 40)),
          const SizedBox(height: AppSpacing.xs),
          Text(step.title,
              style: AppTextStyles.title.copyWith(fontSize: 20)),
          const SizedBox(height: AppSpacing.xs),
          Text(step.body,
              style: AppTextStyles.body.copyWith(color: AppColors.text2)),
          const SizedBox(height: AppSpacing.lg),

          // CTA
          FilledButton(
            onPressed: onNext,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.purple,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(vertical: 13),
            ),
            child: Text(
              isLast
                  ? (step.cta ?? 'Done!')
                  : (stepIndex == 0 ? 'Show me!' : 'Next →'),
              style: AppTextStyles.body.copyWith(
                  color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
