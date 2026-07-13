import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pally/app/router.dart';
import 'package:pally/core/error/pally_error.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/ui/adaptive_content_width.dart';
import 'package:pally/core/ui/no_notes_cta.dart';
import 'package:pally/core/ui/painters/character_painter.dart';
import 'package:pally/core/ui/pally_error_card.dart';
import 'package:pally/core/widgets/loading/pally_skeleton.dart';
import 'package:pally/features/avatar_hub/presentation/avatar_hub_view_model.dart';
import 'package:pally/features/quiz/providers/quiz_status_provider.dart';
import 'package:pally/shared/models/avatar.dart';

/// The per-avatar FRONT DOOR: a guided journey (Learn hero → Practice → Prove →
/// Tools). No gating — hierarchy guides, never blocks. Opened from the Library
/// row tap; deep-link safe (takes only [avatarId]).
class AvatarHubScreen extends ConsumerWidget {
  const AvatarHubScreen({required this.avatarId, super.key});

  final String avatarId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hubAsync = ref.watch(avatarHubViewModelProvider(avatarId));
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: Text(
          hubAsync.valueOrNull?.avatar.name ?? 'Mochi',
          style: AppTextStyles.title,
        ),
      ),
      body: AdaptiveContentWidth(
        child: hubAsync.when(
          loading: () => const _HubSkeleton(),
          error: (e, _) => PallyErrorCard(
            message: PallyError.from(e).userMessage,
            onRetry: () =>
                ref.invalidate(avatarHubViewModelProvider(avatarId)),
          ),
          data: (hub) => RefreshIndicator(
            color: AppColors.purple,
            onRefresh: () async =>
                ref.invalidate(avatarHubViewModelProvider(avatarId)),
            child: _HubBody(hub: hub),
          ),
        ),
      ),
    );
  }
}

class _HubBody extends StatelessWidget {
  const _HubBody({required this.hub});

  final AvatarHubData hub;

  @override
  Widget build(BuildContext context) {
    final avatar = hub.avatar;
    final hasKnowledge = avatar.hasKnowledge;
    // Upload + Teach are hidden for a centre-managed avatar (matches Library's
    // `centreManaged` exclusion). The centre BADGE keys on `isCentreClass` —
    // deliberately a DIFFERENT flag; see _HubHeader.
    final centreManaged = avatar.centreManaged;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        _HubHeader(avatar: avatar),
        const SizedBox(height: AppSpacing.lg),
        // Hero is ALWAYS tappable — invitational when there are no modules yet;
        // the module-list screen owns the compile/upload empty state.
        _HeroModulesCard(hub: hub),
        if (!hasKnowledge) ...[
          const SizedBox(height: AppSpacing.lg),
          // One shared unlock affordance for the Practice/Prove group. NoNotesCta
          // is centre-aware: personal → "Upload notes" button; centre class →
          // static "ask your teacher", no upload (the canonical centre rule).
          NoNotesCta(
            avatarId: avatar.id,
            personalDescription:
                'Upload your notes to unlock quizzes, cards and teaching.',
          ),
        ],
        _HubSection(
          title: 'Practice',
          children: [
            _QuizHubRow(avatarId: avatar.id, enabled: hasKnowledge),
            _HubRow(
              icon: Icons.style_rounded,
              color: AppColors.amber,
              title: 'Cards',
              subtitle: 'Quick recall practice',
              enabled: hasKnowledge,
              onTap: () => FlashcardRoute(avatarId: avatar.id).push(context),
            ),
          ],
        ),
        if (!centreManaged)
          _HubSection(
            title: 'Prove it',
            children: [
              _HubRow(
                icon: Icons.school_rounded,
                color: AppColors.pink,
                title: 'Teach',
                subtitle: 'Explain it back to Mochi',
                enabled: hasKnowledge,
                onTap: () => TeachMochiRoute(avatarId: avatar.id).push(context),
              ),
            ],
          ),
        _HubSection(
          title: 'Tools',
          children: [
            _HubRow(
              icon: Icons.chat_bubble_rounded,
              color: AppColors.purple,
              title: 'Chat',
              subtitle: 'Ask Mochi anything',
              enabled: true,
              onTap: () => ChatRoute(avatarId: avatar.id).push(context),
            ),
            _HubRow(
              icon: Icons.menu_book_rounded,
              color: AppColors.teal,
              title: 'Notes',
              subtitle: 'Review your material',
              enabled: true,
              onTap: () => WikiViewerRoute(avatarId: avatar.id).push(context),
            ),
            if (!centreManaged)
              _HubRow(
                icon: Icons.upload_file_rounded,
                color: AppColors.green,
                title: 'Upload',
                subtitle: 'Add more material',
                enabled: true,
                onTap: () => UploadRoute(avatarId: avatar.id).push(context),
              ),
          ],
        ),
      ],
    );
  }
}

class _HubHeader extends StatelessWidget {
  const _HubHeader({required this.avatar});

