import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/utils/logger.dart';

/// Compares two dot-separated version strings ("1.2.0" vs "1.10.3").
/// Returns negative if a < b, 0 if equal, positive if a > b. Missing segments are
/// treated as 0; build (`+1`) and pre-release (`-beta`) suffixes are dropped.
/// Pure + unit-testable.
int compareSemver(String a, String b) {
  final pa = _parts(a);
  final pb = _parts(b);
  final len = pa.length > pb.length ? pa.length : pb.length;
  for (var i = 0; i < len; i++) {
    final x = i < pa.length ? pa[i] : 0;
    final y = i < pb.length ? pb[i] : 0;
    if (x != y) return x < y ? -1 : 1;
  }
  return 0;
}

List<int> _parts(String v) {
  final core = v.split(RegExp(r'[+\-]')).first.trim();
  return core.split('.').map((s) => int.tryParse(s.trim()) ?? 0).toList();
}

/// True when [current] is strictly below [minimum].
bool isUpdateRequired(String current, String minimum) =>
    compareSemver(current, minimum) < 0;

/// Checks the backend's minimum supported version for this platform against the
/// running app version. FAILS OPEN: any error (offline, timeout, parse, no
/// package info) returns false, so a backend blip never locks users out.
final forceUpdateProvider = FutureProvider<bool>((ref) async {
  try {
    final info = await PackageInfo.fromPlatform();
    final current = info.version; // e.g. "1.0.0"

    final dio = ref.read(dioProvider);
    final res = await dio.get<Map<String, dynamic>>(
      '/api/v1/app/min-version',
      options: Options(receiveTimeout: const Duration(seconds: 3)),
    );
    // The Dio interceptor unwraps ApiResponse → the data map is returned directly.
    final data = res.data;
    if (data == null) return false;
    final key = Platform.isIOS ? 'ios' : 'android';
    final minVersion = data[key] as String?;
    if (minVersion == null || minVersion.isEmpty) return false;

    final required = isUpdateRequired(current, minVersion);
    if (required) {
      appLog.w('[VersionGate] update required: current=$current min=$minVersion');
    }
    return required;
  } catch (e) {
    appLog.w('[VersionGate] check failed (fail-open): $e');
    return false;
  }
});
