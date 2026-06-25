import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/app/router.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/ui/adaptive_content_width.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/ui/painters/character_painter.dart';
import 'package:pally/core/utils/logger.dart';
import 'package:pally/shared/models/avatar.dart';
import 'package:pally/core/ui/pally_delete_tutor_dialog.dart';
import 'package:pally/core/ui/pally_toast.dart';
import 'package:pally/features/home/presentation/home_view_model.dart';
import 'package:pally/features/auth/auth_state.dart';
import 'package:pally/features/home/widgets/assignment_banner.dart';
import 'package:pally/features/home/widgets/due_cards_banner.dart';
import 'package:pally/features/home/widgets/empty_home_state.dart';
import 'package:pally/features/home/widgets/module_progress_banner.dart';
import 'package:pally/features/progress/presentation/progress_view_model.dart';
import 'package:pally/features/subscription/presentation/trial_countdown_banner.dart';
import 'package:pally/features/subscription/presentation/trial_expired_screen.dart';
import 'package:pally/features/subscription/presentation/trial_welcome_screen.dart';
import 'package:pally/features/subscription/trial_status_provider.dart';
import 'package:pally/features/onboarding/presentation/feature_tour.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Show the trial welcome once on first launch after a trial is granted.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final trial = ref.read(trialStatusProvider).valueOrNull;
      if (trial?.isTrialExpired == true) {
        final show = await TrialExpiredScreen.shouldShow();
        if (show && mounted) {
          const TrialExpiredRoute().go(context);
          return;
        }
      } else if (trial?.isOnTrial == true) {
        TrialWelcomeScreen.maybeShow(context);
      }
      // Show the 5-step feature tour once after the first home render.
      // Slight delay so all anchor widgets are laid out.
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) FeatureTour.maybeShow(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final avatarsAsync = ref.watch(homeViewModelProvider);
    final progressAsync = ref.watch(progressViewModelProvider);
    final childName = ref.watch(authStateProvider).childName ?? '';

    ref.listen<AsyncValue<List<Avatar>>>(homeViewModelProvider, (_, next) {
      if (next is AsyncError) {
        PallyToast.error(context, 'Could not load Mochis. Pull down to retry.');
      }
    });

    final level = progressAsync.valueOrNull?.level ?? 0;
    // Use in-level numerator/denominator from the backend so the bar
    // shows real progress within the current level instead of the old
    // nonsense (lifetime xp / "remaining to next level").
    final xpInto = progressAsync.valueOrNull?.xpIntoLevel ?? 0;
    final xpSpan = progressAsync.valueOrNull?.xpSpanForLevel ?? 100;
    final maxLevel = progressAsync.valueOrNull?.maxLevel ?? 30;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: AdaptiveContentWidth(
        child: SafeArea(
        child: Column(
          children: [
            _HomeHeader(
              onNewTutor: () => const CreateTutorRoute().go(context),
              level: level,
              xpInto: xpInto,
              xpSpan: xpSpan,
              maxLevel: maxLevel,
            ),
            const TrialCountdownBanner(),
            Expanded(
              child: avatarsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.purple),
                ),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.wifi_off_rounded,
                            size: 48, color: AppColors.text3),
                        const SizedBox(height: AppSpacing.md),
                        Text('Could not load your Mochis.',
                            style: AppTextStyles.title,
                            textAlign: TextAlign.center),
                        const SizedBox(height: AppSpacing.xs),
                        Text('Check your connection and pull down to retry.',
                            style: AppTextStyles.body
                                .copyWith(color: AppColors.text2),
                            textAlign: TextAlign.center),
                        const SizedBox(height: AppSpacing.lg),
                        FilledButton(
                          onPressed: () => ref
                              .read(homeViewModelProvider.notifier)
                              .refresh(),
                          style: FilledButton.styleFrom(
                              backgroundColor: AppColors.purple),
                          child: const Text('Try again'),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (avatars) => avatars.isEmpty
                    ? EmptyHomeState(childName: childName)
                    : _HomeContent(avatars: avatars),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.onNewTutor,
    required this.level,
    required this.xpInto,
    required this.xpSpan,
    required this.maxLevel,
  });

  final VoidCallback onNewTutor;
  final int level;
  final int xpInto;
  final int xpSpan;
  final int maxLevel;

  @override
  Widget build(BuildContext context) {
    final isMax = level >= maxLevel;
    final xpFraction = isMax
        ? 1.0
        : (xpSpan > 0 ? (xpInto / xpSpan).clamp(0.0, 1.0) : 0.0);

    return Container(
      decoration: const BoxDecoration(color: AppColors.purpleL),
      child: Stack(
        children: [
          Positioned(
            top: 16,
            right: 24,
            child: _StarShape(
                size: 28, color: AppColors.purple.withValues(alpha: 0.15)),
          ),
          Positioned(
            top: 60,
            right: 70,
            child: _StarShape(
                size: 16, color: AppColors.purple.withValues(alpha: 0.1)),
          ),
          Positioned(
            bottom: 20,
            left: 180,
            child: _StarShape(
                size: 20, color: AppColors.purple.withValues(alpha: 0.12)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome back! 👋', style: AppTextStyles.heading1),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Ready to keep learning?',
                  style: AppTextStyles.body.copyWith(color: AppColors.text2),
                ),

                // Level + XP bar
                if (level > 0) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.amber.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: AppColors.amber.withValues(alpha: 0.5)),
                        ),
                        child: Text(
                          '⭐ Level $level',
                          style: AppTextStyles.label.copyWith(
                              color: AppColors.amber,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              isMax ? 'MAX LEVEL ⭐' : '$xpInto / $xpSpan XP',
                              style: AppTextStyles.caption.copyWith(
                                  color: AppColors.text2),
                            ),
                            const SizedBox(height: 3),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: LinearProgressIndicator(
                                value: xpFraction,
                                minHeight: 6,
                                backgroundColor: AppColors.outline,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    AppColors.amber),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    key: featureTourCreateMochiKey,
                    onPressed: onNewTutor,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('New Mochi'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.purple,
                      textStyle: AppTextStyles.label
                          .copyWith(fontWeight: FontWeight.w700),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                    ),
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

class _StarShape extends StatelessWidget {
  const _StarShape({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.star_rounded, size: size, color: color);
  }
}

/// Module-first home content: module progress first, then assignments,
/// then nudge cards, then avatar grid at the bottom.
class _HomeContent extends ConsumerWidget {
  const _HomeContent({required this.avatars});
  final List<Avatar> avatars;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        RefreshIndicator(
          color: AppColors.purple,
          onRefresh: () => ref.read(homeViewModelProvider.notifier).refresh(),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // 1. Module progress — most prominent
              ModuleProgressBanner(avatars: avatars),
              // 2. Assignments with deadlines
              AssignmentBanner(avatars: avatars),
              // 3. Nudge cards + flashcard reminders
              const _NudgeCardsRow(),
              const DueCardsBanner(),
              // 4. Avatar grid — "Your Mochis"
              _AvatarSection(avatars: avatars),
              // Bottom padding for FAB clearance
              const SizedBox(height: 80),
            ],
          ),
        ),
        // Chat FAB
        Positioned(
          right: AppSpacing.md,
          bottom: AppSpacing.md,
          child: FloatingActionButton(
            onPressed: () => const ChatTabRoute().go(context),
            backgroundColor: AppColors.purple,
            child: const Icon(Icons.chat_rounded, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

/// The avatar grid section at the bottom of the home content.
class _AvatarSection extends ConsumerWidget {
  const _AvatarSection({required this.avatars});
  final List<Avatar> avatars;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Centre classes and personal tutors are two distinct systems; group
    // class avatars under their own header above the personal "YOUR MOCHIS".
    final classAvatars =
        avatars.where((a) => a.isCentreClass).toList(growable: false);
    final personalAvatars =
        avatars.where((a) => !a.isCentreClass).toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── My classes (only when the child has centre-class avatars) ─────
        if (classAvatars.isNotEmpty) ...[
          const _SectionHeader(label: 'MY CLASSES'),
          _AvatarGrid(avatars: classAvatars),
        ],
        // ── Personal tutors ────────────────────────────────────────────────
        const _SectionHeader(label: 'YOUR MOCHIS'),
        GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 220,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 178 / 160,
          ),
          itemCount: personalAvatars.length,
          itemBuilder: (context, index) =>
              _AvatarCard(avatar: personalAvatars[index]),
        ),
      ],
    );
  }
}

/// A small uppercase section label used between avatar groups.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xs),
      child: Text(
        label,
        style: AppTextStyles.label.copyWith(
          letterSpacing: 1.2,
          color: AppColors.text2,
        ),
      ),
    );
  }
}

