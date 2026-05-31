import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/app/router.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/ui/painters/character_painter.dart';
import 'package:pally/core/ui/pally_loading_spinner.dart';
import 'package:pally/features/shop/presentation/powerup_view_model.dart';
import 'package:pally/features/shop/presentation/shop_view_model.dart';
import 'package:pally/features/shop/providers/mystery_box_odds_provider.dart';
import 'package:pally/shared/models/mochi_character.dart';

class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shopState = ref.watch(shopViewModelProvider);
    final notifier = ref.read(shopViewModelProvider.notifier);

    ref.listen<ShopState>(shopViewModelProvider, (_, next) {
      if (next.lastUnlocked != null) {
        _showResultDialog(
          context,
          next.lastUnlocked!,
          next.wasDuplicate,
          notifier,
        );
      }
      if (next.lastFreezePurchase != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: const Duration(seconds: 3),
          backgroundColor: AppColors.text1,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          content: Text(
            '❄️ Freeze added — you now have '
            '${next.lastFreezePurchase!.freezes}/'
            '${next.lastFreezePurchase!.freezeCap}',
          ),
        ));
        notifier.clearFreezePurchase();
      }
      if (next.error != null) {
        // Surfaces "Not enough stars" / "Freezes are full" verbatim from
        // the backend. We deliberately don't celebrate failure (no
        // confetti) so the kid understands nothing was charged.
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: const Duration(seconds: 3),
          backgroundColor: AppColors.coral,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          content: Text(next.error!),
        ));
      }
    });

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: Text('Character Shop', style: AppTextStyles.title),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: _StarBalance(stars: shopState.stars),
          ),
        ],
      ),
      body: shopState.isLoading
          ? const PallyLoadingSpinner()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _MysteryBoxCard(
                    stars: shopState.stars,
                    isOpening: shopState.isOpening,
                    onOpen: notifier.openMysteryBox,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _PowerUpsCard(
                    stars: shopState.stars,
                    isBuyingFreeze: shopState.isBuyingFreeze,
                    onBuyFreeze: notifier.buyFreeze,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _PowerupShopCard(stars: shopState.stars),
                  const SizedBox(height: AppSpacing.lg),
                  _EarnMethodsCard(),
                  const SizedBox(height: AppSpacing.md),
                  _CollectionCard(count: shopState.collectionCount),
                ],
              ),
            ),
    );
  }

  void _showResultDialog(
    BuildContext context,
    MochiCharacter character,
    bool wasDuplicate,
    ShopViewModel notifier,
  ) {
    notifier.clearLastUnlocked();
    showDialog<void>(
      context: context,
      builder: (_) => wasDuplicate
          ? _DuplicateDialog(character: character)
          : _UnlockedDialog(character: character),
    );
  }
}

class _StarBalance extends StatelessWidget {
  const _StarBalance({required this.stars});

  final int stars;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.goldL,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: AppColors.gold, size: 16),
          const SizedBox(width: 4),
          Text(
            _formatNumber(stars),
            style: AppTextStyles.label.copyWith(
              color: AppColors.amber,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000) {
      return '${(n / 1000).toStringAsFixed(1)}k';
    }
    return '$n';
  }
}

class _MysteryBoxCard extends StatefulWidget {
  const _MysteryBoxCard({
    required this.stars,
    required this.isOpening,
    required this.onOpen,
  });

  final int stars;
  final bool isOpening;
  final VoidCallback onOpen;

  @override
  State<_MysteryBoxCard> createState() => _MysteryBoxCardState();
}

