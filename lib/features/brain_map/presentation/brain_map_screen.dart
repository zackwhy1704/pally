import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/app/router.dart';
import 'package:pally/core/widgets/loading/pally_skeleton.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/error/pally_error.dart';
import 'package:pally/core/ui/pally_error_card.dart';
import 'package:pally/features/brain_map/presentation/brain_map_view_model.dart';

/// Dark-themed canvas that lays out every wiki page as a glowing topic node
/// connected to the central subject hub. Mastery from quiz_question_results
/// drives the colour — green/amber/red/grey for mastered/working/struggling/
/// untouched. Tap a node → bottom-sheet quick actions (quiz, wiki, teach).
class BrainMapScreen extends ConsumerStatefulWidget {
  const BrainMapScreen({super.key, required this.avatarId});

  final String avatarId;

  @override
  ConsumerState<BrainMapScreen> createState() => _BrainMapScreenState();
}

class _BrainMapScreenState extends ConsumerState<BrainMapScreen> {
  // Cached layout positions, recomputed when node count changes.
  List<Offset>? _positions;
  int _laidOutCount = -1;
  Size _laidOutSize = Size.zero;

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(brainMapViewModelProvider(widget.avatarId));
    return Scaffold(
      backgroundColor: const Color(0xFF0E0925),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('Brain Map',
            style: AppTextStyles.title.copyWith(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
            onPressed: () => ref
                .read(brainMapViewModelProvider(widget.avatarId).notifier)
                .refresh(widget.avatarId),
          ),
        ],
      ),
      body: asyncState.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: PallyAvatarListSkeleton(count: 2),
        ),
        error: (e, _) => PallyErrorCard(
          message: PallyError.from(e).userMessage,
          onRetry: () => ref
              .read(brainMapViewModelProvider(widget.avatarId).notifier)
              .refresh(widget.avatarId),
        ),
        data: (state) {
          if (state.nodes.isEmpty) {
            return const _EmptyState();
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              final size = Size(constraints.maxWidth, constraints.maxHeight);
              _ensureLayout(state.nodes.length, size);
              return GestureDetector(
                onTapUp: (details) => _handleTap(
                    context, details.localPosition, state.nodes),
                child: CustomPaint(
                  size: size,
                  painter: _BrainMapPainter(
                    nodes: state.nodes,
                    subject: state.subject,
                    positions: _positions!,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _ensureLayout(int count, Size size) {
    if (count == _laidOutCount && size == _laidOutSize && _positions != null) {
      return;
    }
    _positions = _radialLayout(count, size);
    _laidOutCount = count;
    _laidOutSize = size;
  }

  List<Offset> _radialLayout(int count, Size size) {
    // Stable radial: nodes on concentric rings around the centre. Single ring
    // when small; second ring kicks in past 8 nodes.
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = math.min(size.width, size.height) * 0.42;
    final positions = <Offset>[];
    if (count <= 8) {
      final radius = maxR * 0.85;
      for (var i = 0; i < count; i++) {
        final angle = (2 * math.pi * i) / count - math.pi / 2;
        positions.add(Offset(
          center.dx + radius * math.cos(angle),
          center.dy + radius * math.sin(angle),
        ));
      }
    } else {
      final innerCount = (count / 2).ceil();
      final outerCount = count - innerCount;
      for (var i = 0; i < innerCount; i++) {
        final angle = (2 * math.pi * i) / innerCount - math.pi / 2;
        positions.add(Offset(
          center.dx + maxR * 0.55 * math.cos(angle),
          center.dy + maxR * 0.55 * math.sin(angle),
        ));
      }
      for (var i = 0; i < outerCount; i++) {
        final angle =
            (2 * math.pi * i) / outerCount - math.pi / 2 + math.pi / outerCount;
        positions.add(Offset(
          center.dx + maxR * 0.95 * math.cos(angle),
          center.dy + maxR * 0.95 * math.sin(angle),
        ));
      }
    }
    return positions;
  }

  void _handleTap(BuildContext context, Offset tap, List<TopicNode> nodes) {
    if (_positions == null) return;
    for (var i = 0; i < nodes.length; i++) {
      if ((tap - _positions![i]).distance < 36) {
        _showTopicSheet(context, nodes[i]);
        return;
      }
    }
  }

  void _showTopicSheet(BuildContext context, TopicNode node) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetCtx) => _TopicSheet(
        node: node,
        avatarId: widget.avatarId,
      ),
    );
  }
}

class _BrainMapPainter extends CustomPainter {
  _BrainMapPainter({
    required this.nodes,
    required this.subject,
    required this.positions,
  });

  final List<TopicNode> nodes;
  final String subject;
  final List<Offset> positions;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Connections behind the nodes.
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..strokeWidth = 1.4;
    for (final p in positions) {
      canvas.drawLine(center, p, linePaint);
    }

    // Hub.
    final hubPaint = Paint()..color = AppColors.purple;
    final hubGlow = Paint()
      ..color = AppColors.purple.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    canvas.drawCircle(center, 44, hubGlow);
    canvas.drawCircle(center, 28, hubPaint);
    _drawText(
        canvas,
        subject.isEmpty ? 'Brain' : subject,
        center,
        const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w800));

    // Topic nodes.
    for (var i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      final pos = positions[i];
      final color = _colorFor(node);
      final glow = Paint()
        ..color = color.withValues(alpha: node.isUntouched ? 0.0 : 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawCircle(pos, 28, glow);
      canvas.drawCircle(pos, 18, Paint()..color = color);

      // R8 — pulsing review ring for pages the harness flagged after a
      // wrong quiz answer. Drawn as a coral stroke at 24px radius so it
      // sits just outside the node body but inside the glow.
      if (node.reviewRequired) {
        final ringPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..color = const Color(0xFFFF6660);
        canvas.drawCircle(pos, 24, ringPaint);
      }

      // Title under the node.
      final title = node.title.length > 14
          ? '${node.title.substring(0, 14)}…'
          : node.title;
      _drawText(
        canvas,
        title,
        Offset(pos.dx, pos.dy + 30),
        const TextStyle(
            color: Colors.white70,
            fontSize: 10,
            fontWeight: FontWeight.w600),
      );
    }
  }

  Color _colorFor(TopicNode n) {
    if (n.isUntouched) return Colors.white.withValues(alpha: 0.18);
    if (n.mastery >= 0.7) return AppColors.green;
    if (n.mastery >= 0.4) return AppColors.amber;
    return AppColors.coral;
  }

  void _drawText(Canvas canvas, String s, Offset center, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: s, style: style),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 96);
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _BrainMapPainter old) =>
      old.nodes != nodes ||
      old.positions != positions ||
      old.subject != subject;
}