/// A non-scrolling avatar grid used for the "My classes" group (the personal
/// group keeps its own grid so it can append the demo-centre marketing card).
class _AvatarGrid extends StatelessWidget {
  const _AvatarGrid({required this.avatars});
  final List<Avatar> avatars;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 178 / 160,
      ),
      itemCount: avatars.length,
      itemBuilder: (context, index) => _AvatarCard(avatar: avatars[index]),
    );
  }
}

class _AvatarCard extends ConsumerWidget {
  const _AvatarCard({required this.avatar});
  final Avatar avatar;

  Color get _bgColor => avatar.character.bgColor;

  Color get _primaryColor => avatar.character.primaryColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLocked = !avatar.isActive;
    return GestureDetector(
      onTap: isLocked
          ? () => _showSlotLockedSheet(context, ref, avatar)
          : () => ModuleListRoute(avatarId: avatar.id).push(context),
      onLongPress: () => _showTutorOptions(context, ref, avatar),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outline),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Column(
              children: [
                // Character area
                Expanded(
                  child: Container(
                    color: _bgColor,
                    width: double.infinity,
                    child: Center(
                      child: CharacterWidget.forAvatar(avatar, 80),
                    ),
                  ),
                ),
                // Info area — centered horizontally
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _bgColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          avatar.subject,
                          style: AppTextStyles.caption.copyWith(
                            color: _primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        avatar.name,
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.text1,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Lock overlay — shown when avatar is outside the user's slot cap
            if (isLocked)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(120),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Icon(Icons.lock_rounded,
                        color: Colors.white, size: 32),
                  ),
                ),
              ),
            // Active / knowledge badge
            if (avatar.hasKnowledge && !isLocked)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: AppColors.teal,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Demo centre card (admin-only, visual preview only) ────────────────────────

// ── Locked Mochi slot sheet ───────────────────────────────────────────────────

void _showSlotLockedSheet(BuildContext context, WidgetRef ref, Avatar avatar) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetCtx) => _SlotLockedSheet(avatar: avatar, ref: ref),
  );
}

