import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/app/router.dart';
import 'package:pally/core/error/pally_error.dart';
import 'package:pally/core/services/feature_flags.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_sizing.dart';
import 'package:pally/core/ui/painters/character_painter.dart';
import 'package:pally/core/ui/pally_loading_spinner.dart';
import 'package:pally/core/ui/pally_toast.dart';
import 'package:pally/features/groups/presentation/groups_view_model.dart';
import 'package:pally/features/progress/data/reading_time_reporter.dart';
import 'package:pally/features/wiki_viewer/presentation/get_it_checked_sheet.dart';
import 'package:pally/features/wiki_viewer/presentation/review_status_widgets.dart';
import 'package:pally/features/wiki_viewer/presentation/wiki_viewer_view_model.dart';
import 'package:pally/shared/models/avatar.dart';
import 'package:pally/shared/models/wiki_page.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/shared/widgets/app_error_view.dart';

class WikiViewerScreen extends ConsumerStatefulWidget {
  const WikiViewerScreen({super.key, required this.avatarId});

  final String avatarId;

  @override
  ConsumerState<WikiViewerScreen> createState() => _WikiViewerScreenState();
}

class _WikiViewerScreenState extends ConsumerState<WikiViewerScreen>
    with WidgetsBindingObserver {
  final _searchController = TextEditingController();

  // ── Active reading-time measurement ────────────────────────────────────────
  // Accumulates only foreground time: backgrounding the app stops the clock
  // (the main source of inflated minutes), and a 60s idle cutoff trims a screen
  // left open and walked away from. Reported once on dispose.
  static const Duration _idleCutoff = Duration(seconds: 60);
  DateTime? _segmentStart; // start of the current foreground segment
  DateTime _lastInteraction = DateTime.now();
  int _accumulatedSeconds = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _segmentStart = DateTime.now();
    _lastInteraction = DateTime.now();
  }

  /// Folds the time since [_segmentStart] into [_accumulatedSeconds], applying
  /// the idle cutoff (a segment with no interaction for >60s only counts up to
  /// the cutoff). Resets the segment clock.
  void _flushSegment() {
    final start = _segmentStart;
    if (start == null) return;
    final now = DateTime.now();
    var seconds = now.difference(start).inSeconds;
    // Idle trim: if the user hasn't touched the screen for a while, cap this
    // segment at the time up to the last interaction + the cutoff grace.
    final sinceInteraction = now.difference(_lastInteraction);
    if (sinceInteraction > _idleCutoff) {
      final activeUntil = _lastInteraction.add(_idleCutoff);
      seconds = activeUntil.difference(start).inSeconds;
    }
    if (seconds > 0) _accumulatedSeconds += seconds;
    _segmentStart = null;
  }

  void _registerInteraction() => _lastInteraction = DateTime.now();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _segmentStart = DateTime.now();
      _lastInteraction = DateTime.now();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      _flushSegment();
    }
  }

  @override
  void dispose() {
    _flushSegment();
    final seconds = _accumulatedSeconds;
    final avatarId = widget.avatarId;
    // Fire-and-forget; reporter clamps + drops trivially short sessions.
    ref
        .read(readingTimeReporterProvider)
        .report(avatarId: avatarId, durationSeconds: seconds);
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vmState = ref.watch(wikiViewerViewModelProvider(widget.avatarId));

    ref.listen<WikiViewerState>(wikiViewerViewModelProvider(widget.avatarId),
        (_, next) {
      if (next.error != null) {
        PallyToast.error(
            context, next.error?.userMessage ?? 'Something went wrong.');
      }
      // One-time celebratory snackbar when a page becomes VERIFIED. The VM
      // tracks shown-once locally (prefs), so acknowledging clears it for good.
      final verified = next.newlyVerified;
      if (verified.isNotEmpty) {
        final p = verified.first;
        final by = p.verifiedBy ?? 'a reviewer';
        final more =
            verified.length > 1 ? ' (+${verified.length - 1} more)' : '';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Checked by $by ✓$more'),
            backgroundColor: AppColors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        ref
            .read(wikiViewerViewModelProvider(widget.avatarId).notifier)
            .acknowledgeVerified(verified.map((e) => e.id).toList());
      }
    });

    return Listener(
      // Any pointer activity counts as active reading — feeds the idle cutoff
      // that trims time when the screen is left open and untouched.
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _registerInteraction(),
      onPointerMove: (_) => _registerInteraction(),
      child: Scaffold(
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
                  // Source documents section sits ABOVE the scrollable pages list
                  // in a Column so it has proper bounded constraints. Putting it
                  // inside SliverToBoxAdapter alongside a ListView child gave
                  // unbounded height to the ListView → "RenderBox was not laid out".
                  : Column(
                      children: [
                        if (vmState.files.isNotEmpty)
                          _SourceDocumentsSection(
                            files: vmState.files,
                            isDeletingFile: vmState.isDeletingFile,
                            onDelete: (fileId) => ref
                                .read(
                                    wikiViewerViewModelProvider(widget.avatarId)
                                        .notifier)
                                .deleteFile(fileId),
                          ),
                        // U4 — show a persistent error card when pages failed to
                        // load and the error is not a transient poller hit.
                        if (vmState.error != null && vmState.pages.isEmpty)
                          Expanded(
                            child: AppErrorView(
                              message: vmState.error!.userMessage,
                              onRetry: vmState.error!.kind ==
                                      PallyErrorKind.slotLocked
                                  ? null
                                  : () => ref
                                      .read(wikiViewerViewModelProvider(
                                              widget.avatarId)
                                          .notifier)
                                      .refresh(),
                              action: vmState.error!.kind ==
                                      PallyErrorKind.slotLocked
                                  ? TextButton(
                                      onPressed: () => context.go('/'),
                                      child: const Text('Manage Mochis'),
                                    )
                                  : null,
                            ),
                          )
                        else
                          Expanded(
                            child: RefreshIndicator(
                              color: AppColors.purple,
                              onRefresh: () => ref
                                  .read(wikiViewerViewModelProvider(
                                          widget.avatarId)
                                      .notifier)
                                  .refresh(),
                              // U5 — context-aware empty state copy
                              child: vmState.filteredPages.isEmpty
                                  ? ListView(
                                      children: [
                                        const SizedBox(height: 80),
                                        _EmptyBrainView(
                                          hasFiles: vmState.files.isNotEmpty,
                                          isCompiling: vmState.isCompiling,
                                          avatarName: vmState.avatar?.name,
                                        ),
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
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header with stats ──────────────────────────────────────────────────────

class _BrainHeader extends ConsumerWidget {
  const _BrainHeader({
    required this.avatarId,
    required this.avatar,
    required this.pageCount,
  });

  final String avatarId;
  final Avatar? avatar;
  final int pageCount;

  void _showTeacherPreferencesSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TeacherPreferencesSheet(
        avatarId: avatarId,
        currentPreferences: avatar?.teacherPreferences,
        // A class Mochi's teaching style is set by the centre (on the web);
        // students see it read-only rather than hitting a 403 on save.
        readOnly: avatar?.kind == AvatarKind.centreClass,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                // Teacher method preferences
                IconButton(
                  icon: const Icon(Icons.school_outlined,
                      color: AppColors.purple),
                  tooltip: 'Teacher notes',
                  onPressed: () => _showTeacherPreferencesSheet(context),
                ),
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
                      child: CharacterWidget.forAvatar(avatar!, 38),
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
          // Always-visible "Add notes" — the knowledge base is a living, growable
          // list (Claude Projects pattern). Teaching the Mochi is the primary
          // action, present whether the brain is empty or full.
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => UploadRoute(avatarId: avatarId).push(context),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(
                  pageCount == 0
                      ? 'Add notes to teach ${avatar?.name ?? 'your Mochi'}'
                      : 'Add more notes',
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.purple,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
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
      widget.page.slug ?? widget.page.title.toLowerCase().replaceAll(' ', '-');

  Future<void> _save() async {
    final newContent = _editController.text.trim();
    if (newContent.isEmpty) return;
    setState(() => _isSaving = true);
    await ref
        .read(wikiViewerViewModelProvider(widget.avatarId).notifier)
        .patchCorrection(_slug, newContent);
    if (mounted) {
      setState(() {
        _isSaving = false;
        _isEditing = false;
      });
    }
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
              style: FilledButton.styleFrom(backgroundColor: AppColors.purple),
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
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (ctx) => SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(ctx).height * 0.85,
            ),
            child: SingleChildScrollView(
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
                            ? Text(g.subject!, style: AppTextStyles.caption)
                            : null,
                        onTap: () => Navigator.of(ctx).pop(g),
                      )),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ),
            ),
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
      final result =
          await ref.read(groupListViewModelProvider.notifier).shareToGroup(
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

  void _openReviewSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => GetItCheckedSheet(
        avatarId: widget.avatarId,
        page: widget.page,
      ),
    );
  }

  void _startEditing() {
    _editController.text = widget.page.content;
    setState(() => _isEditing = true);
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
                      // Tiny status dot — colour-only at card density, no text.
                      ReviewStatusDot(state: widget.page.reviewState),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          filename,
                          style: AppTextStyles.body
                              .copyWith(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                  // U2 — provenance badge: shows which source files this page
                  // was compiled from. Hidden when backend doesn't populate it.
                  if (widget.page.sourceFileNames.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        'from: ${widget.page.sourceFileNames.join(', ')}',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.teal),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    widget.page.updatedAt != null
                        ? 'Updated ${_timeAgo(widget.page.updatedAt!)}'
                        : 'Just added',
                    style: AppTextStyles.caption,
                  ),
                  // Review-state surface: small chip for VERIFIED/UNVERIFIED,
                  // full banner for LOW_CONFIDENCE/FLAGGED. Tapping any of
                  // these opens the "get it checked" sheet.
                  ReviewStateSurface(
                    page: widget.page,
                    onGetChecked: _openReviewSheet,
                    onFixNotes: _startEditing,
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
                          borderSide:
                              const BorderSide(color: AppColors.outline),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: AppColors.outline),
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
                                : () => setState(() => _isEditing = false),
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
                              padding: const EdgeInsets.symmetric(vertical: 10),
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
            style: FilledButton.styleFrom(backgroundColor: AppColors.purple),
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
  const _EmptyView({this.message});

  final String? message;

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
              message ??
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

/// U5 — Context-aware empty state. Gives a different prompt depending on
/// whether there are files uploaded (pending compile) vs. nothing uploaded yet.
class _EmptyBrainView extends StatelessWidget {
  const _EmptyBrainView({
    this.hasFiles = false,
    this.isCompiling = false,
    this.avatarName,
  });

  final bool hasFiles;
  final bool isCompiling;
  final String? avatarName;

  @override
  Widget build(BuildContext context) {
    // The amber banner above already covers the compiling case — stay silent.
    if (isCompiling) return const SizedBox.shrink();
    final name = avatarName ?? 'Mochi';
    final msg = hasFiles
        ? "No pages yet — add more notes to rebuild $name's brain."
        : "Upload notes to start building $name's brain.";
    return _EmptyView(message: msg);
  }
}

// ── Source documents section ──────────────────────────────────────────────────

class _SourceDocumentsSection extends StatefulWidget {
  const _SourceDocumentsSection({
    required this.files,
    required this.isDeletingFile,
    required this.onDelete,
  });

  final List<SourceFile> files;
  final bool isDeletingFile;
  final ValueChanged<String> onDelete;

  @override
  State<_SourceDocumentsSection> createState() =>
      _SourceDocumentsSectionState();
}

class _SourceDocumentsSectionState extends State<_SourceDocumentsSection> {
  // U1 — default to collapsed when there are many files so the pages list
  // always has room. Users with ≤4 files see them expanded by default.
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.files.length <= 4;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header — tap to collapse/expand
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
              child: Row(
                children: [
                  const Icon(Icons.folder_open_rounded,
                      size: 18, color: AppColors.purple),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Source documents (${widget.files.length})',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.text1,
                    ),
                  ),
                  const Spacer(),
                  if (widget.isDeletingFile)
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.purple),
                    )
                  else
                    Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 20,
                      color: AppColors.text3,
                    ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            const Divider(height: 1, color: AppColors.outline),
            // U1 — bounded scroll region so the section never pushes the
            // pages list off-screen. 240 px fits ~4 rows comfortably.
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                itemCount: widget.files.length,
                separatorBuilder: (_, __) => const Divider(
                  height: 1,
                  indent: AppSpacing.md,
                  color: AppColors.outline,
                ),
                itemBuilder: (_, i) {
                  final file = widget.files[i];
                  return _SourceFileRow(
                    file: file,
                    onDelete: widget.isDeletingFile
                        ? null
                        : () => _confirmDelete(context, file),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, SourceFile file) {
    showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColors.surface,
        title: const Text('Remove document?'),
        content: Text(
          '"${file.fileName}" will be removed and Mochi\'s brain will update automatically.',
          style: AppTextStyles.body.copyWith(color: AppColors.text2),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel',
                style: AppTextStyles.body.copyWith(color: AppColors.text2)),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.coral),
            child: const Text('Remove'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) widget.onDelete(file.id);
    });
  }
}

class _SourceFileRow extends StatelessWidget {
  const _SourceFileRow({required this.file, required this.onDelete});

  final SourceFile file;
  final VoidCallback? onDelete;

  IconData get _typeIcon {
    final name = file.fileName.toLowerCase();
    if (name.endsWith('.pdf')) {
      return Icons.picture_as_pdf_rounded;
    }
    if (name.endsWith('.jpg') ||
        name.endsWith('.jpeg') ||
        name.endsWith('.png')) {
      return Icons.image_rounded;
    }
    return Icons.description_rounded;
  }

  Color get _statusColor {
    switch (file.status.toUpperCase()) {
      case 'READY':
        return AppColors.green;
      case 'FAILED':
        return AppColors.coral;
      case 'PROCESSING':
        return AppColors.amber;
      default:
        return AppColors.text3;
    }
  }

  String get _statusLabel {
    switch (file.status.toUpperCase()) {
      case 'READY':
        return file.pageCount > 0 ? '${file.pageCount}p' : 'Ready';
      case 'FAILED':
        return 'Failed';
      case 'PROCESSING':
        return 'Reading…';
      case 'IRRELEVANT':
        return 'Off-topic';
      default:
        return file.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xs + 2),
      child: Row(
        children: [
          Icon(_typeIcon, size: 20, color: AppColors.purpleC),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.fileName,
                  style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.text1, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  constraints: const BoxConstraints(maxWidth: 80),
                  decoration: BoxDecoration(
                    color: _statusColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _statusLabel,
                    style: AppTextStyles.caption.copyWith(color: _statusColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                color: AppColors.coral, size: 20),
            visualDensity: VisualDensity.compact,
            onPressed: onDelete,
            tooltip: 'Remove document',
          ),
        ],
      ),
    );
  }
}

// ── Teacher preferences bottom sheet ─────────────────────────────────────────

class _TeacherPreferencesSheet extends ConsumerStatefulWidget {
  const _TeacherPreferencesSheet({
    required this.avatarId,
    this.currentPreferences,
    this.readOnly = false,
  });

  final String avatarId;
  final String? currentPreferences;
  final bool readOnly;

  @override
  ConsumerState<_TeacherPreferencesSheet> createState() =>
      _TeacherPreferencesSheetState();
}

class _TeacherPreferencesSheetState
    extends ConsumerState<_TeacherPreferencesSheet> {
  late final TextEditingController _ctrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.currentPreferences ?? '');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  /// Quick teaching-style presets that compose into the free-text instruction.
  /// They write into the same field, which is already wired into the tutor's
  /// system prompt (## TEACHER INSTRUCTIONS) — so both chips and free text take
  /// effect identically.
  static const _stylePresets = <String, String>{
    'More examples': 'Use more worked examples.',
    'Harder questions': 'Challenge me with harder questions.',
    'Explain simply': 'Explain things as simply as possible.',
    'Exam-focused': 'Focus on exam-style questions and techniques.',
  };

  void _toggleStyle(String phrase) {
    final current = _ctrl.text.trim();
    if (current.contains(phrase)) {
      // Remove it (toggle off).
      var next = current.replaceAll(phrase, '').replaceAll('  ', ' ').trim();
      _ctrl.text = next;
    } else {
      final sep = current.isEmpty ? '' : (current.endsWith('.') ? ' ' : '. ');
      final next = '$current$sep$phrase';
      if (next.length <= 500) _ctrl.text = next;
    }
    _ctrl.selection =
        TextSelection.collapsed(offset: _ctrl.text.length);
    setState(() {});
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final dio = ref.read(dioProvider);
      await dio.patch<dynamic>(
        '/api/v1/avatars/${widget.avatarId}/teacher-preferences',
        data: {'teacherPreferences': _ctrl.text.trim()},
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save — try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.outline,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('How should Mochi teach you?', style: AppTextStyles.title),
            const SizedBox(height: AppSpacing.xs),
            if (widget.readOnly) ...[
              Text(
                'Your centre sets how this class Mochi teaches.',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.text2),
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surf2,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  (widget.currentPreferences != null &&
                          widget.currentPreferences!.trim().isNotEmpty)
                      ? widget.currentPreferences!.trim()
                      : 'No teaching style set by your centre yet.',
                  style: AppTextStyles.body.copyWith(color: AppColors.text1),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ] else ...[
            Text(
              'Tap a style or write your own — e.g. "Use the bar model for fractions" or "Always show full working." Mochi follows this in every lesson and chat.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.text2),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _stylePresets.entries.map((e) {
                final on = _ctrl.text.contains(e.value);
                return FilterChip(
                  label: Text(e.key),
                  selected: on,
                  onSelected: (_) => _toggleStyle(e.value),
                  showCheckmark: true,
                  selectedColor: AppColors.purpleL,
                  checkmarkColor: AppColors.purple,
                  labelStyle: AppTextStyles.label.copyWith(
                    color: on ? AppColors.purple : AppColors.text2,
                    fontWeight: on ? FontWeight.w700 : FontWeight.w600,
                  ),
                  backgroundColor: AppColors.surf2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                        color: on ? AppColors.purple : AppColors.outline),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _ctrl,
              maxLines: 4,
              maxLength: 500,
              onChanged: (_) => setState(() {}), // keep chip highlights in sync
              decoration: InputDecoration(
                hintText:
                    'e.g. Use model method for fractions. Show all steps.',
                hintStyle:
                    AppTextStyles.bodySmall.copyWith(color: AppColors.text3),
                filled: true,
                fillColor: AppColors.surf2,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.purple,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Save'),
              ),
            ),
            ],
          ],
        ),
      ),
    );
  }
}
