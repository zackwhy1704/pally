import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/core/services/feature_flags.dart';
import 'package:pally/shared/models/avatar.dart';

/// Runtime configuration for a single avatar's centre-mode behaviour.
///
/// Derives from two sources (both must agree):
///   1. `avatar.centreManaged` — set server-side when a centre provisions
///      this avatar. This is the production truth.
///   2. `centreModeDemoOverrideProvider` — an admin-only in-memory toggle
///      so an admin can preview the locked-down experience without a real
///      enrolment. Non-admins who somehow flip this provider get `active=false`
///      because `isFlagEnabled(ref, FeatureFlags.isAdmin)` must also be true.
class CentreModeConfig {
  const CentreModeConfig({
    required this.active,
    required this.brandName,
    this.centreId,
    this.accentColorHex,
  });

  final bool active;
  final String brandName;
  final String? centreId;

  /// Optional hex string (e.g. "#7042ED"). Null → callers fall back to
  /// AppColors.purple. Does NOT include # validation — treat as opaque display hint.
  final String? accentColorHex;

  bool get canUpload => !active;
  bool get canTeach => !active;
  bool get canDelete => !active;
  bool get closedBook => active;

  static const _defaultBrand = 'ABC Mochi';

  static const inactive = CentreModeConfig(
    active: false,
    brandName: '',
  );
}

/// Admin-only demo override. Backed by plain [StateProvider] so it
/// resets on hot-restart (intentional — demo state should not persist).
/// Only effective when `isFlagEnabled(ref, FeatureFlags.isAdmin)` is true;
/// non-admin callers of [resolveCentreMode] always get `active=false`.
final centreModeDemoOverrideProvider = StateProvider<bool>((ref) => false);

/// Resolves the [CentreModeConfig] for [avatar].
///
/// Only looks at `avatar.centreManaged` — this is the server truth for real
/// centre avatars. Personal avatars always return [CentreModeConfig.inactive].
/// The admin demo toggle is handled separately via [showDemoCentreCard].
CentreModeConfig resolveCentreMode(WidgetRef ref, Avatar avatar) {
  if (!avatar.centreManaged) return CentreModeConfig.inactive;
  return CentreModeConfig(
    active: true,
    brandName: avatar.centreBrandName ?? CentreModeConfig._defaultBrand,
    centreId: avatar.centreId,
    accentColorHex: avatar.centreAccentColor,
  );
}

/// Returns true when an admin has the demo toggle on.
/// Used to inject a FAKE centre Mochi card into the avatar list so the admin
/// can preview the extra card without a real centre enrolment. Never affects
/// real/existing avatar cards.
bool showDemoCentreCard(WidgetRef ref) {
  final isAdmin = isFlagEnabled(ref, FeatureFlags.isAdmin);
  final demoOn = ref.watch(centreModeDemoOverrideProvider);
  return isAdmin && demoOn;
}
