import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/features/subscription/entitlement_provider.dart';
import 'package:pally/features/subscription/trial_status_provider.dart';
import 'package:pally/shared/models/entitlement.dart';
import 'package:pally/features/subscription/web_billing.dart';
import 'package:pally/features/subscription/widgets/web_upgrade_cta.dart';

// Plan descriptor — all data needed to render a card.
class _Plan {
  const _Plan({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.annualPrice,
    required this.features,
    this.recommended = false,
    this.badge,
  });

  final String id;        // matches backend plan key
  final String title;
  final String subtitle;
  final String price;       // monthly price string
  final String annualPrice; // annual price string (shown in toggle)
  final List<String> features;
  final bool recommended;
  final String? badge; // "Best value" etc.
}

const _plans = [
  _Plan(
    id: 'pro_monthly',
    title: 'Pro',
    subtitle: '1 student · all AI features',
    price: r'S$8.90/mo',
    annualPrice: r'S$89/yr',
    features: [
      '100 AI messages / day',
      'Up to 5 Mochis',
      'Quiz & flashcards',
      'Homework photo scan',
    ],
  ),
  _Plan(
    id: 'max_monthly',
    title: 'Max',
    subtitle: '1 student · smarter AI for hard problems',
    price: r'S$14.90/mo',
    annualPrice: r'S$149/yr',
    features: [
      'Unlimited AI messages',
      'Unlimited Mochis',
      'Sonnet model for complex questions',
      'All Pro features',
    ],
    recommended: true,
    badge: 'Best for exams',
  ),
  _Plan(
    id: 'family_monthly',
    title: 'Family',
    subtitle: 'Up to 4 students',
    price: r'S$24.90/mo',
    annualPrice: r'S$249/yr',
    features: [
      'Everything in Max',
      'Up to 4 child accounts',
      'Parent dashboard',
      'Shared star rewards',
    ],
    badge: 'Most popular',
  ),
];

// Map from backend plan string to plan ID used above.
String? _planIdFromBackend(String? planKey) {
  if (planKey == null) return null;
  final lower = planKey.toLowerCase();
  if (lower.contains('family')) return 'family_monthly';
  if (lower.contains('max')) return 'max_monthly';
  if (lower.contains('pro')) return 'pro_monthly';
  return null;
}

/// Resolves a short tier name ('pro', 'max', 'family', 'centre') to the
/// matching monthly plan ID, or null if unrecognised.
String? _planIdFromHighlightTier(String? tier) => switch (tier) {
      'pro' => 'pro_monthly',
      'max' => 'max_monthly',
      'family' => 'family_monthly',
      _ => null,
    };

/// Plan picker screen — adapts its copy and CTA based on entitlement:
///
/// • **Free/trial user**: "Start 7-day free trial" → Stripe checkout.
/// • **Premium user**: shows their current plan highlighted, lets them
///   switch plans, and provides a "Manage billing" link to the Stripe
///   portal for cancellation/card updates.
///
/// When [highlightTier] is provided (e.g. from the paywall), that plan
/// is auto-selected on first load instead of defaulting to `max_monthly`.
class SubscriptionPlansScreen extends ConsumerStatefulWidget {
  const SubscriptionPlansScreen({super.key, this.highlightTier});

  /// Short tier name to pre-select: 'pro', 'max', 'family'.
  /// If null or unrecognised, the screen defaults to 'max_monthly'.
  final String? highlightTier;

