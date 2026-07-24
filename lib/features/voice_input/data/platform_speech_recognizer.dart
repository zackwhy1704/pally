import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:pally/core/utils/logger.dart';
import 'package:pally/features/voice_input/domain/speech_recognizer.dart';

/// Real [SpeechRecognizer] backed by the `speech_to_text` plugin.
///
/// PRIVACY: this class never reads or writes audio bytes. `speech_to_text`
/// streams microphone audio directly to the OS recognizer (iOS
/// SFSpeechRecognizer / Android SpeechRecognizer) and the plugin only ever
/// hands this class decoded TEXT via its `onResult` callback — there is no
/// audio buffer to log, write to disk, or send to any Apalchi endpoint (this
/// feature has no backend call at all).
class PlatformSpeechRecognizer implements SpeechRecognizer {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _available = false;
  void Function(String message)? _currentOnError;
  void Function()? _currentOnDone;

  @override
  Future<bool> initialize() async {
    if (_available) return true;
    try {
      _available = await _speech.initialize(
        onError: (error) {
          appLog.d('[VoiceInput] recognizer error: ${error.errorMsg}');
          _currentOnError?.call(error.errorMsg);
        },
        onStatus: (status) {
          if (status == stt.SpeechToText.doneStatus ||
              status == stt.SpeechToText.notListeningStatus) {
            _currentOnDone?.call();
          }
        },
      );
    } catch (e) {
      appLog.w('[VoiceInput] initialize failed (non-fatal): $e');
      _available = false;
    }
    return _available;
  }

  @override
  Future<List<SpeechLocale>> locales() async {
    if (!_available) return const [];
    try {
      final raw = await _speech.locales();
      return [for (final l in raw) SpeechLocale(l.localeId, l.name)];
    } catch (e) {
      appLog.w('[VoiceInput] locales() failed (non-fatal): $e');
      return const [];
    }
  }

  @override
  Future<void> listen({
    required void Function(String transcript, bool isFinal) onResult,
    required void Function(String message) onError,
    required void Function() onDone,
    bool preferOnDevice = true,
    String? localeId,
  }) async {
    if (!_available) {
      onError('Speech recognizer unavailable');
      return;
    }
    _currentOnError = onError;
    _currentOnDone = onDone;

    Future<void> start(bool onDevice) => _speech.listen(
          onResult: (result) =>
              onResult(result.recognizedWords, result.finalResult),
          listenOptions: stt.SpeechListenOptions(
            onDevice: onDevice,
            partialResults: true,
            cancelOnError: true,
            listenMode: stt.ListenMode.dictation,
            localeId: localeId,
          ),
        );

    try {
      await start(preferOnDevice);
    } catch (e) {
      if (!preferOnDevice) {
        // Already tried the platform/server recognizer and it still failed —
        // nothing left to fall back to.
        appLog.w('[VoiceInput] listen() failed, no fallback left: $e');
        onError('Speech recognition failed to start');
        return;
      }
      // On-device recognition unavailable on this device (SpeechListenOptions
      // docs: "If it cannot do this the listen attempt will fail") — fall
      // back to the platform/server recognizer rather than leaving voice
      // input dead on cheap Android devices with no on-device model.
      appLog.d('[VoiceInput] on-device listen failed, falling back: $e');
      try {
        await start(false);
      } catch (e2) {
        appLog.w('[VoiceInput] fallback listen() also failed: $e2');
        onError('Speech recognition failed to start');
      }
    }
  }

  @override
  Future<void> stop() => _speech.stop();

  @override
  bool get isListening => _speech.isListening;
}