class _MysteryBoxCardState extends State<_MysteryBoxCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -8.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: -6.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -6.0, end: 6.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(_MysteryBoxCard old) {
    super.didUpdateWidget(old);
    if (widget.isOpening && !old.isOpening) {
      _shakeController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canAfford = widget.stars >= 600;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6B35D6), Color(0xFF9B59E8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Mystery box visual with shake animation
          AnimatedBuilder(
            animation: _shakeAnimation,
            builder: (context, child) => Transform.translate(
              offset: Offset(_shakeAnimation.value, 0),
              child: child,
            ),
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3), width: 2),
              ),
              child: const Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.help_outline_rounded,
                    color: Colors.white,
                    size: 52,
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Icon(Icons.auto_awesome_rounded,
                        color: AppColors.gold, size: 16),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Icon(Icons.auto_awesome_rounded,
                        color: AppColors.gold, size: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Mystery Box',
            style: AppTextStyles.heading1.copyWith(color: Colors.white),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Open to unlock a random character!',
            style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          const _MysteryOddsPanel(),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: (canAfford && !widget.isOpening) ? widget.onOpen : null,
              style: FilledButton.styleFrom(
                backgroundColor: canAfford ? AppColors.gold : Colors.white24,
                foregroundColor: canAfford ? AppColors.text1 : Colors.white54,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: widget.isOpening
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.text1,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 18, color: AppColors.amber),
                        const SizedBox(width: 6),
                        Text(
                          canAfford
                              ? 'Open Box (600 ⭐)'
                              : 'Need 600 ⭐ to open',
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w700,
                            color: canAfford ? AppColors.text1 : Colors.white54,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Hint / Double-XP / Bonus-quiz buy panel. Reads inventory + catalog
/// from `/shop/powerups*` via PowerupViewModel; each row shows the
/// current owned count and a single "buy 1" tap. Wires snackbar
/// confirmation + error surfacing into the parent screen's existing
/// listener so a child can never spam-purchase past their balance
/// without a kid-friendly error message.
class _PowerupShopCard extends ConsumerWidget {
  const _PowerupShopCard({required this.stars});
  final int stars;

  static const _items = [
    _PowerupItem(
        type: 'HINT_TOKEN',
        emoji: '💡',
        title: 'Hint token',
        sub: 'Reveal one wrong option in a quiz.'),
    _PowerupItem(
        type: 'DOUBLE_XP',
        emoji: '⚡',
        title: 'Double-XP boost',
        sub: 'Doubles XP on your next quiz (within the daily cap).'),
    _PowerupItem(
        type: 'BONUS_QUIZ',
        emoji: '🎯',
        title: 'Bonus practice quiz',
        sub: 'Unlock an extra full-XP quiz today.'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(powerupViewModelProvider);
    final notifier = ref.read(powerupViewModelProvider.notifier);

    ref.listen<PowerupState>(powerupViewModelProvider, (_, next) {
      if (next.lastPurchase != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: const Duration(seconds: 3),
          backgroundColor: AppColors.text1,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          content: Text(
            'Bought ${_labelFor(next.lastPurchase!.type)} — '
            'you now have ${next.lastPurchase!.count}',
          ),
        ));
        notifier.clearPurchase();
      }
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: const Duration(seconds: 3),
          backgroundColor: AppColors.coral,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          content: Text(next.error!),
        ));
        notifier.clearError();
      }
    });

    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quiz Power-ups', style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Spend stars to study smarter.',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          if (state.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: SizedBox(
                height: 16,
                child: LinearProgressIndicator(minHeight: 2),
              ),
            )
          else
            ..._items.map((it) => _PowerupRow(
                  item: it,
                  count: state.counts[it.type] ?? 0,
                  cost: state.catalog[it.type]?.cost ?? 0,
                  stars: stars,
                  isBuying: state.isBuying,
                  onBuy: () => notifier.buy(it.type),
                )),
        ],
      ),
    );
  }

  static String _labelFor(String type) => switch (type) {
        'HINT_TOKEN' => 'a hint token',
        'DOUBLE_XP' => 'a double-XP boost',
        'BONUS_QUIZ' => 'a bonus quiz',
        _ => 'a powerup',
      };
}

@immutable
class _PowerupItem {
  const _PowerupItem({
    required this.type,
    required this.emoji,
    required this.title,
    required this.sub,
  });
  final String type;
  final String emoji;
  final String title;
  final String sub;
}

class _PowerupRow extends StatelessWidget {
  const _PowerupRow({
    required this.item,
    required this.count,
    required this.cost,
    required this.stars,
    required this.isBuying,
    required this.onBuy,
  });

