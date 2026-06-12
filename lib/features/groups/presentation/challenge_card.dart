import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/features/groups/presentation/challenge_view_model.dart';

/// A class daily-challenge card rendered inline in the group feed. Three
/// states:
///   OPEN     — question + options/text, submit (locks the answer)
///   ANSWERED — "answered — reveals in mm:ss" with a live countdown
///   REVEALED — your answer vs correct + per-answer distribution bars
///
/// The countdown reuses the family-link-code pattern: a 1s periodic timer that
/// recomputes the remaining duration and is cancelled in dispose (and the
/// moment it crosses revealAt, when it triggers a one-shot refresh).
class ChallengeCard extends ConsumerStatefulWidget {
  const ChallengeCard({
    super.key,
    required this.challengeId,
    this.clock = DateTime.now,
  });

  final String challengeId;

  /// Injectable wall-clock so tests can drive the countdown deterministically.
  final DateTime Function() clock;

  @override
  ConsumerState<ChallengeCard> createState() => _ChallengeCardState();
}

class _ChallengeCardState extends ConsumerState<ChallengeCard> {
  Timer? _timer;
  Duration _remaining = Duration.zero;
  bool _refreshedOnReveal = false;
  String? _selected;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _syncTimer(DateTime? revealAt) {
    _timer?.cancel();
    if (revealAt == null) {
      _remaining = Duration.zero;
      return;
    }
    void recompute() {
      var left = revealAt.difference(widget.clock());
      if (left.isNegative) left = Duration.zero;
      if (mounted) setState(() => _remaining = left);
      if (left == Duration.zero) {
        _timer?.cancel();
        // One-shot refresh when the reveal moment arrives so the distribution
        // + correct answer appear without a manual pull-to-refresh.
        if (!_refreshedOnReveal) {
          _refreshedOnReveal = true;
          ref
              .read(challengeViewModelProvider(widget.challengeId).notifier)
              .refresh();
        }
      }
    }

    recompute();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        _timer?.cancel();
        return;
      }
      recompute();
    });
  }

  /// "mm:ss" when under an hour, else a friendly "Reveals <date>".
  String _countdownLabel(DateTime? revealAt) {
    if (revealAt == null) return 'Reveal pending';
    if (_remaining > const Duration(hours: 1)) {
      final d = revealAt;
      final mm = d.month.toString().padLeft(2, '0');
      final dd = d.day.toString().padLeft(2, '0');
      return 'Reveals $dd/$mm';
    }
    final total = _remaining.inSeconds;
    final m = (total ~/ 60).toString().padLeft(2, '0');
    final s = (total % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(challengeViewModelProvider(widget.challengeId));

    return async.when(
      loading: () => _shell(
        child: const Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.purple),
            ),
          ),
        ),
      ),
      // A challenge card that fails to load shouldn't blow up the whole feed.
      error: (_, __) => const SizedBox.shrink(),
      data: (c) {
        // Keep the countdown timer in step with the latest revealAt.
        _syncTimer(c.revealAt);
        return _shell(child: _body(c));
      },
    );
  }

  Widget _shell({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.purpleC.withValues(alpha: 0.4)),
      ),
      child: child,
    );
  }

  Widget _body(Challenge c) {
    return Padding(
      padding: AppSpacing.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header pill
          Row(
            children: [
              const Icon(Icons.bolt_rounded,
                  size: 18, color: AppColors.amber),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Daily Challenge',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.amber,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(c.question, style: AppTextStyles.body),
          const SizedBox(height: AppSpacing.md),
          if (c.revealed)
            _revealed(c)
          else if (c.answered)
            _answered(c)
          else
            _open(c),
        ],
      ),
    );
  }

  // ── OPEN ───────────────────────────────────────────────────────────────────

  Widget _open(Challenge c) {
    if (c.isMcq) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final opt in c.options)
            _OptionTile(
              label: opt,
              selected: _selected == opt,
              onTap: () => setState(() => _selected = opt),
            ),
          const SizedBox(height: AppSpacing.sm),
          _submitButton(c, _selected),
        ],
      );
    }
    // Free-text challenge.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          maxLines: 3,
          minLines: 1,
          style: AppTextStyles.body,
          onChanged: (v) => setState(() => _selected = v.trim()),
          decoration: InputDecoration(
            hintText: 'Type your answer…',
            hintStyle:
                AppTextStyles.body.copyWith(color: AppColors.text3),
            filled: true,
            fillColor: AppColors.surf2,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _submitButton(
            c, (_selected != null && _selected!.isNotEmpty) ? _selected : null),
      ],
    );
  }

  Widget _submitButton(Challenge c, String? answer) {
    final enabled = answer != null && answer.isNotEmpty;
    return FilledButton(
      onPressed: enabled
          ? () => ref
              .read(challengeViewModelProvider(widget.challengeId).notifier)
              .submitAnswer(answer)
          : null,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.purple,
        disabledBackgroundColor: AppColors.outline,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text('Submit'),
    );
  }

  // ── ANSWERED (locked, waiting for reveal) ───────────────────────────────────

  Widget _answered(Challenge c) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.tealL,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_clock_rounded,
              size: 18, color: AppColors.teal),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Answered — reveals in ${_countdownLabel(c.revealAt)}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.teal,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── REVEALED (your answer vs correct + distribution) ────────────────────────

  Widget _revealed(Challenge c) {
    final correct = c.correct ?? c.answer;
    final mine = c.myAnswer;
    final gotItRight = mine != null && correct != null && mine == correct;
    final total = c.totalVotes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (mine != null)
          Row(
            children: [
              Icon(
                gotItRight
                    ? Icons.check_circle_rounded
                    : Icons.cancel_rounded,
                size: 18,
                color: gotItRight ? AppColors.green : AppColors.coral,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  gotItRight
                      ? 'You got it right!'
                      : 'Your answer: $mine',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: gotItRight ? AppColors.green : AppColors.coral,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        if (correct != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Text('Correct: ',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.text2)),
              Flexible(
                child: Text(
                  correct,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.green,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ],
        if (c.distribution.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          for (final d in c.distribution)
            _DistributionBar(
              label: d.answer,
              count: d.count,
              total: total,
              isCorrect: correct != null && d.answer == correct,
              isMine: mine != null && d.answer == mine,
            ),
        ],
      ],
    );
  }
}

// ── Option tile (OPEN, MCQ) ────────────────────────────────────────────────

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Material(
        color: selected ? AppColors.purpleL : AppColors.surf2,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? AppColors.purple : AppColors.outline,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 18,
                  color: selected ? AppColors.purple : AppColors.text3,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body.copyWith(
                      color: selected ? AppColors.purple : AppColors.text1,
                      fontWeight:
                          selected ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Distribution bar (REVEALED) ────────────────────────────────────────────

class _DistributionBar extends StatelessWidget {
  const _DistributionBar({
    required this.label,
    required this.count,
    required this.total,
    required this.isCorrect,
    required this.isMine,
  });
  final String label;
  final int count;
  final int total;
  final bool isCorrect;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final frac = total > 0 ? count / total : 0.0;
    final pct = (frac * 100).round();
    final barColor = isCorrect ? AppColors.green : AppColors.purpleC;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight:
                        (isCorrect || isMine) ? FontWeight.w800 : FontWeight.w400,
                    color: isCorrect ? AppColors.green : AppColors.text1,
                  ),
                ),
              ),
              if (isMine) ...[
                const SizedBox(width: 4),
                Text('(you)',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.purple)),
              ],
              const SizedBox(width: AppSpacing.sm),
              Text('$pct%',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.text2)),
            ],
          ),
          const SizedBox(height: 2),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: frac,
              minHeight: 6,
              backgroundColor: AppColors.outline,
              valueColor: AlwaysStoppedAnimation(barColor),
            ),
          ),
        ],
      ),
    );
  }
}
