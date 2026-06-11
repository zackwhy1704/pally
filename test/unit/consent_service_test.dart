import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/consent/data/consent_service.dart';

void main() {
  group('ConsentService.parseAiConsentGranted', () {
    test('reads aiDataTransfer=true from an unwrapped object', () {
      expect(
        ConsentService.parseAiConsentGranted({'aiDataTransfer': true}),
        isTrue,
      );
    });

    test('reads aiConsent=false', () {
      expect(
        ConsentService.parseAiConsentGranted({'aiConsent': false}),
        isFalse,
      );
    });

    test('unwraps a still-enveloped ApiResponse payload', () {
      expect(
        ConsentService.parseAiConsentGranted({
          'data': {'aiDataTransferConsent': true},
        }),
        isTrue,
      );
    });

    test('treats "granted" string as true and "pending" as false', () {
      expect(
        ConsentService.parseAiConsentGranted({'aiConsent': 'granted'}),
        isTrue,
      );
      expect(
        ConsentService.parseAiConsentGranted({'aiConsent': 'pending'}),
        isFalse,
      );
    });

    test('defaults to false when the field is absent or body is null', () {
      expect(ConsentService.parseAiConsentGranted({'other': 1}), isFalse);
      expect(ConsentService.parseAiConsentGranted(null), isFalse);
      expect(ConsentService.parseAiConsentGranted('nope'), isFalse);
    });
  });
}
