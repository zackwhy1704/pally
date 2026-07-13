import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:pally/features/home/presentation/home_view_model.dart';
import 'package:pally/features/modules/presentation/module_list_view_model.dart';
import 'package:pally/shared/models/avatar.dart';

part 'avatar_hub_view_model.g.dart';

/// Immutable data the Avatar Hub renders: the avatar identity + a module summary.
/// Derivation (count, average mastery) lives HERE, never in the widget.
class AvatarHubData {
  const AvatarHubData({
    required this.avatar,
    required this.moduleCount,
    required this.avgMasteryPct,
  });

  final Avatar avatar;
  final int moduleCount;

  /// Average mastery across ALL modules, untouched modules counting as 0 — the
  /// honest "how far through this subject am I" number (not an average over only
  /// the started ones, which would flatter progress).
  final int avgMasteryPct;

  bool get hasModules => moduleCount > 0;
}

/// The Avatar Hub's single fetch-on-open view model.
///
/// Fetch discipline (the module-player lesson): the awaited fetch IS the async
/// `build` return — NOT a fire-and-forget side effect kicked off from a sync
/// `build()`/rebuild path. `module_player_view_model.dart:172` used a sync
/// `build()` that called `_loadModule()` (a GET + `/start` POST) and, being
/// autoDispose, re-fired it on every reconstruction. Here Riverpod caches the
/// resulting `AsyncValue` and only re-runs `build` on invalidation (a
/// RefreshIndicator → `ref.invalidate`), never on a widget rebuild. No
/// side-effectful call is ever made from a widget build path.
///
/// One new fetch on open (the module list); the avatar identity is read from the
/// already-warm home avatar list, and quiz status is composed lazily by the Quiz
/// row itself (see `_QuizHubRow`) rather than blocking the hero on it.
@riverpod
class AvatarHubViewModel extends _$AvatarHubViewModel {
  @override
  Future<AvatarHubData> build(String avatarId) async {
    final avatars = await ref.watch(homeViewModelProvider.future);
    Avatar? avatar;
    for (final a in avatars) {
      if (a.id == avatarId) {
        avatar = a;
        break;
      }
    }
    if (avatar == null) {
      throw StateError('Avatar $avatarId not found in the library');
    }

    final modules =
        await ref.watch(moduleListViewModelProvider(avatarId).future);
    final avgMasteryPct = modules.isEmpty
        ? 0
        : (modules.map((m) => m.masteryPct).reduce((a, b) => a + b) /
                modules.length)
            .round();

    return AvatarHubData(
      avatar: avatar,
      moduleCount: modules.length,
      avgMasteryPct: avgMasteryPct,
    );
  }
}
