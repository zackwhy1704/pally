import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/core/services/feature_flags.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_sizing.dart';
import 'package:pally/core/ui/painters/character_painter.dart';
import 'package:pally/core/ui/pally_loading_spinner.dart';
import 'package:pally/core/ui/pally_toast.dart';
import 'package:pally/features/groups/presentation/groups_view_model.dart';
import 'package:pally/features/wiki_viewer/presentation/wiki_viewer_view_model.dart';
import 'package:pally/shared/models/avatar.dart';
import 'package:pally/shared/models/wiki_page.dart';

class WikiViewerScreen extends ConsumerStatefulWidget {
  const WikiViewerScreen({super.key, required this.avatarId});

  final String avatarId;

  @override
  ConsumerState<WikiViewerScreen> createState() => _WikiViewerScreenState();
}

class _WikiViewerScreenState extends ConsumerState<WikiViewerScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vmState = ref.watch(wikiViewerViewModelProvider(widget.avatarId));

    ref.listen<WikiViewerState>(wikiViewerViewModelProvider(widget.avatarId),
        (_, next) {
      if (next.error != null) {
        PallyToast.error(context, next.error?.userMessage ?? 'Something went wrong.');
      }
    });

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          _BrainHeader(
            avatarId: widget.avatarId,
            avatar: vmState.avatar,
            pageCount: vmState.pageCount,
          ),
          // Compiling banner: shown while async wiki compilation is in
          // progress. Auto-disappears once all files leave PROCESSING state.
          if (vmState.isCompiling)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              color: AppColors.amberL,
              child: Row(
                children: [
                  const SizedBox(
                    width: AppSizing.spinnerSm,
                    height: AppSizing.spinnerSm,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.amber,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Mochi is reading your notes — new pages will appear here automatically.',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.amber),
                    ),
                  ),
                ],
              ),
            ),
          _SearchBar(
            controller: _searchController,
            onChanged: (q) => ref
                .read(wikiViewerViewModelProvider(widget.avatarId).notifier)
                .updateSearch(q),
          ),
          Expanded(
            child: vmState.isLoading
                ? const PallyLoadingSpinner()
                : RefreshIndicator(
                    color: AppColors.purple,
                    onRefresh: () => ref
                        .read(wikiViewerViewModelProvider(widget.avatarId)
                            .notifier)
                        .refresh(),
                    child: vmState.filteredPages.isEmpty
                        ? ListView(
                            children: const [
                              SizedBox(height: 80),
                              _EmptyView(),
                            ],
                          )
                        : _PagesList(
                            pages: vmState.filteredPages,
                            avatarId: widget.avatarId,
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Header with stats ──────────────────────────────────────────────────────

class _BrainHeader extends StatelessWidget {
  const _BrainHeader({
    required this.avatarId,
    required this.avatar,
    required this.pageCount,
  });

  final String avatarId;
  final Avatar? avatar;
  final int pageCount;

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Container(
      color: AppColors.purpleL,
      padding: EdgeInsets.only(top: topPad),
      child: Column(
        children: [
          // AppBar row
          SizedBox(
            height: 56,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: AppColors.purple),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: Text(
                    avatar != null
                        ? "${avatar!.name}'s Brain 🧠"
                        : 'Mochi Brain 🧠',
                    style: AppTextStyles.title,
                    textAlign: TextAlign.center,
                  ),
                ),
                // balance icon button
                const SizedBox(width: 48),
              ],
            ),
          ),
          // Avatar + stats
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.md),
            child: Row(
              children: [
                if (avatar != null)
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: avatar!.character.bgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: CharacterWidget(
                          character: avatar!.character, size: 38),
                    ),
                  ),
                if (avatar != null) const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatBox(value: '$pageCount', label: 'pages'),
                      _StatBox(
                          value: '${(pageCount * 0.3).ceil()}',
                          label: 'topics'),
                      _StatBox(
                          value: '${(pageCount * 0.4).ceil()}',
                          label: 'sources'),
                      _StatBox(
                          value: '${(pageCount * 0.2).ceil()}', label: 'links'),
                    ],
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

class _StatBox extends StatelessWidget {
  const _StatBox({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value,
              style: AppTextStyles.title
                  .copyWith(color: AppColors.purple, fontSize: 20)),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

// ── Search bar ─────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.onChanged});
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bg,
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xs),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppTextStyles.body,
        decoration: InputDecoration(
          hintText: 'Search pages…',
          hintStyle: AppTextStyles.body.copyWith(color: AppColors.text3),
          prefixIcon: const Icon(Icons.search_rounded,
              color: AppColors.text3, size: 20),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded,
                      color: AppColors.text3, size: 18),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.outline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.purple, width: 2),
          ),
        ),
      ),
    );
  }
}

