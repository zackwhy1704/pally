import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/ui/pally_loading_spinner.dart';
import 'package:pally/features/progress/presentation/level_up_controller.dart';
import 'package:pally/features/teach_mochi/presentation/teach_mochi_view_model.dart';
import 'package:pally/shared/models/wiki_page.dart';

/// Single-page experience that walks the child through Feynman-technique
/// teaching: pick a topic → write an explanation → see Mochi's per-concept
/// feedback. Stays in one screen so back navigation always lands on the
/// previous step inside this flow.
class TeachMochiScreen extends ConsumerWidget {
  const TeachMochiScreen({super.key, required this.avatarId});

  final String avatarId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(teachMochiViewModelProvider(avatarId));
    final notifier =
        ref.read(teachMochiViewModelProvider(avatarId).notifier);

    // Fire the level-up celebration the first frame a fresh evaluation
    // arrives with levelledUp = true.
    ref.listen<TeachState>(teachMochiViewModelProvider(avatarId),
        (prev, next) {
      final justArrived = next.evaluation != null &&
          (prev?.evaluation == null);
      if (justArrived && next.evaluation!.levelledUp) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          LevelUpController.maybeCelebrate(
            context,
            levelledUp: true,
            newLevel: next.evaluation!.newLevel,
          );
        });
      }
    });

    Widget body;
    if (state.isLoadingTopics) {
      body = const PallyLoadingSpinner();
    } else if (state.evaluation != null) {
      body = _FeedbackView(
        state: state,
        onTryAgain: notifier.clearEvaluation,
        onBackToTopics: notifier.back,
      );
    } else if (state.selectedTopic != null) {
      body = _ExplainView(
        topic: state.selectedTopic!,
        text: state.explanation,
        isSubmitting: state.isSubmitting,
        error: state.error,
        onChanged: notifier.updateExplanation,
        onSubmit: notifier.submit,
      );
    } else if (state.topics.isEmpty) {
      body = const _NoTopicsState();
    } else {
      body = _TopicSelectView(
        topics: state.topics,
        onTap: notifier.selectTopic,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: Text('Teach Mochi', style: AppTextStyles.title),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            // Inside-flow back: explanation → topic select, feedback → topic
            // select. Only leave the screen entirely when we're already at
            // the topic-list stage.
            if (state.evaluation != null || state.selectedTopic != null) {
              notifier.back();
            } else if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: body,
    );
  }
}

