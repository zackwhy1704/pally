import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pally/core/services/fcm_token_service.dart';

class _MockDio extends Mock implements Dio {}

void main() {
  group('FcmTokenService', () {
    test('creates without error', () {
      final dio = _MockDio();
      final service = FcmTokenService(dio);
      expect(service, isNotNull);
    });

    test('registerToken catches errors gracefully', () async {
      // FcmTokenService.registerToken calls FirebaseMessaging.instance which
      // is a platform call. In test, it will throw a MissingPluginException.
      // The service catches all errors, so this should not throw.
      final dio = _MockDio();
      final service = FcmTokenService(dio);

      // Should not throw — the try/catch in registerToken handles the error.
      await expectLater(service.registerToken(), completes);
    });
  });
}
