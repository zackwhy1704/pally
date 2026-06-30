import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_sizing.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/features/subscription/entitlement_provider.dart';
import 'package:pally/features/subscription/subscription_service.dart';
import 'package:pally/features/subscription/web_billing.dart';

/// The ONE informational upgrade surface. Purchasing is web-only, so this never
/// starts a payment in the app:
///
/// • **iOS** — App Store anti-steering: show the web address as selectable text
///   with a "Copy link" button (copying is an in-app action, not an external
///   launch). NO tappable "open browser" button.
/// • **Android / other** — additionally offer a "Continue on web" button that
///   opens the SYSTEM browser (not an in-app WebView) to the same page.
///
/// Both platforms get an "I've upgraded — refresh" action that silently polls
/// the backend entitlement; once the web purchase's webhook lands, the watching
/// screen flips to premium on its own.
const String _defaultIntro =
    'Subscriptions are managed on the Apalchi website. Sign in with the same '
    'account to upgrade — your app unlocks automatically.';

class WebUpgradeCta extends ConsumerStatefulWidget {
  const WebUpgradeCta({
    super.key,
    this.url = kWebBillingUrl,
    this.displayUrl = kWebBillingDisplay,
    this.intro = _defaultIntro,
    this.launchLabel = 'Continue on web',
    this.showRefresh = true,
  });

  /// Destination opened/copied. Defaults to the public checkout entry; pass
  /// [kWebAccountUrl] for the manage-subscription variant.
  final String url;
  final String displayUrl;
  final String intro;
  final String launchLabel;

  /// Whether to show the "I've upgraded — refresh" poll action. True for the
  /// upgrade flow, false for manage (nothing to unlock).
  final bool showRefresh;

  @override
  ConsumerState<WebUpgradeCta> createState() => _WebUpgradeCtaState();
}

class _WebUpgradeCtaState extends ConsumerState<WebUpgradeCta> {
  bool _copied = false;
  bool _launching = false;
  bool _refreshing = false;
  String? _statusMsg; // persistent inline message (not a toast)

  Future<void> _copyLink() async {
    await Clipboard.setData(ClipboardData(text: widget.url));
    if (!mounted) return;
    setState(() {
      _copied = true;
      _statusMsg = null;
    });
  }

  Future<void> _continueOnWeb() async {
    if (_launching) return; // re-entry guard
    setState(() {
      _launching = true;
      _statusMsg = null;
    });
    try {
      final opened =
          await ref.read(subscriptionServiceProvider).launchExternal(widget.url);
      if (!mounted) return;
      if (!opened) {
        setState(() => _statusMsg =
            "Couldn't open your browser. Tap “Copy link” above and paste it.");
      }
    } finally {
      if (mounted) setState(() => _launching = false);
    }
  }

  Future<void> _refresh() async {
    if (_refreshing) return; // re-entry guard
    setState(() {
      _refreshing = true;
      _statusMsg = null;
    });
    try {
      final becamePremium =
          await ref.read(entitlementVmProvider.notifier).pollUntilPremium();
      if (!mounted) return;
      // On success the parent screen (watching entitlement) rebuilds into its
      // premium state, so we only need to message the not-yet case.
      if (!becamePremium) {
        setState(() => _statusMsg =
            'Not active yet. Finish checkout in your browser, then tap again.');
      }
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.intro,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.text2),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),

        // Selectable, copiable address (the only purchase affordance on iOS).
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.surf2,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.outline),
          ),
          child: Row(
            children: [
              const Icon(Icons.link_rounded, size: 18, color: AppColors.text2),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: SelectableText(
                  widget.displayUrl,
                  style: AppTextStyles.body
                      .copyWith(fontWeight: FontWeight.w700, color: AppColors.text1),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              TextButton(
                onPressed: _copyLink,
                child: Text(_copied ? 'Copied' : 'Copy link',
                    style: AppTextStyles.label.copyWith(
                      color: _copied ? AppColors.green : AppColors.purple,
                    )),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Android (and host): a real one-tap launch. Hidden on iOS, where a
        // tappable external-purchase button violates App Store 3.1.1.
        if (!Platform.isIOS) ...[
          FilledButton(
            onPressed: _launching ? null : _continueOnWeb,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.purple,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: _launching
                ? const SizedBox(
                    height: AppSizing.spinnerSm,
                    width: AppSizing.spinnerSm,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : Text(widget.launchLabel),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],

        // After paying on the web, let the user pull their unlock immediately
        // rather than waiting for the next app-resume.
        if (widget.showRefresh)
        TextButton(
          onPressed: _refreshing ? null : _refresh,
          child: _refreshing
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: AppSizing.spinnerSm,
                      width: AppSizing.spinnerSm,
                      child: CircularProgressIndicator(
                          color: AppColors.purple, strokeWidth: 2),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text('Checking…',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.text2)),
                  ],
                )
              : Text("I've upgraded — refresh",
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.purple)),
        ),

        if (_statusMsg != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            _statusMsg!,
            style: AppTextStyles.caption.copyWith(color: AppColors.coral),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
