import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';

/// Shown when the Socratic escape hatch fires (after N attempts).
/// Auto-dismisses after [autoDismissSeconds] seconds.
class EscapeHatchNotification extends StatefulWidget {
  const EscapeHatchNotification({
    super.key,
    required this.onDismiss,
    this.autoDismissSeconds = 3,
    this.topicLabel,
  });

  final VoidCallback onDismiss;
  final int autoDismissSeconds;
  final String? topicLabel;

  @override
  State<EscapeHatchNotification> createState() =>
      _EscapeHatchNotificationState();
}

class _EscapeHatchNotificationState extends State<EscapeHatchNotification>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();

    _timer = Timer(Duration(seconds: widget.autoDismissSeconds), _dismiss);
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      if (mounted) widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.purpleL,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: AppColors.purple.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: AppColors.purple.withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Text('💡', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Great effort! Here's the answer",
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.purple,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (widget.topicLabel != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Added "${widget.topicLabel}" to your practice list',
                      style: AppTextStyles.caption.copyWith(
                          color: AppColors.text2),
                    ),
                  ],
                ],
              ),
            ),
            GestureDetector(
              onTap: _dismiss,
              child: const Icon(Icons.close_rounded,
                  color: AppColors.text3, size: 16),
            ),
          ],
        ),
      ),
    );
  }
}
