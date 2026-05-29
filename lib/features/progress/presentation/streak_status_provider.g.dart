// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'streak_status_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$streakStatusVmHash() => r'a26ecde1e390a8925be9c5c5f5c38fd76afc51f3';

/// Streak card data — separate from ProgressViewModel so a streak refresh
/// after activity doesn't force the whole dashboard to reload.
///
/// Copied from [StreakStatusVm].
@ProviderFor(StreakStatusVm)
final streakStatusVmProvider =
    AutoDisposeAsyncNotifierProvider<StreakStatusVm, StreakStatus>.internal(
  StreakStatusVm.new,
  name: r'streakStatusVmProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$streakStatusVmHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$StreakStatusVm = AutoDisposeAsyncNotifier<StreakStatus>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
