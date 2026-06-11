import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:pally/core/utils/logger.dart';

/// Registers the device FCM token with the backend so the server can send
/// push notifications. Call [registerToken] fire-and-forget after login.
class FcmTokenService {
  FcmTokenService(this._dio);
  final Dio _dio;

  Future<void> registerToken() async {
    try {
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        appLog.w('[FCM] Permission denied');
        return;
      }
      final token = await messaging.getToken();
      if (token == null) return;
      await _dio.post(
        '/api/v1/account/fcm-token',
        data: {'token': token},
      );
      appLog.i(
        '[FCM] Token registered: ${token.substring(0, 20)}...',
      );
      messaging.onTokenRefresh.listen((t) {
        _dio.post('/api/v1/account/fcm-token', data: {'token': t});
        appLog.d('[FCM] Token refreshed');
      });
    } catch (e, st) {
      appLog.w('[FCM] Token registration failed', error: e, stackTrace: st);
    }
  }
}
