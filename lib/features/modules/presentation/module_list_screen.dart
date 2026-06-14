import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/app/router.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/ui/pally_toast.dart';
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
                onGenerate: () async {
                  final result = await ref
                      .read(moduleListViewModelProvider(avatarId).notifier)
                      .generateModules();
                  if (!context.mounted) return;
                  switch (result) {
                    case ModuleGenResult.success:
                      break; // list refreshes via the provider
                    case ModuleGenResult.noNotes:
                      PallyToast.success(context,
                          'Add your notes and I\'ll build your first lesson.');
                      UploadRoute(avatarId: avatarId).push(context);
                    case ModuleGenResult.error:
                      PallyToast.error(context,
                          'Could not build lessons just now — try again.');
                  }
                },
                onUpload: () => UploadRoute(avatarId: avatarId).push(context),
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

class _EmptyBody extends StatelessWidget {
  const _EmptyBody({required this.onGenerate, required this.onUpload});
  final VoidCallback onGenerate;
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
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
            Text(
              'Add your notes and I\'ll build your first lesson from them.',
              style: AppTextStyles.body.copyWith(color: AppColors.text2),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            // Primary path is upload — the value is the notes. Generation only
            // makes sense once notes exist (and is offered as the secondary tap).
            FilledButton.icon(
              onPressed: onUpload,
              icon: const Icon(Icons.upload_file_rounded, size: 18),
              label: const Text('Upload notes'),
              style:
                  FilledButton.styleFrom(backgroundColor: AppColors.purple),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton.icon(
              onPressed: onGenerate,
              icon: const Icon(Icons.auto_awesome_rounded, size: 18),
              label: const Text('Already added notes? Build my lessons'),
              style: TextButton.styleFrom(foregroundColor: AppColors.purple),
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
