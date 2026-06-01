import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/core/ui/pally_loading_spinner.dart';
import 'package:pally/shared/widgets/app_error_view.dart';
import 'package:pally/shared/widgets/app_empty_view.dart';

/// Renders an [AsyncValue<T>] into the standard four-state widget set:
///  • loading → [PallyLoadingSpinner]
///  • error   → [AppErrorView] with retry button
///  • empty   → [AppEmptyView] (when [isEmpty] returns true for the data)
///  • data    → [data] builder
///
/// Use this instead of hand-rolling `.when(...)` on every screen.
///
/// ```dart
/// AppAsync<List<Avatar>>(
///   value: ref.watch(avatarListProvider),
///   data: (avatars) => AvatarGrid(avatars: avatars),
///   isEmpty: (list) => list.isEmpty,
///   emptyMessage: 'No Mochis yet — tap + to create one.',
///   onRetry: () => ref.invalidate(avatarListProvider),
/// )
/// ```
class AppAsync<T> extends StatelessWidget {
  const AppAsync({
    super.key,
    required this.value,
    required this.data,
    this.isEmpty,
    this.emptyMessage = 'Nothing here yet.',
    this.emptyEmoji = '🧠',
    this.emptyAction,
    this.errorMessage,
    this.onRetry,
    this.loadingWidget,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final bool Function(T data)? isEmpty;
  final String emptyMessage;
  final String emptyEmoji;
  final Widget? emptyAction;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final Widget? loadingWidget;

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () => loadingWidget ?? const PallyLoadingSpinner(),
      error: (e, _) => AppErrorView(
        message: errorMessage ?? _defaultError(e),
        onRetry: onRetry,
      ),
      data: (d) {
        if (isEmpty != null && isEmpty!(d)) {
          return AppEmptyView(
            message: emptyMessage,
            emoji: emptyEmoji,
            action: emptyAction,
          );
        }
        return data(d);
      },
    );
  }

  static String _defaultError(Object e) {
    // Never surface raw exception text — keep it user-safe.
    return 'Something went wrong. Pull down to retry.';
  }
}