  final _PowerupItem item;
  final int count;
  final int cost;
  final int stars;
  final bool isBuying;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    final canAfford = cost > 0 && stars >= cost;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.surf2,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(item.emoji, style: const TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.title,
                          style: AppTextStyles.body
                              .copyWith(fontWeight: FontWeight.w700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (count > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          constraints: const BoxConstraints(maxWidth: 60),
                          decoration: BoxDecoration(
                            color: AppColors.tealL,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '× $count',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.teal,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(item.sub,
                      style: AppTextStyles.caption,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            FilledButton(
              onPressed: (canAfford && !isBuying) ? onBuy : null,
              style: FilledButton.styleFrom(
                backgroundColor:
                    canAfford ? AppColors.purple : AppColors.outline,
                foregroundColor:
                    canAfford ? Colors.white : AppColors.text3,
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    cost == 0 ? '…' : '$cost',
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Nunito'),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.star_rounded, size: 14),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Live odds list rendered from /shop/open-box/odds. Falls back to the
/// spec defaults (6×15% / 8% / 2%) on error, so the card never goes
/// blank. Grouping by rarity keeps the text scannable at small sizes.
class _MysteryOddsPanel extends ConsumerWidget {
  const _MysteryOddsPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncOdds = ref.watch(mysteryBoxOddsNotifierProvider);
    final odds = asyncOdds.valueOrNull;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.amberL,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.amber.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '💡 FYI — Probability:',
            style: AppTextStyles.label.copyWith(
              color: const Color(0xFFB8860B),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          if (odds == null || odds.isEmpty)
            Text(
              'Loading odds…',
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.text2),
            )
          else
            Text(
              _formatOdds(odds),
              style: AppTextStyles.caption.copyWith(
                color: AppColors.text2,
              ),
            ),
        ],
      ),
    );
  }

  String _formatOdds(List<MysteryBoxOdds> odds) {
    final commons = odds.where((o) => o.rarity == 'COMMON').toList();
    final rares = odds.where((o) => o.rarity == 'RARE').toList();
    final secrets = odds.where((o) => o.rarity == 'SECRET').toList();
    final parts = <String>[];
    if (commons.isNotEmpty) {
      final pct = commons.first.percent;
      parts.add('${commons.length} commons = $pct% each');
    }
    for (final r in rares) {
      parts.add('Rare (${r.name}) = ${r.percent}%');
    }
    for (final s in secrets) {
      parts.add('Secret (${s.name}) = ${s.percent}%');
    }
    return parts.join('  ·  ');
  }
}

class _PowerUpsCard extends StatelessWidget {
  const _PowerUpsCard({
    required this.stars,
    required this.isBuyingFreeze,
    required this.onBuyFreeze,
  });

  final int stars;
  final bool isBuyingFreeze;
  final VoidCallback onBuyFreeze;

  @override
  Widget build(BuildContext context) {
    final canAfford = stars >= 150;
    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Power-ups', style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Spend stars to protect your streak.',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.tealL,
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: AppColors.teal.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: const Text('❄️', style: TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Streak Freeze',
                        style: AppTextStyles.body
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        'Save your streak if you miss a day.',
                        style: AppTextStyles.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                FilledButton(
                  onPressed:
                      (canAfford && !isBuyingFreeze) ? onBuyFreeze : null,
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        canAfford ? AppColors.teal : AppColors.outline,
                    foregroundColor:
                        canAfford ? Colors.white : AppColors.text3,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: isBuyingFreeze
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('150',
                                style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontFamily: 'Nunito')),
                            SizedBox(width: 4),
                            Icon(Icons.star_rounded, size: 14),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EarnMethod {
  const _EarnMethod(this.icon, this.label, this.reward, this.color);
  final IconData icon;
  final String label;
  final String reward;
  final Color color;
}

class _EarnMethodsCard extends StatelessWidget {
  static const _methods = [
    _EarnMethod(Icons.bolt_rounded, 'Complete quiz', '+20 ⭐', AppColors.amber),
    _EarnMethod(
        Icons.upload_file_rounded, 'Upload content', '+15 ⭐', AppColors.teal),
    _EarnMethod(Icons.local_fire_department_rounded, 'Daily streak', '+10 ⭐',
        AppColors.coral),
    _EarnMethod(
        Icons.chat_bubble_rounded, 'First chat', '+30 ⭐', AppColors.purple),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Earn Stars', style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.md),
          ..._methods.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: m.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(m.icon, color: m.color, size: 20),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(m.label, style: AppTextStyles.body),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.goldL,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        m.reward,
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.amber,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _CollectionCard extends StatelessWidget {
  const _CollectionCard({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => const CollectionRoute().push<void>(context),
      child: Container(
        padding: AppSpacing.card,
        decoration: BoxDecoration(
          color: AppColors.purpleL,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.collections_rounded,
                color: AppColors.purple, size: 28),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Collection',
                    style: AppTextStyles.body
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '$count / ${MochiCharacter.values.length} characters unlocked',
                    style: AppTextStyles.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.purple),
          ],
        ),
      ),
    );
  }
}

class _UnlockedDialog extends StatelessWidget {
  const _UnlockedDialog({required this.character});

  final MochiCharacter character;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.greenL,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.celebration_rounded,
                  color: AppColors.green, size: 32),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('New Character Unlocked!',
                style: AppTextStyles.title, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: character.bgColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CharacterWidget(character: character, size: 72),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              character.displayName,
              style: AppTextStyles.heading1,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              character.displayName,
              style: AppTextStyles.bodySmall,
            ),
            if (character.rarity != MochiRarity.standard) ...[
              const SizedBox(height: AppSpacing.xs),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.goldL,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '✨ ${character.rarity.label}',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            Text(
              'You can now use this Mochi for studying!',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.text2),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.purple,
                ),
                child: const Text('Awesome!'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DuplicateDialog extends StatelessWidget {
  const _DuplicateDialog({required this.character});

  final MochiCharacter character;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: character.bgColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CharacterWidget(character: character, size: 72),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              character.displayName,
              style: AppTextStyles.heading1,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.amberL,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Already Unlocked',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.amber,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'I will learn harder and try again!',
              style: AppTextStyles.body.copyWith(
                color: AppColors.text2,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.purple,
                  side: const BorderSide(color: AppColors.purple),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('OK'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
