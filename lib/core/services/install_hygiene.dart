import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pally/core/utils/logger.dart';

/// SharedPreferences marker proving this install has launched at least once.
/// SharedPreferences is cleared on uninstall on BOTH iOS and Android, so its
/// absence means "first launch of a fresh install".
const _installMarkerKey = 'secure_storage_install_marker_v1';

/// iOS Keychain (and thus flutter_secure_storage on iOS) SURVIVES app
/// uninstall — Android's keystore does not. So a reinstall can silently
/// resurrect the previous install's stored session (auth token, biometric
/// secret) into a brand-new install, logging the device into a stale identity
/// the user never re-authenticated.
///
/// On the FIRST launch after install — detected by the absence of the
/// SharedPreferences marker above, which uninstall DOES clear — wipe secure
/// storage before any token is read, then set the marker. Every later launch
/// is a no-op, so a live session is never disturbed.
///
/// Returns true iff it performed a wipe (the first launch). Must be awaited in
/// bootstrap BEFORE the auth session is restored from secure storage.
Future<bool> wipeSecureStorageOnFirstLaunch({
  required SharedPreferences prefs,
  // Injectable so the flag logic is unit-testable without the platform channel.
  Future<void> Function()? wipe,
}) async {
  if (prefs.getBool(_installMarkerKey) ?? false) {
    return false; // not the first launch — leave the live session intact
  }

  final doWipe = wipe ?? () => const FlutterSecureStorage().deleteAll();
  try {
    await doWipe();
    appLog.i('[InstallHygiene] First launch after install — wiped secure storage '
        '(iOS Keychain can outlive uninstall)');
  } catch (e) {
    // Best-effort: a wipe failure must never brick startup. We still set the
    // marker so we don't loop-wipe on every launch; worst case a stale item
    // survives this one launch (the server session epoch is the backstop).
    appLog.w('[InstallHygiene] secure-storage wipe failed (non-fatal): $e');
  }
  await prefs.setBool(_installMarkerKey, true);
  return true;
}
