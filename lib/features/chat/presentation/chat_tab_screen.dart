import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/app/router.dart';
import 'package:pally/core/widgets/loading/pally_skeleton.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/shared/widgets/mochi_placeholder.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/ui/painters/character_painter.dart';
import 'package:pally/core/ui/pally_toast.dart';
import 'package:pally/features/home/presentation/home_view_model.dart';
import 'package:pally/shared/models/avatar.dart';

class ChatTabScreen extends ConsumerWidget {
  const ChatTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avatarsAsync = ref.watch(homeViewModelProvider);

    ref.listen<AsyncValue<List<Avatar>>>(homeViewModelProvider, (_, next) {
      if (next is AsyncError) {
        PallyToast.error(context, 'Could not load Mochis.');
      }
    });

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: Text('Chat', style: AppTextStyles.title),
        centerTitle: true,
      ),
      body: avatarsAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: PallyAvatarListSkeleton(count: 3),
        ),
        error: (_, __) => _EmptyView(),
        data: (avatars) => avatars.isEmpty
            ? _EmptyView()
            : ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: avatars.length,
                itemBuilder: (context, index) =>
                    _AvatarTile(avatar: avatars[index]),
              ),
      ),
    );
  }
}

class _AvatarTile extends StatelessWidget {
  const _AvatarTile({required this.avatar});
  final Avatar avatar;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => ChatRoute(avatarId: avatar.id).push(context),
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
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: avatar.character.bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: CharacterWidget.forAvatar(avatar, 38),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    avatar.name,
                    style: AppTextStyles.body
                        .copyWith(fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    avatar.subject,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.text2),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.text3),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: MochiPlaceholder(
          title: 'No Mochis yet',
          subtitle: 'Create a Mochi from the Home tab first.',
        ),
      ),
    );
  }
}
