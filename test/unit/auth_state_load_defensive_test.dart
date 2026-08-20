import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/auth/auth_state.dart';

/// Pins the "never brick startup" guard on AuthNotifier.load() — the same
/// principle already documented on wipeSecureStorageOnFirstLaunch and applied
/// to Firebase init / NotificationService.init() in main.dart's _bootstrap().
/// load() runs before the first frame; an unguarded secure-storage read
/// failure there must degrade to signed-out, not crash startup.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');

  tearDown(() async {
    // Restore a working (in-memory, empty) handler so AuthNotifier can clean
    // up its own state for later test files sharing this singleton.
    final store = <String, String>{};
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
    await AuthNotifier.instance.signOut();
  });

  test('load() completes and degrades to signed-out when secure-storage read throws', () async {
    // Every read() call on the platform channel throws — simulates a real
    // secure-storage failure (corrupted keychain, OS-level denial, etc.).
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'read') {
        throw PlatformException(code: 'read_error', message: 'boom');
      }
      return null;
    });

    // Must NOT throw — this is the core assertion. Before the fix, load()
    // propagates the PlatformException and this await throws, failing the test.
    await AuthNotifier.instance.load();

    final state = AuthNotifier.instance.state;
    expect(state.isSignedIn, isFalse);
    expect(state.userId, isNull);
    expect(state.token, isNull);
    expect(state.isSetupComplete, isFalse);
    expect(state.isOnboardingComplete, isFalse);
    expect(state.childName, isNull);
    expect(state.accountType, isNull);
    expect(state.awaitingConsent, isFalse);
    expect(state.maskedParentEmail, isNull);
  });
}
