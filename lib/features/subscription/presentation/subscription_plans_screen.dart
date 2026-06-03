import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_sizing.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/ui/pally_toast.dart';
import 'package:pally/features/subscription/entitlement_provider.dart';
import 'package:pally/features/subscription/subscription_service.dart';

/// Plan picker screen — adapts its copy and CTA based on entitlement:
///
/// • **Free/trial user**: "Start 7-day free trial" → Stripe checkout.
/// • **Premium user**: shows their current plan highlighted, lets them
///   switch plans (change Individual ↔ Family), and provides a "Manage
///   billing" link to the Stripe portal for cancellation/card updates.
class SubscriptionPlansScreen extends ConsumerStatefulWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  ConsumerState<SubscriptionPlansScreen> createState() =>
      _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState
    extends ConsumerState<SubscriptionPlansScreen> {
  String? _selected;
  bool _loading = false;
  bool _portalLoading = false;

  /// The plan ID from the backend's entitlement (null when free).
  String? _currentPlanId(String? planKey) {
    if (planKey == null) return null;
    // Backend returns plan keys like "individual_monthly" / "family_monthly"
    final lower = planKey.toLowerCase();
    if (lower.contains('family')) return 'family_monthly';
    if (lower.contains('individual')) return 'individual_monthly';
    return null;
  }

  Future<void> _subscribe() async {
    final plan = _selected;
    if (plan == null) return;
    setState(() => _loading = true);
    final service = ref.read(subscriptionServiceProvider);
    try {
      final url = await service.startCheckout(plan);
      if (!mounted) return;
      context.push('/subscription/return?status=success');
      final opened = await service.launchExternal(url);
      if (!opened && mounted) {
        PallyToast.error(context,
            'Could not open browser. Copy this URL to continue:\n$url');
      }
    } on SubscriptionError catch (e) {
      if (mounted) PallyToast.error(context, e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openPortal() async {
    setState(() => _portalLoading = true);
    final service = ref.read(subscriptionServiceProvider);
    try {
      final url = await service.openPortal();
      await service.launchExternal(url);
    } on SubscriptionError catch (e) {
      if (mounted) PallyToast.error(context, e.message);
    } finally {
      if (mounted) setState(() => _portalLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final entAsync = ref.watch(entitlementVmProvider);

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
        final currentPlanId = _currentPlanId(ent.plan);

        // Default selection: for free users → family; for premium → current plan
        _selected ??= currentPlanId ?? 'family_monthly';

        return Scaffold(
          backgroundColor: AppColors.bg,
          appBar: AppBar(
            backgroundColor: AppColors.bg,
            elevation: 0,
            title: Text(
              isPremium ? 'Your subscription' : 'Choose your plan',
              style: AppTextStyles.title,
            ),
            centerTitle: true,
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    isPremium
                        ? 'You\'re on ${ent.plan ?? 'Premium'}. Switch plans below or manage billing to cancel.'
                        : 'Start with a 7-day free trial. Cancel anytime.',
                    style:
                        AppTextStyles.body.copyWith(color: AppColors.text2),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _PlanCard(
                    title: 'Individual',
                    subtitle: '1 child · all premium features',
                    priceLine: r'$7.99 / month',
                    planId: 'individual_monthly',
                    selected: _selected == 'individual_monthly',
                    isCurrent: currentPlanId == 'individual_monthly',
                    onTap: () =>
                        setState(() => _selected = 'individual_monthly'),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _PlanCard(
                    title: 'Family',
                    subtitle: 'Up to 4 kids · share with the whole family',
                    priceLine: r'$14.99 / month',
                    planId: 'family_monthly',
                    selected: _selected == 'family_monthly',
                    isCurrent: currentPlanId == 'family_monthly',
                    recommended: !isPremium,
                    onTap: () =>
                        setState(() => _selected = 'family_monthly'),
                  ),
                  const Spacer(),

                  // CTA — adapts for premium vs free
                  if (isPremium) ...[
                    // Switch plan (if different from current)
                    if (_selected != currentPlanId)
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _loading ? null : _subscribe,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.purple,
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  height: AppSizing.spinnerSm,
                                  width: AppSizing.spinnerSm,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                )
                              : const Text('Switch to this plan'),
                        ),
                      )
                    else
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: null,
                          style: OutlinedButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text('Current plan'),
                        ),
                      ),
                    const SizedBox(height: AppSpacing.sm),
                    // Manage billing / cancel via Stripe portal
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: _portalLoading ? null : _openPortal,
                        child: _portalLoading
                            ? const SizedBox(
                                height: AppSizing.spinnerSm,
                                width: AppSizing.spinnerSm,
                                child: CircularProgressIndicator(
                                    color: AppColors.purple, strokeWidth: 2),
                              )
                            : const Text(
                                'Manage billing / Cancel subscription',
                                style:
                                    TextStyle(color: AppColors.text2),
                              ),
                      ),
                    ),
                  ] else ...[
                    // Free user — start trial
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _loading ? null : _subscribe,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.purple,
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        child: _loading
                            ? const SizedBox(
                                height: AppSizing.spinnerSm,
                                width: AppSizing.spinnerSm,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('Start 7-day free trial'),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'No charge during trial. We\'ll remind you before it ends.',
                      style: AppTextStyles.caption,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.subtitle,
    required this.priceLine,
    required this.planId,
    required this.selected,
    required this.onTap,
    this.recommended = false,
    this.isCurrent = false,
  });

  final String title;
  final String subtitle;
  final String priceLine;
  final String planId;
  final bool selected;
  final bool recommended;
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
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: selected ? AppColors.purple : AppColors.outline,
                      width: 2),
                  color: selected ? AppColors.purple : Colors.transparent,
                ),
                child: selected
                    ? const Icon(Icons.check_rounded,
                        color: Colors.white, size: 14)
                    : null,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(title,
                              style: AppTextStyles.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(width: 6),
                        if (isCurrent)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.teal,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text('Current',
                                style: AppTextStyles.caption
                                    .copyWith(color: Colors.white)),
                          )
                        else if (recommended)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.gold,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text('Best value',
                                style: AppTextStyles.caption
                                    .copyWith(color: Colors.white)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(priceLine,
                  style: AppTextStyles.body
                      .copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}
