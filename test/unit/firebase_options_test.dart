import 'package:flutter_test/flutter_test.dart';
import 'package:pally/firebase_options.dart';

/// Pins the Firebase options so a bad edit / regeneration can't silently ship
/// wrong project config (the class of gap that caused the iOS [core/no-app]
/// red-screen). Values mirror ios/Runner/GoogleService-Info.plist and
/// android/app/google-services.json.
void main() {
  test('iOS options match the apalchi Firebase project', () {
    expect(DefaultFirebaseOptions.ios.projectId, 'apalchi');
    expect(DefaultFirebaseOptions.ios.iosBundleId, 'com.apalchi.app');
    expect(DefaultFirebaseOptions.ios.messagingSenderId, '390174524136');
    expect(DefaultFirebaseOptions.ios.appId,
        '1:390174524136:ios:ceafc82335dda350ef3f5d');
    expect(DefaultFirebaseOptions.ios.storageBucket,
        'apalchi.firebasestorage.app');
    expect(DefaultFirebaseOptions.ios.apiKey, isNotEmpty);
  });

  test('Android options match the apalchi Firebase project', () {
    expect(DefaultFirebaseOptions.android.projectId, 'apalchi');
    expect(DefaultFirebaseOptions.android.messagingSenderId, '390174524136');
    expect(DefaultFirebaseOptions.android.appId,
        '1:390174524136:android:caf85da20fe345eaef3f5d');
    expect(DefaultFirebaseOptions.android.apiKey, isNotEmpty);
  });

  test('iOS and Android share one project but have distinct app ids', () {
    expect(DefaultFirebaseOptions.ios.projectId,
        DefaultFirebaseOptions.android.projectId);
    expect(DefaultFirebaseOptions.ios.appId,
        isNot(DefaultFirebaseOptions.android.appId));
  });
}
