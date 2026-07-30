import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/l10n/app_localizations.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
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
///  - INTERIM vs FINAL split: while listening, the recognizer streams revised
///    interim hypotheses (isFinal=false) that rewrite themselves token-by-token.
///    Those are shown ONLY in a muted "pending" preview pill above the mic —
///    NEVER written to [controller] — so the field never visibly churns. A FINAL
///    result (or the trailing interim at stop) is COMMITTED into the editable
///    field, APPENDED to whatever was already there so a user can dictate in
///    segments across taps. Only text ever leaves the recognizer, never audio;
///    the field stays fully editable, and nothing here EVER auto-submits;
///  - degrades to typing on permission-denied or any recognizer error —
///    the keyboard path always keeps working.
///
/// [onChanged] is for callers whose parent state is driven by the TextField's
/// own `onChanged` (e.g. prove_body.dart, which pushes into a parent `answers`
/// map) — setting `controller.text` programmatically does NOT fire a TextField's
/// `onChanged`, so this widget calls [onChanged] explicitly on each COMMIT (final
/// only, never interim). Sites that read the controller directly (test_body.dart,
/// upload_screen.dart via a controller listener; chat_screen.dart via
/// `controller.text` at send time) don't need it — and, like onChanged, only ever
/// see COMMITTED text, never interim.
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

  // Interim/final split. `_sessionBase` is the committed field text captured at
  // listen-start; finals append to it (segmented dictation). `_interim` is the
  // current unfinalized hypothesis — shown in the preview pill, NEVER in the field.
  String _sessionBase = '';
  String _interim = '';
  final LayerLink _previewLink = LayerLink();
  OverlayEntry? _previewOverlay;

  // Deliberately NOT an animated/repeating indicator: an infinite ticker would
  // keep scheduling frames while listening (hangs tester.pumpAndSettle + burns
  // battery). "Visible recording state" is the coral mic + the preview pill.
  void _setListening(bool value) {
    if (!mounted) return;
    setState(() => _isListening = value);
  }

  @override
  void dispose() {
    if (_isListening) {
      _activeRecognizer?.stop(); // best-effort; no audio is ever buffered here
    }
    _previewOverlay?.remove();
    _previewOverlay = null;
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
      // New session: capture the already-committed text so finals append to it.
      _sessionBase = widget.controller.text;
      _interim = '';
      _setListening(true);
      _showOrUpdatePreview(); // immediate "Listening…" feedback (covers batch case)

      await recognizer.listen(
        onResult: (text, isFinal) {
          if (!mounted) return;
          if (isFinal) {
            _commit(text);
          } else {
            _interim = text;
            _showOrUpdatePreview();
          }
        },
        onError: (message) {
          if (!mounted) return;
          _finalizeSession(commitTrailing: false); // discard the trailing hypothesis
          _showTransientMessage("Didn't catch that — you can type instead.");
        },
        onDone: () {
          if (!mounted) return;
          _finalizeSession(commitTrailing: true);
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
    // Commit any trailing interim the engine never marked final (batch engines
    // only finalize at stop). onDone may also fire this — it is idempotent.
    _finalizeSession(commitTrailing: true);
  }

  /// Ends the session: optionally commits any trailing interim, tears down the
  /// preview, clears listening. Idempotent — safe from both stop() and onDone
  /// (after a commit, `_interim` is empty so a second call only cleans up).
  void _finalizeSession({required bool commitTrailing}) {
    if (commitTrailing && _interim.isNotEmpty) {
      _commit(_interim); // clears _interim + removes the preview
    } else {
      _interim = '';
      _removePreview();
    }
    _setListening(false);
  }

  /// Commit finalized text into the editable field, appended to the session base.
  /// Uses `_sessionBase` (NOT the live controller) so a cumulative final replaces
  /// this session's contribution rather than duplicating it; across taps, each new
  /// session's base is the prior committed text, so segments accumulate.
  void _commit(String text) {
    _interim = '';
    _removePreview();
    final t = text.trim();
    if (t.isEmpty) return;
    final base = _sessionBase;
    final needsSpace =
        base.isNotEmpty && !base.endsWith(' ') && !base.endsWith('\n');
    final next = needsSpace ? '$base $t' : '$base$t';
    widget.controller.text = next;
    widget.controller.selection =
        TextSelection.collapsed(offset: next.length);
    widget.onChanged?.call(next);
  }

  // ── Pending-preview overlay (interim text, never the field) ────────────────
  void _showOrUpdatePreview() {
    if (!mounted) return;
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return; // no Overlay ancestor — degrade silently
    if (_previewOverlay == null) {
      _previewOverlay = _buildPreviewOverlay();
      overlay.insert(_previewOverlay!);
    } else {
      _previewOverlay!.markNeedsBuild();
    }
  }

  void _removePreview() {
    _previewOverlay?.remove();
    _previewOverlay = null;
  }

  OverlayEntry _buildPreviewOverlay() => OverlayEntry(
        builder: (ctx) => CompositedTransformFollower(
          link: _previewLink,
          targetAnchor: Alignment.topRight,
          followerAnchor: Alignment.bottomRight,
          offset: const Offset(0, -8),
          child: Align(
            alignment: Alignment.bottomRight,
            child: Material(
              color: Colors.transparent,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 260),
                child: Container(
                  key: const ValueKey('voiceInputPreview'),
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: AppColors.surf2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.mic_rounded,
                          size: 14, color: AppColors.coral),
                      const SizedBox(width: AppSpacing.xs),
                      Flexible(
                        child: Text(
                          _interim.isEmpty ? 'Listening…' : _interim,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          // Muted + italic = clearly "pending, not committed".
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.text3,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  /// One-time, per-account (per-device local storage) plain-language explainer
  /// shown before the very first listen. Never shown again once
  /// [voiceInputExplainerShownPrefsKey] is persisted.
  Future<void> _maybeShowExplainer() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(voiceInputExplainerShownPrefsKey) == true) return;
    if (!mounted) return;
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.voiceTalkTo(l10n.mascotName)),
        content: Text(l10n.voiceExplainer(l10n.mascotName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.consentPendingGotIt),
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
    final l10n = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.voiceMicNeeded),
        content: Text(l10n.voiceMicGuidance(l10n.mascotName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.voiceNotNow),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              openAppSettings();
            },
            child: Text(l10n.voiceOpenSettings),
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

    return CompositedTransformTarget(
      link: _previewLink,
      child: Tooltip(
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
      ),
    );
  }
}
