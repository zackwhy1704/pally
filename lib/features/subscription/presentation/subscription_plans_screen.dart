import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/ui/pally_toast.dart';
import 'package:pally/features/subscription/subscription_service.dart';

/// "P2" Plan Picker — two cards (Individual / Family). Tap → backend
/// /checkout, open Stripe URL externally, then push the return route so
/// it's already mounted and polling when the user comes back.
class SubscriptionPlansScreen extends ConsumerStatefulWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  ConsumerState<SubscriptionPlansScreen> createState() =>
      _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState
    extends ConsumerState<SubscriptionPlansScreen> {
  String _selected = 'family_monthly';
  bool _loading = false;

  Future<void> _startTrial() async {
    setState(() => _loading = true);
    final service = ref.read(subscriptionServiceProvider);
    try {
      final url = await service.startCheckout(_selected);
      // Mount the return screen FIRST so the polling loop is already
      // running by the time Stripe's webhook lands.
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: Text('Choose your plan', style: AppTextStyles.title),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Start with a 7-day free trial. Cancel anytime.',
                  style: AppTextStyles.body
                      .copyWith(color: AppColors.text2)),
              const SizedBox(height: AppSpacing.md),
              _PlanCard(
                title: 'Individual',
                subtitle: '1 child · all premium features',
                priceLine: r'$7.99 / month',
                planId: 'individual_monthly',
                selected: _selected == 'individual_monthly',
                onTap: () => setState(() => _selected = 'individual_monthly'),
              ),
              const SizedBox(height: AppSpacing.sm),
              _PlanCard(
                title: 'Family',
                subtitle: 'Up to 4 kids · share with the whole family',
                priceLine: r'$14.99 / month',
                planId: 'family_monthly',
                selected: _selected == 'family_monthly',
                recommended: true,
                onTap: () => setState(() => _selected = 'family_monthly'),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _loading ? null : _startTrial,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.purple,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
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
          ),
        ),
      ),
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
  });

  final String title;
  final String subtitle;
  final String priceLine;
  final String planId;
  final bool selected;
  final bool recommended;
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
                        Text(title, style: AppTextStyles.title),
                        const SizedBox(width: 6),
                        if (recommended)
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
