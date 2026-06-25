import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/error/pally_error.dart';
import 'package:pally/core/ui/pally_error_card.dart';
import 'package:pally/core/ui/pally_loading_spinner.dart';
import 'package:pally/core/ui/pally_toast.dart';
import 'package:pally/features/referral/referral_service.dart';
import 'package:pally/shared/models/referral.dart';
import 'package:share_plus/share_plus.dart' as share_plus;

class ReferralScreen extends ConsumerWidget {
  const ReferralScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(referralSummaryProvider);
    final redemptionsAsync = ref.watch(referralRedemptionsProvider);
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: Text('Invite friends', style: AppTextStyles.title),
        centerTitle: true,
      ),
      body: summaryAsync.when(
        loading: () => const PallyLoadingSpinner(),
        error: (e, _) => PallyErrorCard(
          message: PallyError.from(e).userMessage,
          onRetry: () => ref.invalidate(referralSummaryProvider),
        ),
        data: (summary) => RefreshIndicator(
          color: AppColors.purple,
          onRefresh: () async {
            ref.invalidate(referralSummaryProvider);
            ref.invalidate(referralRedemptionsProvider);
          },
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              _CodeCard(code: summary.code),
              const SizedBox(height: AppSpacing.md),
              _TierProgress(summary: summary),
              const SizedBox(height: AppSpacing.lg),
              Text('Friends you invited', style: AppTextStyles.title),
              const SizedBox(height: AppSpacing.sm),
              redemptionsAsync.when(
                loading: () => const Center(
                    child: Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: PallyLoadingSpinner(),
                )),
                error: (_, __) => Text(
                    'Could not load your invites',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.text2)),
                data: (rows) => rows.isEmpty
                    ? _EmptyInvites()
                    : Column(
                        children: rows
                            .map((r) => _RedemptionRow(redemption: r))
                            .toList(),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CodeCard extends StatelessWidget {
  const _CodeCard({required this.code});
  final String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.purple, AppColors.purpleC],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text('🎁', style: TextStyle(fontSize: 40)),
          const SizedBox(height: AppSpacing.sm),
          Text('Your invite code',
              style: AppTextStyles.bodySmall
                  .copyWith(color: Colors.white70)),
          const SizedBox(height: 4),
          Text(code,
              style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 6)),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: code));
                    HapticFeedback.lightImpact();
                    PallyToast.success(context, 'Code copied');
                  },
                  icon: const Icon(Icons.copy_rounded,
                      size: 16, color: Colors.white),
                  label: const Text('Copy',
                      style: TextStyle(color: Colors.white)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white70),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => share_plus.Share.share(
                      'Try Apalchi — the AI study companion. '
                      'Use my code $code at sign-up so we both earn bonus '
                      'stars when you take your first quiz.'),
                  icon: const Icon(Icons.ios_share_rounded, size: 16),
                  label: const Text('Share'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.purple,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TierProgress extends StatelessWidget {
  const _TierProgress({required this.summary});
  final ReferralSummary summary;

  @override
  Widget build(BuildContext context) {
    final target = summary.nextTierAt;
    final pct = target == 0
        ? 1.0
        : (summary.activatedCount / target).clamp(0.0, 1.0);
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
              Flexible(
                child: Text(
                  '${summary.activatedCount} of $target friends activated',
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body
                      .copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.goldL,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('⭐ ${summary.rewardsEarned}',
                    style: AppTextStyles.label
                        .copyWith(color: AppColors.gold)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: AppColors.outline,
              valueColor: const AlwaysStoppedAnimation(AppColors.purple),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 4),
          if (summary.nextTierBonus > 0 &&
              summary.activatedCount < target)
            Text(
              'Refer ${target - summary.activatedCount} more → '
              '+${summary.nextTierBonus}⭐ bonus',
              style: AppTextStyles.label.copyWith(
                  color: AppColors.purple, fontWeight: FontWeight.w700),
            ),
          const SizedBox(height: 4),
          Text(
            'Friends count as "activated" after they complete their first quiz.',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}

class _RedemptionRow extends StatelessWidget {
  const _RedemptionRow({required this.redemption});
  final ReferralRedemption redemption;

  @override
  Widget build(BuildContext context) {
    final activated = redemption.status == 'activated';
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: activated
                ? AppColors.greenL
                : AppColors.amberL,
            radius: 16,
            child: Icon(
              activated
                  ? Icons.check_rounded
                  : Icons.hourglass_bottom_rounded,
              size: 18,
              color: activated ? AppColors.green : AppColors.amber,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(redemption.displayName,
                style: AppTextStyles.body
                    .copyWith(fontWeight: FontWeight.w700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
          Text(activated ? 'Activated' : 'Pending',
              style: AppTextStyles.caption.copyWith(
                  color: activated ? AppColors.green : AppColors.amber)),
        ],
      ),
    );
  }
}

class _EmptyInvites extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: AppColors.surf2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline),
      ),
      child: Text(
        'No invites yet — share your code above to get started!',
        style: AppTextStyles.bodySmall,
        textAlign: TextAlign.center,
      ),
    );
  }
}
