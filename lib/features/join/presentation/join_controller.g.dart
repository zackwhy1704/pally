// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'join_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$joinControllerHash() => r'fc16cb6f878790173505e0308d90e3d0dfdb6bd4';

/// Orchestrates the Join surface: resolve a code to a name (for the mandatory
/// confirmation), then commit through the EXISTING backends — class redeem and
/// group join. Never auto-joins; the screen always confirms first.
///
/// Copied from [JoinController].
@ProviderFor(JoinController)
final joinControllerProvider =
    AutoDisposeNotifierProvider<JoinController, void>.internal(
  JoinController.new,
  name: r'joinControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$joinControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$JoinController = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
