import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/auth/auth_state.dart';
import 'package:pally/features/consent/data/consent_service.dart';
import 'package:pally/features/consent/data/consent_unlock.dart';

/// Records fetchStatus calls and returns a canned server status.
class _FakeConsentService extends ConsentService {
  _FakeConsentService(this._status) : super(Dio());
  final ConsentStatus _status;
  int fetchCalls = 0;
  @override
  Future<ConsentStatus> fetchStatus() async {
    fetchCalls++;
    return _status;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // In-memory flutter_secure_storage so AuthNotifier (a singleton) works in tests.
  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  final store = <String, String>{};

  setUp(() {
    store.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      final args = (call.arguments as Map?) ?? {};
      switch (call.method) {
        case 'read':
          return store[args['key']];
        case 'write':
          store[args['key'] as String] = args['value'] as String;
          return null;
        case 'delete':
          store.remove(args['key']);
          return null;
        case 'deleteAll':
          store.clear();
          return null;
        case 'readAll':
          return Map<String, String>.from(store);
        case 'containsKey':
          return store.containsKey(args['key']);
      }
      return null;
    });
  });

  tearDown(() async {
    await AuthNotifier.instance.signOut();
  });

  ProviderContainer containerWith(ConsentService fake) => ProviderContainer(
        overrides: [consentServiceProvider.overrideWith((ref) => fake)],
      );

  test('reconcile() checks the SERVER even when awaitingConsent is false '
      '(closes the resume/desync gap)', () async {
    // Signed in, but the local awaiting-consent flag is FALSE (desynced).
    await AuthNotifier.instance.signIn(userId: 'child-1', token: 'tok');
    expect(AuthNotifier.instance.state.awaitingConsent, isFalse);

    final fake = _FakeConsentService(
        const ConsentStatus(active: true, pending: false));
    final container = containerWith(fake);
    addTearDown(container.dispose);

    await container.read(consentUnlockProvider).reconcile();

    // The OLD flag-gated path would have early-returned without a server call.
    expect(fake.fetchCalls, 1,
        reason: 'reconcile must hit the server regardless of the local flag');
  });

  test('reconcile() RESTORES the gate when the flag is false but server is PENDING',
      () async {
    await AuthNotifier.instance.signIn(userId: 'child-2', token: 'tok');
    expect(AuthNotifier.instance.state.awaitingConsent, isFalse);

    final fake = _FakeConsentService(const ConsentStatus(
        active: false, pending: true, parentEmail: 'mum@example.com'));
    final container = containerWith(fake);
    addTearDown(container.dispose);

    await container.read(consentUnlockProvider).reconcile();

    // Server truth wins: a lost local flag is restored so the gate reappears.
    expect(AuthNotifier.instance.state.awaitingConsent, isTrue);
    expect(AuthNotifier.instance.state.maskedParentEmail, 'mu***@example.com');
  });

  test('reconcile() no-ops when signed out (no server call)', () async {
    final fake = _FakeConsentService(
        const ConsentStatus(active: true, pending: false));
    final container = containerWith(fake);
    addTearDown(container.dispose);

    await container.read(consentUnlockProvider).reconcile();

    expect(fake.fetchCalls, 0);
  });
}
