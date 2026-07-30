import 'dart:io' show Platform;

import 'package:dio/dio.dart' show DioException;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_sizing.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/services/feature_flags.dart';
import 'package:pally/features/subscription/entitlement_provider.dart';
import 'package:pally/features/subscription/subscription_service.dart';
import 'package:pally/features/subscription/web_billing.dart';
import 'package:pally/l10n/app_localizations.dart';

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
class WebUpgradeCta extends ConsumerStatefulWidget {
  const WebUpgradeCta({
    super.key,
    this.url = kWebBillingUrl,
    this.displayUrl = kWebBillingDisplay,
    this.intro,
    this.launchLabel,
    this.showRefresh = true,
    this.showEmailLink = true,
  });

  /// Destination opened/copied. Defaults to the public checkout entry; pass
  /// [kWebAccountUrl] for the manage-subscription variant.
  final String url;
  final String displayUrl;
  // Null → the localized default is resolved at render (this widget must not
  // bake English defaults into a const constructor). Callers pass a localized
  // override (e.g. the manage variant) resolved at their own call site.
  final String? intro;
  final String? launchLabel;

  /// Whether to show the "I've upgraded — refresh" poll action. True for the
  /// upgrade flow, false for manage (nothing to unlock).
  final bool showRefresh;

  /// Whether to show "Email me the link" (emails + pushes the billing link).
  /// True for the upgrade flow; false for the manage variant.
  final bool showEmailLink;

  @override
  ConsumerState<WebUpgradeCta> createState() => _WebUpgradeCtaState();
}

class _WebUpgradeCtaState extends ConsumerState<WebUpgradeCta> {
  bool _copied = false;
  bool _launching = false;
  bool _refreshing = false;
  bool _emailing = false;
  String? _statusMsg; // persistent inline message (not a toast)
  String? _emailMsg; // persistent result of the "Email me the link" action
  bool _emailOk = false; // colours _emailMsg green on success, coral on error

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
    final l10n = AppLocalizations.of(context);
    setState(() {
      _launching = true;
      _statusMsg = null;
    });
    try {
      final opened =
          await ref.read(subscriptionServiceProvider).launchExternal(widget.url);
      if (!mounted) return;
      if (!opened) {
        setState(() => _statusMsg = l10n.webCtaCouldntOpenBrowser);
      }
    } finally {
      if (mounted) setState(() => _launching = false);
    }
  }

  Future<void> _sendEmailLink() async {
    if (_emailing) return; // re-entry guard
    final l10n = AppLocalizations.of(context);
    setState(() {
      _emailing = true;
      _emailMsg = null;
      _statusMsg = null;
    });
    try {
      final result = await ref.read(upgradeLinkSenderProvider).send();
      if (!mounted) return;
      setState(() {
        _emailOk = result.anySent;
        if (!result.anySent) {
          _emailMsg = l10n.webCtaEmailFailNow;
        } else if (result.emailSent && result.pushSent) {
          _emailMsg = l10n.webCtaEmailBothSent;
        } else if (result.emailSent) {
          _emailMsg = l10n.webCtaEmailSent;
        } else {
          _emailMsg = l10n.webCtaPushSent;
        }
      });
    } on DioException catch (e) {
      if (!mounted) return;
      final tooMany = e.response?.statusCode == 429;
      setState(() {
        _emailOk = false;
        _emailMsg = tooMany
            ? l10n.webCtaRateLimited
            : l10n.webCtaEmailError;
      });
    } finally {
      if (mounted) setState(() => _emailing = false);
    }
  }

  Future<void> _refresh() async {
    if (_refreshing) return; // re-entry guard
    final l10n = AppLocalizations.of(context);
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
        setState(() => _statusMsg = l10n.webCtaNotActiveYet);
      }
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // On iOS the one-tap launch is hidden (App Store 3.1.1) UNTIL Apple grants
    // the External Link Account Entitlement, at which point the server flips
    // ios_external_link_enabled and the button appears. Android/host always show it.
    final allowLaunch = !Platform.isIOS ||
        isFlagEnabled(ref, FeatureFlags.iosExternalLinkEnabled);
    final l10n = AppLocalizations.of(context);
    final intro = widget.intro ?? l10n.webCtaDefaultIntro;
    final launchLabel = widget.launchLabel ?? l10n.webCtaContinueOnWeb;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          intro,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.text2),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),

        // Selectable, copiable web address. Shown ONLY where a launch is allowed
        // (Android/host, or iOS once the External Link Account Entitlement is
        // granted via ios_external_link_enabled). On iOS without the entitlement
        // we must not surface ANY web-billing URL — App Store 3.1.1 anti-steering
        // — so the email button below is the sole continue affordance.
        if (allowLaunch) ...[
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
                const Icon(Icons.link_rounded,
                    size: 18, color: AppColors.text2),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: SelectableText(
                    widget.displayUrl,
                    style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w700, color: AppColors.text1),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                TextButton(
                  onPressed: _copyLink,
                  child: Text(_copied ? l10n.webCtaCopied : l10n.webCtaCopyLink,
                      style: AppTextStyles.label.copyWith(
                        color: _copied ? AppColors.green : AppColors.purple,
                      )),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],

        // Send the billing link to email + a push notification. Works on every
        // platform (a network action, not an external launch) so it's the
        // primary continue affordance on iOS, where the launch button is hidden.
        if (widget.showEmailLink) ...[
          OutlinedButton.icon(
            onPressed: _emailing ? null : _sendEmailLink,
            icon: _emailing
                ? const SizedBox(
                    height: AppSizing.spinnerSm,
                    width: AppSizing.spinnerSm,
                    child: CircularProgressIndicator(
                        color: AppColors.purple, strokeWidth: 2),
                  )
                : const Icon(Icons.mail_outline_rounded, size: 18),
            label: Text(_emailing ? l10n.webCtaSending : l10n.webCtaEmailLink),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.purple,
              side: const BorderSide(color: AppColors.outline),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          if (_emailMsg != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              _emailMsg!,
              style: AppTextStyles.caption.copyWith(
                  color: _emailOk ? AppColors.green : AppColors.coral),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
        ],

        // Android (and host): a real one-tap launch. Hidden on iOS unless the
        // Apple External Link Account Entitlement has been granted (gated by the
        // ios_external_link_enabled server flag), since otherwise a tappable
        // external-purchase button violates App Store 3.1.1.
        if (allowLaunch) ...[
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
                : Text(launchLabel),
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
                    Text(l10n.webCtaChecking,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.text2)),
                  ],
                )
              : Text(l10n.webCtaUpgradedRefresh,
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