// ── Pages list ─────────────────────────────────────────────────────────────

class _PagesList extends StatelessWidget {
  const _PagesList({required this.pages, required this.avatarId});
  final List<WikiPage> pages;
  final String avatarId;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(
          left: AppSpacing.md, right: AppSpacing.md, bottom: AppSpacing.lg),
      children: [
        const SizedBox(height: AppSpacing.sm),
        Text('RECENT PAGES',
            style: AppTextStyles.label
                .copyWith(color: AppColors.text3, letterSpacing: 0.8)),
        const SizedBox(height: AppSpacing.sm),
        ...pages.map((p) => _PageTile(page: p, avatarId: avatarId)),
      ],
    );
  }
}

class _PageTile extends ConsumerStatefulWidget {
  const _PageTile({required this.page, required this.avatarId});
  final WikiPage page;
  final String avatarId;

  @override
  ConsumerState<_PageTile> createState() => _PageTileState();
}

class _PageTileState extends ConsumerState<_PageTile> {
  bool _isEditing = false;
  bool _isSaving = false;
  bool _isSharing = false;
  late final TextEditingController _editController;

  @override
  void initState() {
    super.initState();
    _editController = TextEditingController(text: widget.page.content);
  }

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  String get _slug =>
      widget.page.slug ??
      widget.page.title.toLowerCase().replaceAll(' ', '-');

  Future<void> _save() async {
    final newContent = _editController.text.trim();
    if (newContent.isEmpty) return;
    setState(() => _isSaving = true);
    await ref
        .read(wikiViewerViewModelProvider(widget.avatarId).notifier)
        .patchCorrection(_slug, newContent);
    if (mounted) setState(() { _isSaving = false; _isEditing = false; });
  }

