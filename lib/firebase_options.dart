// Firebase configuration for options-based initialisation.
//
// Hand-authored from ios/Runner/GoogleService-Info.plist and
// android/app/google-services.json (same values `flutterfire configure`
// would generate). Options-based init is used INSTEAD of the bare
// `Firebase.initializeApp()` because the iOS bundle historically did not
// ship GoogleService-Info.plist (it was never added to the Xcode project),
// which made bundle-plist-based init fail silently on iOS. Compiling the
// options into Dart removes that per-platform fragility.
//
// If Firebase config changes, regenerate with `flutterfire configure` or
// update these constants; test/unit/firebase_options_test.dart pins them.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for the current platform.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for '
          '$defaultTargetPlatform.',
        );
    }
  }

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDWmRdxzQF_AjFL3qqKmrqVlcgznH4iKu8',
    appId: '1:390174524136:ios:ceafc82335dda350ef3f5d',
    messagingSenderId: '390174524136',
    projectId: 'apalchi',
    storageBucket: 'apalchi.firebasestorage.app',
    iosBundleId: 'com.apalchi.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAVnljAs-3VupaONPY2WN2LDtnybnnTWfA',
    appId: '1:390174524136:android:caf85da20fe345eaef3f5d',
    messagingSenderId: '390174524136',
    projectId: 'apalchi',
    storageBucket: 'apalchi.firebasestorage.app',
  );
}
