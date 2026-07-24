/// A locale offered by the platform speech recognizer (e.g. 'en_US', 'en_SG').
class SpeechLocale {
  const SpeechLocale(this.localeId, this.name);

  final String localeId;
  final String name;
}

/// Abstraction over the speech-to-text ENGINE only.
///
/// PRIVACY CONTRACT: implementations must never persist or transmit raw audio.
/// The platform recognizer (iOS SFSpeechRecognizer / Android SpeechRecognizer)
/// owns the microphone stream; this interface only ever hands back decoded
/// TEXT via [listen]'s `onResult`. Apalchi has no code path that writes audio
/// bytes to disk or to any network call — see PlatformSpeechRecognizer, the
/// only production implementation, which never touches raw audio either.
///
/// Tests substitute a fake implementation so no test drives a real platform
/// channel or microphone.
abstract class SpeechRecognizer {
  /// Prepares the recognizer. Returns whether it is ready to listen (false on
  /// devices/simulators with no recognizer, or if the platform call fails).
  Future<bool> initialize();

  /// Locales offered by the platform recognizer. Empty if [initialize] wasn't
  /// called or returned false.
  Future<List<SpeechLocale>> locales();

  /// Starts listening.
  ///
  /// [onResult] fires with the current transcript on every partial AND final
  /// chunk — TEXT only, never audio. [preferOnDevice] requests on-device
  /// recognition first; implementations must fall back to the platform/server
  /// recognizer if on-device is unavailable rather than silently doing
  /// nothing, so devices without an on-device model still get voice input.
  /// [onError] fires on a recoverable recognition error (no speech, recognizer
  /// hiccup) — callers must degrade to typing, never crash. [onDone] fires
  /// when the recognizer stops listening on its own (e.g. a silence timeout).
  Future<void> listen({
    required void Function(String transcript, bool isFinal) onResult,
    required void Function(String message) onError,
    required void Function() onDone,
    bool preferOnDevice = true,
    String? localeId,
  });

  /// Stops listening. The last transcript already delivered via [listen]'s
  /// `onResult` remains wherever the caller put it (never re-sent here).
  Future<void> stop();

  bool get isListening;
}

/// Picks the best available locale for voice input: en-SG if the platform
/// offers it, else en-US, else en-GB, else the platform default (null — never
/// hardcode a locale that might not exist on this device).
///
/// Pure function (no plugin/platform access) so it's unit-testable without a
/// widget tree or a real recognizer.
String? pickPreferredLocale(List<SpeechLocale> available) {
  SpeechLocale? findById(String id) {
    for (final locale in available) {
      if (locale.localeId.toLowerCase() == id.toLowerCase()) return locale;
    }
    return null;
  }

  return (findById('en_SG') ?? findById('en_US') ?? findById('en_GB'))
      ?.localeId;
}
