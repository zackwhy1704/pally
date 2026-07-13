import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/app/router.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/ui/adaptive_content_width.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/error/pally_error.dart';
import 'package:pally/core/ui/adaptive_center.dart';
import 'package:pally/core/ui/painters/character_painter.dart';
import 'package:pally/core/ui/pally_error_card.dart';
import 'package:pally/core/ui/pally_delete_tutor_dialog.dart';
import 'package:pally/core/widgets/loading/pally_skeleton.dart';
import 'package:pally/core/ui/pally_toast.dart';
import 'package:pally/features/home/presentation/home_view_model.dart';
import 'package:pally/features/library/presentation/library_view_model.dart';
import 'package:pally/shared/models/avatar.dart';
enum _LibraryItemType { header, avatar }

/// A single positioned row in the library list: a section header or avatar row.
class _LibraryItem {
  const _LibraryItem.header(String label)
      : type = _LibraryItemType.header,
        headerLabel = label,
        avatar = null;
  const _LibraryItem.avatar(Avatar a)
      : type = _LibraryItemType.avatar,
        headerLabel = null,
        avatar = a;

  final _LibraryItemType type;
  final String? headerLabel;
  final Avatar? avatar;
}

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
      body: AdaptiveContentWidth(
        child: avatarsAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: PallyAvatarListSkeleton(),
        ),
        error: (e, _) => PallyErrorCard(
          message: PallyError.from(e).userMessage,
          onRetry: () => ref.read(libraryViewModelProvider.notifier).refresh(),
        ),
        data: (avatars) => avatars.isEmpty
            ? _EmptyLibraryView()
            : RefreshIndicator(
                color: AppColors.purple,
                onRefresh: () =>
                    ref.read(libraryViewModelProvider.notifier).refresh(),
                child: Builder(builder: (context) {
                  final items = _buildLibraryItems(avatars);
                  return ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: items.length,
                    itemBuilder: (context, index) =>
                        _buildLibraryRow(context, ref, items[index]),
                  );
                }),
              ),
      ),
      ),
    );
  }

  /// Orders library rows so class avatars are grouped under a "My classes"
  /// header above personal tutors.
  List<_LibraryItem> _buildLibraryItems(List<Avatar> avatars) {
    final classAvatars = avatars.where((a) => a.isCentreClass);
    final personalAvatars = avatars.where((a) => !a.isCentreClass);
    return [
      if (classAvatars.isNotEmpty) ...[
        const _LibraryItem.header('My classes'),
        for (final a in classAvatars) _LibraryItem.avatar(a),
      ],
      for (final a in personalAvatars) _LibraryItem.avatar(a),
    ];
  }

  Widget _buildLibraryRow(
    BuildContext context,
    WidgetRef ref,
    _LibraryItem item,
  ) {
    switch (item.type) {
      case _LibraryItemType.header:
        return Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.xs, AppSpacing.xs, AppSpacing.xs, AppSpacing.sm),
          child: Text(
            item.headerLabel!,
            style: AppTextStyles.label
                .copyWith(letterSpacing: 1.2, color: AppColors.text2),
          ),
        );
      case _LibraryItemType.avatar:
        final avatar = item.avatar!;
        // Centre-class avatars are provisioned by a centre and can't be DELETED
        // by the child — but the child may LEAVE the class (swipe → confirm).
        // Class materials stay read-only; only their enrolment + class avatar go.
        if (avatar.isCentreClass) {
          final classId = avatar.classId;
          if (classId == null) {
            return _AvatarRow(avatar: avatar); // corpus/edge case — no action
          }
          return Dismissible(
            key: ValueKey('leave-${avatar.id}'),
            direction: DismissDirection.endToStart,
            background: Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 24),
              decoration: BoxDecoration(
                color: AppColors.amber,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout_rounded, color: Colors.white, size: 24),
                  SizedBox(height: 2),
                  Text('Leave',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            confirmDismiss: (_) =>
                _confirmAndLeaveClass(context, ref, avatar.name, classId),
            child: _AvatarRow(avatar: avatar),
          );
        }
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
          // Delete in confirmDismiss so the data is gone BEFORE the dismiss
          // animation completes — prevents the "A dismissed Dismissible widget
          // is still part of the tree" Flutter crash on next rebuild.
          confirmDismiss: (_) async {
            final confirmed = await PallyDeleteTutorDialog.show(
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
              PallyToast.success(context, '${avatar.name} deleted');
              ref.invalidate(libraryViewModelProvider);
              return true;
            }
            PallyToast.error(context, 'Delete failed. Try again.');
            return false;
          },
          child: _AvatarRow(avatar: avatar),
        );
    }
  }

  /// Confirms then leaves a class via POST /centre/leave-class. Returns true if
  /// the row should dismiss. Only the enrolment + this class avatar are removed;
  /// personal Mochis and class materials are untouched.
  Future<bool> _confirmAndLeaveClass(
      BuildContext context, WidgetRef ref, String name, String classId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave this class?'),
        content: Text(
          "You'll lose access to $name's materials and class Mochi. "
          'Your personal Mochis stay. You can rejoin with the class code.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.coral),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
    if (confirmed != true) return false;

    try {
      await ref.read(dioProvider).post<dynamic>(
        '/api/v1/centre/leave-class',
        data: {'classId': classId},
      );
      if (!context.mounted) return true;
      HapticFeedback.heavyImpact();
      PallyToast.success(context, 'Left $name');
      ref.invalidate(libraryViewModelProvider);
      ref.invalidate(homeViewModelProvider);
      return true;
    } on DioException catch (e) {
      if (context.mounted) {
        PallyToast.error(context, PallyError.from(e).userMessage);
      }
      return false;
    }
  }
}

class _AvatarRow extends ConsumerWidget {
  const _AvatarRow({required this.avatar});

  final Avatar avatar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      // The row is now a clean front door into the per-avatar Hub — the guided
      // journey lives there. (Notes/Wiki is one row inside the hub.)
      onTap: () => AvatarHubRoute(avatarId: avatar.id).push(context),
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
                child: CharacterWidget.forAvatar(avatar, 40),
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
                    // Compiling takes priority over the knowledge count: after a
                    // chapter pick the brain leaves READY (PENDING_RECOMPILE →
                    // COMPILING) while it may already have pages, so this is the
                    // honest "async job in flight" surface the compile dialog + the
                    // compile timeout copy both point users to.
                    avatar.isBrainCompiling
                        ? '📖 Mochi is reading your chapters…'
                        : avatar.hasKnowledge
                            ? '🧠 ${avatar.wikiPageCount} brain page${avatar.wikiPageCount == 1 ? '' : 's'}'
                            : avatar.fileCount > 0
                                ? '⏳ Building brain from ${avatar.fileCount} file${avatar.fileCount == 1 ? '' : 's'}…'
                                : '📂 No notes yet — teach me your material!',
                    style: AppTextStyles.caption.copyWith(
                      color: avatar.isBrainCompiling
                          ? AppColors.purple
                          : avatar.hasKnowledge
                              ? AppColors.purple
                              : avatar.fileCount > 0
                                  ? AppColors.amber
                                  : AppColors.text3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Chevron — the whole row taps into the hub.
            const Icon(Icons.chevron_right_rounded, color: AppColors.text3),
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

class _EmptyLibraryView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AdaptiveCenter(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.menu_book_outlined,
              size: 64, color: AppColors.text3),
          const SizedBox(height: AppSpacing.md),
          Text('No Mochis yet', style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Create a Mochi from the Home tab to see it here.',
            style: AppTextStyles.body.copyWith(color: AppColors.text2),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}



