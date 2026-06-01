import 'package:flutter/material.dart';
import 'package:pally/core/theme/app_colors.dart';

/// Consistent scaffold surface: `AppColors.bg`, SafeArea, optional title.
/// Use instead of raw `Scaffold` to guarantee the background colour token
/// is applied everywhere and never drifts to the theme default.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.leading,
    this.actions,
    this.bottomBar,
    this.floatingActionButton,
    this.resizeToAvoidBottomInset = true,
    this.safeAreaBottom = true,
  });

  final Widget body;
  final String? title;
  final Widget? leading;
  final List<Widget>? actions;
  final Widget? bottomBar;
  final Widget? floatingActionButton;
  final bool resizeToAvoidBottomInset;
  final bool safeAreaBottom;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: title != null || leading != null || actions != null
          ? AppBar(
              backgroundColor: AppColors.bg,
              elevation: 0,
              leading: leading,
              title: title != null
                  ? Text(title!,
                      style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text1))
                  : null,
              actions: actions,
            )
          : null,
      body: SafeArea(
        bottom: safeAreaBottom,
        child: body,
      ),
      bottomNavigationBar: bottomBar,
      floatingActionButton: floatingActionButton,
    );
  }
}
