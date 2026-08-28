import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/ui/pally_toast.dart';
import 'package:pally/features/groups/presentation/blocked_users_view_model.dart';
import 'package:pally/l10n/app_localizations.dart';

/// "Blocked people" — the unblock surface.
///
/// App Store Guideline 1.2 expects blocking to be reversible, and reversibility
/// is useless if a student cannot find who they blocked. A 13-year-old who
/// mis-taps must not permanently lose a classmate's study notes with no recourse.
///
/// Renders state only — the network lives in BlockedUsersVm.
class BlockedUsersScreen extends ConsumerWidget {
  const BlockedUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(blockedUsersVmProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: Text(l.blockedListTitle, style: AppTextStyles.title)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        // Persistent inline error with a Retry — never a toast for a primary load.
        error: (_, __) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: AppSpacing.card,
                // Deliberately NOT the raw exception: a student should not be
                // shown a Dio stack string. The detail is in the log; the user
                // gets a sentence and a way forward.
                child: Text(l.blockedListLoadFailed,
                    style: AppTextStyles.body, textAlign: TextAlign.center),
              ),
              TextButton(
                onPressed: () => ref.read(blockedUsersVmProvider.notifier).refresh(),
                child: Text(l.commonRetry),
              ),
            ],
          ),
        ),
        data: (list) => list.isEmpty
            ? Center(
                child: Padding(
                  padding: AppSpacing.card,
                  child: Text(l.blockedListEmpty,
                      style: AppTextStyles.body, textAlign: TextAlign.center),
                ),
              )
            : ListView.builder(
                padding: AppSpacing.card,
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final b = list[i];
                  return ListTile(
                    leading: const Icon(Icons.person_off_outlined,
                        color: AppColors.text3),
                    title: Text(b.displayName, style: AppTextStyles.body),
                    trailing: TextButton(
                      onPressed: () async {
                        await ref
                            .read(blockedUsersVmProvider.notifier)
                            .unblock(b.userId);
                        if (context.mounted) {
                          PallyToast.success(
                              context, l.blockedListUnblocked(b.displayName));
                        }
                      },
                      child: Text(l.blockedListUnblock),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
