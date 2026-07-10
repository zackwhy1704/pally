// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_account_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$deleteAccountViewModelHash() =>
    r'393abbd71e3e3caf35b3cce48ab17dea31341643';

/// Drives the account-deletion request flow (grace/re-auth). All network access
/// lives here, never in the screen. Deletion enters a 14-day restore window; the
/// screen shows the scheduled state on success.
///
/// Copied from [DeleteAccountViewModel].
@ProviderFor(DeleteAccountViewModel)
final deleteAccountViewModelProvider = AutoDisposeNotifierProvider<
    DeleteAccountViewModel, DeleteAccountState>.internal(
  DeleteAccountViewModel.new,
  name: r'deleteAccountViewModelProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$deleteAccountViewModelHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DeleteAccountViewModel = AutoDisposeNotifier<DeleteAccountState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
