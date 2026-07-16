import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/app/router.dart';
import 'package:pally/core/ui/adaptive_center.dart';
import 'package:pally/core/ui/math_text.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/shared/widgets/mochi_placeholder.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_sizing.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pally/core/ui/painters/character_painter.dart';
import 'package:pally/core/ui/pally_delete_tutor_dialog.dart';
import 'package:pally/core/ui/typing_indicator.dart';
import 'package:pally/shared/models/avatar.dart';
import 'package:pally/features/weakness/presentation/weakness_focus_card.dart';
import 'package:pally/shared/models/chat_message.dart';
import 'package:pally/core/ui/pally_toast.dart';
import 'package:pally/features/chat/presentation/chat_view_model.dart';
import 'package:pally/features/home/presentation/home_view_model.dart';
import 'package:pally/features/progress/presentation/level_up_controller.dart';
import 'package:pally/features/chat/presentation/widgets/photo_message_bubble.dart';
import 'package:pally/features/chat/presentation/widgets/photo_processing_bubble.dart';
import 'package:pally/features/chat/presentation/widgets/homework_scan_result_bubble.dart';
import 'package:pally/features/chat/widgets/mochi_tip_coach.dart';
import 'package:pally/features/chat/widgets/mode_coach_mark.dart';
import 'package:pally/features/chat/widgets/teaching_mode_toggle.dart';
import 'package:pally/features/chat/providers/chat_usage_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.avatarId, this.seed});

  final String avatarId;

  /// Optional composer PREFILL — pre-fills the message box (does NOT auto-send).
  final String? seed;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _scrollController = ScrollController();
  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _scrollSaveTimer;
  bool _scrollRestored = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Prefill (NOT auto-send) the composer from a nudge seed, so the student reviews +
    // taps send themselves — keeps their agency and doesn't fire an LLM call unprompted.
    final seed = widget.seed;
    if (seed != null && seed.trim().isNotEmpty) {
      _textController.text = seed;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restoreScroll();
    });
  }

  void _restoreScroll() {
    if (_scrollRestored) return;
    final offset =
        ref.read(chatViewModelProvider(widget.avatarId)).savedScrollOffset;
    if (offset > 0 && _scrollController.hasClients) {
      _scrollController.jumpTo(
        offset.clamp(0.0, _scrollController.position.maxScrollExtent),
      );
      _scrollRestored = true;
    }
  }

  void _onScroll() {
    _scrollSaveTimer?.cancel();
    _scrollSaveTimer = Timer(const Duration(milliseconds: 500), () {
      if (_scrollController.hasClients) {
        ref
            .read(chatViewModelProvider(widget.avatarId).notifier)
            .saveScrollOffset(_scrollController.offset);
      }
    });
  }

  @override
  void dispose() {
    _scrollSaveTimer?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    _textController.clear();
    ref.read(chatViewModelProvider(widget.avatarId).notifier).sendMessage(text);
    // Optimistic counter bump so "N left today" updates in the same frame
    // as the send — server /usage/today reconciles on next refresh.
    ref.read(chatUsageNotifierProvider.notifier).recordSent();
    _scrollToBottom();
  }

  Future<void> _onCameraPressed() async {
    final String? photoPath = await const CameraRoute().push<String>(context);
    if (photoPath == null || !mounted) return;
    await PhotoPreviewRoute(avatarId: widget.avatarId, $extra: photoPath)
        .push<void>(context);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatViewModelProvider(widget.avatarId));

    ref.listen<ChatState>(chatViewModelProvider(widget.avatarId), (prev, next) {
      _scrollToBottom();
      if (next.error != null && prev?.error != next.error) {
        PallyToast.error(context, next.error ?? 'Something went wrong.');
      }
      // Level-up from photo solve (or stamped before this screen rebuilt
      // from a session-end credit). Fire once then clear so it doesn't
      // re-trigger on rebuild.
      if (next.pendingLevelUp > 0 &&
          next.pendingLevelUp != prev?.pendingLevelUp) {
        final newLevel = next.pendingLevelUp;
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await LevelUpController.maybeCelebrate(
            context,
            levelledUp: true,
            newLevel: newLevel,
          );
          if (context.mounted) {
            ref
                .read(chatViewModelProvider(widget.avatarId).notifier)
                .clearPendingLevelUp();
          }
        });
      }
    });

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.bg,
      // Handle keyboard inset manually so only the input bar moves, not the
      // entire list — this matches WhatsApp/Telegram behaviour.
      resizeToAvoidBottomInset: false,
      appBar: _ChatAppBar(avatar: state.avatar, avatarId: widget.avatarId),
      body: SafeArea(
        // We manage bottom padding ourselves via AnimatedContainer below.
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                // Weakness focus (pilot, flag-gated) — visibly closes the loop:
                // what Mochi is focusing on + recently-improved wins. Renders
                // nothing until the pilot is on and there's content.
                if (state.avatar != null)
                  WeaknessFocusCard(
                      backendSubject: toBackendSubject(state.avatar!.subject)),
                // Message list — tapping it dismisses the keyboard
                Expanded(
                  child: GestureDetector(
                    onTap: () => FocusScope.of(context).unfocus(),
                    behavior: HitTestBehavior.opaque,
                    child: _MessageList(
                      avatarId: widget.avatarId,
                      messages: state.sortedMessages,
                      isTyping: state.isTyping,
                      isProcessingPhoto: state.isProcessingPhoto,
                      processingPhotoQuestions: state.processingPhotoQuestions,
                      scrollController: _scrollController,
                    ),
                  ),
                ),
                // Input bar slides up with the keyboard; drops back when it closes.
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOut,
                  padding: EdgeInsets.only(
                    bottom: bottomInset > 0 ? bottomInset : bottomPadding,
                  ),
                  color: AppColors.bg,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // GM4: Gentle once-per-session nudge when ANSWER mode active
                      if (state.teachingMode == TeachingMode.direct)
                        const AnswerModeNudge(),
                      const DailyChatHint(),
                      _InputBar(
                        controller: _textController,
                        focusNode: _focusNode,
                        canSend: state.canSend,
                        onSend: _sendMessage,
                        onCameraPressed: _onCameraPressed,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Floating tip coach — sits just above the input bar.
            Positioned(
              right: 12,
              bottom: 76 + bottomPadding,
              child: MochiTipCoach(
                avatarId: widget.avatarId,
                keyboardOpen: bottomInset > 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── App bar ───────────────────────────────────────────────────────────────────

class _ChatAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const _ChatAppBar({required this.avatar, required this.avatarId});

  final Avatar? avatar;
  final String avatarId;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(chatViewModelProvider(avatarId));
    final isCentre = avatar?.centreManaged ?? false;

    // Derive the AppBar content height from the theme so it adapts if the
    // theme ever changes (no magic numbers).
    final topPad = MediaQuery.of(context).padding.top;
    final barHeight = preferredSize.height;

    return Container(
      height: barHeight + topPad,
      padding: EdgeInsets.only(top: topPad),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.outline)),
      ),
      child: Row(
        // crossAxisAlignment centres children on the content-height axis.
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ← Back — use GoRouter.of(context).pop() so the routing
          // system pops the correct navigator entry regardless of whether
          // the chat screen is on the root or a nested navigator.
          // Navigator.of(context).pop() was finding the shell's inner
          // navigator (which had no entries) and silently doing nothing.
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () {
              final router = GoRouter.of(context);
              if (router.canPop()) {
                router.pop();
              } else {
                const HomeRoute().go(context);
              }
            },
          ),
          // Avatar circle — AppSizing.avatarMd (36) is a design token.
          SizedBox(
            width: AppSizing.avatarMd,
            height: AppSizing.avatarMd,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: avatar != null
                    ? avatar!.character.bgColor
                    : AppColors.purpleL,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: avatar != null
                    ? CharacterWidget.forAvatar(avatar!, AppSizing.avatarSm)
                    : const Icon(Icons.smart_toy_outlined,
                        color: AppColors.purple, size: AppSizing.icon18),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),

          // Name text — Expanded(flex:1): takes 1 part of the remaining
          // space after fixed-width items (back, avatar, gap, menu) are
          // measured.  Using Expanded here (rather than a plain non-flex
          // child) guarantees the Row can NEVER overflow: flex children
          // fill exactly the leftover space and never exceed it.
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  avatar?.name ?? 'Loading…',
                  style:
                      AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (isCentre)
                  Text(
                    'Centre-curated answers only',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.text3),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),

          // Toggle — Expanded(flex:2): takes 2 parts of remaining space.
          // With both name and toggle inside Expanded, the Row always
          // distributes the remaining space proportionally — overflow is
          // mathematically impossible on any screen size.
          // The toggle's internal LayoutBuilder now receives a FINITE
          // maxWidth (its flex share), so the sliding-indicator half-width
          // is computed from actual available space, not MediaQuery.
          Expanded(
            flex: 2,
            child: TeachingModeToggle(
              mode: chatState.teachingMode,
              onToggle: () {
                ref
                    .read(chatViewModelProvider(avatarId).notifier)
                    .toggleMode();
                if (chatState.teachingMode == TeachingMode.direct) {
                  resetAnswerOnlyStreak();
                }
              },
              enabled: chatState.canSend,
            ),
          ),
          // ⋮ overflow menu — school + upload moved here to keep the bar
          // within screen width on 360dp phones.
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.text2),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            onSelected: (value) async {
              if (value == 'teach') {
                TeachMochiRoute(avatarId: avatarId).push(context);
              } else if (value == 'upload') {
                // Defensive: the upload menu item is already hidden for centre
                // classes (students can't upload — uploads are blocked
                // server-side). Guard the action too in case it's ever invoked.
                if (isCentre) return;
                UploadRoute(avatarId: avatarId).push(context);
              } else if (value == 'delete' && chatState.avatar != null) {
                final avatar = chatState.avatar!;
                final confirmed = await PallyDeleteTutorDialog.show(
                  context: context,
                  avatar: avatar,
                );
                if (confirmed == true && context.mounted) {
                  final ok = await ref
                      .read(homeViewModelProvider.notifier)
                      .deleteAvatar(avatar.id);
                  if (!context.mounted) return;
                  if (ok) {
                    HapticFeedback.heavyImpact();
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    } else {
                      const HomeRoute().go(context);
                    }
                    PallyToast.success(context, '${avatar.name} deleted');
                  } else {
                    PallyToast.error(context, 'Delete failed. Try again.');
                  }
                }
              }
            },
            itemBuilder: (_) => [
              if (!isCentre)
                PopupMenuItem(
                  value: 'teach',
                  child: Row(children: [
                    const Icon(Icons.school_outlined,
                        color: AppColors.purple, size: 18),
                    const SizedBox(width: 10),
                    Text('Teach Mochi',
                        style: AppTextStyles.body.copyWith(fontSize: 13)),
                  ]),
                ),
              if (!isCentre)
                PopupMenuItem(
                  value: 'upload',
                  child: Row(children: [
                    const Icon(Icons.upload_file_outlined,
                        color: AppColors.text2, size: 18),
                    const SizedBox(width: 10),
                    Text('Add knowledge',
                        style: AppTextStyles.body.copyWith(fontSize: 13)),
                  ]),
                ),
              if (!isCentre) ...[
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(children: [
                    const Icon(Icons.delete_outline_rounded,
                        color: AppColors.coral, size: 18),
                    const SizedBox(width: 10),
                    Text('Delete Mochi',
                        style: AppTextStyles.body.copyWith(
                            fontSize: 13, color: AppColors.coral)),
                  ]),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ── Message list ──────────────────────────────────────────────────────────────

class _MessageList extends StatelessWidget {
  const _MessageList({
    required this.avatarId,
    required this.messages,
    required this.isTyping,
    required this.isProcessingPhoto,
    required this.processingPhotoQuestions,
    required this.scrollController,
  });

  final String avatarId;
  final List<ChatMessage> messages;
  final bool isTyping;
  final bool isProcessingPhoto;
  final List processingPhotoQuestions;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty && !isTyping && !isProcessingPhoto) {
      return const _WelcomePrompt();
    }

    // Count trailing indicator slots
    final trailingCount = (isTyping ? 1 : 0) + (isProcessingPhoto ? 1 : 0);
    // +1 for the session disclaimer at index 0
    final itemCount = messages.length + trailingCount + 1;

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        // Item 0 — once-per-session safety disclaimer
        if (index == 0) return const _SessionDisclaimer();
        final adjusted = index - 1;
        // Trailing typing indicator (adjusted for disclaimer slot)
        if (isTyping && adjusted == messages.length) {
          return const Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.sm),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TypingIndicator(),
            ),
          );
        }
        // Trailing photo processing bubble
        if (isProcessingPhoto &&
            adjusted == messages.length + (isTyping ? 1 : 0)) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: PhotoProcessingBubble(
              questions: List.from(processingPhotoQuestions),
            ),
          );
        }

        return _MessageBubble(message: messages[adjusted], avatarId: avatarId);
      },
    );
  }
}

