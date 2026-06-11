// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consent_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$consentServiceHash() => r'0b500aee430194e57cbca7843433a890bfda812c';

/// Thin wrapper over the backend consent endpoints used by the AI-disclosure
/// gate:
///   GET  /api/v1/consent/status            -> reports consent flags
///   POST /api/v1/consent/ai-data-transfer  -> records AI data-transfer consent
///
/// Copied from [consentService].
@ProviderFor(consentService)
final consentServiceProvider = AutoDisposeProvider<ConsentService>.internal(
  consentService,
  name: r'consentServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$consentServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ConsentServiceRef = AutoDisposeProviderRef<ConsentService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
