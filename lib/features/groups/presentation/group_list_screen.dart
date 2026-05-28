import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/app/router.dart';
import 'package:pally/core/services/feature_flags.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/ui/pally_loading_spinner.dart';
import 'package:pally/core/ui/pally_toast.dart';
import 'package:pally/features/groups/presentation/groups_view_model.dart';

class GroupListScreen extends ConsumerWidget {
  const GroupListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flagAsync = ref.watch(featureFlagsProvider);
    // Even when the user reaches the tab directly (deep link), respect the
    // pilot gate. Render the coming-soon card until ops flips the flag.
    final enabled =
        flagAsync.valueOrNull?[FeatureFlags.groupsEnabled] == true;
    if (!enabled) {
      return const _ComingSoonScreen();
    }
    final groupsAsync = ref.watch(groupListViewModelProvider);
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: Text('Study Groups', style: AppTextStyles.title),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () =>
                ref.read(groupListViewModelProvider.notifier).refresh(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.purple,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Group',
            style: TextStyle(color: Colors.white)),
        onPressed: () => const CreateGroupRoute().go(context),
      ),
      body: groupsAsync.when(
        loading: () => const PallyLoadingSpinner(),
        error: (e, _) => Center(child: Text('$e')),
        data: (groups) {
          return RefreshIndicator(
            color: AppColors.purple,
            onRefresh: () => ref
                .read(groupListViewModelProvider.notifier)
                .refresh(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.md, AppSpacing.md, 96),
              children: [
                _JoinByCodeCard(ref: ref),
                const SizedBox(height: AppSpacing.md),
                if (groups.isEmpty)
                  const _EmptyState()
                else
                  ...groups.map((g) => Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _GroupTile(group: g),
                      )),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _JoinByCodeCard extends StatefulWidget {
  const _JoinByCodeCard({required this.ref});
  final WidgetRef ref;

  @override
  State<_JoinByCodeCard> createState() => _JoinByCodeCardState();
}

class _JoinByCodeCardState extends State<_JoinByCodeCard> {
  final _controller = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    final code = _controller.text.trim().toUpperCase();
    if (code.isEmpty) return;
    setState(() => _busy = true);
    final joined = await widget.ref
        .read(groupListViewModelProvider.notifier)
        .join(code);
    if (!mounted) return;
    setState(() => _busy = false);
    if (joined != null) {
      _controller.clear();
      PallyToast.success(context, 'Joined ${joined.name}');
    } else {
      PallyToast.error(context, "Couldn't join — check the code");
    }
  }

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
          Text('Have an invite code?',
              style: AppTextStyles.title.copyWith(fontSize: 16)),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'[A-Z0-9]'))
                  ],
                  maxLength: 6,
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: 'e.g. AB23CD',
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: _busy ? null : _join,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.purple,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _busy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Join'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GroupTile extends StatelessWidget {
  const _GroupTile({required this.group});
  final StudyGroup group;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () =>
            StudyGroupDetailRoute(groupId: group.id).go(context),
        child: Container(
          padding: AppSpacing.card,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.outline),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                    color: AppColors.purpleL, shape: BoxShape.circle),
                child: const Icon(Icons.groups_rounded,
                    color: AppColors.purple),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(group.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body
                            .copyWith(fontWeight: FontWeight.w700)),
                    Text(
                      '${group.memberCount} member${group.memberCount == 1 ? '' : 's'} · code ${group.inviteCode}',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.text2),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.text2),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: Column(
        children: [
          const Icon(Icons.group_add_outlined,
              size: 60, color: AppColors.text3),
          const SizedBox(height: AppSpacing.md),
          Text('No groups yet', style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Create a group or join one with an invite code from a friend.',
            textAlign: TextAlign.center,
            style:
                AppTextStyles.body.copyWith(color: AppColors.text2),
          ),
        ],
      ),
    );
  }
}

class _ComingSoonScreen extends StatelessWidget {
  const _ComingSoonScreen();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: Text('Study Groups', style: AppTextStyles.title),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_clock_rounded,
                  size: 64, color: AppColors.text3),
              const SizedBox(height: AppSpacing.md),
              Text('Coming soon to your account',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.title),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Study groups are in pilot. Ask your teacher to invite you to '
                'the rollout — your account will unlock automatically.',
                textAlign: TextAlign.center,
                style: AppTextStyles.body
                    .copyWith(color: AppColors.text2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
