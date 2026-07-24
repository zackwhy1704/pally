import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pally/features/voice_input/data/voice_input_prefs.dart';
import 'package:pally/features/voice_input/domain/speech_recognizer.dart';
import 'package:pally/features/voice_input/presentation/voice_input_button.dart';

/// Fake recognizer — a widget test must NEVER drive the real speech_to_text
/// platform channel or microphone. This substitutes entirely for the plugin
/// and never touches audio in any form; tests only ever see TEXT flow
/// through [emit], mirroring the real onResult contract.
class _FakeSpeechRecognizer implements SpeechRecognizer {
  bool available = true;
  List<SpeechLocale> localesToReturn = const [
    SpeechLocale('en_US', 'English (US)'),
  ];
  void Function(String, bool)? _onResult;
  bool _listening = false;

  @override
  Future<bool> initialize() async => available;

  @override
  Future<List<SpeechLocale>> locales() async => localesToReturn;

  @override
  Future<void> listen({
    required void Function(String, bool) onResult,
    required void Function(String) onError,
    required void Function() onDone,
    bool preferOnDevice = true,
    String? localeId,
  }) async {
    _onResult = onResult;
    _listening = true;
  }

  /// Simulates the platform recognizer handing back a transcript chunk.
  void emit(String text, {bool isFinal = false}) =>
      _onResult?.call(text, isFinal);

  @override
  Future<void> stop() async {
    _listening = false;
  }

  @override
  bool get isListening => _listening;
}

const _voiceKey = ValueKey('voiceInputButton');
const _permissionChannel =
    MethodChannel('flutter.baseflow.com/permissions/methods');

/// Wires the permission_handler method channel to canned responses so no
/// test touches a real OS permission dialog. 1 = granted, 0 = denied (see
/// permission_handler_platform_interface's PermissionStatus int encoding).
void _mockPermission(int microphoneStatusValue) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_permissionChannel, (call) async {
    switch (call.method) {
      case 'checkPermissionStatus':
        return microphoneStatusValue;
      case 'requestPermissions':
        return {7: microphoneStatusValue}; // 7 == Permission.microphone.value
      case 'openAppSettings':
        return true;
    }
    return null;
  });
}

