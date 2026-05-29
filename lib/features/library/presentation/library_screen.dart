import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/app/router.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/ui/painters/character_painter.dart';
import 'package:pally/core/ui/pally_delete_tutor_dialog.dart';
import 'package:pally/core/ui/pally_loading_spinner.dart';
import 'package:pally/core/ui/pally_toast.dart';
import 'package:pally/features/home/presentation/home_view_model.dart';
import 'package:pally/features/library/presentation/library_view_model.dart';
import 'package:pally/features/quiz/providers/quiz_status_provider.dart';
import 'package:pally/shared/models/avatar.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avatarsAsync = ref.watch(libraryViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: Text('Library', style: AppTextStyles.title),
        centerTitle: true,
      ),
      body: avatarsAsync.when(
        loading: () => const PallyLoadingSpinner(),
        error: (e, _) => _ErrorView(
          onRetry: () => ref.read(libraryViewModelProvider.notifier).refresh(),
        ),
        data: (avatars) => avatars.isEmpty
            ? _EmptyLibraryView()
            : RefreshIndicator(
                color: AppColors.purple,
                onRefresh: () =>
                    ref.read(libraryViewModelProvider.notifier).refresh(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: avatars.length,
                  itemBuilder: (context, index) {
                    final avatar = avatars[index];
                    return Dismissible(
                      key: ValueKey(avatar.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 24),
                        decoration: BoxDecoration(
                          color: AppColors.coral,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.delete_outline_rounded,
                                color: Colors.white, size: 24),
                            SizedBox(height: 2),
                            Text('Delete',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      // Delete in confirmDismiss so the data is gone BEFORE
                      // the dismiss animation completes — prevents the
                      // "A dismissed Dismissible widget is still part of
                      // the tree" Flutter crash on next rebuild.
                      confirmDismiss: (_) async {
                        final confirmed =
                            await PallyDeleteTutorDialog.show(
                          context: context,
                          avatar: avatar,
                        );
                        if (confirmed != true) return false;

                        final ok = await ref
                            .read(homeViewModelProvider.notifier)
                            .deleteAvatar(avatar.id);
                        if (!context.mounted) return ok;

                        if (ok) {
                          HapticFeedback.heavyImpact();
                          PallyToast.success(
                              context, '${avatar.name} deleted');
                          ref.invalidate(libraryViewModelProvider);
                          return true;
                        }
                        PallyToast.error(
                            context, 'Delete failed. Try again.');
                        return false;
                      },
                      child: _AvatarRow(avatar: avatar),
                    );
                  },
                ),
              ),
      ),
    );
  }
}

class _AvatarRow extends StatelessWidget {
  const _AvatarRow({required this.avatar});

  final Avatar avatar;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => WikiViewerRoute(avatarId: avatar.id).push(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: AppSpacing.card,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outline),
        ),
        child: Row(
          children: [
            // Character avatar
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: avatar.character.bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: CharacterWidget(character: avatar.character, size: 40),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          avatar.name,
                          style: AppTextStyles.body
                              .copyWith(fontWeight: FontWeight.w700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      _SubjectBadge(
                        subject: avatar.subject,
                        color: avatar.character.primaryColor,
                        bgColor: avatar.character.bgColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    avatar.hasKnowledge
                        ? '${avatar.wikiPageCount} page${avatar.wikiPageCount == 1 ? '' : 's'} learned'
                        : 'No content yet',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            // Action buttons
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ActionChip(
                      label: 'Chat',
                      icon: Icons.chat_bubble_rounded,
                      color: AppColors.purple,
                      onTap: () => ChatRoute(avatarId: avatar.id).push(context),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    _ActionChip(
                      label: 'Add',
                      icon: Icons.add_rounded,
                      color: AppColors.teal,
                      onTap: () =>
                          UploadRoute(avatarId: avatar.id).push(context),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _QuizChipForAvatar(avatar: avatar),
                    const SizedBox(width: AppSpacing.xs),
                    _ActionChip(
                      label: 'Map',
                      icon: Icons.bubble_chart_rounded,
                      color: avatar.hasKnowledge
                          ? AppColors.teal
                          : AppColors.text3,
                      onTap: avatar.hasKnowledge
                          ? () =>
                              BrainMapRoute(avatarId: avatar.id).push(context)
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SubjectBadge extends StatelessWidget {
  const _SubjectBadge({
    required this.subject,
    required this.color,
    required this.bgColor,
  });

  final String subject;
  final Color color;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      constraints: const BoxConstraints(maxWidth: 140),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        subject,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 3),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyLibraryView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.menu_book_outlined,
                size: 64, color: AppColors.text3),
            const SizedBox(height: AppSpacing.md),
            Text('No tutors yet', style: AppTextStyles.title),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Create a tutor from the Home tab to see it here.',
              style: AppTextStyles.body.copyWith(color: AppColors.text2),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 64, color: AppColors.coral),
          const SizedBox(height: AppSpacing.md),
          Text('Could not load library', style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.lg),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

/// Quiz chip with daily-journey state baked in.
///  • Knowledge empty → grey, "upload first" snackbar (legacy behaviour).
///  • Already taken today → green tick, "Done today" label, tap reopens
///    the quiz screen anyway (free-play) but the chip telegraphs that
///    the streak is already locked in.
///  • Available → amber lightning, label shows "X/Y" coverage when the
///    avatar has any quiz history.
class _QuizChipForAvatar extends ConsumerWidget {
  const _QuizChipForAvatar({required this.avatar});
  final Avatar avatar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!avatar.hasKnowledge) {
      return _ActionChip(
        label: 'Quiz',
        icon: Icons.bolt_rounded,
        color: AppColors.text3,
        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Upload notes first to unlock quizzes'),
            backgroundColor: AppColors.amber,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );
    }
    final statusAsync = ref.watch(quizStatusProvider(avatar.id));
    final status = statusAsync.valueOrNull;
    final takenToday = status?.takenToday ?? false;
    final coverageLabel = (status != null && status.totalTopics > 0)
        ? ' ${status.masteredTopics}/${status.totalTopics}'
        : '';
    return _ActionChip(
      label: takenToday ? 'Done today' : 'Quiz$coverageLabel',
      icon: takenToday ? Icons.check_circle_rounded : Icons.bolt_rounded,
      color: takenToday ? AppColors.green : AppColors.amber,
      onTap: () => QuizRoute(avatarId: avatar.id).push(context),
    );
  }
}
