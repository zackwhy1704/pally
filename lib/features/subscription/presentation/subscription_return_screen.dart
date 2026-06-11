import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/features/subscription/entitlement_provider.dart';

/// Polls entitlement after the user returns from Stripe checkout. The
/// webhook usually beats the redirect, but not always — so we keep
/// asking for ~20s before giving up and letting the user retry from
/// Settings → Subscription.
class SubscriptionReturnScreen extends ConsumerStatefulWidget {
  const SubscriptionReturnScreen({super.key, this.status});

  /// Either 'success' (poll) or 'cancel' (pop and tell the caller).
  final String? status;

  @override
  ConsumerState<SubscriptionReturnScreen> createState() =>
      _SubscriptionReturnScreenState();
}

class _SubscriptionReturnScreenState
    extends ConsumerState<SubscriptionReturnScreen> {
  Timer? _timer;
  int _attempts = 0;
  static const _maxAttempts = 10; // ~20s at 2s intervals
  bool _done = false;

  @override
  void initState() {
    super.initState();
    if (widget.status == 'cancel') {
      // Defer to next frame so context.pop is safe.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop();
      });
      return;
    }
    _poll();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => _poll());
  }

  Future<void> _poll() async {
    _attempts++;
    await ref.read(entitlementVmProvider.notifier).refresh();
    final ent = ref.read(entitlementVmProvider).valueOrNull;
    if (ent != null && ent.isPremium) {
      _timer?.cancel();
      if (!mounted) return;
      setState(() => _done = true);
      return;
    }
    if (_attempts >= _maxAttempts) {
      _timer?.cancel();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timedOut = !_done && _attempts >= _maxAttempts;
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: Text('Subscription', style: AppTextStyles.title),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_done) ...[
                const Text('🎉', style: TextStyle(fontSize: 56)),
                const SizedBox(height: AppSpacing.sm),
                Text('You are premium!', style: AppTextStyles.heading1),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Everything just unlocked — unlimited Mochis, family '
                  'sharing, parent dashboard, and more.',
                  style: AppTextStyles.body.copyWith(color: AppColors.text2),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                FilledButton(
                  onPressed: () => context.go('/progress'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.purple,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 14),
                  ),
                  child: const Text('Start exploring'),
                ),
              ] else if (timedOut) ...[
                const Icon(Icons.hourglass_bottom_rounded,
                    size: 56, color: AppColors.text3),
                const SizedBox(height: AppSpacing.sm),
                Text('Still confirming…', style: AppTextStyles.title),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Your payment may still be processing. You can check '
                  'Settings → Subscription in a minute or two.',
                  style: AppTextStyles.body.copyWith(color: AppColors.text2),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                OutlinedButton(
                  onPressed: () => context.go('/progress'),
                  child: const Text('Back to Apalchi'),
                ),
              ] else ...[
                const CircularProgressIndicator(
                    color: AppColors.purple),
                const SizedBox(height: AppSpacing.md),
                Text('Confirming your subscription…',
                    style: AppTextStyles.body),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
