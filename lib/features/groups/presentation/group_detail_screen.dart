import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/app/router.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/error/pally_error.dart';
import 'package:pally/core/ui/pally_error_card.dart';
import 'package:pally/core/ui/pally_loading_spinner.dart';
import 'package:pally/core/ui/pally_toast.dart';
import 'package:pally/features/groups/presentation/challenge_card.dart';
import 'package:pally/features/groups/presentation/challenge_view_model.dart';
import 'package:pally/features/groups/presentation/groups_view_model.dart';

class GroupDetailScreen extends ConsumerWidget {
  const GroupDetailScreen({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(groupDetailViewModelProvider(groupId));
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        // G2 — real back button so user can always return to the list
        leading: const BackButton(),
        title: detailAsync.whenOrNull(
              data: (d) =>
                  Text(d.group.name, style: AppTextStyles.title),
            ) ??
            Text('Study Group', style: AppTextStyles.title),
        centerTitle: true,
        actions: [
          // CLASS groups are centre-managed: students get 403 on leave/kick,
          // so the leave control is hidden entirely for them.
          if (detailAsync.valueOrNull?.group.isClassGroup == false)
            PopupMenuButton<_MenuAction>(
              onSelected: (action) {
                if (action == _MenuAction.leave) {
                  _confirmLeave(context, ref);
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: _MenuAction.leave,
                  child: Row(
                    children: [
                      Icon(Icons.logout_rounded,
                          color: AppColors.coral, size: 18),
                      SizedBox(width: 8),
                      Text('Leave group',
                          style: TextStyle(color: AppColors.coral)),
                    ],
                  ),
                ),
              ],
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
        data: (detail) => RefreshIndicator(
          color: AppColors.purple,
          onRefresh: () async =>
              ref.invalidate(groupDetailViewModelProvider(groupId)),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.sm, AppSpacing.md, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Purpose line
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.purpleL,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(detail.group.isClassGroup ? '🏫' : '📚',
                          style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          detail.group.isClassGroup
                              ? 'Your class feed — challenges & released answers'
                              : 'Share your best notes — learn from each other',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.purple),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Class groups: challenges + system feed. Invite is hidden
                // (students can't invite into a centre-managed class).
                if (detail.group.isClassGroup) ...[
                  if (detail.group.classId != null &&
                      detail.group.classId!.isNotEmpty)
                    _ChallengesSection(classId: detail.group.classId!),
                ] else ...[
                  // Invite card (peer groups only)
                  _InviteCard(group: detail.group),
                  const SizedBox(height: AppSpacing.md),
                ],

                // Members
                _SectionHeader(
                    'Members (${detail.members.length})'),
                const SizedBox(height: AppSpacing.xs),
                ...detail.members.map((m) => _MemberTile(
                      member: m,
                      groupId: groupId,
                      ref: ref,
                    )),
                const SizedBox(height: AppSpacing.md),

                // Shared notes feed
                _SectionHeader(
                    'Shared notes (${detail.sharedNotes.length})'),
                const SizedBox(height: AppSpacing.xs),
                if (detail.sharedNotes.isEmpty)
                  _EmptyNotesState(groupId: groupId)
                else ...[
                  ...detail.sharedNotes.map((n) => _NoteTile(note: n)),
                  const SizedBox(height: AppSpacing.sm),
                  // Always show the "share a note" nudge at the bottom
                  _ShareNudge(groupId: groupId),
                ],
              ],
            ),
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
        content:
            const Text("You'll need a new invite code to re-join."),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style:
                TextButton.styleFrom(foregroundColor: AppColors.coral),
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

enum _MenuAction { leave }

// ── Challenges section (P3) ──────────────────────────────────────────────────

/// Renders every open/recent challenge for the class as inline cards.
class _ChallengesSection extends ConsumerWidget {
  const _ChallengesSection({required this.classId});
  final String classId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(classChallengesViewModelProvider(classId));
    final challenges = async.valueOrNull ?? const [];
    if (challenges.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionHeader('Challenges'),
        const SizedBox(height: AppSpacing.xs),
        for (final c in challenges) ChallengeCard(challengeId: c.id),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }
}

// ── Invite card ──────────────────────────────────────────────────────────────

class _InviteCard extends StatelessWidget {
  const _InviteCard({required this.group});
  final StudyGroup group;

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
          Row(
            children: [
              const Icon(Icons.group_add_rounded,
                  size: 18, color: AppColors.purple),
              const SizedBox(width: 6),
              Text('Invite a friend',
                  style: AppTextStyles.body
                      .copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text('Share this code with a friend to invite them',
              style:
                  AppTextStyles.bodySmall.copyWith(color: AppColors.text2)),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.purpleL,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  group.inviteCode,
                  style: AppTextStyles.title.copyWith(
                      letterSpacing: 4, color: AppColors.purple),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    Clipboard.setData(
                        ClipboardData(text: group.inviteCode));
                    PallyToast.success(context, 'Code copied!');
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.purple,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  label: const Text('Copy'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 4),
      child: Text(
        text.toUpperCase(),
        style: AppTextStyles.label
            .copyWith(letterSpacing: 1.2, color: AppColors.text3),
      ),
    );
  }
}

// ── Member tile ───────────────────────────────────────────────────────────────

class _MemberTile extends StatelessWidget {
  const _MemberTile({
    required this.member,
    required this.groupId,
    required this.ref,
  });
  final GroupMember member;
  final String groupId;
  final WidgetRef ref;

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
              child: Text(
                member.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body,
              ),
            ),
            if (member.role == 'OWNER')
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 2),
                constraints: const BoxConstraints(maxWidth: 80),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'OWNER',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Note tile ─────────────────────────────────────────────────────────────────

class _NoteTile extends StatelessWidget {
  const _NoteTile({required this.note});
  final SharedNote note;

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final canNavigate =
        note.avatarId.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: canNavigate
              ? () => WikiViewerRoute(avatarId: note.avatarId).push(context)
              : null,
          child: Container(
            padding: AppSpacing.card,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outline),
            ),
            child: Row(
              children: [
                const Icon(Icons.menu_book_rounded,
                    color: AppColors.purple, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        note.title.isEmpty ? 'Shared note' : note.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'by ${note.sharedBy} · ${_timeAgo(note.sharedAt)}',
                        style: AppTextStyles.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (note.relevanceStatus == 'WARNING')
                  Container(
                    margin: const EdgeInsets.only(left: 4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    constraints: const BoxConstraints(maxWidth: 80),
                    decoration: BoxDecoration(
                      color: AppColors.amberL,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Off topic?',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.amber),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                if (canNavigate) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right_rounded,
                      size: 18, color: AppColors.text3),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyNotesState extends StatelessWidget {
  const _EmptyNotesState({required this.groupId});
  final String groupId;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AppColors.outline, style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          const Text('📖', style: TextStyle(fontSize: 40)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'No notes shared yet',
            style: AppTextStyles.title,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Open a wiki page from your Library and tap "Share to group" to add the first note!',
            style: AppTextStyles.body.copyWith(color: AppColors.text2),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton.icon(
            onPressed: () => context.go('/library'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.purple,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.auto_stories_rounded, size: 18),
            label: const Text('Go to Library'),
          ),
        ],
      ),
    );
  }
}

class _ShareNudge extends StatelessWidget {
  const _ShareNudge({required this.groupId});
  final String groupId;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/library'),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.tealL,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.add_circle_outline_rounded,
                color: AppColors.teal, size: 18),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Share another note from Library',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.teal),
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                size: 16, color: AppColors.teal),
          ],
        ),
      ),
    );
  }
}
