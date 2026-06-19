import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pally/app/router.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/ui/painters/character_painter.dart';
import 'package:pally/features/chat/presentation/chat_view_model.dart';
import 'package:pally/shared/models/avatar.dart';
import 'package:pally/shared/models/mochi_character.dart';

/// Floating Mochi avatar that surfaces a single rotating tip in the chat
/// view. Designed to be a gentle nudge — never blocks the conversation,
/// caps itself per-session, and remembers what the user already saw.
///
/// Rules baked in:
///  - Hides entirely while the tutor is typing or the user has the
///    keyboard open (chat is the primary task, the coach is secondary).
///  - Once dismissed (×), no more bubbles surface this session — only
///    the small idle Mochi face stays, tap-to-expand.
///  - Action tips (upload / attach curriculum / few notes) auto-skip
///    once the underlying condition is resolved (e.g. once an upload
///    lands, "Upload your notes" is never shown again on that tutor).
///  - Healthy-state tips rotate among 5+ kid-friendly study nudges so
///    a kid with a full brain still occasionally sees a useful tip.
class MochiTipCoach extends ConsumerStatefulWidget {
  const MochiTipCoach({
    super.key,
    required this.avatarId,
    this.keyboardOpen = false,
  });

  final String avatarId;

  /// Caller passes the current keyboard inset so the coach can hide
  /// while the keyboard is up — composing a message is the active task
  /// and the bubble would compete with the input.
  final bool keyboardOpen;

  @override
  ConsumerState<MochiTipCoach> createState() => _MochiTipCoachState();
}

