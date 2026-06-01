import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/ui/pally_button.dart';
import 'package:pally/features/shop/providers/unlocked_characters_provider.dart';
import 'package:pally/shared/models/mochi_character.dart';

class CharacterPickerStep extends ConsumerWidget {
  const CharacterPickerStep({
    super.key,
    required this.selectedCharacter,
    required this.onSelect,
    required this.onNext,
  });

  final MochiCharacter? selectedCharacter;
  final ValueChanged<MochiCharacter?> onSelect;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unlockedAsync = ref.watch(unlockedCharactersProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xs),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Choose Your Mochi', style: AppTextStyles.heading1),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Pick a Mochi that matches your vibe! 🎉',
                style: AppTextStyles.body.copyWith(color: AppColors.text2),
              ),
            ],
          ),
        ),
        Expanded(
          child: unlockedAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Could not load Mochis — pull down to retry.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            data: (unlocked) => GridView.builder(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 181 / 178,
              ),
              itemCount: MochiCharacter.values.length,
              itemBuilder: (context, index) {
                final character = MochiCharacter.values[index];
                final isUnlocked = unlocked.contains(character) ||
                    !character.isLockedByDefault;
                final isSelected = character == selectedCharacter;
                return _MochiCard(
                  character: character,
                  isSelected: isSelected,
                  isUnlocked: isUnlocked,
                  onTap: isUnlocked
                      // Second tap on the same card deselects it
                      ? () => onSelect(isSelected ? null : character)
                      : null,
                );
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: PallyButton(
            label: 'Next →',
            onPressed: selectedCharacter != null ? onNext : null,
            fullWidth: true,
          ),
        ),
      ],
    );
  }
}

class _MochiCard extends StatelessWidget {
  const _MochiCard({
    required this.character,
    required this.isSelected,
    required this.isUnlocked,
    required this.onTap,
  });

  final MochiCharacter character;
  final bool isSelected;
  final bool isUnlocked;
  // null for locked cards — the card handles the locked dialog internally
  final VoidCallback? onTap;

  void _showLockedDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: true, // tap outside to dismiss
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColors.surface,
        title: Row(
          children: [
            const Text('🔒', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Character Locked',
                style: AppTextStyles.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Text(
          'Earn XP to open a mystery box and unlock ${character.displayName}!',
          style: AppTextStyles.body.copyWith(color: AppColors.text2),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Dismiss',
              style: AppTextStyles.body.copyWith(color: AppColors.text2),
            ),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.push('/shop');
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.purple,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Open Mystery Box'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => _showLockedDialog(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: character.bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.purple
                : character.accentColor.withValues(alpha: 0.35),
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.purple.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(character.assetPath,
                      width: 88, height: 88, fit: BoxFit.contain),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      character.displayName,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.text1,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Hide the COMMON badge for the free base Mochi —
                  // all other characters (including other COMMON ones) show it.
                  if (character != MochiCharacter.mochi ||
                      character.rarity != MochiRarity.standard)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: character.rarity.badgeColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          character.rarity.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  if (!isUnlocked)
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Text(
                        '600 ⭐ to unlock',
                        style: TextStyle(color: AppColors.text3, fontSize: 9),
                      ),
                    ),
                ],
              ),
            ),
            if (!isUnlocked) ...[
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              // Lock sits in the top-left corner — above the Mochi face so
              // the full character is visible and desirable.
              const Positioned(
                top: 6,
                left: 8,
                child: Text('🔒', style: TextStyle(fontSize: 18)),
              ),
            ],
            if (isSelected)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: AppColors.purple,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.check_rounded,
                      color: Colors.white, size: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
