// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blocked_users_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$blockedUsersVmHash() => r'c7bcbce03d69d8d1ade667b76443f3a191ff458e';

/// Owns the network for the "Blocked people" screen.
///
/// Data access lives here, not in the widget: screens render state, they do not
/// fetch (enforced by `test/guard/layering_guard_test.dart`).
///
/// The list is read from the SERVER rather than cached locally — blocking is
/// server-enforced, so the server is the only honest source of who is blocked.
///
/// Copied from [BlockedUsersVm].
@ProviderFor(BlockedUsersVm)
final blockedUsersVmProvider = AutoDisposeAsyncNotifierProvider<BlockedUsersVm,
    List<BlockedUser>>.internal(
  BlockedUsersVm.new,
  name: r'blockedUsersVmProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$blockedUsersVmHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BlockedUsersVm = AutoDisposeAsyncNotifier<List<BlockedUser>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
