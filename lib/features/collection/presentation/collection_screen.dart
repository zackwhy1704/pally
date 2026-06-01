import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/widgets/loading/pally_skeleton.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/ui/pally_error_card.dart';
import 'package:pally/features/collection/presentation/collection_view_model.dart';

/// Mochi Album — the "collect them all" screen. Owned characters show
/// in colour; unowned ones show as silhouettes with their rarity badge
/// and a "🔒" overlay. Progress chip at the top doubles as the long-term
/// retention hook the spec calls out (sec 5.2 "Collection screen").
class CollectionScreen extends ConsumerWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(collectionViewModelProvider);
    final notifier = ref.read(collectionViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: Text('Mochi Album', style: AppTextStyles.title),
        centerTitle: true,
      ),
      body: state.isLoading
          ? const Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: PallyGridSkeleton(),
          )
          : state.error != null
              ? Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: PallyErrorCard(
                    message: state.error ?? 'Something went wrong — try again.',
                    onRetry: notifier.refresh,
                  ),
                )
              : RefreshIndicator(
                  onRefresh: notifier.refresh,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _ProgressBanner(
                          owned: state.ownedCount,
                          total: state.totalCount,
                          progress: state.progress,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _AlbumGrid(entries: state.entries),
                      ],
                    ),
                  ),
                ),
    );
  }
}

class _ProgressBanner extends StatelessWidget {
  const _ProgressBanner({
    required this.owned,
    required this.total,
    required this.progress,
  });

  final int owned;
  final int total;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7042ED), Color(0xFF8F66FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🏆', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text(
                'Collection',
                style: AppTextStyles.heading1.copyWith(color: Colors.white),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$owned / $total',
                  style: AppTextStyles.body.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white.withValues(alpha: 0.15),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.gold),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            owned == total && total > 0
                ? 'Complete! 🎉'
                : 'Collect them all by opening mystery boxes!',
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

class _AlbumGrid extends StatelessWidget {
  const _AlbumGrid({required this.entries});
  final List<CollectionEntry> entries;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: entries.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 180,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.95,
      ),
      itemBuilder: (context, i) => _AlbumTile(entry: entries[i]),
    );
  }
}

class _AlbumTile extends StatelessWidget {
  const _AlbumTile({required this.entry});
  final CollectionEntry entry;

  @override
  Widget build(BuildContext context) {
    final char = entry.character;
    final bg = char?.bgColor ?? AppColors.surf2;
    final accent = char?.accentColor ?? AppColors.outline;
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: entry.unlocked
              ? accent.withValues(alpha: 0.5)
              : AppColors.outline,
          width: 1.5,
        ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: char == null
                      ? Center(
                          child: Text(
                            '?',
                            style: AppTextStyles.heading1
                                .copyWith(color: AppColors.text3),
                          ),
                        )
                      : Opacity(
                          opacity: entry.unlocked ? 1.0 : 0.25,
                          child: Image.asset(
                            char.assetPath,
                            fit: BoxFit.contain,
                          ),
                        ),
                ),
                const SizedBox(height: 4),
                Text(
                  char?.displayName ?? entry.id,
                  style: AppTextStyles.caption.copyWith(
                    color: entry.unlocked
                        ? AppColors.text1
                        : AppColors.text3,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    constraints: const BoxConstraints(maxWidth: 80),
                    decoration: BoxDecoration(
                      color: _rarityColor(entry.rarity),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      entry.rarity,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (!entry.unlocked)
            const Positioned(
              top: 6,
              right: 6,
              child: Text('🔒', style: TextStyle(fontSize: 16)),
            ),
        ],
      ),
    );
  }

  Color _rarityColor(String r) => switch (r) {
        'SECRET' => const Color(0xFF1A1A2E),
        'RARE' => const Color(0xFF7042ED),
        _ => AppColors.teal, // COMMON + STANDARD → teal
      };
}
