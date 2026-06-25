import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart' as share_plus;
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/ui/pally_toast.dart';
import 'package:pally/features/wiki_viewer/data/review_service.dart';
import 'package:pally/features/wiki_viewer/presentation/review_view_model.dart';
import 'package:pally/shared/models/wiki_page.dart';

/// "Get it checked" bottom sheet. Standard scrollable sheet
/// (isScrollControlled + maxHeight + SingleChildScrollView).
class GetItCheckedSheet extends ConsumerWidget {
  const GetItCheckedSheet({
    super.key,
    required this.avatarId,
    required this.page,
    this.canEditNotes = true,
  });

  final String avatarId;
  final WikiPage page;
  // Centre classes: notes are managed by the teacher, not the student.
  final bool canEditNotes;

  Future<void> _shareLink(BuildContext context, WidgetRef ref) async {
    final url = await ref
        .read(reviewViewModelProvider(page.id).notifier)
        .createShareLink();
    if (!context.mounted) return;
    if (url == null) {
      final err = ref.read(reviewViewModelProvider(page.id)).error;
      PallyToast.error(context, err ?? "Couldn't create a review link.");
      return;
    }
    await share_plus.Share.share(
      'Hi! I made a study guide on ${page.title} with Apalchi. '
      "Could you check it's accurate? Takes 2 min: $url",
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reviewViewModelProvider(page.id));
    final pending = state.pending;

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
          AppSpacing.lg + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Get it checked', style: AppTextStyles.title),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Ask a grown-up to confirm “${page.title}” is accurate.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.text2),
            ),
            const SizedBox(height: AppSpacing.md),

            // Pending request row — share link active, with revoke.
            if (pending != null) ...[
              _PendingRow(
                request: pending,
                isRevoking: state.isRevoking,
                onRevoke: () => ref
                    .read(reviewViewModelProvider(page.id).notifier)
                    .revoke(pending.id),
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            _SheetAction(
              icon: Icons.ios_share_rounded,
              label: 'Share review link',
              subtitle: 'Send a link to anyone to check it',
              busy: state.isCreating,
              onTap: state.isCreating ? null : () => _shareLink(context, ref),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Centre classes: notes are managed by the teacher, not the student.
            if (canEditNotes)
              _SheetAction(
                icon: Icons.edit_note_rounded,
                label: 'Fix my notes',
                subtitle: 'Add or re-upload content for this page',
                onTap: () {
                  Navigator.of(context).pop();
                  context.go('/avatar/$avatarId/upload');
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _PendingRow extends StatelessWidget {
  const _PendingRow({
    required this.request,
    required this.isRevoking,
    required this.onRevoke,
  });

  final ReviewRequest request;
  final bool isRevoking;
  final VoidCallback onRevoke;

  @override
  Widget build(BuildContext context) {
    final days = request.daysUntilExpiry;
    final expiry = days == null
        ? 'Review link active'
        : 'Review link active — expires in $days day${days == 1 ? '' : 's'}';
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.tealL,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.teal.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.link_rounded, size: 18, color: AppColors.teal),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              expiry,
              style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.teal, fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          TextButton(
            onPressed: isRevoking ? null : onRevoke,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.coral,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              minimumSize: const Size(0, 36),
            ),
            child: isRevoking
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.coral),
                  )
                : const Text('Revoke'),
          ),
        ],
      ),
    );
  }
}

class _SheetAction extends StatelessWidget {
  const _SheetAction({
    required this.icon,
    required this.label,
    required this.subtitle,
    this.busy = false,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final bool busy;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surf2,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.outline),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: busy
                  ? const CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.purple)
                  : Icon(icon,
                      size: 22,
                      color:
                          disabled ? AppColors.text3 : AppColors.purple),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w700,
                      color: disabled ? AppColors.text3 : AppColors.text1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style:
                        AppTextStyles.caption.copyWith(color: AppColors.text2),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