  final Avatar avatar;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: avatar.character.bgColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(child: CharacterWidget.forAvatar(avatar, 48)),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                avatar.name,
                style: AppTextStyles.heading1,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _HeaderBadge(
                    label: avatar.subject,
                    color: avatar.character.primaryColor,
                    bgColor: avatar.character.bgColor,
                  ),
                  // Badge keys on isCentreClass — NOT centreManaged (the two can
                  // diverge; Upload/Teach visibility uses centreManaged).
                  if (avatar.isCentreClass)
                    const _HeaderBadge(
                      label: 'Class',
                      color: AppColors.purple,
                      bgColor: AppColors.purpleL,
                      icon: Icons.school_rounded,
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeaderBadge extends StatelessWidget {
  const _HeaderBadge({
    required this.label,
    required this.color,
    required this.bgColor,
    this.icon,
  });

  final String label;
  final Color color;
  final Color bgColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      constraints: const BoxConstraints(maxWidth: 180),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 3),
          ],
          Flexible(
            child: Text(
              label,
              style: AppTextStyles.caption
                  .copyWith(color: color, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroModulesCard extends StatelessWidget {
  const _HeroModulesCard({required this.hub});

  final AvatarHubData hub;

  @override
  Widget build(BuildContext context) {
    final subtitle = hub.hasModules
        ? '${hub.moduleCount} module${hub.moduleCount == 1 ? '' : 's'} · ${hub.avgMasteryPct}% mastery'
        : 'Start your first module';
    return Semantics(
      button: true,
      label: 'Learn. $subtitle',
      child: Material(
        color: AppColors.purple,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => ModuleListRoute(avatarId: hub.avatar.id).push(context),
          child: Container(
            constraints: const BoxConstraints(minHeight: 96),
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                const Icon(Icons.auto_stories_rounded,
                    color: AppColors.surface, size: 34),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Learn',
                        style: AppTextStyles.title
                            .copyWith(color: AppColors.surface),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.surface),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (hub.hasModules) ...[
                        const SizedBox(height: AppSpacing.sm),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: (hub.avgMasteryPct / 100).clamp(0.0, 1.0),
                            minHeight: 6,
                            backgroundColor:
                                AppColors.surface.withValues(alpha: 0.3),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.surface),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.surface),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HubSection extends StatelessWidget {
  const _HubSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.xs, AppSpacing.lg, AppSpacing.xs, AppSpacing.sm),
          child: Text(
            title,
            style: AppTextStyles.label
                .copyWith(letterSpacing: 1.2, color: AppColors.text2),
          ),
        ),
        ...children,
      ],
    );
  }
}

/// One journey row: icon + title + one-line purpose subtitle + chevron. Disabled
/// (greyed, no tap) when its feature needs knowledge the avatar doesn't have yet.
class _HubRow extends StatelessWidget {
  const _HubRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final titleColor = enabled ? AppColors.text1 : AppColors.text3;
    final iconColor = enabled ? color : AppColors.text3;
    final iconBg =
        enabled ? color.withValues(alpha: 0.12) : AppColors.surf2;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Semantics(
        button: true,
        enabled: enabled,
        label: '$title. $subtitle',
        child: Material(
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.outline),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: enabled ? onTap : null,
            child: Container(
              constraints: const BoxConstraints(minHeight: 56), // ≥48dp target
              padding: AppSpacing.card,
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 20, color: iconColor),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.w700, color: titleColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          subtitle,
                          // wrap, don't clip — survives large text scale
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.text3),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: enabled ? AppColors.text3 : AppColors.outline,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Quiz row — composes the EXISTING per-avatar quiz-status provider (lazily, and
/// only when enabled) so a slow status never blocks the hero, and a disabled row
/// fires no fetch at all.
class _QuizHubRow extends ConsumerWidget {
  const _QuizHubRow({required this.avatarId, required this.enabled});

  final String avatarId;
  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var subtitle = 'Test yourself with MCQs';
    var icon = Icons.bolt_rounded;
    if (enabled) {
      final status = ref.watch(quizStatusProvider(avatarId)).valueOrNull;
      if (status != null) {
        if (status.takenToday) {
          subtitle = 'Done today · free play anytime';
          icon = Icons.check_circle_rounded;
        } else if (status.totalTopics > 0) {
          subtitle =
              'Test yourself · ${status.masteredTopics}/${status.totalTopics} mastered';
        }
      }
    }
    return _HubRow(
      icon: icon,
      color: AppColors.amber,
      title: 'Quiz',
      subtitle: subtitle,
      enabled: enabled,
      onTap: () => QuizRoute(avatarId: avatarId).push(context),
    );
  }
}

class _HubSkeleton extends StatelessWidget {
  const _HubSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      physics: const NeverScrollableScrollPhysics(),
      children: const [
        PallyBlockSkeleton(height: 64),
        SizedBox(height: AppSpacing.lg),
        PallyBlockSkeleton(height: 96, borderRadius: 20),
        SizedBox(height: AppSpacing.lg),
        PallyBlockSkeleton(height: 72),
        SizedBox(height: AppSpacing.sm),
        PallyBlockSkeleton(height: 72),
        SizedBox(height: AppSpacing.sm),
        PallyBlockSkeleton(height: 72),
      ],
    );
  }
}
