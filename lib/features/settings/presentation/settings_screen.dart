import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/i18n/app_languages.dart';
import 'package:pally/core/i18n/locale_controller.dart';
import 'package:pally/core/services/notification_service.dart';
import 'package:pally/core/services/feature_flags.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/utils/device_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pally/features/auth/auth_state.dart';
import 'package:pally/features/auth/services/auth_service.dart';
import 'package:pally/features/referral/referral_service.dart';
import 'package:pally/features/subscription/entitlement_provider.dart';
import 'package:pally/features/subscription/trial_status_provider.dart';
import 'package:pally/core/ui/pally_toast.dart';
import 'package:pally/shared/models/entitlement.dart';
import 'package:pally/features/home/widgets/how_pally_is_different.dart';
import 'package:pally/features/settings/presentation/learning_style_screen.dart';
import 'package:pally/features/settings/widgets/language_picker_sheet.dart';
import 'package:pally/l10n/app_localizations.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late final TextEditingController _nameController;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 18, minute: 0);
  bool _dailyReminder = true;
  bool _savingName = false;
  bool _biometricEnabled = false;
  bool _biometricSupported = true;
  final _localAuth = LocalAuthentication();
  String _versionLabel = '—';

  static const _kReminderEnabled = 'settings_daily_reminder_enabled';
  static const _kReminderHour = 'settings_daily_reminder_hour';
  static const _kReminderMinute = 'settings_daily_reminder_minute';

  @override
  void initState() {
    super.initState();
    final childName = ref.read(authStateProvider).childName ?? '';
    _nameController = TextEditingController(text: childName);
    _loadBiometricState();
    _loadReminderSettings();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!mounted) return;
      // Apple/industry-standard "version (build)" — never the raw Flutter "1.0.1+5".
      setState(() => _versionLabel = '${info.version} (${info.buildNumber})');
    } catch (_) {
      // Leave the placeholder — a missing version string is not worth surfacing.
    }
  }

  Future<void> _loadReminderSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _dailyReminder = prefs.getBool(_kReminderEnabled) ?? true;
      _reminderTime = TimeOfDay(
        hour: prefs.getInt(_kReminderHour) ?? 18,
        minute: prefs.getInt(_kReminderMinute) ?? 0,
      );
    });
  }

  Future<void> _persistReminderEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kReminderEnabled, enabled);
    if (enabled) {
      await NotificationService.scheduleDailyQuizReminder(
          _reminderTime.hour, _reminderTime.minute);
    } else {
      await NotificationService.cancelDailyQuizReminder();
    }
  }

  Future<void> _persistReminderTime(TimeOfDay t) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kReminderHour, t.hour);
    await prefs.setInt(_kReminderMinute, t.minute);
    if (_dailyReminder) {
      await NotificationService.scheduleDailyQuizReminder(t.hour, t.minute);
    }
  }

  Future<void> _loadBiometricState() async {
    final supported = await _deviceSupportsBiometrics();
    final registered = await AuthNotifier.instance.isBiometricRegistered();
    if (mounted) {
      setState(() {
        _biometricSupported = supported;
        _biometricEnabled = registered && supported;
      });
    }
  }

  Future<bool> _deviceSupportsBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics &&
          await _localAuth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    final l = AppLocalizations.of(context);
    if (value) {
      try {
        final authenticated = await _localAuth.authenticate(
          localizedReason: l.settingsBiometricReason,
          options: const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: true,
          ),
        );
        if (!authenticated) return;

        final deviceId = await DeviceInfo.getStableDeviceId();
        final deviceName = await DeviceInfo.getDeviceName();
        await AuthService.instance.registerBiometricDevice(
          deviceId: deviceId,
          deviceName: deviceName,
        );
        await AuthNotifier.instance.markBiometricRegistered();
        if (mounted) {
          setState(() => _biometricEnabled = true);
          showAppSnackBar(
            SnackBar(
              content: Text(l.settingsBiometricEnabled),
              backgroundColor: AppColors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      } catch (_) {
        if (mounted) {
          showAppSnackBar(
            SnackBar(
              content: Text(l.settingsBiometricEnableFailed),
              backgroundColor: AppColors.coral,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    } else {
      await AuthNotifier.instance.clearBiometricRegistration();
      if (mounted) {
        setState(() => _biometricEnabled = false);
        showAppSnackBar(
          SnackBar(
            content: Text(l.settingsBiometricDisabled),
            backgroundColor: AppColors.text2,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveDisplayName() async {
    final l = AppLocalizations.of(context);
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    setState(() => _savingName = true);
    try {
      final dio = ref.read(dioProvider);
      await dio.patch<void>(
        '/api/v1/auth/setup',
        data: {'childName': name},
      );
      await AuthNotifier.instance.setChildName(name);
      if (mounted) {
        showAppSnackBar(
          SnackBar(
            content: Text(l.settingsNameUpdated),
            backgroundColor: AppColors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } on DioException {
      if (mounted) {
        showAppSnackBar(
          SnackBar(
            content: Text(l.settingsNameSaveFailed),
            backgroundColor: AppColors.coral,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _savingName = false);
    }
  }

  Future<void> _confirmSignOut() async {
    final l = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.settingsSignOutTitle),
        content: Text(l.settingsSignOutBody),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(false),
            child: Text(l.commonCancel),
          ),
          TextButton(
            onPressed: () => ctx.pop(true),
            child: Text(l.settingsSignOut,
                style: const TextStyle(color: AppColors.coral)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await AuthService.instance.signOut();
    if (mounted) context.go('/auth/signin');
  }

  /// Opens the re-auth + grace deletion flow. (Replaces the old bearer-only
  /// immediate DELETE /auth/account — now 410 GONE — which purged instantly with
  /// no re-auth and no restore window.)
  void _confirmDeleteAccount() => context.push('/settings/delete-account');

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final currentLang =
        AppLanguages.byCode(ref.watch(localeControllerProvider).languageCode) ??
            AppLanguages.fallback;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: Text(l.settingsTitle, style: AppTextStyles.title),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _SectionHeader(title: l.settingsSectionSubscription),
          const _SubscriptionTile(),
          const SizedBox(height: AppSpacing.md),
          // 'Join a class' tile removed — class/group join lives in the Home
          // empty state and the persistent "Join a class or group" handle on
          // the Me tab. Referral (outbound) stays below; this is its home.
          _SectionHeader(title: l.settingsSectionReferral),
          const _ReferralTile(),
          const SizedBox(height: AppSpacing.md),
          _SectionHeader(title: l.settingsSectionProfile),
          _SettingsCard(
            children: [
              _TextFieldTile(
                label: l.settingsDisplayName,
                controller: _nameController,
                icon: Icons.person_outline_rounded,
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: AppSpacing.md,
                  right: AppSpacing.md,
                  bottom: AppSpacing.sm,
                ),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    height: 34,
                    child: ElevatedButton(
                      onPressed: _savingName ? null : _saveDisplayName,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.purple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        elevation: 0,
                      ),
                      child: _savingName
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : Text(l.settingsSave,
                              style: AppTextStyles.label
                                  .copyWith(color: Colors.white)),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Language (UI chrome). The row shows the current language in its own
          // name; tapping opens the registry-driven picker. This is a different
          // axis from an avatar's teaching language — the picker copy says so.
          _SectionHeader(title: l.language),
          _SettingsCard(
            children: [
              _TappableTile(
                icon: Icons.language_rounded,
                label: currentLang.endonym,
                trailing: const Icon(Icons.chevron_right_rounded,
                    size: 16, color: AppColors.text3),
                onTap: () => LanguagePickerSheet.show(context),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _SectionHeader(title: l.settingsSectionNotifications),
          _SettingsCard(
            children: [
              _SwitchTile(
                icon: Icons.notifications_outlined,
                label: l.settingsDailyReminder,
                value: _dailyReminder,
                onChanged: (v) {
                  setState(() => _dailyReminder = v);
                  _persistReminderEnabled(v);
                },
              ),
              if (_dailyReminder) ...[
                const Divider(height: 1, color: AppColors.outline),
                _TappableTile(
                  icon: Icons.access_time_rounded,
                  label: l.settingsReminderTime,
                  trailing: Text(
                    _reminderTime.format(context),
                    style: AppTextStyles.body
                        .copyWith(color: AppColors.purple),
                  ),
                  onTap: () => _pickTime(context),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _SectionHeader(title: l.settingsSectionSecurity),
          _SettingsCard(
            children: [
              _SwitchTile(
                icon: Icons.fingerprint_rounded,
                label: l.settingsBiometricLogin,
                subtitle: _biometricSupported
                    ? null
                    : l.settingsBiometricUnavailable,
                value: _biometricEnabled,
                onChanged: _biometricSupported ? _toggleBiometric : null,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _SectionHeader(title: l.settingsSectionLearning),
          _SettingsCard(
            children: [
              _TappableTile(
                icon: Icons.school_rounded,
                label: l.settingsLearningStyle,
                trailing: const Icon(Icons.chevron_right_rounded,
                    size: 16, color: AppColors.text3),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const LearningStyleScreen())),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _SectionHeader(title: l.settingsSectionAbout),
          _SettingsCard(
            children: [
              _TappableTile(
                icon: Icons.lightbulb_outline_rounded,
                label: l.settingsWhyDifferent,
                trailing: const Icon(Icons.chevron_right_rounded,
                    size: 16, color: AppColors.text3),
                onTap: () => HowPallyIsDifferent.show(context),
              ),
              const Divider(height: 1, color: AppColors.outline),
              _InfoTile(
                icon: Icons.info_outline_rounded,
                label: l.settingsVersion,
                value: _versionLabel,
              ),
              const Divider(height: 1, color: AppColors.outline),
              _TappableTile(
                icon: Icons.public_rounded,
                label: l.settingsAboutApalchi,
                trailing: const Icon(Icons.open_in_new_rounded,
                    size: 16, color: AppColors.text3),
                onTap: () => launchUrl(
                  Uri.parse('https://apalchi.com'),
                  mode: LaunchMode.externalApplication,
                ),
              ),
              const Divider(height: 1, color: AppColors.outline),
              _TappableTile(
                icon: Icons.privacy_tip_outlined,
                label: l.settingsPrivacyPolicy,
                trailing: const Icon(Icons.open_in_new_rounded,
                    size: 16, color: AppColors.text3),
                onTap: () => launchUrl(
                  Uri.parse('https://apalchi.com/privacy'),
                  mode: LaunchMode.externalApplication,
                ),
              ),
              const Divider(height: 1, color: AppColors.outline),
              _TappableTile(
                icon: Icons.description_outlined,
                label: l.settingsTermsOfService,
                trailing: const Icon(Icons.open_in_new_rounded,
                    size: 16, color: AppColors.text3),
                onTap: () => launchUrl(
                  Uri.parse('https://apalchi.com/terms'),
                  mode: LaunchMode.externalApplication,
                ),
              ),
              const Divider(height: 1, color: AppColors.outline),
              _TappableTile(
                icon: Icons.help_outline_rounded,
                label: l.settingsHelpSupport,
                trailing: const Icon(Icons.open_in_new_rounded,
                    size: 16, color: AppColors.text3),
                onTap: () => launchUrl(
                  Uri.parse('https://apalchi.com/support'),
                  mode: LaunchMode.externalApplication,
                ),
              ),
              const Divider(height: 1, color: AppColors.outline),
              _TappableTile(
                icon: Icons.mail_outline_rounded,
                label: l.settingsEmailUs,
                trailing: const Icon(Icons.open_in_new_rounded,
                    size: 16, color: AppColors.text3),
                onTap: () => launchUrl(
                  Uri.parse('mailto:hello@apalchi.com'),
                  mode: LaunchMode.externalApplication,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _SectionHeader(title: l.settingsSectionAccount),
          _SettingsCard(
            children: [
              _TappableTile(
                icon: Icons.logout_rounded,
                label: l.settingsSignOut,
                trailing: const Icon(Icons.chevron_right_rounded,
                    size: 20, color: AppColors.text3),
                onTap: _confirmSignOut,
                labelColor: AppColors.coral,
              ),
              const Divider(height: 1, color: AppColors.outline),
              _TappableTile(
                icon: Icons.delete_outline_rounded,
                label: l.settingsDeleteAccount,
                trailing: const Icon(Icons.chevron_right_rounded,
                    size: 20, color: AppColors.text3),
                onTap: _confirmDeleteAccount,
                labelColor: AppColors.coral,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.purple,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _reminderTime = picked);
      await _persistReminderTime(picked);
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: AppSpacing.xs, left: AppSpacing.xs),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.label.copyWith(
          letterSpacing: 1.2,
          color: AppColors.text3,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(children: children),
    );
  }
}

class _TextFieldTile extends StatelessWidget {
  const _TextFieldTile({
    required this.label,
    required this.controller,
    required this.icon,
  });

  final String label;
  final TextEditingController controller;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.card,
      child: Row(
        children: [
          Icon(icon, color: AppColors.text2, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.label),
                const SizedBox(height: AppSpacing.xs),
                TextField(
                  controller: controller,
                  style: AppTextStyles.body,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.outline),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.outline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: AppColors.purple, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
    this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final String? subtitle;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final disabled = onChanged == null;
    return Padding(
      padding: AppSpacing.card,
      child: Row(
        children: [
          Icon(icon,
              color: disabled ? AppColors.text3 : AppColors.text2, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTextStyles.body.copyWith(
                        color: disabled ? AppColors.text3 : AppColors.text1)),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(subtitle!,
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.text3)),
                  ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.purple,
          ),
        ],
      ),
    );
  }
}

class _TappableTile extends StatelessWidget {
  const _TappableTile({
    required this.icon,
    required this.label,
    required this.trailing,
    required this.onTap,
    this.labelColor,
  });

  final IconData icon;
  final String label;
  final Widget trailing;
  final VoidCallback onTap;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    final color = labelColor ?? AppColors.text2;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: AppSpacing.card,
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(label,
                  style: AppTextStyles.body.copyWith(color: color)),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.card,
      child: Row(
        children: [
          Icon(icon, color: AppColors.text2, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(label, style: AppTextStyles.body)),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(value,
                style:
                    AppTextStyles.bodySmall.copyWith(color: AppColors.text3),
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

/// Subscription tile shown at the top of Settings. Reads entitlement and
/// either offers an Upgrade CTA (free user) or a Manage button that opens
/// the Stripe Billing Portal (premium user).
class _SubscriptionTile extends ConsumerWidget {
  const _SubscriptionTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final entAsync = ref.watch(entitlementVmProvider);
    return entAsync.when(
      loading: () => _SettingsCard(
        children: [
          ListTile(
            leading: const Icon(Icons.workspace_premium_rounded,
                color: AppColors.purple),
            title: Text(l.settingsSectionSubscription),
            subtitle: Text(l.commonLoading),
          ),
        ],
      ),
      error: (_, __) => _SettingsCard(children: [
          ListTile(
            leading: const Icon(Icons.workspace_premium_rounded, color: AppColors.text3),
            title: Text(l.settingsSectionSubscription),
            subtitle: Text(l.settingsSubLoadError),
          ),
        ]),
      data: (ent) {
        final isPremium = ent.isPremium;
        final isOnTrial = ent.source == 'TRIAL';

        // Trial card (PR5)
        if (isOnTrial) {
          final trialInfo = ref.watch(trialStatusProvider).valueOrNull;
          final days = trialInfo?.trialDaysLeft ?? 0;
          final endsAt = trialInfo?.trialEndsAt;
          final endsLabel = endsAt != null
              ? '${endsAt.day}/${endsAt.month}/${endsAt.year}'
              : '—';
          return _SettingsCard(children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.workspace_premium_rounded,
                        color: AppColors.purple, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                          l.settingsPremiumTrialLeft(days),
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.body
                              .copyWith(fontWeight: FontWeight.w700)),
                    ),
                  ]),
                  const SizedBox(height: 4),
                  Text(l.settingsEndsLabel(endsLabel),
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.text2)),
                  const SizedBox(height: AppSpacing.sm),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: days / 7,
                      minHeight: 6,
                      backgroundColor: AppColors.outline,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.purple),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => context.push('/subscription/plans'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.purple,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding:
                            const EdgeInsets.symmetric(vertical: 10),
                      ),
                      // iOS App Store 3.1.1: no in-app price without the External
                      // Link entitlement. Gate like every sibling surface, and quote
                      // USD to match the plans screen + the actual (USD) charge.
                      child: Text(allowPriceDisplay(ref)
                          ? l.settingsKeepPremiumPrice
                          : l.settingsKeepPremium),
                    ),
                  ),
                ],
              ),
            ),
          ]);
        }

        final planLabel = isPremium
            ? (ent.source == 'PARENT'
                ? l.settingsFamilyPlan
                : prettyTier(ent.plan))
            : l.settingsFreePlan;
        return _SettingsCard(
          children: [
            ListTile(
              leading: const Icon(Icons.workspace_premium_rounded,
                  color: AppColors.purple),
              title: Text(planLabel),
              subtitle: Text(isPremium
                  ? l.settingsPremiumManage
                  : l.settingsFreePlanSubtitle),
              trailing: FilledButton(
                onPressed: () => _onTap(context, ref, ent.isPremium,
                    ent.source == 'PARENT'),
                style: FilledButton.styleFrom(
                  backgroundColor:
                      isPremium ? AppColors.text2 : AppColors.purple,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                ),
                child: Text(isPremium ? l.settingsManage : l.settingsUpgrade),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _onTap(BuildContext context, WidgetRef ref,
      bool isPremium, bool inheritedFromParent) async {
    if (!isPremium) {
      context.push('/subscription/plans');
      return;
    }
    if (inheritedFromParent) {
      PallyToast.success(context,
          AppLocalizations.of(context).settingsManagedByParent);
      return;
    }
    // Premium self-managed users: go to the plans screen which shows their
    // current plan, lets them switch plans, AND has a "Manage billing / Cancel"
    // link to the Stripe portal. Going straight to the portal only is wrong —
    // users must be able to see and change their plan from within the app.
    context.push('/subscription/plans');
  }
}

/// Sanitises error messages before showing them to the user.

/// Settings → Referral section. Two actions: open your own referral page
/// (P-ref) and a prompt to enter someone else's code.
class _ReferralTile extends ConsumerWidget {
  const _ReferralTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return _SettingsCard(
      children: [
        ListTile(
          leading: const Icon(Icons.card_giftcard_rounded,
              color: AppColors.purple),
          title: Text(l.settingsInviteFriends),
          subtitle: Text(l.settingsInviteFriendsSubtitle),
          trailing: const Icon(Icons.chevron_right_rounded,
              color: AppColors.text3),
          onTap: () => context.push('/referral'),
        ),
        const Divider(height: 1, color: AppColors.outline),
        ListTile(
          leading: const Icon(Icons.redeem_rounded,
              color: AppColors.teal),
          title: Text(l.settingsHaveReferralCode),
          subtitle: Text(l.settingsHaveReferralCodeSubtitle),
          trailing: const Icon(Icons.chevron_right_rounded,
              color: AppColors.text3),
          onTap: () => _showRedeemSheet(context, ref),
        ),
      ],
    );
  }

  Future<void> _showRedeemSheet(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final controller = TextEditingController();
    try {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetCtx).viewInsets.bottom),
        child: SafeArea(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(sheetCtx).height * 0.85,
            ),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.settingsEnterReferralCode, style: AppTextStyles.title),
                const SizedBox(height: 4),
                Text(l.settingsShareReward,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.text2)),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: controller,
                  textCapitalization: TextCapitalization.characters,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 6),
                  decoration: InputDecoration(
                    hintText: 'ABCDEF',
                    filled: true,
                    fillColor: AppColors.surf2,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () async {
                      final code = controller.text.trim();
                      if (code.length != 6) {
                        PallyToast.error(
                            sheetCtx, l.settingsCodes6Chars);
                        return;
                      }
                      final err = await ref
                          .read(referralServiceProvider)
                          .redeem(code);
                      if (!sheetCtx.mounted) return;
                      if (err == null) {
                        Navigator.of(sheetCtx).pop();
                        PallyToast.success(context,
                            l.settingsCodeApplied);
                      } else {
                        PallyToast.error(sheetCtx, err);
                      }
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.purple,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(l.settingsApplyCode),
                  ),
                ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    } finally {
      controller.dispose();
    }
  }
}