class _TopicSelectView extends StatelessWidget {
  const _TopicSelectView({required this.topics, required this.onTap});
  final List<WikiPage> topics;
  final ValueChanged<WikiPage> onTap;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Container(
          padding: AppSpacing.card,
          decoration: BoxDecoration(
            color: AppColors.purpleL,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Text('🎓', style: TextStyle(fontSize: 28)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Pick a topic and TEACH Mochi! '
                  'Explaining is the fastest way to know you really understand.',
                  style: AppTextStyles.body
                      .copyWith(color: AppColors.text1),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        for (final t in topics) ...[
          Material(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => onTap(t),
              child: Container(
                padding: AppSpacing.card,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.outline),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.menu_book_rounded,
                        color: AppColors.purple, size: 22),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        t.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded,
                        color: AppColors.text2),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _ExplainView extends StatefulWidget {
  const _ExplainView({
    required this.topic,
    required this.text,
    required this.isSubmitting,
    required this.error,
    required this.onChanged,
    required this.onSubmit,
  });
  final WikiPage topic;
  final String text;
  final bool isSubmitting;
  final String? error;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmit;

  @override
  State<_ExplainView> createState() => _ExplainViewState();
}

class _ExplainViewState extends State<_ExplainView> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController.fromValue(
      TextEditingValue(
        text: widget.text,
        selection: TextSelection.collapsed(offset: widget.text.length),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = widget.text.trim().length >= 10 && !widget.isSubmitting;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: AppSpacing.card,
            decoration: BoxDecoration(
              color: AppColors.surf2,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Teach Mochi about',
                    style: AppTextStyles.label
                        .copyWith(color: AppColors.text2)),
                const SizedBox(height: 2),
                Text(widget.topic.title, style: AppTextStyles.title),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: TextField(
              controller: _ctrl,
              onChanged: widget.onChanged,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                hintText:
                    'Pretend Mochi has never heard of this. Use your own words…',
                hintStyle: AppTextStyles.body
                    .copyWith(color: AppColors.text3),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: AppSpacing.card,
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
                  borderSide:
                      const BorderSide(color: AppColors.purple, width: 2),
                ),
              ),
            ),
          ),
          if (widget.error != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(widget.error!,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.coral)),
          ],
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: canSubmit ? widget.onSubmit : null,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.purple,
                disabledBackgroundColor: AppColors.outline,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: widget.isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Done — show me how I did'),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedbackView extends StatelessWidget {
  const _FeedbackView({
    required this.state,
    required this.onTryAgain,
    required this.onBackToTopics,
  });
  final TeachState state;
  final VoidCallback onTryAgain;
  final VoidCallback onBackToTopics;

  @override
  Widget build(BuildContext context) {
    final eval = state.evaluation!;
    final ratio = eval.totalConcepts == 0
        ? 0.0
        : eval.score / eval.totalConcepts;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: AppSpacing.card,
            decoration: BoxDecoration(
              color: ratio >= 0.8
                  ? AppColors.greenL
                  : ratio >= 0.5
                      ? AppColors.amberL
                      : AppColors.coralL,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${eval.score}/${eval.totalConcepts}',
                    style: AppTextStyles.title
                        .copyWith(color: AppColors.text1),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        eval.isPerfect
                            ? 'You taught it all!'
                            : 'Great teaching!',
                        style: AppTextStyles.title,
                      ),
                      const SizedBox(height: 2),
                      Text(eval.feedback,
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.text2)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (eval.xpEarned > 0)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.goldL,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded,
                      color: AppColors.gold, size: 22),
                  const SizedBox(width: 6),
                  Text('+${eval.xpEarned} XP',
                      style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.amber)),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          if (eval.coveredConcepts.isNotEmpty)
            _ConceptList(
              title: 'You explained',
              icon: Icons.check_circle_rounded,
              color: AppColors.green,
              bgColor: AppColors.greenL,
              items: eval.coveredConcepts,
            ),
          if (eval.missedConcepts.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            _ConceptList(
              title: 'Missed concepts',
              icon: Icons.help_outline_rounded,
              color: AppColors.coral,
              bgColor: AppColors.coralL,
              items: eval.missedConcepts,
            ),
          ],
          if (eval.followUpQuestion != null) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: AppSpacing.card,
              decoration: BoxDecoration(
                color: AppColors.purpleL,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.purple, width: 1),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.psychology_outlined,
                      color: AppColors.purple, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Mochi asks: ${eval.followUpQuestion}',
                      style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.text1),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onBackToTopics,
                  style: OutlinedButton.styleFrom(
                    side:
                        const BorderSide(color: AppColors.outline),
                    padding:
                        const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Pick another'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: FilledButton(
                  onPressed: onTryAgain,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.purple,
                    padding:
                        const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Try again'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConceptList extends StatelessWidget {
  const _ConceptList({
    required this.title,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.items,
  });
  final String title;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Text(title,
                  style: AppTextStyles.body
                      .copyWith(color: color, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 6),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text('· $item',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.text1)),
            ),
        ],
      ),
    );
  }
}

class _NoTopicsState extends StatelessWidget {
  const _NoTopicsState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.menu_book_outlined,
                size: 64, color: AppColors.text3),
            const SizedBox(height: AppSpacing.md),
            Text('No topics to teach yet',
                style: AppTextStyles.title),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Upload some notes first so Mochi has something to learn from!',
              textAlign: TextAlign.center,
              style: AppTextStyles.body
                  .copyWith(color: AppColors.text2),
            ),
          ],
        ),
      ),
    );
  }
}
