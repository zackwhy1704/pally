import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/shared/models/avatar.dart';

/// Runtime configuration for a single avatar's centre-mode behaviour.
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

/// Resolves the [CentreModeConfig] for [avatar].
///
/// Centre mode is active when EITHER:
///   1. `avatar.centreManaged` — the legacy server flag set when a centre
///      provisions a branded avatar, OR
///   2. `avatar.kind == AvatarKind.centreClass` — the avatar belongs to a
///      centre CLASS (a student's per-class avatar or the hidden class corpus).
///      These are filled by the teacher/centre, so students must not upload,
///      teach, or delete them.
///
/// Either signal alone locks the avatar down. Personal avatars
/// (centreManaged == false AND kind == personal) return [CentreModeConfig.inactive].
CentreModeConfig resolveCentreMode(WidgetRef ref, Avatar avatar) {
  final isClass = avatar.kind == AvatarKind.centreClass;
  if (!avatar.centreManaged && !isClass) return CentreModeConfig.inactive;
  return CentreModeConfig(
    active: true,
    brandName: avatar.centreBrandName ?? CentreModeConfig._defaultBrand,
    centreId: avatar.centreId,
    accentColorHex: avatar.centreAccentColor,
  );
}

