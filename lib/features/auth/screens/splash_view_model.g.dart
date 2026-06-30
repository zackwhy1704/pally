// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'splash_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$resolveStartRouteHash() => r'32bdbb8ed9b6a07bd1e5388c025ab625b63ccf6e';

/// Resolves the route the app should navigate to after the splash screen:
/// runs the /auth/me check, syncs any missing auth flags, and returns the
/// appropriate deep-link string.  The splash screen owns animation timing and
/// navigation; this provider owns the auth logic.
///
/// Copied from [resolveStartRoute].
@ProviderFor(resolveStartRoute)
final resolveStartRouteProvider = AutoDisposeFutureProvider<String>.internal(
  resolveStartRoute,
  name: r'resolveStartRouteProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$resolveStartRouteHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ResolveStartRouteRef = AutoDisposeFutureProviderRef<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
