import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/l10n/app_localizations.dart';

/// Maps a feature code to the cheapest plan tier that unlocks it.
/// Used to pre-select the recommended plan on the plans screen.
String? _highlightTierForFeature(String? feature) => switch (feature) {
      'CHAT_DAILY' => 'pro',
      'CREATE_TUTOR' => 'pro',
      'GROUPS' => 'pro',
      'PARENT_DASHBOARD' => 'pro',
      'ADD_STUDENT' => 'family',
      _ => null,
    };

/// "P1" Paywall — the friction moment when a free user hits a server-side
/// gate. Briefly explains the feature they want, lists what premium
/// unlocks, and routes to the plan picker.
class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key, this.feature});

  /// Server-supplied feature code (CREATE_TUTOR, UPLOAD_DOC, CHAT_DAILY,
  /// PARENT_DASHBOARD, CURRICULUM, EXTRA_FREEZE, GROUPS, ADD_STUDENT).
  /// Drives the headline and the recommended tier on the plans screen.
  final String? feature;

  String _headline(AppLocalizations l) => switch (feature) {
        'CREATE_TUTOR' => l.paywallHeadCreateTutor(l.mascotName),
        'UPLOAD_DOC' => l.paywallHeadUpload,
        'CHUNK_COMPILE' => l.paywallHeadCompile,
        'CHAT_DAILY' => l.paywallHeadChat,
        'PARENT_DASHBOARD' => l.paywallHeadParent,
        'CURRICULUM' => l.paywallHeadCurriculum,
        'EXTRA_FREEZE' => l.paywallHeadFreeze,
        'GROUPS' => l.paywallHeadGroups,
        'ADD_STUDENT' => l.paywallHeadAddStudent,
        _ => l.paywallHeadDefault,
      };

  String _subhead(AppLocalizations l) => switch (feature) {
        'CREATE_TUTOR' => l.paywallSubCreateTutor(l.mascotName),
        'UPLOAD_DOC' => l.paywallSubUpload(l.mascotName),
        'CHUNK_COMPILE' => l.paywallSubCompile(l.mascotName),
        'CHAT_DAILY' => l.paywallSubChat,
        'PARENT_DASHBOARD' => l.paywallSubParent,
        'CURRICULUM' => l.paywallSubCurriculum,
        'EXTRA_FREEZE' => l.paywallSubFreeze,
        'GROUPS' => l.paywallSubGroups,
        'ADD_STUDENT' => l.paywallSubAddStudent,
        _ => l.paywallSubDefault(l.mascotName),
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.text2),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/progress');
            }
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, 0, AppSpacing.lg, 0),
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.md),
                    if (feature == 'CREATE_TUTOR')
                      Image.asset('assets/images/mochi.png',
                          width: 110, height: 110, fit: BoxFit.contain)
                    else
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.purple, AppColors.purpleC],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: AppColors.purple.withValues(alpha: 0.35),
                                blurRadius: 24),
                          ],
                        ),
                        child: const Center(
                            child: Text('⭐', style: TextStyle(fontSize: 44))),
                      ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(_headline(l10n),
                        style: AppTextStyles.heading1,
                        textAlign: TextAlign.center),
                    const SizedBox(height: AppSpacing.sm),
                    Text(_subhead(l10n),
                        style:
                            AppTextStyles.body.copyWith(color: AppColors.text2),
                        textAlign: TextAlign.center),
                    const SizedBox(height: AppSpacing.lg),
                    const _PremiumPerks(),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton(
                    onPressed: () {
                      final highlight = _highlightTierForFeature(feature);
                      if (highlight != null) {
                        context.push(
                            '/subscription/plans?highlightTier=$highlight');
                      } else {
                        context.push('/subscription/plans');
                      }
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.purple,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(l10n.paywallSeePlans),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        } else {
                          context.go('/progress');
                        }
                      },
                      child: Text(l10n.paywallMaybeLater),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumPerks extends StatelessWidget {
  const _PremiumPerks();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final perks = [
      ('🧠', l.paywallPerk1(l.mascotName)),
      ('💬', l.paywallPerk2),
      ('👨‍👩‍👧', l.paywallPerk3),
      ('📊', l.paywallPerk4),
      ('🔥', l.paywallPerk5),
    ];
    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        children: perks
            .map((p) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Text(p.$1, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(child: Text(p.$2, style: AppTextStyles.body)),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }
}