class _TopicSheet extends StatelessWidget {
  const _TopicSheet({required this.node, required this.avatarId});
  final TopicNode node;
  final String avatarId;

  String get _masteryLabel {
    if (node.isUntouched) return 'Untouched · no quiz attempts yet';
    return '${(node.mastery * 100).round()}% mastery · ${node.attempts} attempt'
        '${node.attempts == 1 ? '' : 's'}';
  }

  Color get _accent {
    if (node.isUntouched) return AppColors.text2;
    if (node.mastery >= 0.7) return AppColors.green;
    if (node.mastery >= 0.4) return AppColors.amber;
    return AppColors.coral;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                      color: _accent, shape: BoxShape.circle),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(node.title,
                          style: AppTextStyles.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      Text(_masteryLabel,
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.text2)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _SheetButton(
                    icon: Icons.bolt_rounded,
                    label: 'Quick quiz',
                    onTap: () {
                      Navigator.of(context).pop();
                      QuizRoute(avatarId: avatarId).push(context);
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _SheetButton(
                    icon: Icons.menu_book_rounded,
                    label: 'Open wiki',
                    onTap: () {
                      Navigator.of(context).pop();
                      WikiViewerRoute(avatarId: avatarId).push(context);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            _SheetButton(
              icon: Icons.school_outlined,
              label: 'Teach Mochi this topic',
              onTap: () {
                Navigator.of(context).pop();
                TeachMochiRoute(avatarId: avatarId).push(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetButton extends StatelessWidget {
  const _SheetButton(
      {required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.purpleL,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.purple, size: 18),
              const SizedBox(width: 6),
              Text(label,
                  style: AppTextStyles.body.copyWith(
                      color: AppColors.purple,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bubble_chart_outlined,
                size: 80, color: Colors.white24),
            const SizedBox(height: AppSpacing.md),
            Text('No topics yet',
                style: AppTextStyles.title
                    .copyWith(color: Colors.white)),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'Upload some notes — Mochi will fill the map for you.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
