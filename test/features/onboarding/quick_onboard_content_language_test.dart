import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/onboarding/presentation/direct_onboarding_view_model.dart';

/// Pins the zh-audit-round-4 Phase A2 fix: quickOnboard() — the PRIMARY
/// signup path virtually every user takes — previously sent NO
/// contentLanguage at all, so every default avatar it created was 'en'
/// regardless of the signup UI's language. Workstream 1 only fixed the
/// SECONDARY create_tutor wizard; this is the path that actually matters
/// most.
///
/// Tests the request-body-building function directly (no Dio, no network) —
/// quickOnboard() constructs its OWN unauthenticated Dio inline (deliberately,
/// since the user isn't signed in yet), so the shape of what it sends is
/// tested in isolation from that network plumbing.
void main() {
  group('quickOnboardRequestBody', () {
    test('includes contentLanguage sourced from the caller (the UI locale)', () {
      final body = quickOnboardRequestBody(
        email: 'kid@test.com',
        password: 'password123',
        displayName: 'Kid',
        subject: 'MATHS',
        level: 'primary',
        birthYear: 2013,
        parentEmail: null,
        contentLanguage: 'zh',
      );

      expect(body['contentLanguage'], 'zh');
    });

    test('en UI locale sends contentLanguage: en (byte-identical-en path)', () {
      final body = quickOnboardRequestBody(
        email: 'kid@test.com',
        password: 'password123',
        displayName: 'Kid',
        subject: 'MATHS',
        level: 'primary',
        birthYear: 2013,
        parentEmail: null,
        contentLanguage: 'en',
      );

      expect(body['contentLanguage'], 'en');
      // Every other field unchanged from the pre-fix shape.
      expect(body['email'], 'kid@test.com');
      expect(body['subject'], 'MATHS');
      expect(body.containsKey('parentEmail'), isFalse);
    });

    test('under-13 path still carries parentEmail alongside contentLanguage', () {
      final body = quickOnboardRequestBody(
        email: 'child@test.com',
        password: 'password123',
        displayName: 'Child',
        subject: 'MATHS',
        level: 'primary',
        birthYear: 2018,
        parentEmail: 'parent@test.com',
        contentLanguage: 'zh',
      );

      expect(body['parentEmail'], 'parent@test.com');
      expect(body['contentLanguage'], 'zh');
    });

    test('13+ path omits parentEmail entirely (not sent as null)', () {
      final body = quickOnboardRequestBody(
        email: 'kid@test.com',
        password: 'password123',
        displayName: 'Kid',
        subject: 'MATHS',
        level: 'primary',
        birthYear: 2010,
        parentEmail: null,
        contentLanguage: 'en',
      );

      expect(body.containsKey('parentEmail'), isFalse);
    });
  });
}
