import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/app/router.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/ui/painters/character_painter.dart';
import 'package:pally/core/ui/pally_delete_tutor_dialog.dart';
import 'package:pally/core/ui/typing_indicator.dart';
import 'package:pally/shared/models/avatar.dart';
import 'package:pally/shared/models/chat_message.dart';
import 'package:pally/core/ui/pally_toast.dart';
import 'package:pally/features/chat/presentation/chat_view_model.dart';
import 'package:pally/features/home/presentation/home_view_model.dart';
import 'package:pally/features/progress/presentation/level_up_controller.dart';
import 'package:pally/features/chat/presentation/widgets/photo_message_bubble.dart';
import 'package:pally/features/chat/presentation/widgets/photo_processing_bubble.dart';
import 'package:pally/features/chat/presentation/widgets/homework_scan_result_bubble.dart';
import 'package:pally/features/chat/widgets/teaching_mode_toggle.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.avatarId});

  final String avatarId;

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
    // Restore scroll position once messages are loaded
    WidgetsBinding.instance.addPostFrameCallback((_) => _restoreScroll());
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
        PallyToast.error(context, next.error!);
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
        child: Column(
          children: [
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
              child: _InputBar(
                controller: _textController,
                focusNode: _focusNode,
                canSend: state.canSend,
                onSend: _sendMessage,
                onCameraPressed: _onCameraPressed,
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

    return Container(
      height: 64 + MediaQuery.of(context).padding.top,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.outline)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                const HomeRoute().go(context);
              }
            },
          ),
          if (avatar != null)
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: avatar!.character.bgColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CharacterWidget(character: avatar!.character, size: 32),
              ),
            )
          else
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                  color: AppColors.purpleL, shape: BoxShape.circle),
              child: const Icon(Icons.smart_toy_outlined,
                  color: AppColors.purple, size: 20),
            ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              avatar?.name ?? 'Loading…',
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Teaching mode toggle
          TeachingModeToggle(
            mode: chatState.teachingMode,
            onToggle: () =>
                ref.read(chatViewModelProvider(avatarId).notifier).toggleMode(),
            enabled: chatState.canSend,
          ),
          const SizedBox(width: AppSpacing.xs),
          IconButton(
            icon: const Icon(Icons.school_outlined,
                color: AppColors.purple),
            onPressed: () => TeachMochiRoute(avatarId: avatarId).push(context),
            tooltip: 'Teach Mochi (Feynman)',
          ),
          IconButton(
            icon:
                const Icon(Icons.upload_file_outlined, color: AppColors.text2),
            onPressed: () => UploadRoute(avatarId: avatarId).push(context),
            tooltip: 'Add Knowledge',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.text2),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            onSelected: (value) async {
              if (value == 'delete' && chatState.avatar != null) {
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
                    // Pop the chat screen to return to whatever pushed it.
                    // Using .pop() instead of HomeRoute().go() avoids a stack
                    // reset that races with the popup menu's own pop.
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
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete_outline_rounded,
                        color: AppColors.coral, size: 18),
                    const SizedBox(width: 10),
                    Text('Delete tutor',
                        style: AppTextStyles.body.copyWith(
                            fontSize: 13, color: AppColors.coral)),
                  ],
                ),
              ),
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
    final itemCount = messages.length + trailingCount;

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        // Trailing typing indicator
        if (isTyping && index == messages.length) {
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
            index == messages.length + (isTyping ? 1 : 0)) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: PhotoProcessingBubble(
              questions: List.from(processingPhotoQuestions),
            ),
          );
        }

        return _MessageBubble(message: messages[index], avatarId: avatarId);
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
                      : Text(
                          message.content,
                          style: AppTextStyles.body.copyWith(
                            color: _isUser ? Colors.white : AppColors.text1,
                          ),
                        ),
            ),
          ),
        ),
        if (!_isUser && message.sources.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.tealL,
                borderRadius: BorderRadius.circular(6),
                border:
                    Border.all(color: AppColors.teal.withValues(alpha: 0.4)),
              ),
              child: Text(
                '📖 from your notes',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.teal,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
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

// ── Welcome prompt ────────────────────────────────────────────────────────────

class _WelcomePrompt extends StatelessWidget {
  const _WelcomePrompt();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.chat_bubble_outline_rounded,
                size: 64, color: AppColors.text3),
            const SizedBox(height: AppSpacing.md),
            Text('Start the conversation!',
                style: AppTextStyles.title, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Ask your tutor anything, or tap 📷 to snap a homework question!',
              style: AppTextStyles.body.copyWith(color: AppColors.text2),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
