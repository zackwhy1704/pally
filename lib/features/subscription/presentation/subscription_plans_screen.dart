import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/core/services/feature_flags.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/features/subscription/entitlement_provider.dart';
import 'package:pally/features/subscription/trial_status_provider.dart';
import 'package:pally/shared/models/entitlement.dart';
import 'package:pally/features/subscription/web_billing.dart';
import 'package:pally/features/subscription/widgets/web_upgrade_cta.dart';
import 'package:pally/l10n/app_localizations.dart';

// Plan descriptor — id + price data only. All DISPLAY text (title, subtitle,
// features, badge) is localized at render via the _plan* resolvers below, keyed
// on the stable [id]; the const list holds only the price strings (which stay
// literal + gated for App Store anti-steering) and layout flags.
class _Plan {
  const _Plan({
    required this.id,
    required this.price,
    required this.annualPrice,
    this.recommended = false,
  });

  final String id;        // matches backend plan key
  final String price;       // monthly price string
  final String annualPrice; // annual price string (shown in toggle)
  final bool recommended;
}

const _plans = [
  _Plan(id: 'pro_monthly', price: r'US$9.99/mo', annualPrice: r'US$79/yr'),
  _Plan(
      id: 'max_monthly',
      price: r'US$19.99/mo',
      annualPrice: r'US$159/yr',
      recommended: true),
  _Plan(id: 'family_monthly', price: r'US$34.99/mo', annualPrice: r'US$279/yr'),
];

// ── Per-plan localized display (keyed on the stable backend plan id) ──────────
// A semantic switch on the canonical id — the ARB holds the per-locale strings,
// no language conditional (B-EXT.2). Unknown ids degrade to the raw id / empty.
String _planTitle(AppLocalizations l, String id) => switch (id) {
      'pro_monthly' => l.tierPro,
      'max_monthly' => l.tierMax,
      'family_monthly' => l.tierFamily,
      _ => id,
    };
String _planSubtitle(AppLocalizations l, String id) => switch (id) {
      'pro_monthly' => l.subPlansProSubtitle,
      'max_monthly' => l.subPlansMaxSubtitle,
      'family_monthly' => l.subPlansFamilySubtitle,
      _ => '',
    };
List<String> _planFeatures(AppLocalizations l, String id) => switch (id) {
      'pro_monthly' => [
          l.subPlansProFeat1,
          l.subPlansProFeat2(l.mascotName),
          l.subPlansProFeat3,
          l.subPlansProFeat4,
        ],
      'max_monthly' => [
          l.subPlansMaxFeat1,
          l.subPlansMaxFeat2(l.mascotName),
          l.subPlansMaxFeat3,
          l.subPlansMaxFeat4,
        ],
      'family_monthly' => [
          l.subPlansFamilyFeat1,
          l.subPlansFamilyFeat2,
          l.subPlansFamilyFeat3,
          l.subPlansFamilyFeat4,
        ],
      _ => const [],
    };
String? _planBadge(AppLocalizations l, String id) => switch (id) {
      'max_monthly' => l.subPlansBadgeExams,
      'family_monthly' => l.subPlansBadgePopular,
      _ => null,
    };

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
    final l10n = AppLocalizations.of(context);
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
          title: Text(l10n.subPlansChooseTitle, style: AppTextStyles.title),
          centerTitle: true,
        ),
        body: Center(
          child: Text(l10n.subPlansLoadError),
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

        // iOS anti-steering: on iOS without the external-link entitlement, the
        // App Store forbids DISPLAYING subscription prices in-app (same rule
        // that gates the buy URL). Hide price strings there; show plan names +
        // features only. Same guard WebUpgradeCta uses for the launch button.
        final allowPrice = allowPriceDisplay(ref);

        return Scaffold(
          backgroundColor: AppColors.bg,
          appBar: AppBar(
            backgroundColor: AppColors.bg,
            elevation: 0,
            title: Text(
              isPremium ? l10n.subPlansYourSubscription : l10n.subPlansUpgradeTitle,
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
                              ? l10n.subPlansHeaderCentre(l10n.mascotName)
                              : isOnTrial
                                  ? l10n.subPlansHeaderTrial(
                                      trialDaysLeft, l10n.mascotName)
                                  : isPremium
                                      ? l10n.subPlansHeaderPremium(
                                          tier ?? prettyTier(ent.plan))
                                      : l10n.subPlansHeaderFree,
                          style: AppTextStyles.body
                              .copyWith(color: AppColors.text2),
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Monthly / Annual toggle — only meaningful when prices
                        // are shown (hidden on gated iOS).
                        if (allowPrice) ...[
                          _BillingToggle(
                            annual: _annual,
                            onToggle: (v) => setState(() => _annual = v),
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],

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
                            allowPrice: allowPrice,
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
    final l10n = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(child: _tab(l10n.subPlansMonthly, !annual, () => onToggle(false))),
        const SizedBox(width: AppSpacing.xs),
        Flexible(child: _tab(l10n.subPlansAnnual, annual, () => onToggle(true))),
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
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
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
    final l10n = AppLocalizations.of(context);
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
                Text(l10n.tierFree, style: AppTextStyles.title),
                Text(
                  l10n.subPlansFreeFeatures(l10n.mascotName),
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
            child: Text(l10n.subPlansCurrent,
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
    required this.allowPrice,
    this.isCurrent = false,
  });

  final _Plan plan;
  final bool annual;
  final bool selected;
  final bool isCurrent;
  final VoidCallback onTap;
  // When false (gated iOS), the price string is hidden for App Store compliance.
  final bool allowPrice;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final badge = _planBadge(l, plan.id);
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
                    child: Text(_planTitle(l, plan.id),
                        style: AppTextStyles.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  if (isCurrent)
                    _Badge(l.subPlansCurrent, AppColors.teal)
                  else if (badge != null)
                    _Badge(badge, AppColors.gold)
                  else if (plan.recommended)
                    _Badge(l.subPlansBestValue, AppColors.purple),
                  // Price pushed to right — hidden on gated iOS (anti-steering).
                  const Spacer(),
                  if (allowPrice)
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
                    Text(_planSubtitle(l, plan.id),
                        style: AppTextStyles.bodySmall),
                    if (selected) ...[
                      const SizedBox(height: AppSpacing.sm),
                      for (final f in _planFeatures(l, plan.id))
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
            WebUpgradeCta(
              url: kWebAccountUrl,
              displayUrl: kWebAccountDisplay,
              intro: AppLocalizations.of(context).subPlansManageIntro,
              launchLabel: AppLocalizations.of(context).subPlansManageOnWeb,
              showRefresh: false,
              showEmailLink: false,
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
          AppLocalizations.of(context).subPlansCentreBanner,
          style: AppTextStyles.body.copyWith(
            color: AppColors.teal,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
