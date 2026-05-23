import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/app/router.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/ui/painters/character_painter.dart';
import 'package:pally/core/ui/typing_indicator.dart';
import 'package:pally/shared/models/avatar.dart';
import 'package:pally/shared/models/chat_message.dart';
import 'package:pally/core/ui/pally_toast.dart';
import 'package:pally/features/chat/presentation/chat_view_model.dart';
import 'package:pally/features/chat/presentation/widgets/photo_message_bubble.dart';
import 'package:pally/features/chat/presentation/widgets/photo_processing_bubble.dart';
import 'package:pally/features/chat/presentation/widgets/homework_scan_result_bubble.dart';

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

  @override
  void dispose() {
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
    final vm = ref.read(chatViewModelProvider(widget.avatarId).notifier);

    ref.listen<ChatState>(chatViewModelProvider(widget.avatarId), (prev, next) {
      _scrollToBottom();
      if (next.error != null && prev?.error != next.error) {
        PallyToast.error(context, next.error!);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: _ChatAppBar(avatar: state.avatar, avatarId: widget.avatarId),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _MessageList(
                messages: state.sortedMessages,
                isTyping: state.isTyping,
                isProcessingPhoto: state.isProcessingPhoto,
                processingPhotoQuestions: state.processingPhotoQuestions,
                scrollController: _scrollController,
              ),
            ),
            if (!state.isTyping &&
                !state.isProcessingPhoto &&
                state.messages.isNotEmpty)
              _QuickReplies(
                replies: vm.quickReplies,
                onTap: _sendMessage,
              ),
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
    );
  }
}

// ── App bar ───────────────────────────────────────────────────────────────────

class _ChatAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const _ChatAppBar({required this.avatar, required this.avatarId});

  final Avatar? avatar;
  final String avatarId;

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = avatar?.pedagogyMode ?? PedagogyMode.socratic;
    final vm = ref.read(chatViewModelProvider(avatarId).notifier);

    return Container(
      height: 72 + MediaQuery.of(context).padding.top,
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
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: avatar!.character.bgColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CharacterWidget(character: avatar!.character, size: 38),
              ),
            )
          else
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                  color: AppColors.purpleL, shape: BoxShape.circle),
              child: const Icon(Icons.smart_toy_outlined,
                  color: AppColors.purple, size: 24),
            ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(avatar?.name ?? 'Loading…', style: AppTextStyles.title),
                Row(
                  children: [
                    Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                            color: AppColors.teal, shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    Text('Online',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.teal)),
                  ],
                ),
              ],
            ),
          ),
          // P5: Pedagogy mode toggle pill
          GestureDetector(
            onTap: () => vm.togglePedagogyMode(),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm, vertical: 4),
              decoration: BoxDecoration(
                color: mode == PedagogyMode.socratic
                    ? AppColors.purpleL
                    : AppColors.tealL,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: mode == PedagogyMode.socratic
                      ? AppColors.purple.withValues(alpha: 0.4)
                      : AppColors.teal.withValues(alpha: 0.4),
                ),
              ),
              child: Text(
                mode == PedagogyMode.socratic ? '💬 Socratic' : '📖 Direct',
                style: AppTextStyles.caption.copyWith(
                  color: mode == PedagogyMode.socratic
                      ? AppColors.purple
                      : AppColors.teal,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          IconButton(
            icon:
                const Icon(Icons.upload_file_outlined, color: AppColors.text2),
            onPressed: () => UploadRoute(avatarId: avatarId).push(context),
            tooltip: 'Add Knowledge',
          ),
        ],
      ),
    );
  }
}

// ── Message list ──────────────────────────────────────────────────────────────

class _MessageList extends StatelessWidget {
  const _MessageList({
    required this.messages,
    required this.isTyping,
    required this.isProcessingPhoto,
    required this.processingPhotoQuestions,
    required this.scrollController,
  });

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

        return _MessageBubble(message: messages[index]);
      },
    );
  }
}

// ── Message bubble router ─────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: switch (message.messageType) {
        MessageType.photo => PhotoMessageBubble(message: message),
        MessageType.homeworkResult when message.scanResult != null =>
          HomeworkScanResultBubble(result: message.scanResult!),
        _ => _TextBubble(message: message),
      },
    );
  }
}

class _TextBubble extends StatelessWidget {
  const _TextBubble({required this.message});

  final ChatMessage message;

  bool get _isUser => message.role == MessageRole.user;

  @override
  Widget build(BuildContext context) {
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
      ],
    );
  }
}

// ── Quick replies ─────────────────────────────────────────────────────────────

class _QuickReplies extends StatelessWidget {
  const _QuickReplies({required this.replies, required this.onTap});

  final List<String> replies;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: replies.length,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(right: AppSpacing.sm),
          child: ActionChip(
            label: Text(replies[index]),
            onPressed: () => onTap(replies[index]),
            backgroundColor: AppColors.surface,
            side: const BorderSide(color: AppColors.outline),
            labelStyle: AppTextStyles.bodySmall.copyWith(
              color: AppColors.purple,
              fontWeight: FontWeight.w600,
            ),
            shape: const StadiumBorder(),
          ),
        ),
      ),
    );
  }
}

// ── Input bar ─────────────────────────────────────────────────────────────────

class _InputBar extends StatefulWidget {
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
  State<_InputBar> createState() => _InputBarState();
}

class _InputBarState extends State<_InputBar> {
  // ignore: prefer_final_fields
  bool _isListening = false;

  void _toggleMic() async {
    if (!mounted) return;
    // Placeholder: actual SpeechToText integration would go here.
    // For now, show a snackbar telling the user it's coming.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎤 Voice input — tap & speak! (coming in next update)'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canSend = widget.canSend;
    final controller = widget.controller;
    final focusNode = widget.focusNode;
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
      child: SafeArea(
        top: false,
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
                onSubmitted: canSend ? widget.onSend : null,
                maxLines: null,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),

            // Mic button — green
            GestureDetector(
              onTap: canSend ? _toggleMic : null,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _isListening ? AppColors.green : AppColors.greenL,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: canSend ? AppColors.green : AppColors.outline,
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  _isListening ? Icons.mic : Icons.mic_none_rounded,
                  color: canSend ? AppColors.green : AppColors.text3,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),

            // Camera button — teal
            GestureDetector(
              onTap: canSend ? widget.onCameraPressed : null,
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
              onPressed: canSend ? () => widget.onSend(controller.text) : null,
              backgroundColor: canSend ? AppColors.purple : AppColors.outline,
              elevation: 0,
              child: const Icon(Icons.send_rounded, color: Colors.white),
            ),
          ],
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
