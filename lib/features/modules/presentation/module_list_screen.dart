import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/app/router.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/ui/no_notes_cta.dart';
import 'package:pally/features/modules/presentation/module_list_view_model.dart';
import 'package:pally/shared/models/learning_module.dart';

class ModuleListScreen extends ConsumerWidget {
  const ModuleListScreen({super.key, required this.avatarId});

  final String avatarId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modulesAsync = ref.watch(moduleListViewModelProvider(avatarId));

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: Text('Modules', style: AppTextStyles.title),
        centerTitle: true,
      ),
      body: modulesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.purple),
        ),
        error: (e, _) => _ErrorBody(
          onRetry: () =>
              ref.read(moduleListViewModelProvider(avatarId).notifier).refresh(),
        ),
        data: (modules) => modules.isEmpty
            ? _EmptyBody(
                avatarId: avatarId,
                // Notes + kind pick the CTA. A centre class with NO notes shows
                // a static "ask your teacher" message (via NoNotesCta) with no
                // action; Generate only appears once notes exist; personal with
                // no notes gets Upload (the only place upload is offered here).
                info: ref.watch(moduleAvatarInfoProvider(avatarId)),
                onGenerate: () => ref
                    .read(moduleListViewModelProvider(avatarId).notifier)
                    .generateModules(),
              )
            : _ModuleList(avatarId: avatarId, modules: modules),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded,
                size: 48, color: AppColors.text3),
            const SizedBox(height: AppSpacing.md),
            Text('Could not load modules.',
                style: AppTextStyles.title, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xs),
            Text('Check your connection and try again.',
                style: AppTextStyles.body.copyWith(color: AppColors.text2),
                textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: onRetry,
              style:
                  FilledButton.styleFrom(backgroundColor: AppColors.purple),
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyBody extends StatefulWidget {
  const _EmptyBody({
    required this.avatarId,
    required this.info,
    required this.onGenerate,
  });

  final String avatarId;
  final ModuleAvatarInfo? info;
  final Future<ModuleGenResult> Function() onGenerate;

  @override
  State<_EmptyBody> createState() => _EmptyBodyState();
}

class _EmptyBodyState extends State<_EmptyBody> {
  bool _isGenerating = false;
  String? _errorMessage;

  Future<void> _handleGenerate() async {
    if (_isGenerating) return;
    setState(() {
      _isGenerating = true;
      _errorMessage = null;
    });
    final result = await widget.onGenerate();
    if (!mounted) return;
    setState(() => _isGenerating = false);
    switch (result) {
      case ModuleGenResult.success:
        break;
      case ModuleGenResult.noNotes:
        setState(() => _errorMessage = 'No notes to build lessons from yet.');
      case ModuleGenResult.error:
        setState(
          () => _errorMessage =
              'Could not build lessons. Check your connection and try again.',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loaded = widget.info;
    final notes = loaded?.hasNotes ?? false;
    final isCentre = loaded?.isCentreClass ?? false;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_stories_rounded,
                size: 56, color: AppColors.purpleC),
            const SizedBox(height: AppSpacing.md),
            Text('No lessons yet',
                style: AppTextStyles.title, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            // Three-state rule (mirrors NoNotesCta so the module list never
            // drifts from every other surface):
            //  • loading       → nothing (never flash a button)
            //  • notes present → Generate button (works for either kind)
            //  • no notes      → NoNotesCta: centre = static "ask your teacher"
            //                    (NO action), personal = Upload button.
            if (loaded == null)
              const SizedBox.shrink()
            else if (notes) ...[
              Text(
                isCentre
                    ? 'Generate lessons from your class materials.'
                    : 'Your notes are in — let\'s build your first lesson.',
                style: AppTextStyles.body.copyWith(color: AppColors.text2),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton.icon(
                onPressed: _isGenerating ? null : _handleGenerate,
                icon: _isGenerating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.auto_awesome_rounded, size: 18),
                label: Text(
                    isCentre ? 'Generate lessons' : 'Build my first lesson'),
                style: FilledButton.styleFrom(backgroundColor: AppColors.purple),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  _errorMessage!,
                  style: AppTextStyles.body.copyWith(color: AppColors.coral),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xs),
                TextButton(
                  onPressed: _handleGenerate,
                  child: const Text('Try again'),
                ),
              ],
            ] else
              NoNotesCta(
                avatarId: widget.avatarId,
                personalDescription:
                    'Add your notes and I\'ll build your first lesson from them.',
              ),
          ],
        ),
      ),
    );
  }
}