class _MochiTipCoachState extends ConsumerState<MochiTipCoach>
    with TickerProviderStateMixin {
  static const _initialDelay = Duration(seconds: 3);
  static const _rotateEvery = Duration(seconds: 25);
  static const _bobPeriod = Duration(milliseconds: 1800);

  Timer? _initialTimer;
  Timer? _rotateTimer;
  late final AnimationController _bobController;

  bool _hasAppeared = false;
  bool _dismissedThisSession = false;
  bool _expanded = true;
  int _rotation = 0;
  Set<String> _seenIds = const <String>{};

  @override
  void initState() {
    super.initState();
    _bobController =
        AnimationController(vsync: this, duration: _bobPeriod)..repeat();
    _loadSeen();
    _initialTimer = Timer(_initialDelay, () {
      if (!mounted) return;
      setState(() => _hasAppeared = true);
    });
    _rotateTimer = Timer.periodic(_rotateEvery, (_) {
      if (!mounted || _dismissedThisSession || !_expanded) return;
      setState(() => _rotation++);
    });
  }

  Future<void> _loadSeen() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_seenKey) ?? const <String>[];
    if (!mounted) return;
    setState(() => _seenIds = saved.toSet());
  }

  Future<void> _markSeen(String tipId) async {
    if (_seenIds.contains(tipId)) return;
    final prefs = await SharedPreferences.getInstance();
    final next = {..._seenIds, tipId};
    await prefs.setStringList(_seenKey, next.toList());
    if (mounted) setState(() => _seenIds = next);
  }

  String get _seenKey => 'mochi_tip_seen_${widget.avatarId}';

  @override
  void dispose() {
    _initialTimer?.cancel();
    _rotateTimer?.cancel();
    _bobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatViewModelProvider(widget.avatarId));
    final avatar = state.avatar;

    // Loading or busy → render nothing. A bubble while the tutor is
    // streaming an answer is the worst possible time to nag.
    if (avatar == null) return const SizedBox.shrink();
    if (state.isTyping) return const SizedBox.shrink();
    if (state.isProcessingPhoto) return const SizedBox.shrink();
    if (widget.keyboardOpen) return const SizedBox.shrink();
    if (!_hasAppeared) return const SizedBox.shrink();

    final tip = _selectTip(avatar);
    if (tip == null) {
      // Nothing to show — render just the idle Mochi so the screen still
      // has a friendly companion the user can re-tap later.
      return _IdleMochi(
        character: avatar.character,
        bob: _bobController,
        onTap: () => setState(() {
          _dismissedThisSession = false;
          _expanded = true;
          _hasAppeared = true;
        }),
      );
    }

    final collapsed = _dismissedThisSession || !_expanded;
    if (collapsed) {
      return _IdleMochi(
        character: avatar.character,
        bob: _bobController,
        onTap: () => setState(() {
          _dismissedThisSession = false;
          _expanded = true;
        }),
      );
    }

    return _BubbleAndMochi(
      character: avatar.character,
      bob: _bobController,
      tip: tip,
      onAction: tip.action == null
          ? null
          : () {
              _markSeen(tip.id);
              tip.action!.call(context, widget.avatarId);
            },
      onDismiss: () {
        _markSeen(tip.id);
        setState(() {
          _dismissedThisSession = true;
          _expanded = false;
        });
      },
    );
  }

  /// Highest-priority tip wins. Action tips (1-3) only fire while the
  /// underlying condition is still unresolved; rotating study tips
  /// cycle through {@link _studyTips} based on _rotation.
  _ChatTip? _selectTip(Avatar avatar) {
    final actionable = _actionableTips(avatar);
    if (actionable.isNotEmpty) {
      // Pick the first unseen actionable tip; fall back to the first
      // actionable tip if everything has been seen but the condition
      // still holds (e.g. they uploaded once but the count regressed).
      final fresh = actionable.firstWhere(
        (t) => !_seenIds.contains(t.id),
        orElse: () => actionable.first,
      );
      return fresh;
    }
    // Healthy state — rotate among the study nudges.
    if (_studyTips.isEmpty) return null;
    return _studyTips[_rotation % _studyTips.length];
  }

  List<_ChatTip> _actionableTips(Avatar avatar) {
    final result = <_ChatTip>[];
    // Centre classes are filled by the teacher/centre — students can't upload,
    // so any "add notes" nudge must point at the teacher and NEVER navigate to
    // the (blocked) upload screen.
    final isCentre = avatar.kind == AvatarKind.centreClass;
    if (!avatar.hasKnowledge) {
      result.add(_ChatTip(
        id: 'no-notes',
        text: isCentre
            ? "This class doesn't have notes yet. Ask your teacher to add some! 📚"
            : 'Upload your notes or textbook so I can learn from YOUR syllabus!',
        emoji: isCentre ? '📚' : '📷',
        action: isCentre ? null : _openUpload,
      ));
      return result; // hard-block: nothing else matters before notes exist
    }
    // Curriculum + "feed me more notes" nudges only apply to a child's own
    // Mochi; for a centre class the centre manages both.
    if (!isCentre && avatar.curriculumType == null) {
      result.add(const _ChatTip(
        id: 'no-curriculum',
        text: 'What are you studying towards? Set your goal so I can tailor my help!',
        emoji: '🎯',
        action: _openLibrary,
      ));
    }
    if (!isCentre && avatar.wikiPageCount >= 1 && avatar.wikiPageCount <= 2) {
      result.add(const _ChatTip(
        id: 'few-notes',
        text: 'Keep feeding me! The more notes you add, the smarter I get.',
        emoji: '🧠',
        action: _openUpload,
      ));
    }
    return result;
  }

  // Healthy-state rotation — 6 tips so the cycle takes ~2.5 minutes
  // before repeating. Copy is kid-friendly + nudges a specific action
  // the rest of the app supports.
  static const List<_ChatTip> _studyTips = [
    _ChatTip(
      id: 'teach-mode',
      text: 'Try Teach Mochi mode to lock in what you just learned!',
      emoji: '🎓',
    ),
    _ChatTip(
      id: 'weak-topics',
      text: "Ask me to quiz you on weak topics to drill what's shaky.",
      emoji: '🔴',
    ),
    _ChatTip(
      id: 'reword',
      text: 'Stuck? Ask me to explain it a different way.',
      emoji: '💡',
    ),
    _ChatTip(
      id: 'photo-question',
      text: "Snap a photo of homework — I'll solve it step by step.",
      emoji: '📸',
    ),
    _ChatTip(
      id: 'daily-quiz',
      text: "Take today's quiz before bed — even 5 questions counts!",
      emoji: '⚡',
    ),
    _ChatTip(
      id: 'flashcards',
      text: 'Flashcards are due! A quick review unlocks bonus XP.',
      emoji: '🃏',
    ),
  ];
}

