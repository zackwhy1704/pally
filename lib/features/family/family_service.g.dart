// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'family_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$familyServiceHash() => r'29a1ec3ce01fb8b452d354cd94c440a8633d4ff9';

/// Thin wrapper over /api/v1/account/{link-code,claim,family}. The
/// AccountController shipped in a prior milestone; this only exposes the
/// methods the family UI needs and translates Dio errors into a small set
/// of strings the screens can branch on.
///
/// Copied from [familyService].
@ProviderFor(familyService)
final familyServiceProvider = AutoDisposeProvider<FamilyService>.internal(
  familyService,
  name: r'familyServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$familyServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FamilyServiceRef = AutoDisposeProviderRef<FamilyService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