class _ModuleList extends ConsumerWidget {
  const _ModuleList({required this.avatarId, required this.modules});
  final String avatarId;
  final List<LearningModule> modules;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      color: AppColors.purple,
      onRefresh: () =>
          ref.read(moduleListViewModelProvider(avatarId).notifier).refresh(),
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: modules.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) =>
            _ModuleCard(avatarId: avatarId, module: modules[index]),
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({required this.avatarId, required this.module});
  final String avatarId;
  final LearningModule module;

  Color get _stageColor => switch (module.stage) {
        'LEARN' => AppColors.teal,
        'TEST' => AppColors.amber,
        'PROVE' => AppColors.purple,
        'COMPLETE' => AppColors.green,
        _ => AppColors.text3,
      };

  Color get _stageBgColor => switch (module.stage) {
        'LEARN' => AppColors.tealL,
        'TEST' => AppColors.amberL,
        'PROVE' => AppColors.purpleL,
        'COMPLETE' => AppColors.greenL,
        _ => AppColors.surf2,
      };

  String get _stageLabel => switch (module.stage) {
        'LEARN' => 'LEARN',
        'TEST' => 'TEST',
        'PROVE' => 'PROVE',
        'COMPLETE' => 'COMPLETE',
        _ => module.stage,
      };

  IconData get _stageIcon => switch (module.stage) {
        'LEARN' => Icons.menu_book_rounded,
        'TEST' => Icons.quiz_rounded,
        'PROVE' => Icons.psychology_rounded,
        'COMPLETE' => Icons.check_circle_rounded,
        _ => Icons.circle_outlined,
      };

  String get _ctaLabel => switch (module.stage) {
        'COMPLETE' => 'Review',
        'LEARN' => 'Start learning',
        _ => 'Continue',
      };

  @override
  Widget build(BuildContext context) {
    final isComplete = module.stage == 'COMPLETE';
    final masteryPct = (module.masteryPct * 100).round();

    return GestureDetector(
      onTap: () =>
          ModulePlayerRoute(avatarId: avatarId, moduleId: module.id)
              .push(context),
      child: Container(
        padding: AppSpacing.card,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isComplete
                ? AppColors.green.withValues(alpha: 0.4)
                : AppColors.outline,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row with stage badge
            Row(
              children: [
                Expanded(
                  child: Text(
                    module.title,
                    style: AppTextStyles.title.copyWith(fontSize: 16),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                _StageBadge(
                  label: _stageLabel,
                  color: _stageColor,
                  bgColor: _stageBgColor,
                  icon: _stageIcon,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // Mastery bar
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: module.masteryPct.clamp(0.0, 1.0),
                      minHeight: 6,
                      backgroundColor: AppColors.outline,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(_stageColor),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '$masteryPct%',
                  style: AppTextStyles.label.copyWith(
                    color: _stageColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // Item counts + CTA
            Row(
              children: [
                if (module.itemCounts.isNotEmpty)
                  Expanded(
                    child: Wrap(
                      spacing: AppSpacing.sm,
                      children: module.itemCounts.entries.map((e) {
                        return Text(
                          '${e.value} ${e.key}',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.text2,
                          ),
                        );
                      }).toList(),
                    ),
                  )
                else
                  const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isComplete ? AppColors.greenL : AppColors.purpleL,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _ctaLabel,
                    style: AppTextStyles.label.copyWith(
                      color:
                          isComplete ? AppColors.green : AppColors.purple,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StageBadge extends StatelessWidget {
  const _StageBadge({
    required this.label,
    required this.color,
    required this.bgColor,
    required this.icon,
  });

  final String label;
  final Color color;
  final Color bgColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