class _SlotLockedSheet extends ConsumerStatefulWidget {
  const _SlotLockedSheet({required this.avatar, required this.ref});
  final Avatar avatar;
  final WidgetRef ref;

  @override
  ConsumerState<_SlotLockedSheet> createState() => _SlotLockedSheetState();
}

class _SlotLockedSheetState extends ConsumerState<_SlotLockedSheet> {
  bool _isLoading = false;
  String? _error;

  Future<void> _activateSlot() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final dio = ref.read(dioProvider);
      await dio.patch<dynamic>(
        '/api/v1/avatars/${widget.avatar.id}/active',
        data: {'active': true},
      );
      if (mounted) Navigator.of(context).pop();
      // Refresh home so the avatar unlocks immediately
      ref.invalidate(homeViewModelProvider);
    } on DioException catch (e) {
      final msg = e.response?.data is Map
          ? (e.response!.data as Map)['error']?.toString() ??
              'Could not activate — try again.'
          : 'Could not activate — try again.';
      if (mounted) setState(() { _isLoading = false; _error = msg; });
    } catch (_) {
      if (mounted) setState(() { _isLoading = false; _error = 'Something went wrong.'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final trial = ref.watch(trialStatusProvider).valueOrNull;
    final cap = trial?.freeTutorCap ?? 1;
    final isPremium = trial?.isPremium ?? false;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg + MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.outline, borderRadius: BorderRadius.circular(2)),
            ),
          const SizedBox(height: AppSpacing.lg),
          const Icon(Icons.lock_rounded, color: AppColors.amber, size: 48),
          const SizedBox(height: AppSpacing.md),
          Text('${widget.avatar.name} is locked', style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.sm),
          Text(
            isPremium
                ? 'Something went wrong — this Mochi should be active. Pull to refresh.'
                : 'You have $cap active Mochi${cap == 1 ? '' : 's'} on your free plan. '
                  'Deactivate another Mochi first, then activate this one.\n\n'
                  'You can swap once every 24 hours.',
            style: AppTextStyles.body.copyWith(color: AppColors.text2),
            textAlign: TextAlign.center,
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.coralL,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(_error!,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.coral),
                  textAlign: TextAlign.center),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          if (!isPremium) ...[
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isLoading ? null : _activateSlot,
                icon: _isLoading
                    ? const SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.lock_open_rounded, size: 18),
                label: Text(_isLoading ? 'Activating…' : 'Activate ${widget.avatar.name}'),
                style: FilledButton.styleFrom(
                    backgroundColor: AppColors.purple,
                    padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ),
          ],
        ),
      ),
    );
  }
}

// ── Tutor long-press options sheet ────────────────────────────────────────────