  Future<void> _shareToGroup(BuildContext context) async {
    // Capture before any async gap.
    final scaffold = ScaffoldMessenger.of(context);
    final groups = ref.read(groupListViewModelProvider).valueOrNull ?? [];
    if (groups.isEmpty) {
      final goToGroups = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Join a group first'),
          content: const Text(
              "You're not in any study groups yet. Join or create one, then you can share notes!"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style:
                  FilledButton.styleFrom(backgroundColor: AppColors.purple),
              child: const Text('Go to Groups'),
            ),
          ],
        ),
      );
      if (goToGroups == true && context.mounted) {
        context.go('/groups');
      }
      return;
    }

    // Pick a group
    StudyGroup? picked;
    if (groups.length == 1) {
      picked = groups.first;
    } else {
      picked = await showModalBottomSheet<StudyGroup>(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (ctx) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
                child: Text('Share to which group?',
                    style: AppTextStyles.title),
              ),
              ...groups.map((g) => ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.purpleL,
                      child: Icon(Icons.groups_rounded,
                          color: AppColors.purple, size: 20),
                    ),
                    title: Text(g.name,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: g.subject != null
                        ? Text(g.subject!,
                            style: AppTextStyles.caption)
                        : null,
                    onTap: () => Navigator.of(ctx).pop(g),
                  )),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      );
    }
    if (picked == null) return;

    setState(() => _isSharing = true);
    final groupName = picked.name;
    String? successMsg;
    String? errorMsg;
    try {
      final result = await ref
          .read(groupListViewModelProvider.notifier)
          .shareToGroup(
            groupId: picked.id,
            wikiPageId: widget.page.id,
            title: widget.page.title,
          );
      successMsg = result.earnedReward
          ? 'Shared to $groupName! ⭐ +${result.starsGranted}'
          : 'Shared to $groupName!';
    } catch (_) {
      errorMsg = "That note doesn't match the group's subject";
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
    if (successMsg != null) {
      scaffold.showSnackBar(SnackBar(
        content: Text(successMsg),
        backgroundColor: AppColors.green,
        behavior: SnackBarBehavior.floating,
      ));
    }
    if (errorMsg != null) {
      scaffold.showSnackBar(SnackBar(
        content: Text(errorMsg),
        backgroundColor: AppColors.coral,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final filename = '$_slug.md';

    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      alignment: Alignment.topCenter,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isEditing ? AppColors.purple : AppColors.outline,
            width: _isEditing ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main row
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          filename,
                          style: AppTextStyles.body
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      _CertaintyBadge(certainty: widget.page.certainty),
                      if (widget.page.hasConflict) ...[
                        const SizedBox(width: AppSpacing.xs),
                        _ConflictBadge(
                          onFix: () {
                            _editController.text = widget.page.content;
                            setState(() => _isEditing = true);
                          },
                        ),
                      ],
                      const SizedBox(width: AppSpacing.xs),
                      // ✏️ Fix button
                      GestureDetector(
                        onTap: () {
                          if (!_isEditing) {
                            _editController.text = widget.page.content;
                          }
                          setState(() => _isEditing = !_isEditing);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _isEditing
                                ? AppColors.purpleL
                                : AppColors.surf2,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _isEditing
                                  ? AppColors.purple
                                  : AppColors.outline,
                            ),
                          ),
                          child: Text(
                            _isEditing ? '✕ Close' : '✏️ Fix',
                            style: AppTextStyles.caption.copyWith(
                              color: _isEditing
                                  ? AppColors.purple
                                  : AppColors.text2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      // Share to group — only shown when groups feature is enabled
                      _ShareToGroupButton(
                        isBusy: _isSharing,
                        onTap: () => _shareToGroup(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    widget.page.updatedAt != null
                        ? 'Updated ${_timeAgo(widget.page.updatedAt!)}'
                        : 'Just added',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),

            // Inline editor — only shown when editing
            if (_isEditing) ...[
              const Divider(height: 1, color: AppColors.outline),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Edit page content',
                      style: AppTextStyles.label.copyWith(
                          color: AppColors.text2, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    TextField(
                      controller: _editController,
                      maxLines: 5,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.text1),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.bg,
                        contentPadding: const EdgeInsets.all(AppSpacing.sm),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppColors.outline),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppColors.outline),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                              color: AppColors.purple, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isSaving
                                ? null
                                : () =>
                                    setState(() => _isEditing = false),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.text2,
                              side: const BorderSide(color: AppColors.outline),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: FilledButton(
                            onPressed: _isSaving ? null : _save,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.purple,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10),
                            ),
                            child: _isSaving
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Save'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _CertaintyBadge extends StatelessWidget {
  const _CertaintyBadge({required this.certainty});
  final String certainty;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = switch (certainty.toLowerCase()) {
      'verified' => (AppColors.greenL, AppColors.green, 'fact'),
      'uncertain' => (AppColors.coralL, AppColors.coral, 'uncertain'),
      _ => (AppColors.purpleL, AppColors.purple, 'inferred'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      constraints: const BoxConstraints(maxWidth: 80),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _ConflictBadge extends StatelessWidget {
  const _ConflictBadge({this.onFix});
  final VoidCallback? onFix;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showConflictDialog(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.amberL,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.amber.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded,
                size: 10, color: AppColors.amber),
            const SizedBox(width: 3),
            Text(
              'Conflict',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.amber,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConflictDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColors.surface,
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: AppColors.amber, size: 22),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                'Conflicting Info',
                style: AppTextStyles.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Text(
          'This page contains information from multiple sources that may disagree with each other.\n\nYou can fix the content manually to resolve the conflict.',
          style: AppTextStyles.body.copyWith(color: AppColors.text2),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Dismiss',
                style: AppTextStyles.body.copyWith(color: AppColors.text2)),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              onFix?.call();
            },
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.purple),
            child: const Text('Fix Now'),
          ),
        ],
      ),
    );
  }
}

class _ShareToGroupButton extends ConsumerWidget {
  const _ShareToGroupButton({required this.isBusy, required this.onTap});
  final bool isBusy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flagsAsync = ref.watch(featureFlagsProvider);
    final groupsEnabled =
        flagsAsync.valueOrNull?[FeatureFlags.groupsEnabled] == true;
    if (!groupsEnabled) return const SizedBox.shrink();
    return GestureDetector(
      onTap: isBusy ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.tealL,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.teal.withValues(alpha: 0.4)),
        ),
        child: isBusy
            ? const SizedBox(
                width: 10,
                height: 10,
                child: CircularProgressIndicator(
                    strokeWidth: 1.5, color: AppColors.teal),
              )
            : Text(
                '↗ Share',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.teal,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.psychology_outlined,
                size: 64, color: AppColors.text3),
            const SizedBox(height: AppSpacing.md),
            Text('Brain is empty', style: AppTextStyles.title),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Upload content from the Library tab to build the knowledge base.',
              style: AppTextStyles.body.copyWith(color: AppColors.text2),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
