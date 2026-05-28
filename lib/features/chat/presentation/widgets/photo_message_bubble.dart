import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/ui/adaptive_layout.dart';
import 'package:pally/shared/models/chat_message.dart';

class PhotoMessageBubble extends StatelessWidget {
  const PhotoMessageBubble({super.key, required this.message});

  final ChatMessage message;

  void _showFullScreen(BuildContext context) {
    if (message.imagePath == null) return;
    showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            InteractiveViewer(
              child: Image.file(
                File(message.imagePath!),
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            Positioned(
              top: 40,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close_rounded,
                    color: Colors.white, size: 32),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = message.imagePath;
    final questionCount = message.photoQuestions.length;

    final bubbleWidth = Adaptive.width(context, 0.72, max: 274);

    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () => _showFullScreen(context),
        child: Container(
          width: bubbleWidth,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(4),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            border: Border.all(color: AppColors.outline, width: 0.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F1F1733),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              if (imagePath != null)
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(15)),
                  child: Stack(
                    children: [
                      Image.file(
                        File(imagePath),
                        width: bubbleWidth,
                        height: 92,
                        fit: BoxFit.cover,
                      ),
                      if (questionCount > 0)
                        Positioned(
                          right: 8,
                          bottom: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.55),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '📷 $questionCount question${questionCount == 1 ? '' : 's'} detected',
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.white,
                                fontSize: 8,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              // Caption
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  message.content.isNotEmpty
                      ? message.content
                      : '📷 Homework photo',
                  style: AppTextStyles.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