void _showTutorOptions(BuildContext context, WidgetRef ref, Avatar avatar) {
  // centreManaged=true → this avatar is a centre Mochi; suppress destructive
  // and knowledge-management options. Personal avatars are always fully editable.
  final isCentre = avatar.centreManaged;
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetCtx) => Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(sheetCtx).height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
            decoration: BoxDecoration(
              color: AppColors.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: avatar.character.bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Image.asset(avatar.character.assetPath,
                      width: 40, height: 40, fit: BoxFit.contain),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(avatar.name,
                        style: AppTextStyles.title.copyWith(fontSize: 16),
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
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (!isCentre)
            _OptionTile(
              icon: Icons.library_books_outlined,
              label: 'Manage knowledge',
              color: AppColors.teal,
              onTap: () {
                Navigator.pop(sheetCtx);
                UploadRoute(avatarId: avatar.id).push(context);
              },
            ),
          if (!isCentre)
            _OptionTile(
              icon: Icons.delete_outline_rounded,
              label: 'Delete Mochi',
              color: AppColors.coral,
              onTap: () async {
                Navigator.pop(sheetCtx);
                final confirmed = await PallyDeleteTutorDialog.show(
                  context: context,
                  avatar: avatar,
                );
                if (confirmed == true) {
                  final ok = await ref
                      .read(homeViewModelProvider.notifier)
                      .deleteAvatar(avatar.id);
                  if (context.mounted) {
                    if (ok) {
                      HapticFeedback.heavyImpact();
                      PallyToast.success(context, '${avatar.name} deleted');
                    } else {
                      PallyToast.error(context, 'Delete failed. Try again.');
                    }
                  }
                }
              },
            ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
          ],
        ),
      ),
    ),
  );
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        label,
        style: AppTextStyles.body.copyWith(
          color:
              color == AppColors.coral ? AppColors.coral : AppColors.text1,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.chevron_right,
          color: AppColors.text3, size: 20),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}


// ── P9: Nudge cards ───────────────────────────────────────────────────────────

class _NudgeCardsRow extends ConsumerStatefulWidget {
  const _NudgeCardsRow();

  @override
  ConsumerState<_NudgeCardsRow> createState() => _NudgeCardsRowState();
}

class _NudgeCardsRowState extends ConsumerState<_NudgeCardsRow> {
  List<_NudgeData> _nudges = [];

  static const _fallback = [
    _NudgeData(
      emoji: '⚡',
      message: 'You have flashcards due today!',
      color: AppColors.amber,
      bgColor: AppColors.amberL,
    ),
    _NudgeData(
      emoji: '🔥',
      message: 'Keep your streak going!',
      color: AppColors.coral,
      bgColor: AppColors.coralL,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final dio = ref.read(dioProvider);
      final res = await dio.get<Map<String, dynamic>>('/api/v1/home/nudges');
      final List raw = (res.data?['nudges'] as List?) ?? [];
      final parsed = raw.map((n) {
        final m = n as Map<String, dynamic>;
        final type = m['type'] as String? ?? 'info';
        final (color, bgColor) = switch (type) {
          'streak' => (AppColors.coral, AppColors.coralL),
          'quiz' => (AppColors.purple, AppColors.purpleL),
          'flashcard' => (AppColors.amber, AppColors.amberL),
          'content' => (AppColors.teal, AppColors.tealL),
          _ => (AppColors.text2, AppColors.surf2),
        };
        return _NudgeData(
          emoji: m['emoji'] as String? ?? '💡',
          message: m['message'] as String? ?? '',
          color: color,
          bgColor: bgColor,
        );
      }).where((n) => n.message.isNotEmpty).toList();
      if (mounted) setState(() => _nudges = parsed);
    } on DioException catch (e) {
      appLog.d('[Home] Nudges unavailable (${e.type.name}); using fallback');
      if (mounted) setState(() => _nudges = _fallback);
    } catch (e, st) {
      appLog.e('[Home] Nudges load error', error: e, stackTrace: st);
      if (mounted) setState(() => _nudges = _fallback);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_nudges.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        itemCount: _nudges.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (_, i) => _NudgeCard(
          data: _nudges[i],
          onDismiss: () => setState(() => _nudges.removeAt(i)),
        ),
      ),
    );
  }
}

class _NudgeData {
  const _NudgeData({
    required this.emoji,
    required this.message,
    required this.color,
    required this.bgColor,
  });
  final String emoji;
  final String message;
  final Color color;
  final Color bgColor;
}

class _NudgeCard extends StatelessWidget {
  const _NudgeCard({required this.data, required this.onDismiss});
  final _NudgeData data;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: data.bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: data.color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(data.emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            data.message,
            style: AppTextStyles.caption.copyWith(
              color: data.color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onDismiss,
            child: Icon(Icons.close_rounded, size: 14, color: data.color),
          ),
        ],
      ),
    );
  }
}
