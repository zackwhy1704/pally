import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/app/router.dart';
import 'package:pally/core/widgets/loading/pally_skeleton.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_sizing.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/error/pally_error.dart';
import 'package:pally/core/ui/pally_error_card.dart';
import 'package:pally/features/brain_map/presentation/brain_map_view_model.dart';

/// Which lens the brain map is shown through.
enum BrainMapView { graph, list }

/// Dark-themed knowledge map. Two lenses (IMPROVEMENT 2):
///  • Graph — a layered/topological knowledge graph: pages with no
///    prerequisites on top, dependents in lower rows, thin arrows
///    prerequisite→dependent. Node colour by certainty, border weight by
///    certaintyScore, size by quizUseCount, conflict nodes pulse.
///  • List — the flat topic list (mastery + certainty + conflict per row).
/// Newly compiled pages (this session) fade+scale in with a stagger
/// (IMPROVEMENT 6). Tap any node/row → quick-action sheet.
class BrainMapScreen extends ConsumerStatefulWidget {
  const BrainMapScreen({super.key, required this.avatarId});

  final String avatarId;

  @override
  ConsumerState<BrainMapScreen> createState() => _BrainMapScreenState();
}

class _BrainMapScreenState extends ConsumerState<BrainMapScreen>
    with TickerProviderStateMixin {
  BrainMapView _view = BrainMapView.graph;

  // Pulse for conflict nodes (opacity 0.6 → 1.0).
  late final AnimationController _pulse;
  // Staggered entrance for newly-compiled nodes (0 → 1).
  late final AnimationController _entrance;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _pulse.dispose();
    _entrance.dispose();
    super.dispose();
  }

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
          // Restart the entrance animation whenever the set of new nodes
          // changes (e.g. after a fresh compile while the screen is open).
          if (state.newSlugs.isNotEmpty && !_entrance.isAnimating) {
            _entrance
              ..reset()
              ..forward();
          }
          return Column(
            children: [
              _ViewToggle(
                value: _view,
                onChanged: (v) => setState(() => _view = v),
              ),
              Expanded(
                child: _view == BrainMapView.graph
                    ? _GraphView(
                        state: state,
                        pulse: _pulse,
                        entrance: _entrance,
                        onTapNode: (n) => _showTopicSheet(context, n),
                      )
                    : _ListView(
                        state: state,
                        entrance: _entrance,
                        onTapNode: (n) => _showTopicSheet(context, n),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showTopicSheet(BuildContext context, TopicNode node) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetCtx) => _TopicSheet(
        node: node,
        avatarId: widget.avatarId,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// View toggle (Graph | List)
// ─────────────────────────────────────────────────────────────────────────

class _ViewToggle extends StatelessWidget {
  const _ViewToggle({required this.value, required this.onChanged});
  final BrainMapView value;
  final ValueChanged<BrainMapView> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: LayoutBuilder(builder: (context, constraints) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(3),
          child: Row(
            children: [
              _toggleTab('Graph', Icons.hub_rounded, BrainMapView.graph),
              _toggleTab('List', Icons.view_list_rounded, BrainMapView.list),
            ],
          ),
        );
      }),
    );
  }

  Widget _toggleTab(String label, IconData icon, BrainMapView v) {
    final selected = value == v;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(v),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.purple : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 16, color: selected ? Colors.white : Colors.white60),
              const SizedBox(width: 6),
              Text(label,
                  style: AppTextStyles.label.copyWith(
                      color: selected ? Colors.white : Colors.white60,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Shared colour helpers
// ─────────────────────────────────────────────────────────────────────────

/// Node colour by certainty: VERIFIED=green, INFERRED=purple, UNCERTAIN=red.
Color certaintyColor(String certainty) {
  switch (certainty.toUpperCase()) {
    case 'VERIFIED':
      return AppColors.green;
    case 'UNCERTAIN':
      return AppColors.coral;
    case 'INFERRED':
    default:
      return AppColors.purpleC;
  }
}

/// Entrance progress (0→1) for the node at [index], with a 100ms stagger.
double entranceProgress(Animation<double> entrance, int index) {
  // The controller runs 0→1 over 1200ms; map 100ms-stagger onto that window.
  const stepMs = 100.0;
  const totalMs = 1200.0;
  final start = (index * stepMs) / totalMs;
  final span = 1.0 - start;
  if (span <= 0) return 1.0;
  return ((entrance.value - start) / span).clamp(0.0, 1.0);
}

// ─────────────────────────────────────────────────────────────────────────
// Graph view — InteractiveViewer + layered topological CustomPainter
// ─────────────────────────────────────────────────────────────────────────

class _GraphView extends StatelessWidget {
  const _GraphView({
    required this.state,
    required this.pulse,
    required this.entrance,
    required this.onTapNode,
  });

  final BrainMapState state;
  final Animation<double> pulse;
  final Animation<double> entrance;
  final ValueChanged<TopicNode> onTapNode;

  @override
  Widget build(BuildContext context) {
    final layout = _GraphLayout(state.nodes);
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 3.0,
      boundaryMargin: const EdgeInsets.all(120),
      constrained: false,
      child: SizedBox(
        width: layout.canvasSize.width,
        height: layout.canvasSize.height,
        child: GestureDetector(
          onTapUp: (d) {
            final node = layout.hitTest(d.localPosition);
            if (node != null) onTapNode(node);
          },
          child: AnimatedBuilder(
            animation: Listenable.merge([pulse, entrance]),
            builder: (context, _) => CustomPaint(
              size: layout.canvasSize,
              painter: _GraphPainter(
                layout: layout,
                state: state,
                pulseValue: pulse.value,
                entrance: entrance,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Layered topological layout. Depth = longest prerequisite chain. Roots
/// (no prereqs, or prereqs not present in this avatar) sit at depth 0.
class _GraphLayout {
  _GraphLayout(this.nodes) {
    _compute();
  }

  final List<TopicNode> nodes;

  // Per-node centre position (index-aligned with [nodes]).
  late final List<Offset> positions;
  late final Size canvasSize;
  // slug → index for edge drawing.
  final Map<String, int> _indexBySlug = {};

  static const double _rowGap = 130;
  static const double _colGap = 110;
  static const double _topPad = 60;
  static const double _sidePad = 70;

  void _compute() {
    for (var i = 0; i < nodes.length; i++) {
      _indexBySlug[nodes[i].slug] = i;
    }
    final depth = _computeDepths();
    // Bucket nodes by depth.
    final byDepth = <int, List<int>>{};
    var maxDepth = 0;
    for (var i = 0; i < nodes.length; i++) {
      final d = depth[i];
      byDepth.putIfAbsent(d, () => []).add(i);
      if (d > maxDepth) maxDepth = d;
    }
    var widest = 1;
    for (final row in byDepth.values) {
      if (row.length > widest) widest = row.length;
    }
    positions = List<Offset>.filled(nodes.length, Offset.zero);
    for (var d = 0; d <= maxDepth; d++) {
      final row = byDepth[d] ?? const [];
      for (var k = 0; k < row.length; k++) {
        final i = row[k];
        final x = _sidePad +
            (k + 0.5) * _colGap +
            // centre each row within the widest row
            (widest - row.length) * _colGap / 2;
        final y = _topPad + d * _rowGap;
        positions[i] = Offset(x, y);
      }
    }
    canvasSize = Size(
      _sidePad * 2 + widest * _colGap,
      _topPad * 2 + (maxDepth + 1) * _rowGap,
    );
  }

  /// Longest-prerequisite-chain depth per node, robust to cycles.
  List<int> _computeDepths() {
    final depth = List<int>.filled(nodes.length, -1);
    final visiting = List<bool>.filled(nodes.length, false);

    int resolve(int i) {
      if (depth[i] >= 0) return depth[i];
      if (visiting[i]) return 0; // cycle guard
      visiting[i] = true;
      var d = 0;
      for (final pre in nodes[i].prerequisiteSlugs) {
        final pi = _indexBySlug[pre];
        if (pi != null && pi != i) {
          d = math.max(d, resolve(pi) + 1);
        }
      }
      visiting[i] = false;
      depth[i] = d;
      return d;
    }

    for (var i = 0; i < nodes.length; i++) {
      resolve(i);
    }
    return depth;
  }

  /// Directed edges as (fromIndex, toIndex) — prerequisite → dependent.
  List<(int, int)> get edges {
    final out = <(int, int)>[];
    for (var i = 0; i < nodes.length; i++) {
      for (final pre in nodes[i].prerequisiteSlugs) {
        final pi = _indexBySlug[pre];
        if (pi != null && pi != i) out.add((pi, i));
      }
    }
    return out;
  }

  TopicNode? hitTest(Offset p) {
    for (var i = 0; i < nodes.length; i++) {
      final r = nodes[i].nodeDiameter / 2;
      if ((p - positions[i]).distance <= r + 6) return nodes[i];
    }
    return null;
  }
}

class _GraphPainter extends CustomPainter {
  _GraphPainter({
    required this.layout,
    required this.state,
    required this.pulseValue,
    required this.entrance,
  });

  final _GraphLayout layout;
  final BrainMapState state;
  final double pulseValue;
  final Animation<double> entrance;

  @override
  void paint(Canvas canvas, Size size) {
    final nodes = layout.nodes;

    // Edges (prerequisite → dependent) behind nodes.
    final edgePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    for (final (from, to) in layout.edges) {
      final a = layout.positions[from];
      final b = layout.positions[to];
      canvas.drawLine(a, b, edgePaint);
      _drawArrowHead(canvas, a, b, nodes[to].nodeDiameter / 2, edgePaint.color);
    }

    for (var i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      final pos = layout.positions[i];
      final isNew = state.isNew(node);
      final prog = isNew ? entranceProgress(entrance, i) : 1.0;
      if (prog <= 0) continue;

      final baseColor = certaintyColor(node.certainty);
      final r = (node.nodeDiameter / 2) * (0.7 + 0.3 * prog); // scale 0.7→1.0
      var alpha = prog; // fade 0→1

      // Conflict nodes pulse 0.6 → 1.0.
      if (node.hasConflict) {
        alpha *= 0.6 + 0.4 * pulseValue;
      }

      final fill = Paint()..color = baseColor.withValues(alpha: alpha);
      final glow = Paint()
        ..color = baseColor.withValues(alpha: 0.30 * alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawCircle(pos, r + 6, glow);
      canvas.drawCircle(pos, r, fill);

      // Border weight = 1 + certaintyScore*3.
      final border = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = node.borderWeight
        ..color = Colors.white.withValues(alpha: 0.85 * alpha);
      canvas.drawCircle(pos, r, border);

      // Conflict marker — a small ! ring outside the node.
      if (node.hasConflict) {
        final ring = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = AppColors.coral.withValues(alpha: alpha);
        canvas.drawCircle(pos, r + 5, ring);
      }

      // Review-required pulsing coral ring (R8).
      if (node.reviewRequired) {
        final ring = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..color = const Color(0xFFFF6660)
              .withValues(alpha: alpha * (0.6 + 0.4 * pulseValue));
        canvas.drawCircle(pos, r + 9, ring);
      }

      final title = node.title.length > 14
          ? '${node.title.substring(0, 14)}…'
          : node.title;
      _drawText(
        canvas,
        title,
        Offset(pos.dx, pos.dy + r + 12),
        TextStyle(
            color: Colors.white.withValues(alpha: 0.75 * alpha),
            fontSize: 10,
            fontWeight: FontWeight.w600),
      );
    }
  }

  void _drawArrowHead(
      Canvas canvas, Offset from, Offset to, double targetRadius, Color color) {
    final dir = (to - from);
    final len = dir.distance;
    if (len < 1) return;
    final unit = dir / len;
    // Land just outside the target node body.
    final tip = to - unit * (targetRadius + 2);
    const headLen = 8.0;
    const headW = 4.0;
    final perp = Offset(-unit.dy, unit.dx);
    final base = tip - unit * headLen;
    final p1 = base + perp * headW;
    final p2 = base - perp * headW;
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _drawText(Canvas canvas, String s, Offset center, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: s, style: style),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 96);
    tp.paint(
        canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _GraphPainter old) =>
      old.layout.nodes != layout.nodes ||
      old.pulseValue != pulseValue ||
      old.state != state;
}

// ─────────────────────────────────────────────────────────────────────────
// List view — flat topic rows
// ─────────────────────────────────────────────────────────────────────────

class _ListView extends StatelessWidget {
  const _ListView({
    required this.state,
    required this.entrance,
    required this.onTapNode,
  });

  final BrainMapState state;
  final Animation<double> entrance;
  final ValueChanged<TopicNode> onTapNode;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: state.nodes.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, i) {
        final node = state.nodes[i];
        final isNew = state.isNew(node);
        final row = _TopicRow(node: node, onTap: () => onTapNode(node));
        if (!isNew) return row;
        return AnimatedBuilder(
          animation: entrance,
          builder: (context, child) {
            final prog = entranceProgress(entrance, i);
            return Opacity(
              opacity: prog,
              child: Transform.scale(
                scale: 0.7 + 0.3 * prog,
                child: child,
              ),
            );
          },
          child: row,
        );
      },
    );
  }
}

class _TopicRow extends StatelessWidget {
  const _TopicRow({required this.node, required this.onTap});
  final TopicNode node;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = certaintyColor(node.certainty);
    return Material(
      color: Colors.white.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: AppSizing.checkboxSize,
                height: AppSizing.checkboxSize,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(node.title,
                        style: AppTextStyles.body.copyWith(color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(
                      node.isUntouched
                          ? 'No quiz attempts yet'
                          : '${(node.mastery * 100).round()}% mastery',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: Colors.white60),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              if (node.hasConflict)
                const Icon(Icons.warning_amber_rounded,
                    color: AppColors.coral, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Topic sheet
// ─────────────────────────────────────────────────────────────────────────

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
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: AppSizing.brainMapNode,
                    height: AppSizing.brainMapNode,
                    decoration:
                        BoxDecoration(color: _accent, shape: BoxShape.circle),
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
              // IMPROVEMENT 3 — conflict note. When the page has a conflict and
              // Mochi left a note, show it under a warning icon.
              if (node.hasConflict) ...[
                const SizedBox(height: AppSpacing.md),
                _ConflictBadge(note: node.conflictNote),
              ],
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
                      label: 'Open in brain',
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
      ),
    );
  }
}

/// IMPROVEMENT 3 — conflict banner shown in the topic sheet. Always shows the
/// "Fix my notes" affordance; when a [note] is present it reads it out as
/// "Mochi noticed: …".
class _ConflictBadge extends StatelessWidget {
  const _ConflictBadge({required this.note});
  final String? note;

  @override
  Widget build(BuildContext context) {
    final hasNote = note != null && note!.trim().isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.coralL,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: AppColors.coral, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Mochi found a contradiction here',
                  style: AppTextStyles.body.copyWith(
                      color: AppColors.coral, fontWeight: FontWeight.w700),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (hasNote) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Mochi noticed: ${note!.trim()}',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.text1),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: 4),
                foregroundColor: AppColors.coral,
              ),
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: const Text('Fix my notes'),
              onPressed: () {
                // Keep the existing route: the wiki viewer is where notes are
                // edited / fixed.
                final state =
                    context.findAncestorStateOfType<_BrainMapScreenState>();
                final avatarId = state?.widget.avatarId;
                Navigator.of(context).pop();
                if (avatarId != null) {
                  WikiViewerRoute(avatarId: avatarId).push(context);
                }
              },
            ),
          ),
        ],
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
              Flexible(
                child: Text(label,
                    style: AppTextStyles.body.copyWith(
                        color: AppColors.purple, fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
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
                style: AppTextStyles.title.copyWith(color: Colors.white)),
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