  @override
  ConsumerState<SubscriptionPlansScreen> createState() =>
      _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState
    extends ConsumerState<SubscriptionPlansScreen> {
  String? _selected;
  bool _annual = false;

  @override
  Widget build(BuildContext context) {
    final entAsync = ref.watch(entitlementVmProvider);
    final trialAsync = ref.watch(trialStatusProvider);

    return entAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(child: CircularProgressIndicator(color: AppColors.purple)),
      ),
      error: (_, __) => Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          backgroundColor: AppColors.bg,
          elevation: 0,
          title: Text('Choose your plan', style: AppTextStyles.title),
          centerTitle: true,
        ),
        body: const Center(
          child: Text('Could not load subscription info. Try again.'),
        ),
      ),
      data: (ent) {
        final isPremium = ent.isPremium;
        final currentPlanId = _planIdFromBackend(ent.plan);
        final trialData = trialAsync.valueOrNull;
        final tier = trialData?.subscriptionTier;
        final isOnTrial = trialData?.isOnTrial ?? false;
        final trialDaysLeft = trialData?.trialDaysLeft ?? 0;
        final isCentreSourced = trialData?.source == 'CENTRE';

        // Default selection — honour highlightTier from the paywall, or the
        // user's current plan, falling back to 'max_monthly'.
        _selected ??= currentPlanId
            ?? _planIdFromHighlightTier(widget.highlightTier)
            ?? 'max_monthly';

        return Scaffold(
          backgroundColor: AppColors.bg,
          appBar: AppBar(
            backgroundColor: AppColors.bg,
            elevation: 0,
            title: Text(
              isPremium ? 'Your subscription' : 'Upgrade Apalchi',
              style: AppTextStyles.title,
            ),
            centerTitle: true,
          ),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header copy
                        Text(
                          isCentreSourced
                              ? 'Your Premium comes from your centre. Enjoy unlimited chat and Mochis!'
                              : isOnTrial
                                  ? 'Your free trial ends in $trialDaysLeft day${trialDaysLeft == 1 ? '' : 's'}.'
                                      ' Subscribe to keep all your Mochis.'
                                  : isPremium
                                      ? 'You\'re on ${tier ?? prettyTier(ent.plan)}.'
                                          ' Manage or cancel anytime on the web.'
                                      : 'Start with a 7-day free trial. Cancel anytime.',
                          style: AppTextStyles.body
                              .copyWith(color: AppColors.text2),
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Monthly / Annual toggle
                        _BillingToggle(
                          annual: _annual,
                          onToggle: (v) => setState(() => _annual = v),
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Free tier summary (always visible for free users)
                        if (!isPremium) ...[
                          _FreeTierBanner(),
                          const SizedBox(height: AppSpacing.sm),
                        ],

                        // Plan cards
                        for (final plan in _plans) ...[
                          _PlanCard(
                            plan: plan,
                            annual: _annual,
                            selected: _selected == plan.id,
                            isCurrent: currentPlanId == plan.id,
                            onTap: () =>
                                setState(() => _selected = plan.id),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                        ],
                        const SizedBox(height: AppSpacing.sm),
                      ],
                    ),
                  ),
                ),

                // Bottom action area — purchasing is web-only.
                _ActionArea(
                  isPremium: isPremium,
                  isOnTrial: isOnTrial,
                  isCentreSourced: isCentreSourced,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Billing cycle toggle ──────────────────────────────────────────────────────

class _BillingToggle extends StatelessWidget {
  const _BillingToggle({required this.annual, required this.onToggle});
  final bool annual;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _tab('Monthly', !annual, () => onToggle(false)),
        const SizedBox(width: AppSpacing.xs),
        _tab('Annual  (save ~34%)', annual, () => onToggle(true)),
      ],
    );
  }

  Widget _tab(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: active ? AppColors.purple : AppColors.surf2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: active ? AppColors.purple : AppColors.outline),
        ),
        child: Text(
          label,
          style: AppTextStyles.label.copyWith(
            color: active ? Colors.white : AppColors.text2,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ── Free tier summary banner ──────────────────────────────────────────────────

class _FreeTierBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: AppColors.surf2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          const Text('🆓', style: TextStyle(fontSize: 20)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Free', style: AppTextStyles.title),
                Text(
                  '20 messages/day · 1 Mochi · basic features',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.outline,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text('Current',
                style:
                    AppTextStyles.caption.copyWith(color: AppColors.text2)),
          ),
        ],
      ),
    );
  }
}

// ── Plan card ─────────────────────────────────────────────────────────────────

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.annual,
    required this.selected,
    required this.onTap,
    this.isCurrent = false,
  });

  final _Plan plan;
  final bool annual;
  final bool selected;
  final bool isCurrent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          padding: AppSpacing.card,
          decoration: BoxDecoration(
            color: selected ? AppColors.purpleL : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.purple : AppColors.outline,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Radio circle
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: selected
                              ? AppColors.purple
                              : AppColors.outline,
                          width: 2),
                      color: selected ? AppColors.purple : Colors.transparent,
                    ),
                    child: selected
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 14)
                        : null,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  // Title + badges
                  Flexible(
                    child: Text(plan.title,
                        style: AppTextStyles.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  if (isCurrent)
                    const _Badge('Current', AppColors.teal)
                  else if (plan.badge != null)
                    _Badge(plan.badge!, AppColors.gold)
                  else if (plan.recommended)
                    const _Badge('Best value', AppColors.purple),
                  // Price pushed to right
                  const Spacer(),
                  Text(
                    annual ? plan.annualPrice : plan.price,
                    style: AppTextStyles.body
                        .copyWith(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(plan.subtitle, style: AppTextStyles.bodySmall),
                    if (selected) ...[
                      const SizedBox(height: AppSpacing.sm),
                      for (final f in plan.features)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Row(
                            children: [
                              const Icon(Icons.check_rounded,
                                  color: AppColors.green, size: 14),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(f,
                                    style: AppTextStyles.bodySmall,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.label, this.color);
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      constraints: const BoxConstraints(maxWidth: 100),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(color: Colors.white),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

// ── Bottom action area (web-only purchasing) ─────────────────────────────────

class _ActionArea extends StatelessWidget {
  const _ActionArea({
    required this.isPremium,
    required this.isOnTrial,
    required this.isCentreSourced,
  });

  final bool isPremium;
  final bool isOnTrial;
  final bool isCentreSourced;

  @override
  Widget build(BuildContext context) {
    // Premium via the centre/org — the org pays; nothing for the student to do.
    // Already paying for themselves (not a trial) → manage/cancel on the web.
    final showManage = !isCentreSourced && isPremium && !isOnTrial;
    // Free, or still on the trial → upgrade on the web.
    final showUpgrade = !isCentreSourced && (!isPremium || isOnTrial);

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        MediaQuery.of(context).padding.bottom + AppSpacing.sm,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.outline)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isCentreSourced)
            const _CentreBanner()
          else if (showManage)
            const WebUpgradeCta(
              url: kWebAccountUrl,
              displayUrl: kWebAccountDisplay,
              intro: 'Manage your plan, update your card, or cancel anytime on '
                  'the Apalchi website.',
              launchLabel: 'Manage on web',
              showRefresh: false,
            )
          else if (showUpgrade)
            const WebUpgradeCta(),
        ],
      ),
    );
  }
}

class _CentreBanner extends StatelessWidget {
  const _CentreBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.tealL,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.teal),
      ),
      child: Center(
        child: Text(
          '⭐ Premium via your centre',
          style: AppTextStyles.body.copyWith(
            color: AppColors.teal,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