// ── Message bubble router ─────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.avatarId});

  final ChatMessage message;
  final String avatarId;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: switch (message.messageType) {
        MessageType.photo => PhotoMessageBubble(message: message),
        MessageType.homeworkResult when message.scanResult != null =>
          HomeworkScanResultBubble(result: message.scanResult!),
        _ => _TextBubble(message: message, avatarId: avatarId),
      },
    );
  }
}

class _TextBubble extends ConsumerWidget {
  const _TextBubble({required this.message, required this.avatarId});

  final ChatMessage message;
  final String avatarId;

  bool get _isUser => message.role == MessageRole.user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Failed-stream pill: tap to retry the last user message.
    if (message.isError) {
      return Align(
        alignment: Alignment.centerLeft,
        child: GestureDetector(
          onTap: () => ref
              .read(chatViewModelProvider(avatarId).notifier)
              .retryLastMessage(),
          child: Container(
            margin: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.xs),
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.coralL,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.coral, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded,
                    color: AppColors.coral, size: 16),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    message.error ?? message.content,
                    style: AppTextStyles.body.copyWith(color: AppColors.coral),
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.refresh_rounded,
                    color: AppColors.coral, size: 16),
              ],
            ),
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment:
          _isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Align(
          alignment: _isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: _isUser ? AppColors.purple : AppColors.purpleL,
                borderRadius: BorderRadius.only(
                  topLeft: _isUser
                      ? const Radius.circular(18)
                      : const Radius.circular(4),
                  topRight: _isUser
                      ? const Radius.circular(4)
                      : const Radius.circular(18),
                  bottomLeft: const Radius.circular(18),
                  bottomRight: const Radius.circular(18),
                ),
              ),
              child: message.content.isEmpty && message.isStreaming
                  ? const SizedBox(
                      width: 40,
                      height: 16,
                      child: Center(
                        child: LinearProgressIndicator(
                          color: AppColors.purple,
                          backgroundColor: AppColors.purpleL,
                        ),
                      ),
                    )
                  : message.content.isEmpty
                      ? Text(
                          'Hmm, I lost my train of thought. Ask me again!',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.text2,
                            fontStyle: FontStyle.italic,
                          ),
                        )
                      : MathText(
                          text: message.content,
                          style: AppTextStyles.body,
                          textColor: _isUser ? Colors.white : AppColors.text1,
                        ),
            ),
          ),
        ),
        if (!_isUser && message.sources.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: _SourceBadge(sources: message.sources),
          ),
        if (message.syncStatus == SyncStatus.failed)
          Padding(
            padding: const EdgeInsets.only(top: 2, right: 4, left: 4),
            child: GestureDetector(
              onTap: () => ref
                  .read(chatViewModelProvider(avatarId).notifier)
                  .retryMessage(message.id),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      size: 12, color: AppColors.coral),
                  const SizedBox(width: 3),
                  Text(
                    'Not synced — tap to retry',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.coral),
                  ),
                ],
              ),
            ),
          )
        else if (message.syncStatus == SyncStatus.pending)
          Padding(
            padding: const EdgeInsets.only(top: 2, right: 4, left: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 10,
                  height: 10,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: AppColors.text3,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'Sending…',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.text3),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ── Daily chat hint ───────────────────────────────────────────────────────────

/// Shows "{N} chats left today" when a free user is within 5 of the cap.
/// Hidden for premium users (no cap). Hidden when remaining is null
/// (loading / failed-fetch) so the chat input doesn't shift unexpectedly.
///
/// Exposed at library level (not private) so the widget test can render
/// it with overridden providers — kept const and stateless for clarity.
class DailyChatHint extends ConsumerWidget {
  const DailyChatHint({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usage = ref.watch(chatUsageNotifierProvider);
    if (usage == null || !usage.shouldWarn) {
      return const SizedBox.shrink();
    }
    final remaining = usage.remaining!;
    final emoji = remaining == 0
        ? '🌙'
        : remaining <= 2
            ? '⚡'
            : '✨';
    final copy = remaining == 0
        ? 'Daily chats done — come back tomorrow or go Premium.'
        : '$remaining message${remaining == 1 ? '' : 's'} left today';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: 6),
      color: AppColors.amberL,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              copy,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.text1,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Input bar ─────────────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.focusNode,
    required this.canSend,
    required this.onSend,
    required this.onCameraPressed,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool canSend;
  final ValueChanged<String> onSend;
  final VoidCallback onCameraPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.outline)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A1F1733),
            blurRadius: 10,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              enabled: canSend,
              decoration: InputDecoration(
                hintText: canSend ? 'Ask anything…' : 'Please wait…',
                hintStyle:
                    AppTextStyles.body.copyWith(color: AppColors.text3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppColors.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppColors.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide:
                      const BorderSide(color: AppColors.purple, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                filled: true,
                fillColor: AppColors.bg,
              ),
              style: AppTextStyles.body,
              textInputAction: TextInputAction.send,
              onSubmitted: canSend ? onSend : null,
              maxLines: null,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),

          // Camera button — teal
          GestureDetector(
            onTap: canSend ? onCameraPressed : null,
            child: Container(
              width: 44,
              height: 52,
              decoration: BoxDecoration(
                color: canSend ? AppColors.tealL : AppColors.outline,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: canSend ? AppColors.teal : AppColors.outline,
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '📷',
                    style: TextStyle(
                        fontSize: 18,
                        color: canSend ? null : AppColors.text3),
                  ),
                  Text(
                    'Snap',
                    style: AppTextStyles.caption.copyWith(
                      color: canSend ? AppColors.teal : AppColors.text3,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),

          // Send button — purple
          FloatingActionButton(
            mini: false,
            onPressed: canSend ? () => onSend(controller.text) : null,
            backgroundColor: canSend ? AppColors.purple : AppColors.outline,
            elevation: 0,
            child: const Icon(Icons.send_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

// ── Source badge ──────────────────────────────────────────────────────────────

class _SourceBadge extends StatelessWidget {
  const _SourceBadge({required this.sources});
  final List<String> sources;

  bool get _isGeneralKnowledge =>
      sources.length == 1 && sources.first == 'general-knowledge';

  @override
  Widget build(BuildContext context) {
    if (_isGeneralKnowledge) {
      return Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.amberL,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.amber.withValues(alpha: 0.4)),
        ),
        child: Text(
          '🌐 general knowledge — upload notes for tailored answers',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.amberText,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.tealL,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.teal.withValues(alpha: 0.4)),
      ),
      child: Text(
        '📖 from your notes',
        style: AppTextStyles.caption.copyWith(
          color: AppColors.teal,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Welcome prompt ────────────────────────────────────────────────────────────

class _WelcomePrompt extends StatelessWidget {
  const _WelcomePrompt();

  @override
  Widget build(BuildContext context) {
    return const AdaptiveCenter(
      padding: EdgeInsets.all(AppSpacing.xl),
      child: MochiPlaceholder(
        title: 'Start the conversation!',
        subtitle:
            'Ask your Mochi anything, or tap 📷 to snap a homework question!',
      ),
    );
  }
}

// ── Session disclaimer (D1) ───────────────────────────────────────────────────
// Shown once per session at the top of the message list. Uses SharedPreferences
// keyed by today's date so it re-appears the next day. Dismisses on tap.

class _SessionDisclaimer extends StatefulWidget {
  const _SessionDisclaimer();

  @override
  State<_SessionDisclaimer> createState() => _SessionDisclaimerState();
}

class _SessionDisclaimerState extends State<_SessionDisclaimer> {
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    _checkDismissed();
  }

  Future<void> _checkDismissed() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'chat_disclaimer_${DateTime.now().toIso8601String().substring(0, 10)}';
    if (mounted) setState(() => _dismissed = prefs.getBool(key) ?? false);
  }

  Future<void> _dismiss() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'chat_disclaimer_${DateTime.now().toIso8601String().substring(0, 10)}';
    await prefs.setBool(key, true);
    if (mounted) setState(() => _dismissed = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();
    return GestureDetector(
      onTap: _dismiss,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.surf2,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.outline),
        ),
        child: Row(
          children: [
            const Text('💡', style: TextStyle(fontSize: 14)),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Mochi can make mistakes — always double-check your work!',
                style:
                    AppTextStyles.bodySmall.copyWith(color: AppColors.text2),
              ),
            ),
            const Icon(Icons.close_rounded,
                size: 14, color: AppColors.text3),
          ],
        ),
      ),
    );
  }
}

/// Inline amber strip shown under a tutor message that contains a
/// calculation or a visual disclaimer (D2).
class DoubleCheckStrip extends StatelessWidget {
  const DoubleCheckStrip({
    super.key,
    this.calculatorVerified = false,
  });

  final bool calculatorVerified;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: AppSpacing.md, right: AppSpacing.md, bottom: AppSpacing.xs),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.amberL,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: AppColors.amber.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning_amber_rounded,
                    size: 12, color: AppColors.amber),
                const SizedBox(width: 4),
                Text(
                  'Double-check the numbers against your worksheet',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.amber),
                ),
              ],
            ),
          ),
          if (calculatorVerified) ...[
            const SizedBox(width: AppSpacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.greenL,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_rounded,
                      size: 12, color: AppColors.green),
                  const SizedBox(width: 4),
                  Text(
                    'checked with calculator',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.green),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
