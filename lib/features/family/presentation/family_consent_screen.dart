import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_sizing.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/ui/pally_toast.dart';
import 'package:pally/core/utils/logger.dart';

/// PDPA consent screen shown to children (13+) after joining via family link code.
/// The child must agree before the parent can view their progress.
class FamilyConsentScreen extends ConsumerStatefulWidget {
  const FamilyConsentScreen({super.key, this.parentName});
  final String? parentName;

  @override
  ConsumerState<FamilyConsentScreen> createState() =>
      _FamilyConsentScreenState();
}

class _FamilyConsentScreenState extends ConsumerState<FamilyConsentScreen> {
  bool _loading = false;

  Future<void> _accept() async {
    setState(() => _loading = true);
    try {
      final dio = ref.read(dioProvider);
      await dio.post<void>('/api/v1/consent/family-accept');
      if (mounted) {
        PallyToast.success(context, 'Consent given. Welcome!');
        context.go('/');
      }
    } on DioException catch (e, st) {
      appLog.e('[FamilyConsent] Accept failed', error: e, stackTrace: st);
      if (mounted) PallyToast.error(context, 'Something went wrong');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _decline() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Are you sure?', style: AppTextStyles.title),
        content: Text(
          'Your parent needs your approval to view your progress. '
          'You can change this in Settings later.',
          style: AppTextStyles.body.copyWith(color: AppColors.text2),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Go back'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.go('/');
            },
            child: const Text('Decline'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final parent = widget.parentName ?? 'Your parent';
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xxl),
              Container(
                width: AppSizing.iconContainer,
                height: AppSizing.iconContainer,
                decoration: const BoxDecoration(
                  color: AppColors.purpleL,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.visibility_rounded,
                    color: AppColors.purple, size: 32),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Can $parent see your progress?',
                style: AppTextStyles.heading1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                '$parent will be able to see your study progress, '
                'concept mastery, and weekly reports. Is that okay?',
                style: AppTextStyles.body.copyWith(color: AppColors.text2),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
                padding: AppSpacing.card,
                decoration: BoxDecoration(
                  color: AppColors.surf2,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.outline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$parent will see:',
                        style: AppTextStyles.body
                            .copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: AppSpacing.sm),
                    const _InfoRow(text: 'Study progress and streaks'),
                    const _InfoRow(text: 'Subject mastery levels'),
                    const _InfoRow(text: 'Weekly learning reports'),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '$parent will NOT see your chat messages.',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.green),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                height: AppSizing.buttonHeight,
                child: ElevatedButton(
                  onPressed: _loading ? null : _accept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.purple,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        AppColors.purple.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: AppSizing.spinnerSm,
                          height: AppSizing.spinnerSm,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text("Yes, that's okay",
                          style: AppTextStyles.body.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Center(
                child: TextButton(
                  onPressed: _decline,
                  style:
                      TextButton.styleFrom(foregroundColor: AppColors.text2),
                  child:
                      Text("No, don't share", style: AppTextStyles.bodySmall),
                ),
              ),
              SizedBox(
                  height:
                      MediaQuery.of(context).padding.bottom + AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_rounded, color: AppColors.purple, size: 16),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(text, style: AppTextStyles.bodySmall)),
        ],
      ),
    );
  }
}
