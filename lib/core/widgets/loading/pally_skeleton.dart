import 'package:flutter/material.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';

/// Animated shimmer skeleton for content lists (Pattern B).
/// Shows while the first network load is in flight; swaps to real content on success.
/// Has a ~400ms minimum-display floor baked in via [DelayedLoader].

// ── Shimmer animation ─────────────────────────────────────────────────────────

class _Shimmer extends StatefulWidget {
  const _Shimmer({required this.child});
  final Widget child;

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _anim = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                Color(0xFFEAE6F4),
                Color(0xFFF5F2FC),
                Color(0xFFEAE6F4),
              ],
              stops: const [0.0, 0.5, 1.0],
              transform: _GradientTransform(_anim.value),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _GradientTransform extends GradientTransform {
  const _GradientTransform(this.offset);
  final double offset;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * offset, 0, 0);
  }
}

// ── Skeleton block primitives ─────────────────────────────────────────────────

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });
  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFEAE6F4),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

// ── Public skeleton widgets ───────────────────────────────────────────────────

/// One skeleton row shaped like a tutor/avatar card (avatar circle + 2 text lines).
class PallyAvatarCardSkeleton extends StatelessWidget {
  const PallyAvatarCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return _Shimmer(
      child: Container(
        padding: AppSpacing.card,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outline),
        ),
        child: Row(
          children: [
            const _SkeletonBox(width: 52, height: 52, borderRadius: 12),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SkeletonBox(width: MediaQuery.of(context).size.width * 0.35, height: 14),
                  const SizedBox(height: 6),
                  _SkeletonBox(width: MediaQuery.of(context).size.width * 0.22, height: 11),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Vertical list of [count] avatar-card skeletons.
class PallyAvatarListSkeleton extends StatelessWidget {
  const PallyAvatarListSkeleton({super.key, this.count = 4});
  final int count;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: count,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (_, __) => const PallyAvatarCardSkeleton(),
    );
  }
}

/// Generic shimmer block — use for progress bars, stat tiles, etc.
class PallyBlockSkeleton extends StatelessWidget {
  const PallyBlockSkeleton({
    super.key,
    this.height = 80,
    this.borderRadius = 16,
  });
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return _Shimmer(
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: AppColors.outline),
        ),
      ),
    );
  }
}

/// A grid-style skeleton for album/collection screens.
class PallyGridSkeleton extends StatelessWidget {
  const PallyGridSkeleton({super.key, this.count = 6, this.crossAxisCount = 3});
  final int count;
  final int crossAxisCount;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: count,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (_, __) => _Shimmer(
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.outline),
          ),
        ),
      ),
    );
  }
}

/// Wraps an async state: shows skeleton during load, child on data, error card on error.
/// Enforces a ~400ms minimum-display floor so a fast call doesn't flash a skeleton.
class DelayedLoader extends StatefulWidget {
  const DelayedLoader({
    super.key,
    required this.isLoading,
    required this.skeleton,
    required this.child,
    this.delayMs = 200,
    this.minDisplayMs = 400,
  });

  final bool isLoading;
  final Widget skeleton;
  final Widget child;
  /// Wait this long before showing the skeleton (kills flicker on fast calls).
  final int delayMs;
  /// Once shown, keep skeleton visible for at least this long.
  final int minDisplayMs;

  @override
  State<DelayedLoader> createState() => _DelayedLoaderState();
}

class _DelayedLoaderState extends State<DelayedLoader> {
  bool _showSkeleton = false;
  bool _holdingMinimum = false;

  @override
  void initState() {
    super.initState();
    if (widget.isLoading) _scheduleShow();
  }

  @override
  void didUpdateWidget(DelayedLoader old) {
    super.didUpdateWidget(old);
    if (!old.isLoading && widget.isLoading) {
      _scheduleShow();
    } else if (old.isLoading && !widget.isLoading && !_holdingMinimum) {
      setState(() => _showSkeleton = false);
    }
  }

  void _scheduleShow() {
    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (!mounted || !widget.isLoading) return;
      setState(() {
        _showSkeleton = true;
        _holdingMinimum = true;
      });
      Future.delayed(Duration(milliseconds: widget.minDisplayMs), () {
        if (!mounted) return;
        setState(() {
          _holdingMinimum = false;
          if (!widget.isLoading) _showSkeleton = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _showSkeleton ? widget.skeleton : widget.child;
  }
}
