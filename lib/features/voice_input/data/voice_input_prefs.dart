import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pally/features/voice_input/data/platform_speech_recognizer.dart';
import 'package:pally/features/voice_input/domain/speech_recognizer.dart';

/// Local (per-device) shared_preferences key for the voice-input off-switch.
const voiceInputEnabledPrefsKey = 'voice_input_enabled_v1';

/// shared_preferences key marking the first-use explainer as shown.
const voiceInputExplainerShownPrefsKey = 'voice_input_explainer_shown_v1';

/// Per-account off-switch for the ENTIRE voice-input feature. All four mic
/// affordances render through the one VoiceInputButton widget, which is the
/// single place that reads this flag — flipping it here hides the mic
/// everywhere at once (e.g. if a legal/DPIA review comes back stricter).
///
/// This synchronous `true` is a TEST-ONLY default so widget tests never need to
/// mock shared_preferences just to render a screen. It is NOT the runtime
/// default — at app bootstrap main.dart always overrides this provider with
/// `readPersistedVoiceInputEnabled`, whose default is OFF (see below). So voice
/// is DARK by default in the real app until it is explicitly enabled.
final voiceInputEnabledProvider = StateProvider<bool>((ref) => true);

/// Flips the off-switch and persists it locally. Not wired to any settings
/// UI yet (the task treats a visible toggle as optional polish) — this is
/// the hook a future settings screen would call.
Future<void> setVoiceInputEnabled(WidgetRef ref, bool enabled) async {
  ref.read(voiceInputEnabledProvider.notifier).state = enabled;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(voiceInputEnabledPrefsKey, enabled);
}

/// Reads the persisted off-switch value, if any, for `main.dart` bootstrap to
/// apply as a `ProviderScope` override before first frame.
///
/// Default is **OFF** (`?? false`): voice ships DARK until the DPIA/legal review
/// on children's-voice-to-cloud-STT clears. Flip this ONE line to `?? true` (in
/// a release whose notes announce it) to turn voice on by default. The
/// asymmetry is the point — dictated audio can't be un-sent; a one-line flip can wait.
Future<bool> readPersistedVoiceInputEnabled(SharedPreferences prefs) async {
  return prefs.getBool(voiceInputEnabledPrefsKey) ?? false;
}

/// The speech recognition engine. Overridden in tests with a fake so no test
/// ever drives a real platform channel or microphone.
final speechRecognizerProvider =
    Provider<SpeechRecognizer>((ref) => PlatformSpeechRecognizer());
