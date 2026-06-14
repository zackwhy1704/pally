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

/// Dark-themed knowledge map shown as a **mastery list** (Anki/Quizlet pattern):
/// topics ordered by what needs attention — conflicts first, then lowest mastery
/// (what to study next), then mastered. Each row shows a mastery bar, a certainty
/// chip, a conflict flag and a practice count. Tap a row → quick-action sheet.
/// (The old force-directed graph lens was removed: bare circles conveyed nothing
/// about what to do next.) Newly compiled pages fade+scale in with a stagger.
class BrainMapScreen extends ConsumerStatefulWidget {
  const BrainMapScreen({super.key, required this.avatarId});

  final String avatarId;

  @override
  ConsumerState<BrainMapScreen> createState() => _BrainMapScreenState();
}

class _BrainMapScreenState extends ConsumerState<BrainMapScreen>
    with TickerProviderStateMixin {
  // Staggered entrance for newly-compiled rows (0 → 1).
  late final AnimationController _entrance;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
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
          return _ListView(
            state: state,
            entrance: _entrance,
            onTapNode: (n) => _showTopicSheet(context, n),
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
    // Order by what needs attention: conflicts first, then lowest mastery (what
    // to study next), then mastered. This is the "study this next" the graph
    // never conveyed.
    final nodes = [...state.nodes]..sort((a, b) {
      if (a.hasConflict != b.hasConflict) return a.hasConflict ? -1 : 1;
      return a.mastery.compareTo(b.mastery);
    });
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: nodes.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, i) {
        final node = nodes[i];
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
    final masteryPct = (node.mastery.clamp(0.0, 1.0) * 100).round();
    return Material(
      color: Colors.white.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title + certainty chip + conflict flag
              Row(
                children: [
                  Expanded(
                    child: Text(node.title,
                        style: AppTextStyles.body
                            .copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  if (node.hasConflict) ...[
                    const Icon(Icons.warning_amber_rounded,
                        color: AppColors.coral, size: 16),
                    const SizedBox(width: 4),
                  ],
                  _CertaintyChip(certainty: node.certainty, color: color),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              // Mastery bar
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: node.isUntouched ? 0.0 : node.mastery.clamp(0.0, 1.0),
                  minHeight: 6,
                  backgroundColor: Colors.white.withValues(alpha: 0.10),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              const SizedBox(height: 6),
              // Mastery % + practice count
              Row(
                children: [
                  Text(
                    node.isUntouched ? 'Not studied yet' : '$masteryPct% mastery',
                    style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
                  ),
                  const Spacer(),
                  Text(
                    node.attempts == 0
                        ? 'Tap to study'
                        : 'Practised ${node.attempts}×',
                    style: AppTextStyles.caption.copyWith(color: Colors.white54),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small pill showing the page's certainty (VERIFIED / INFERRED / UNCERTAIN).
class _CertaintyChip extends StatelessWidget {
  const _CertaintyChip({required this.certainty, required this.color});
  final String certainty;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final label = certainty.toUpperCase() == 'VERIFIED'
        ? 'Verified'
        : certainty.toUpperCase() == 'UNCERTAIN'
            ? 'Uncertain'
            : 'Inferred';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption
            .copyWith(color: color, fontWeight: FontWeight.w700),
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
