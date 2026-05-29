import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/error/pally_error.dart';
import 'package:pally/core/ui/pally_error_card.dart';
import 'package:pally/core/ui/pally_loading_spinner.dart';
import 'package:pally/core/ui/pally_toast.dart';
import 'package:pally/features/groups/presentation/groups_view_model.dart';

class GroupDetailScreen extends ConsumerWidget {
  const GroupDetailScreen({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync =
        ref.watch(groupDetailViewModelProvider(groupId));
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: Text('Group', style: AppTextStyles.title),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.coral),
            tooltip: 'Leave group',
            onPressed: () => _confirmLeave(context, ref),
          ),
        ],
      ),
      body: detailAsync.when(
        loading: () => const PallyLoadingSpinner(),
        error: (e, _) => PallyErrorCard(
          message: PallyError.from(e).userMessage,
          onRetry: () =>
              ref.invalidate(groupDetailViewModelProvider(groupId)),
        ),
        data: (detail) => SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _HeaderCard(group: detail.group),
              const SizedBox(height: AppSpacing.md),
              _SectionHeader('Members (${detail.members.length})'),
              const SizedBox(height: AppSpacing.xs),
              for (final m in detail.members)
                _MemberTile(member: m),
              const SizedBox(height: AppSpacing.md),
              const _SectionHeader('Shared notes'),
              const SizedBox(height: AppSpacing.xs),
              if (detail.sharedNotes.isEmpty)
                Padding(
                  padding: AppSpacing.card,
                  child: Text(
                    'No notes shared yet. Open a wiki page and tap "Share to group".',
                    style: AppTextStyles.body
                        .copyWith(color: AppColors.text2),
                  ),
                )
              else
                for (final n in detail.sharedNotes)
                  _NoteTile(note: n),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmLeave(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave this group?'),
        content: const Text("You'll need a new invite code to re-join."),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.coral),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(groupListViewModelProvider.notifier).leave(groupId);
    if (context.mounted) context.pop();
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.group});
  final StudyGroup group;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: AppColors.purpleL,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(group.name, style: AppTextStyles.heading1),
          if (group.subject != null) ...[
            const SizedBox(height: 4),
            Text(group.subject!,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.purple)),
          ],
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const Icon(Icons.tag_rounded,
                  size: 16, color: AppColors.text2),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  group.inviteCode,
                  style: AppTextStyles.body
                      .copyWith(fontFamily: 'monospace'),
                ),
              ),
              TextButton.icon(
                icon: const Icon(Icons.copy_rounded, size: 16),
                label: const Text('Copy'),
                onPressed: () {
                  Clipboard.setData(
                      ClipboardData(text: group.inviteCode));
                  PallyToast.success(context, 'Code copied');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 8),
      child: Text(text.toUpperCase(),
          style: AppTextStyles.label
              .copyWith(letterSpacing: 1.2, color: AppColors.text3)),
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({required this.member});
  final GroupMember member;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Container(
        padding: AppSpacing.card,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outline),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: AppColors.purpleL,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_rounded,
                  size: 18, color: AppColors.purple),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(member.displayName,
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            if (member.role == 'OWNER')
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('OWNER',
                    style: AppTextStyles.caption.copyWith(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w800)),
              ),
          ],
        ),
      ),
    );
  }
}

class _NoteTile extends StatelessWidget {
  const _NoteTile({required this.note});
  final SharedNote note;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Container(
        padding: AppSpacing.card,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outline),
        ),
        child: Row(
          children: [
            const Icon(Icons.menu_book_rounded,
                color: AppColors.purple, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                note.title.isEmpty ? 'Shared note' : note.title,
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
