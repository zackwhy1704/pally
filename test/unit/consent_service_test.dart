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

  // The authoritative reconcile relies on this parse to drive the gate from
  // server truth (the fix for approved children staying locally gated).
  group('ConsentService.parseConsentStatus', () {
    test('ACTIVE → active, not pending (drives unlock regardless of local flag)', () {
      final s = ConsentService.parseConsentStatus({'accountStatus': 'ACTIVE'});
      expect(s.active, isTrue);
      expect(s.pending, isFalse);
    });

    test('PENDING_CONSENT → pending with the parent email (restores the gate)', () {
      final s = ConsentService.parseConsentStatus({
        'accountStatus': 'PENDING_CONSENT',
        'pendingRequest': {'parentEmail': 'mum@example.com'},
      });
      expect(s.active, isFalse);
      expect(s.pending, isTrue);
      expect(s.parentEmail, 'mum@example.com');
    });

    test('unwraps a still-enveloped ApiResponse payload', () {
      final s = ConsentService.parseConsentStatus({
        'data': {'accountStatus': 'ACTIVE'},
      });
      expect(s.active, isTrue);
    });

    test('null / malformed body → neither active nor pending (safe)', () {
      final s = ConsentService.parseConsentStatus(null);
      expect(s.active, isFalse);
      expect(s.pending, isFalse);
      expect(s.parentEmail, isNull);
    });
  });
}
