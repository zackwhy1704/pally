// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entitlement_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$entitlementVmHash() => r'93972c6d23ea4c730a529b3ed6ad6b0a9c642a6e';

/// Premium gate state. Refreshed on app resume + after returning from
/// Stripe checkout. Defensive unwrap mirrors the working view models.
///
/// Copied from [EntitlementVm].
@ProviderFor(EntitlementVm)
final entitlementVmProvider =
    AutoDisposeAsyncNotifierProvider<EntitlementVm, Entitlement>.internal(
  EntitlementVm.new,
  name: r'entitlementVmProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$entitlementVmHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$EntitlementVm = AutoDisposeAsyncNotifier<Entitlement>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
