import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/features/voice_input/data/voice_input_prefs.dart';
import 'package:pally/features/voice_input/domain/speech_recognizer.dart';

/// Shared mic affordance for the four voice-input text-entry sites.
///
/// Drop it in/next to any `TextField`'s [controller]. It:
///  - hides entirely when [voiceInputEnabledProvider] is false (the single
///    off-switch every one of the four sites shares, by construction — they
///    all render THIS widget, so there is exactly one place to check);
///  - shows a one-time plain-language explainer before the FIRST listen ever
///    (persisted in shared_preferences so it never repeats);
///  - writes live partial + final transcripts into [controller] — never
///    audio, only text, and the field stays fully editable throughout and
///    after; nothing here ever auto-submits;
///  - degrades to typing on permission-denied or any recognizer error —
///    the keyboard path always keeps working.
///
/// [onChanged] is for callers whose parent state is driven by the TextField's
/// own `onChanged` (e.g. prove_body.dart, which pushes into a parent
/// `answers` map) — setting `controller.text` programmatically does NOT fire
/// a TextField's `onChanged`, so this widget calls [onChanged] explicitly
/// after every transcript update to keep such parents in sync. Sites that
/// read the controller directly (test_body.dart, upload_screen.dart via a
/// controller listener; chat_screen.dart via `controller.text` at send time)
/// don't need it.
class VoiceInputButton extends ConsumerStatefulWidget {
  const VoiceInputButton({
    super.key,
    required this.controller,
    this.onChanged,
    this.iconSize = 20,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final double iconSize;

  @override
  ConsumerState<VoiceInputButton> createState() => VoiceInputButtonState();
}

class VoiceInputButtonState extends ConsumerState<VoiceInputButton> {
  bool _isListening = false;
  bool _isStarting = false;

  // Cached at listen-start time — `dispose()` must NOT call `ref.read(...)`
  // (Riverpod throws "Cannot use ref after the widget was disposed" once
  // teardown begins), so the in-flight recognizer is stashed here instead of
  // re-resolved from the provider during teardown.
  SpeechRecognizer? _activeRecognizer;

  // Deliberately NOT an animated/repeating indicator: an infinite ticker
  // would keep scheduling frames for as long as the mic is listening, which
  // hangs `tester.pumpAndSettle()` on every screen this button sits on (it
  // waits for scheduled frames to stop) and burns battery on a real device.
  // "Visible recording state" is satisfied with a plain colour swap instead.
  void _setListening(bool value) {
    if (!mounted) return;
    setState(() => _isListening = value);
  }

  @override
  void dispose() {
    // Fail-without-fix: this used to call ref.read(speechRecognizerProvider)
    // here, which throws a StateError during widget-tree teardown — e.g. a
    // student navigating away mid-dictation would have crashed the app.
    if (_isListening) {
      // Best-effort stop; no audio is ever buffered here to worry about.
      _activeRecognizer?.stop();
    }
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (_isStarting) return; // re-entry guard
    if (_isListening) {
      await _stopListening();
      return;
    }

    setState(() => _isStarting = true);
    try {
      await _maybeShowExplainer();
      if (!mounted) return;
      final granted = await _ensurePermission();
      if (!granted) return; // guidance dialog already shown; typing still works

      final recognizer = ref.read(speechRecognizerProvider);
      _activeRecognizer = recognizer;
      final available = await recognizer.initialize();
      if (!mounted) return;
      if (!available) {
        _showTransientMessage("Couldn't start voice input — you can still type.");
        return;
      }

      final locales = await recognizer.locales();
      final localeId = pickPreferredLocale(locales);

      if (!mounted) return;
      _setListening(true);

      await recognizer.listen(
        onResult: (text, isFinal) {
          if (!mounted) return;
          widget.controller.text = text;
          widget.controller.selection =
              TextSelection.collapsed(offset: text.length);
          widget.onChanged?.call(text);
        },
        onError: (message) {
          if (!mounted) return;
          _setListening(false);
          _showTransientMessage("Didn't catch that — you can type instead.");
        },
        onDone: () {
          if (!mounted) return;
          _setListening(false);
        },
        preferOnDevice: true,
        localeId: localeId,
      );
    } finally {
      if (mounted) setState(() => _isStarting = false);
    }
  }

  Future<void> _stopListening() async {
    await _activeRecognizer?.stop();
    _setListening(false);
  }

  /// One-time, per-account (per-device local storage) plain-language
  /// explainer shown before the very first listen. Never shown again once
  /// [voiceInputExplainerShownPrefsKey] is persisted.
  Future<void> _maybeShowExplainer() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(voiceInputExplainerShownPrefsKey) == true) return;
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Talk to Mochi'),
        content: const Text(
          "Mochi uses your phone's speech recognition to turn talking into "
          "text — your voice isn't saved.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
    await prefs.setBool(voiceInputExplainerShownPrefsKey, true);
  }

  Future<bool> _ensurePermission() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
    }
    // iOS separately gates SFSpeechRecognizer behind its own permission.
    if (status.isGranted && Platform.isIOS) {
      var speechStatus = await Permission.speech.status;
      if (!speechStatus.isGranted) {
        speechStatus = await Permission.speech.request();
      }
      if (!speechStatus.isGranted) status = speechStatus;
    }
    if (status.isGranted) return true;

    if (!mounted) return false;
    await _showPermissionGuidance();
    return false;
  }

  Future<void> _showPermissionGuidance() async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Microphone access needed'),
        content: const Text(
          'To talk to Mochi, turn on microphone access in Settings. '
          'You can still type your answer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _showTransientMessage(String message) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final enabled = ref.watch(voiceInputEnabledProvider);
    if (!enabled) return const SizedBox.shrink();

    return Tooltip(
      message: _isListening ? 'Stop' : 'Speak your answer',
      child: IconButton(
        key: const ValueKey('voiceInputButton'),
        visualDensity: VisualDensity.compact,
        onPressed: _isStarting ? null : _handleTap,
        icon: Icon(
          _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
          size: widget.iconSize,
          color: _isListening ? AppColors.coral : AppColors.text2,
        ),
      ),
    );
  }
}