// ── Tips data ────────────────────────────────────────────────────────────────

typedef _TipAction = void Function(BuildContext context, String avatarId);

class _ChatTip {
  const _ChatTip({
    required this.id,
    required this.text,
    required this.emoji,
    this.action,
  });

  final String id;
  final String text;
  final String emoji;
  final _TipAction? action;
}

void _openUpload(BuildContext context, String avatarId) {
  UploadRoute(avatarId: avatarId).push(context);
}

void _openLibrary(BuildContext context, String avatarId) {
  // Library has the curriculum-attach affordance per-tutor.
  const LibraryRoute().push(context);
}

// ── Idle / collapsed Mochi ───────────────────────────────────────────────────

class _IdleMochi extends StatelessWidget {
  const _IdleMochi({
    required this.character,
    required this.bob,
    required this.onTap,
  });

  final MochiCharacter character;
  final AnimationController bob;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: _BobbingMochi(
        character: character,
        bob: bob,
        size: 44,
        // Subtle glow so the user notices they can tap.
        haloColor: AppColors.purple.withValues(alpha: 0.18),
      ),
    );
  }
}

// ── Speech bubble + Mochi ────────────────────────────────────────────────────

class _BubbleAndMochi extends StatelessWidget {
  const _BubbleAndMochi({
    required this.character,
    required this.bob,
    required this.tip,
    required this.onAction,
    required this.onDismiss,
  });

  final MochiCharacter character;
  final AnimationController bob;
  final _ChatTip tip;
  final VoidCallback? onAction;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    // Constrain the bubble width so a long tip never spans the full
    // screen and bleeds under the avatar's halo.
    final maxBubble =
        (MediaQuery.of(context).size.width * 0.66).clamp(180.0, 280.0);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutBack,
      builder: (context, t, child) {
        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 8),
            child: child,
          ),
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxBubble),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: onAction,
                  child: Ink(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.sm + 4, AppSpacing.sm, 4, AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.amberL,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color:
                              AppColors.text1.withValues(alpha: 0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tip.emoji,
                            style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            tip.text,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: const Color(0xFFB8860B),
                              fontWeight: FontWeight.w600,
                              height: 1.25,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Dismiss is its own hit target so a stray tap
                        // doesn't accidentally trigger the tip action.
                        GestureDetector(
                          onTap: onDismiss,
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              Icons.close_rounded,
                              size: 14,
                              color: const Color(0xFFB8860B)
                                  .withValues(alpha: 0.7),
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
          const SizedBox(width: 6),
          _BobbingMochi(character: character, bob: bob, size: 52),
        ],
      ),
    );
  }
}

// ── Bobbing Mochi face ───────────────────────────────────────────────────────

class _BobbingMochi extends StatelessWidget {
  const _BobbingMochi({
    required this.character,
    required this.bob,
    required this.size,
    this.haloColor,
  });

  final MochiCharacter character;
  final AnimationController bob;
  final double size;
  final Color? haloColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: bob,
      builder: (context, child) {
        // Soft sine bob — ±3px so the companion feels alive without
        // distracting during a long chat read.
        final dy = math.sin(bob.value * 2 * math.pi) * 3;
        return Transform.translate(
          offset: Offset(0, dy),
          child: child,
        );
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (haloColor != null)
            Container(
              width: size + 16,
              height: size + 16,
              decoration: BoxDecoration(
                color: haloColor,
                shape: BoxShape.circle,
              ),
            ),
          SizedBox(
            width: size,
            height: size,
            child: CharacterWidget(character: character, size: size),
          ),
        ],
      ),
    );
  }
}
