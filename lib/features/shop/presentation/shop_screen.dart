import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/ui/painters/character_painter.dart';
import 'package:pally/core/ui/pally_loading_spinner.dart';
import 'package:pally/features/shop/presentation/shop_view_model.dart';
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
          Container(
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
                Text(
                  'Secret (Gold Star) = 1/24  ·  Rare (Headmaster) = 23/24',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.text2,
                  ),
                ),
              ],
            ),
          ),
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
    return Container(
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Collection',
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                '$count / ${MochiCharacter.values.length} characters unlocked',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ],
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
              '${character.defaultSubject} tutor',
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
              'You can now select this Mochi when creating a tutor!',
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
