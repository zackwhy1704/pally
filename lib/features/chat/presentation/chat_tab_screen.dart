import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/app/router.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/ui/painters/character_painter.dart';
import 'package:pally/core/ui/pally_loading_spinner.dart';
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
        PallyToast.error(context, 'Could not load tutors.');
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
        loading: () => const PallyLoadingSpinner(),
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
                child: CharacterWidget(character: avatar.character, size: 38),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.chat_bubble_outline_rounded,
                size: 64, color: AppColors.text3),
            const SizedBox(height: AppSpacing.md),
            Text('No tutors yet', style: AppTextStyles.title),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Create a tutor from the Home tab first.',
              style: AppTextStyles.body.copyWith(color: AppColors.text2),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
