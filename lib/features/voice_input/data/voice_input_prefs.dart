import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/core/services/feature_flags.dart';
import 'package:pally/features/voice_input/data/platform_speech_recognizer.dart';
import 'package:pally/features/voice_input/domain/speech_recognizer.dart';

/// shared_preferences key marking the first-use explainer as shown (per device).
const voiceInputExplainerShownPrefsKey = 'voice_input_explainer_shown_v1';

/// Whether the voice-input mic is enabled. SERVER-CONTROLLED: synced from the
/// `voice_input` feature flag (backend `FeatureFlagService.getFlags` ← Railway
/// `VOICE_INPUT_ENABLED` env var) by an app-root `ref.listen` in PallyApp — see
/// `syncVoiceInputFlag`. Flipping the Railway env var toggles the mic on every
/// device with NO client redeploy (the kill-switch for children's-voice-to-cloud-STT
/// pending the DPIA).
///
/// FAIL-CLOSED: defaults `false` — the mic stays DARK unless the app-root sync sets
/// it true from a confirmed server flag. Kept a plain [StateProvider] (not derived
/// from featureFlagsProvider) so a mic-bearing widget does NOT transitively pull the
/// async auth/flags graph into every widget test — the sync happens in ONE place.
///
/// (Replaced the former local shared_preferences off-switch: a device-local flag
/// would DESYNC from server truth and couldn't be flipped remotely.) All four mic
/// affordances render through the one VoiceInputButton, which reads this.
final voiceInputEnabledProvider = StateProvider<bool>((ref) => false);

/// Pure flag→bool mapping (fail-closed): the mic is enabled ONLY when the server
/// explicitly returns `voice_input == true`. Absent/null/false → OFF. PallyApp's
/// `ref.listen(featureFlagsProvider, ...)` mirrors this into [voiceInputEnabledProvider].
bool voiceEnabledFromFlags(Map<String, bool>? flags) =>
    flags?[FeatureFlags.voiceInputEnabled] == true;

/// The speech recognition engine. Overridden in tests with a fake so no test ever
/// drives a real platform channel or microphone.
final speechRecognizerProvider =
    Provider<SpeechRecognizer>((ref) => PlatformSpeechRecognizer());
