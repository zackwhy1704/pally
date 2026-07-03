import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/auth/auth_state.dart';

/// The celebration must fire ONLY on a genuine awaiting→approved transition, and
/// exactly once — never on a plain sign-out / state reset. That guard lives in
/// AuthNotifier.clearAwaitingConsent (the single unlock chokepoint).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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

  tearDown(() => AuthNotifier.instance.signOut());

  final auth = AuthNotifier.instance;

  test('gated→approved transition sets the one-shot celebration flag', () async {
    await auth.signIn(userId: 'c1', token: 't');
    await auth.setAwaitingConsent(maskedParentEmail: 'm***@x.com');
    expect(auth.state.justConsentUnlocked, isFalse);

    await auth.clearAwaitingConsent(); // the genuine approval

    expect(auth.state.awaitingConsent, isFalse);
    expect(auth.state.justConsentUnlocked, isTrue);
  });

  test('clearing when NOT awaiting does not fire (no false celebration)', () async {
    await auth.signIn(userId: 'c2', token: 't'); // awaitingConsent already false
    await auth.clearAwaitingConsent();
    expect(auth.state.justConsentUnlocked, isFalse);
  });

  test('consume clears the flag so it fires exactly once', () async {
    await auth.signIn(userId: 'c3', token: 't');
    await auth.setAwaitingConsent(maskedParentEmail: 'm***@x.com');
    await auth.clearAwaitingConsent();
    expect(auth.state.justConsentUnlocked, isTrue);

    auth.consumeConsentCelebration();
    expect(auth.state.justConsentUnlocked, isFalse);
  });

  test('flag is STICKY across a second clear (push + reconcile) until consumed',
      () async {
    await auth.signIn(userId: 'c4', token: 't');
    await auth.setAwaitingConsent(maskedParentEmail: 'm***@x.com');
    await auth.clearAwaitingConsent(); // route 1 (push) — transition, flag true
    await auth.clearAwaitingConsent(); // route 2 (reconcile) — already cleared
    expect(auth.state.justConsentUnlocked, isTrue,
        reason: 'a second clear must not wipe the pending celebration');
  });
}