void main() {
  late _FakeSpeechRecognizer fakeRecognizer;

  Widget wrap(Widget child, {List<Override> overrides = const []}) =>
      ProviderScope(
        overrides: overrides,
        child: MaterialApp(home: Scaffold(body: child)),
      );

  setUp(() {
    fakeRecognizer = _FakeSpeechRecognizer();
    // Default: explainer already shown, mic permission already granted — most
    // tests care about a DIFFERENT step of the flow and shouldn't have to
    // fight through the one-time dialog every time.
    SharedPreferences.setMockInitialValues({
      voiceInputExplainerShownPrefsKey: true,
    });
    _mockPermission(1); // granted
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_permissionChannel, null);
  });

  group('off-switch', () {
    testWidgets(
        'voiceInputEnabled=false hides the mic entirely — the off-switch works',
        (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(wrap(
        VoiceInputButton(controller: controller),
        overrides: [
          voiceInputEnabledProvider.overrideWith((ref) => false),
          speechRecognizerProvider.overrideWithValue(fakeRecognizer),
        ],
      ));

      expect(find.byKey(_voiceKey), findsNothing);
    });

    testWidgets('voiceInputEnabled=true renders the mic (fail-closed: OFF is the default)',
        (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(wrap(
        VoiceInputButton(controller: controller),
        overrides: [
          voiceInputEnabledProvider.overrideWith((ref) => true),
          speechRecognizerProvider.overrideWithValue(fakeRecognizer),
        ],
      ));

      expect(find.byKey(_voiceKey), findsOneWidget);
    });
  });

  group('transcription', () {
    testWidgets(
        'tapping the mic starts listening; partial + final transcripts land '
        'in the controller, which stays editable afterwards', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(wrap(
        VoiceInputButton(controller: controller),
        overrides: [
          voiceInputEnabledProvider.overrideWith((ref) => true),
          speechRecognizerProvider.overrideWithValue(fakeRecognizer),
        ],
      ));

      await tester.tap(find.byKey(_voiceKey));
      await tester.pumpAndSettle();
      expect(fakeRecognizer.isListening, isTrue);

      fakeRecognizer.emit('hello mochi', isFinal: false);
      await tester.pump();
      expect(controller.text, 'hello mochi');

      fakeRecognizer.emit('hello mochi it is sunny', isFinal: true);
      await tester.pump();
      expect(controller.text, 'hello mochi it is sunny');

      // Fail-without-fix: a version that locked the field (readOnly / disabled
      // while "confirming" the dictation) would make this assignment a no-op.
      controller.text = 'a student edit after dictation';
      await tester.pump();
      expect(controller.text, 'a student edit after dictation');
    });

    testWidgets('onChanged fires on every transcript update (prove_body sync)',
        (tester) async {
      final controller = TextEditingController();
      final synced = <String>[];
      await tester.pumpWidget(wrap(
        VoiceInputButton(controller: controller, onChanged: synced.add),
        overrides: [
          voiceInputEnabledProvider.overrideWith((ref) => true),
          speechRecognizerProvider.overrideWithValue(fakeRecognizer),
        ],
      ));

      await tester.tap(find.byKey(_voiceKey));
      await tester.pumpAndSettle();
      fakeRecognizer.emit('partial', isFinal: false);
      await tester.pump();
      fakeRecognizer.emit('partial final', isFinal: true);
      await tester.pump();

      // Fail-without-fix: setting controller.text directly does NOT fire a
      // TextField's own onChanged, so without this explicit pass-through the
      // parent (e.g. ProveBody's `answers` map) never sees a dictated answer.
      expect(synced, ['partial', 'partial final']);
    });
  });

  group('permission denied', () {
    testWidgets('shows guidance and the typing path still works (no dead-end)',
        (tester) async {
      _mockPermission(0); // denied
      final controller = TextEditingController();
      await tester.pumpWidget(wrap(
        Column(children: [
          TextField(controller: controller),
          VoiceInputButton(controller: controller),
        ]),
        overrides: [
          voiceInputEnabledProvider.overrideWith((ref) => true),
          speechRecognizerProvider.overrideWithValue(fakeRecognizer),
        ],
      ));

      await tester.tap(find.byKey(_voiceKey));
      await tester.pumpAndSettle();

      expect(find.text('Microphone access needed'), findsOneWidget);
      expect(
        find.textContaining('turn on microphone access in Settings'),
        findsOneWidget,
      );
      // Never started listening.
      expect(fakeRecognizer.isListening, isFalse);

      await tester.tap(find.text('Not now'));
      await tester.pumpAndSettle();

      // Fail-without-fix: a version with no keyboard fallback would leave the
      // student stuck after a permission denial. Typing must still work.
      await tester.enterText(find.byType(TextField), 'typed instead');
      await tester.pump();
      expect(controller.text, 'typed instead');
    });
  });

  group('first-use explainer', () {
    testWidgets('shown once before the first listen, then never again',
        (tester) async {
      SharedPreferences.setMockInitialValues({}); // not yet shown
      final controller = TextEditingController();
      await tester.pumpWidget(wrap(
        VoiceInputButton(controller: controller),
        overrides: [
          voiceInputEnabledProvider.overrideWith((ref) => true),
          speechRecognizerProvider.overrideWithValue(fakeRecognizer),
        ],
      ));

      await tester.tap(find.byKey(_voiceKey));
      await tester.pumpAndSettle();

      expect(find.text('Talk to Mochi'), findsOneWidget);
      expect(find.textContaining("your voice isn't saved"), findsOneWidget);

      await tester.tap(find.text('Got it'));
      await tester.pumpAndSettle();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(voiceInputExplainerShownPrefsKey), isTrue);

      // Stop, then start a second, FRESH listen session — the explainer must
      // not resurface once it's been dismissed once for this account.
      await tester.tap(find.byKey(_voiceKey)); // stop
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(_voiceKey)); // start again
      await tester.pumpAndSettle();
      expect(find.text('Talk to Mochi'), findsNothing);
    });
  });
}
