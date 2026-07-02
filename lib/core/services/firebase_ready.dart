import 'package:firebase_core/firebase_core.dart';

/// True only when `Firebase.initializeApp` has succeeded and a default app
/// exists. Every FirebaseMessaging caller MUST guard on this — if Firebase
/// failed to initialise (bad/missing config on a platform), touching
/// `FirebaseMessaging.instance` throws `[core/no-app]` and, from the widget
/// build path, red-screens the whole app. Guarding lets push features degrade
/// silently instead of crashing.
bool get isFirebaseReady => Firebase.apps.isNotEmpty;
