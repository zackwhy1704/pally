import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/services/notification_service.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/utils/device_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pally/features/auth/auth_state.dart';
import 'package:pally/features/auth/services/auth_service.dart';

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
    if (value) {
      try {
        final authenticated = await _localAuth.authenticate(
          localizedReason: 'Verify to enable biometric login',
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Biometric login enabled'),
              backgroundColor: AppColors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Could not enable biometric login'),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Biometric login disabled'),
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Name updated!'),
            backgroundColor: AppColors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } on DioException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save name — check your connection'),
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out?'),
        content: const Text("You'll need to sign in again"),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => ctx.pop(true),
            child: const Text('Sign Out',
                style: TextStyle(color: AppColors.coral)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await AuthService.instance.signOut();
    if (mounted) context.go('/auth/signin');
  }

  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text(
          'This will permanently delete your account and all your tutors. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => ctx.pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.coral),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      final dio = ref.read(dioProvider);
      await dio.delete<void>('/api/v1/auth/account');
      await AuthService.instance.signOut();
      if (mounted) context.go('/auth/signin');
    } on DioException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not delete account — try again later'),
            backgroundColor: AppColors.coral,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: Text('Settings', style: AppTextStyles.title),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          const _SectionHeader(title: 'Profile'),
          _SettingsCard(
            children: [
              _TextFieldTile(
                label: 'Display Name',
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
                          : Text('Save',
                              style: AppTextStyles.label
                                  .copyWith(color: Colors.white)),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const _SectionHeader(title: 'Notifications'),
          _SettingsCard(
            children: [
              _SwitchTile(
                icon: Icons.notifications_outlined,
                label: 'Daily quiz reminder',
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
                  label: 'Reminder time',
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
          const _SectionHeader(title: 'Security'),
          _SettingsCard(
            children: [
              _SwitchTile(
                icon: Icons.fingerprint_rounded,
                label: 'Biometric Login',
                subtitle: _biometricSupported
                    ? null
                    : 'Not available on this device',
                value: _biometricEnabled,
                onChanged: _biometricSupported ? _toggleBiometric : null,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const _SectionHeader(title: 'About'),
          _SettingsCard(
            children: [
              const _InfoTile(
                icon: Icons.info_outline_rounded,
                label: 'Version',
                value: '1.0.0',
              ),
              const Divider(height: 1, color: AppColors.outline),
              _TappableTile(
                icon: Icons.privacy_tip_outlined,
                label: 'Privacy Policy',
                trailing: const Icon(Icons.open_in_new_rounded,
                    size: 16, color: AppColors.text3),
                onTap: () {},
              ),
              const Divider(height: 1, color: AppColors.outline),
              _TappableTile(
                icon: Icons.help_outline_rounded,
                label: 'Help & Support',
                trailing: const Icon(Icons.open_in_new_rounded,
                    size: 16, color: AppColors.text3),
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const _SectionHeader(title: 'Account'),
          _SettingsCard(
            children: [
              _TappableTile(
                icon: Icons.logout_rounded,
                label: 'Sign Out',
                trailing: const Icon(Icons.chevron_right_rounded,
                    size: 20, color: AppColors.text3),
                onTap: _confirmSignOut,
                labelColor: AppColors.coral,
              ),
              const Divider(height: 1, color: AppColors.outline),
              _TappableTile(
                icon: Icons.delete_outline_rounded,
                label: 'Delete Account',
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
          Text(value,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.text3)),
        ],
      ),
    );
  }
}
