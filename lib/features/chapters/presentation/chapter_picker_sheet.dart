import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pally/core/error/pally_error.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/features/chapters/domain/chapter.dart';
import 'package:pally/features/chapters/presentation/chapter_picker_view_model.dart';
import 'package:pally/features/library/presentation/library_view_model.dart';

/// Opens the chapter picker — the ONE place chunk-picking lives (shown after a large
/// upload AND from the locked-chapter surface). Interaction design mirrors the memoly
/// web picker screenshot-for-screenshot: chapter list, page counts, none pre-selected,
/// a live "N of M compiles left this month" counter, compile-selected + compile-all.
/// [pointToLibraryOnSuccess] — main-app callers (library lock banner, upload
/// screen) set this so a successful compile confirms with a dialog pointing at
/// the Library "Mochi is reading" indicator. Onboarding leaves it false: it has
/// its own forward flow (`onCompiled` → `proceedAfterChapters`) and no Library
/// tab yet, so a "Go to Library" dialog there would be a check it can't cash.
Future<void> showChapterPicker(
  BuildContext context, {
  required String avatarId,
  VoidCallback? onCompiled,
  bool pointToLibraryOnSuccess = false,
  WidgetRef? ref,
}) async {
  // The sheet pops `true` ONLY on a confirmed compile; drag/barrier dismiss
  // returns null, so onCompiled + the dialog fire only on real success.
  final compiled = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => ChapterPickerSheet(avatarId: avatarId),
  );
  if (compiled != true) return;
  onCompiled?.call();
  // Library lives in a keep-alive shell branch, so its list is cached; invalidate
  // it so the "Mochi is reading" indicator can actually appear when the dialog
  // sends the user there (best-effort — the brain flips to COMPILING async, so a
  // pull-to-refresh remains the belt-and-braces path).
  ref?.invalidate(libraryViewModelProvider);
  if (pointToLibraryOnSuccess && context.mounted) {
    await _showCompilingDialog(context);
  }
}

/// Success confirmation: the compile is an async server job, so this points the
/// user to the honest progress surface (the Library "Mochi is reading" row)
/// rather than pretending the work is already done.
Future<void> _showCompilingDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (dctx) => AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text('Mochi is reading your chapters!', style: AppTextStyles.title),
      content: Text(
        'This takes a few minutes. You can follow along in Library — Mochi will '
        'show which chapter it is reading, and your lessons unlock when it is done.',
        style: AppTextStyles.body.copyWith(color: AppColors.text2),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dctx).pop(),
          child: Text('OK',
              style: AppTextStyles.body.copyWith(color: AppColors.text2)),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(dctx).pop();
            if (context.mounted) context.go('/library');
          },
          style: FilledButton.styleFrom(backgroundColor: AppColors.purple),
          child: const Text('Go to Library'),
        ),
      ],
    ),
  );
}

class ChapterPickerSheet extends ConsumerStatefulWidget {
  const ChapterPickerSheet({super.key, required this.avatarId});

  final String avatarId;

  @override
  ConsumerState<ChapterPickerSheet> createState() => _ChapterPickerSheetState();
}

class _ChapterPickerSheetState extends ConsumerState<ChapterPickerSheet> {
  final Set<String> _selected = {};
  String? _error;

  /// Drives the button's disabled+spinner state REACTIVELY. The view model's own
  /// `isCompiling` guard flips a plain field mid-`await` with no rebuild between
  /// true→false, so the spinner never rendered; this sheet-local flag (mutated
  /// via setState) is what the button actually watches. The VM guard stays as a
  /// re-entry backstop.
  bool _compiling = false;

  void _toggle(String id) {
    setState(() {
      if (!_selected.remove(id)) _selected.add(id);
    });
  }

