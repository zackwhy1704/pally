import 'package:flutter/material.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';

/// App-root messenger key. Set on MaterialApp.router so every snackbar is shown
/// through the ONE root ScaffoldMessenger, decoupled from any screen's
/// BuildContext. Showing via `ScaffoldMessenger.of(context)` binds the call to the
/// caller's context, which can throw "Looking up a deactivated widget's ancestor is
/// unsafe" if the screen disposes while the snackbar animates. Routing through the
/// key avoids the context lookup entirely.
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

/// Show a snackbar through the app-root messenger — NEVER `ScaffoldMessenger.of(context)`.
/// Safe to call even if the widget that triggered it has since been disposed.
void showAppSnackBar(SnackBar snackBar, {bool hideCurrent = true}) {
  final messenger = rootScaffoldMessengerKey.currentState;
  if (messenger == null) return; // messenger not mounted yet — drop silently
  if (hideCurrent) messenger.hideCurrentSnackBar();
  messenger.showSnackBar(snackBar);
}

abstract class PallyToast {
  /// [context] is retained for call-site compatibility but intentionally unused —
  /// the snackbar is shown through [rootScaffoldMessengerKey], not the context, so
  /// it can't throw a deactivated-ancestor error when the caller is disposing.
  static void show(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    showAppSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.body.copyWith(color: Colors.white),
        ),
        backgroundColor: isError ? AppColors.coral : AppColors.text1,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        duration: Duration(seconds: isError ? 4 : 2),
      ),
    );
  }

  static void error(BuildContext context, String message) =>
      show(context, message, isError: true);

  static void success(BuildContext context, String message) =>
      show(context, message);
}
