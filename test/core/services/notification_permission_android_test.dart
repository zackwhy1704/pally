import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/core/services/notification_service.dart';

/// Pins the Android 13+ notification-permission request.
///
/// THE DEFECT: iOS has always prompted for notification permission inside
/// NotificationService.init() (DarwinInitializationSettings with
/// requestAlertPermission: true). Android never did. POST_NOTIFICATIONS is
/// present in the merged manifest — firebase_messaging injects it — but
/// flutter_local_notifications only ever issues the runtime request via its
/// requestNotificationsPermission dispatch case, and nothing in lib/ called
/// it. Android users therefore received no reminders at all, with no prompt
/// and no error: a silent platform inconsistency, not a missing feature.
///
/// These tests drive the REAL plugin call path — the production code's
/// resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
/// resolves against FlutterLocalNotificationsPlatform.instance and invokes the
/// genuine 'dexterous.com/flutter/local_notifications' method channel, which is
/// mocked here. Asserting on the recorded channel traffic is what makes the
/// invocation provable.
///
/// A test asserting only `completes` would pass against a no-op init and prove
/// nothing. That exact trap was already hit once in this project (the first
/// SrsReminderArmer suite), so every case below asserts the channel actually
/// received requestNotificationsPermission.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('dexterous.com/flutter/local_notifications');
  late List<MethodCall> calls;

  /// Installs a mock handler. [onRequest] decides what the permission request
  /// does; every other method succeeds so init() reaches the request at all.
  void mockChannel({required Object? Function() onRequest}) {
    calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
      calls.add(call);
      if (call.method == 'requestNotificationsPermission') return onRequest();
      // initialize() is typed Future<bool> — returning null here throws
      // "type 'Null' is not a subtype of type 'FutureOr<bool>'" and the whole
      // suite then measures a FAILED init rather than the permission path.
      if (call.method == 'initialize') return true;
      if (call.method == 'getNotificationAppLaunchDetails') {
        return <String, Object?>{'notificationLaunchedApp': false};
      }
      return null;
    });
  }

  bool requested() =>
      calls.any((c) => c.method == 'requestNotificationsPermission');

  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    FlutterLocalNotificationsPlatform.instance =
        AndroidFlutterLocalNotificationsPlugin();
    NotificationService.debugResetForTest();
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    NotificationService.debugResetForTest();
  });

  test('init requests the Android notification permission — GRANTED', () async {
    mockChannel(onRequest: () => true);

    await NotificationService.init();

    expect(requested(), isTrue,
        reason: 'init() must actually invoke requestNotificationsPermission '
            'on Android; completing without it is the defect');
  });

  test('init still completes when the permission is DENIED', () async {
    mockChannel(onRequest: () => false);

    await NotificationService.init();

    expect(requested(), isTrue);
    // A denial is a no-op, never a startup failure.
    expect(NotificationService.debugIsInitialised, isTrue,
        reason: 'a denied permission must not leave the service uninitialised');
  });

  test('init survives the permission request THROWING', () async {
    // The real reachable failure: the plugin returns
    // PERMISSION_REQUEST_IN_PROGRESS_ERROR_MESSAGE as a PlatformException when
    // a request is already in flight.
    mockChannel(
        onRequest: () => throw PlatformException(
            code: 'permissionRequestInProgress',
            message: 'Permission request already in progress'));

    await NotificationService.init();

    expect(requested(), isTrue);
    expect(NotificationService.debugIsInitialised, isTrue,
        reason: 'a throwing permission request must not break startup');
  });

  test('a DENIED permission does not stop later scheduling from being attempted',
      () async {
    // The permission failing must not latch the service into a state where
    // scheduling silently stops being tried — the OS decides what surfaces,
    // not us.
    mockChannel(onRequest: () => false);
    await NotificationService.init();
    calls.clear();

    await NotificationService.cancelDailyQuizReminder();

    expect(calls.any((c) => c.method == 'cancel'), isTrue,
        reason: 'scheduling/cancel calls must still reach the platform after '
            'a denied permission');
  });

  test('no Android permission request is made on iOS', () async {
    // Guards the reverse inconsistency: iOS already prompts inside
    // initialize(), so an extra Android-shaped request there would be wrong.
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    FlutterLocalNotificationsPlatform.instance =
        IOSFlutterLocalNotificationsPlugin();
    mockChannel(onRequest: () => true);

    await NotificationService.init();

    expect(requested(), isFalse,
        reason: 'the Android request path must not fire on iOS');
  });
}
