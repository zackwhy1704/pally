import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/features/home/presentation/home_view_model.dart';
import 'package:pally/shared/models/avatar.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kKeeperKey    = 'trial_expired_keeper_avatar_id';
const _kDismissedKey = 'trial_expired_dismissed_v1';

/// PR4 — Trial-expired paywall.
///
/// Shown on the first launch after the trial expires (or when opening a
/// locked Mochi). Lets the user:
///  (a) Subscribe to restore all Mochis instantly, or
///  (b) Continue free with 1 Mochi — they pick which one stays active;
///      the rest become locked (🔒) but are never deleted.
///
/// Framing: "keep what you built", not "you lost access".
class TrialExpiredScreen extends ConsumerStatefulWidget {
  const TrialExpiredScreen({super.key, this.avatarId});

  /// When opened by tapping a locked Mochi, pass its ID to pre-select it.
  final String? avatarId;

  static Future<bool> shouldShow() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_kDismissedKey) ?? false);
  }

  @override
  ConsumerState<TrialExpiredScreen> createState() =>
      _TrialExpiredScreenState();
}

class _TrialExpiredScreenState extends ConsumerState<TrialExpiredScreen> {
  String? _selectedKeeperId;

  @override
  void initState() {
    super.initState();
    _selectedKeeperId = widget.avatarId;
    _loadSavedKeeper();
  }

  Future<void> _loadSavedKeeper() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kKeeperKey);
    if (saved != null && _selectedKeeperId == null && mounted) {
      setState(() => _selectedKeeperId = saved);
    }
  }

  Future<void> _savePick() async {
    if (_selectedKeeperId == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kKeeperKey, _selectedKeeperId!);
  }

  void _continueFree() async {
    await _savePick();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDismissedKey, true);
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final avatarsAsync = ref.watch(homeViewModelProvider);
    final avatars = avatarsAsync.valueOrNull ?? [];
    final hasMultiple = avatars.length > 1;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.lg),

              // Hero
              Center(
                child: Image.asset('assets/images/mochi.png',
                    width: 90, height: 90),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Your free week is up! ⏰',
                  style: AppTextStyles.heading1, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'You still have all your Mochis — nothing was deleted. '
                'Subscribe to keep them all, or pick one to stay free.',
                style: AppTextStyles.body.copyWith(color: AppColors.text2),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),

              // Subscribe CTA (gold/premium feel)
              Container(
                padding: AppSpacing.card,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7042ED), Color(0xFF8F66FA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text('⭐ Keep all your Mochis',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        )),
                    const SizedBox(height: 4),
                    Text(
                      'Unlimited Mochis, unlimited chat, full flashcards & brain map.',
                      style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.8)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: _PlanButton(
                            label: 'Individual',
                            price: 'S\$7.99/mo',
                            onTap: () => context.push('/subscription/plans'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _PlanButton(
                            label: 'Family',
                            price: 'S\$12.99/mo',
                            subtitle: 'up to 4 kids',
                            onTap: () => context.push('/subscription/plans'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Mochi picker (only when >1 Mochi exists)
              if (hasMultiple) ...[
                Text(
                  'Or — continue free with 1 Mochi',
                  style: AppTextStyles.title.copyWith(fontSize: 16),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Choose which Mochi stays active. The rest are locked '
                  '(🔒) but not deleted — subscribing restores them instantly.',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.text2),
                ),
                const SizedBox(height: AppSpacing.md),
                ...avatars.map((a) => _AvatarPickRow(
                      avatar: a,
                      selected: _selectedKeeperId == a.id,
                      onTap: () =>
                          setState(() => _selectedKeeperId = a.id),
                    )),
                const SizedBox(height: AppSpacing.md),
                OutlinedButton(
                  onPressed: _selectedKeeperId != null ? _continueFree : null,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.text2,
                    side: const BorderSide(color: AppColors.outline),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text('Continue free with $_selectedKeeperName'),
                ),
              ] else ...[
                // Only 1 Mochi — just offer subscribe or continue free
                OutlinedButton(
                  onPressed: _continueFree,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.text2,
                    side: const BorderSide(color: AppColors.outline),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Continue free with 1 Mochi'),
                ),
              ],

              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  String get _selectedKeeperName {
    if (_selectedKeeperId == null) return '…';
    final avatars = ref.read(homeViewModelProvider).valueOrNull ?? [];
    return avatars
        .where((a) => a.id == _selectedKeeperId)
        .map((a) => a.name)
        .firstOrNull ?? '1 Mochi';
  }
}

class _PlanButton extends StatelessWidget {
  const _PlanButton({
    required this.label,
    required this.price,
    this.subtitle,
    required this.onTap,
  });

  final String label;
  final String price;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(label,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                )),
            Text(price,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                )),
            if (subtitle != null)
              Text(subtitle!,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 10,
                    color: Colors.white.withValues(alpha: 0.7),
                  )),
          ],
        ),
      ),
    );
  }
}

class _AvatarPickRow extends StatelessWidget {
  const _AvatarPickRow({
    required this.avatar,
    required this.selected,
    required this.onTap,
  });

  final Avatar avatar;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: AppSpacing.xs),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
        decoration: BoxDecoration(
          color: selected ? AppColors.purpleL : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.purple : AppColors.outline,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.purple.withValues(alpha: 0.15)
                    : AppColors.surf2,
                shape: BoxShape.circle,
              ),
              child: const Center(
                  child: Text('🧠', style: TextStyle(fontSize: 18))),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(avatar.name,
                      style: AppTextStyles.body
                          .copyWith(fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text(avatar.subject,
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.text2),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.purple, size: 22)
            else
              const Icon(Icons.circle_outlined,
                  color: AppColors.outline, size: 22),
          ],
        ),
      ),
    );
  }
}
