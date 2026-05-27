import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

class DeviceInfo {
  static const _storage = FlutterSecureStorage();
  static const _keyDeviceId = 'device_stable_id';

  static Future<String> getStableDeviceId() async {
    final existing = await _storage.read(key: _keyDeviceId);
    if (existing != null) return existing;

    String? hardwareId;
    try {
      final info = DeviceInfoPlugin();
      if (Platform.isIOS) {
        hardwareId = (await info.iosInfo).identifierForVendor;
      } else if (Platform.isAndroid) {
        hardwareId = (await info.androidInfo).id;
      }
    } catch (_) {}

    final id = hardwareId ?? const Uuid().v4();
    await _storage.write(key: _keyDeviceId, value: id);
    return id;
  }

  static Future<String> getDeviceName() async {
    try {
      final info = DeviceInfoPlugin();
      if (Platform.isIOS) {
        return (await info.iosInfo).name;
      } else if (Platform.isAndroid) {
        final a = await info.androidInfo;
        return '${a.manufacturer} ${a.model}';
      }
    } catch (_) {}
    return 'Unknown device';
  }
}