  Future<void> _compile(List<String> ids) async {
    if (_compiling) return; // single-flight: ignore a second tap while in flight
    setState(() {
      _error = null;
      _compiling = true;
    });
    try {
      await ref
          .read(chapterPickerViewModelProvider(widget.avatarId).notifier)
          .compileSelected(ids);
      if (!mounted) return;
      // Compile ACK'd (the request is fast — the LLM work is async server-side).
      // Pop `true` so showChapterPicker fires onCompiled + the "Mochi is reading"
      // dialog. A client timeout here does NOT mean the server failed — the
      // per-cause copy below points to Library, and a retry is safe because the
      // compile quota is success-based (a still-running/failed pick never burns
      // an allowance), so no duplicate job or double-spend.
      Navigator.of(context).pop(true);
    } catch (e) {
      // Per-cause copy so a dead spinner is impossible: every failure clears the
      // spinner, re-enables the button, and shows an honest, retryable message.
      // Mapping lives in the central PallyError.forCompile — the widget never
      // inspects DioException itself (layering guard).
      if (mounted) {
        setState(() {
          _compiling = false;
          _error = PallyError.forCompile(e).userMessage;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(chapterPickerViewModelProvider(widget.avatarId));

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        // ONE scroll view wraps every state (loading / error / data) so a large
        // text scale, a narrow device, or the keyboard can never overflow the sheet.
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: async.when(
            loading: () => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(context),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
            ),
            error: (_, __) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(context),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                  child: Center(
                    child: Text("Couldn't load chapters. Please close and try again.",
                        style: AppTextStyles.body.copyWith(color: AppColors.coral)),
                  ),
                ),
              ],
            ),
            data: (result) => _loaded(context, result),
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Choose chapters to compile', style: AppTextStyles.title),
                const SizedBox(height: 2),
                Text(
                  'Mochi only reads the chapters you pick — start with what you’re studying now.',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.text3),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.close, color: AppColors.text3),
            splashRadius: 20,
          ),
        ],
      );

  Widget _loaded(BuildContext context, ChaptersResult result) {
    final chapters = result.chapters;
    final locked = result.locked;
    final remaining = result.remaining;
    final selectedCount = _selected.length;
    final overLimit = !result.unlimited && selectedCount > remaining;
    final canCompile = selectedCount > 0 && !overLimit && !_compiling;
    final showCompileAll = locked.length >= 2 &&
        (result.unlimited || remaining >= locked.length) &&
        !_compiling;

    // Plain Column — the parent SingleChildScrollView provides the scroll, so a tall
    // list / large text scale scrolls instead of overflowing.
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(context),
        const SizedBox(height: AppSpacing.sm),
        _counter(result),
        const SizedBox(height: AppSpacing.sm),
        if (chapters.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: Center(
              child: Text('No chapters to compile.',
                  style: AppTextStyles.body.copyWith(color: AppColors.text3)),
            ),
          )
        else
          for (final c in chapters)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: _row(c),
            ),
        if (_error != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(_error!, style: AppTextStyles.bodySmall.copyWith(color: AppColors.coral)),
        ],
        const SizedBox(height: AppSpacing.md),
        _footer(context, result, locked, showCompileAll, canCompile, overLimit, remaining),
      ],
    );
  }

  Widget _counter(ChaptersResult result) {
    final unlimited = result.unlimited;
    final remaining = result.remaining;
    final none = !unlimited && remaining == 0;
    final bg = none ? AppColors.coralL : (unlimited ? AppColors.purpleL : AppColors.surf2);
    final fg = none ? AppColors.coral : (unlimited ? AppColors.purple : AppColors.text2);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(
        unlimited
            ? 'Unlimited chapter compiles'
            : '$remaining of ${result.allowanceLimit} compiles left this month',
        style: AppTextStyles.label.copyWith(color: fg),
      ),
    );
  }

  Widget _row(Chapter c) {
    final isLocked = c.isLocked;
    final checked = _selected.contains(c.chunkId);
    return Opacity(
      opacity: isLocked ? 1 : 0.7,
      child: InkWell(
        onTap: isLocked ? () => _toggle(c.chunkId) : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surf2,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.outline),
          ),
          child: Row(
            children: [
              if (isLocked)
                Checkbox(
                  value: checked,
                  onChanged: (_) => _toggle(c.chunkId),
                  activeColor: AppColors.purple,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                )
              else
                const SizedBox(width: 24),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                    Text('Pages ${c.pageFrom}–${c.pageTo} · ${c.pageCount} '
                        '${c.pageCount == 1 ? "page" : "pages"}',
                        style: AppTextStyles.caption.copyWith(color: AppColors.text3)),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              _StateBadge(state: c.state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _footer(
    BuildContext context,
    ChaptersResult result,
    List<Chapter> locked,
    bool showCompileAll,
    bool canCompile,
    bool overLimit,
    int remaining,
  ) {
    final selectedCount = _selected.length;
    // Hint on its own line, buttons in a Wrap — so a narrow screen or a large text
    // scale wraps the CTAs instead of overflowing the Row (the recurring bug class).
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          overLimit
              ? 'Only $remaining left this month — deselect ${selectedCount - remaining}.'
              : selectedCount > 0
                  ? '$selectedCount selected'
                  : 'Select one or more chapters',
          style: AppTextStyles.caption.copyWith(color: AppColors.text3),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          alignment: WrapAlignment.end,
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            if (showCompileAll)
              OutlinedButton(
                onPressed: () => _compile(locked.map((c) => c.chunkId).toList()),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.purple,
                  side: const BorderSide(color: AppColors.purpleC),
                ),
                child: Text('Compile all (${locked.length})'),
              ),
            ElevatedButton(
              onPressed: canCompile ? () => _compile(_selected.toList()) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purple,
                foregroundColor: AppColors.surface,
                disabledBackgroundColor: AppColors.outline,
              ),
              child: _compiling
                  ? const SizedBox(
                      width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(selectedCount > 0 ? 'Compile ($selectedCount)' : 'Compile'),
            ),
          ],
        ),
      ],
    );
  }
}

class _StateBadge extends StatelessWidget {
  const _StateBadge({required this.state});
  final ChapterState state;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (state) {
      ChapterState.compiled => ('✓ Compiled', AppColors.green),
      ChapterState.compiling => ('Compiling…', AppColors.purple),
      ChapterState.locked => ('Not compiled', AppColors.text3),
    };
    return Text(label,
        style: AppTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.w600));
  }
}
