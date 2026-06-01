import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/widgets/loading/mochi_tips.dart';

/// Pattern E — full-screen Mochi + progress bar + step label + rotating tip
/// for long jobs (3–15s): wiki compile, quiz gen, flashcard gen.
///
/// Pass real [progress] (0–1) when available. If progress can't be measured,
/// use [stepLabels] with [stepDuration] for honest phased labels — the bar
/// advances deterministically, never stalls at 99%.
class MochiGenerating extends StatefulWidget {
  const MochiGenerating({
    super.key,
    this.progress,
    this.stepLabel = 'Working on it…',
    this.stepLabels,
    this.stepDuration = const Duration(seconds: 3),
    this.onCancel,
  });

  /// True progress 0–1 from the caller. When null, uses indeterminate steps.
  final double? progress;

  /// Single step label (when you have real progress).
  final String stepLabel;

  /// Ordered list of step labels for timed-phase mode (no real progress signal).
  final List<String>? stepLabels;

  /// How long to stay on each step label in timed-phase mode.
  final Duration stepDuration;

  /// Optional cancel callback. Hidden when null.
  final VoidCallback? onCancel;

  @override
  State<MochiGenerating> createState() => _MochiGeneratingState();
}

class _MochiGeneratingState extends State<MochiGenerating>
    with SingleTickerProviderStateMixin {
  late final AnimationController _tipFade;
  late String _tip;
  Timer? _tipTimer;
  Timer? _stepTimer;

  int _stepIndex = 0;
  double _timedProgress = 0;

  @override
  void initState() {
    super.initState();
    _tip = randomMochiTip();

    _tipFade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      value: 1.0,
    );

    // Rotate tip every 4s
    _tipTimer = Timer.periodic(const Duration(seconds: 4), (_) => _rotateTip());

    // Phased step labels when no real progress
    if (widget.progress == null && (widget.stepLabels?.length ?? 0) > 1) {
      _startPhaseTimer();
    }
  }

  void _startPhaseTimer() {
    final labels = widget.stepLabels!;
    final total = labels.length;
    _stepTimer = Timer.periodic(widget.stepDuration, (_) {
      if (!mounted) return;
      if (_stepIndex < total - 1) {
        setState(() {
          _stepIndex++;
          _timedProgress = _stepIndex / (total - 1);
        });
      }
    });
  }

  void _rotateTip() {
    if (!mounted) return;
    _tipFade.reverse().then((_) {
      if (!mounted) return;
      setState(() => _tip = nextMochiTip(_tip));
      _tipFade.forward();
    });
  }

  @override
  void dispose() {
    _tipFade.dispose();
    _tipTimer?.cancel();
    _stepTimer?.cancel();
    super.dispose();
  }

  String get _currentLabel {
    final labels = widget.stepLabels;
    if (labels != null && labels.isNotEmpty) return labels[_stepIndex];
    return widget.stepLabel;
  }

  double get _currentProgress {
    if (widget.progress != null) return widget.progress!.clamp(0.0, 1.0);
    return _timedProgress;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/mochi.png', width: 100, height: 100),
              const SizedBox(height: AppSpacing.lg),
              Text(
                _currentLabel,
                style: AppTextStyles.title,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: _currentProgress),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOut,
                  builder: (_, v, __) => LinearProgressIndicator(
                    value: v > 0 ? v : null, // null = indeterminate until first step
                    minHeight: 10,
                    backgroundColor: AppColors.outline,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppColors.purple),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              FadeTransition(
                opacity: _tipFade,
                child: Container(
                  padding: AppSpacing.card,
                  decoration: BoxDecoration(
                    color: AppColors.purpleL,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    _tip,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.purple),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              if (widget.onCancel != null) ...[
                const SizedBox(height: AppSpacing.lg),
                TextButton(
                  onPressed: widget.onCancel,
                  child: Text('Cancel',
                      style: AppTextStyles.body
                          .copyWith(color: AppColors.text2)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Convenience step labels for the wiki compile flow.
const kCompileStepLabels = [
  'Reading your notes…',
  'Finding key ideas…',
  'Building your Mochi brain…',
  'Almost ready…',
];

/// Convenience step labels for quiz generation.
const kQuizGenStepLabels = [
  'Reading your material…',
  'Writing questions…',
  'Checking the answers…',
  'Finishing up…',
];

/// Convenience step labels for flashcard generation.
const kFlashcardGenStepLabels = [
  'Reading your notes…',
  'Making flashcards…',
  'Almost done…',
];

/// Convenience step labels shown while a file is being uploaded and processed.
const kUploadStepLabels = [
  'Uploading your notes…',
  'Reading the content…',
  'Checking relevance…',
  'Teaching your Mochi…',
];
