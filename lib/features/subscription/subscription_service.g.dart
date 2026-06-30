// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$subscriptionServiceHash() =>
    r'08f145933608d07f7d311b22eb1df6ac2cf92f58';

/// Opens the public web checkout in an EXTERNAL browser.
///
/// Purchasing happens entirely on the Apalchi website — the app never
/// runs in-app billing (no Stripe-in-webview, no store IAP). This keeps us
/// onside with App Store anti-steering (iOS shows a copiable link instead of
/// a launch button) and Google Play (an external-browser link-out is treated
/// far more leniently than an embedded payment WebView). After the user pays
/// on the web, the backend webhook grants premium and [EntitlementVm] unlocks
/// the app by polling — see entitlement_provider.dart.
///
/// Copied from [subscriptionService].
@ProviderFor(subscriptionService)
final subscriptionServiceProvider =
    AutoDisposeProvider<SubscriptionService>.internal(
  subscriptionService,
  name: r'subscriptionServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$subscriptionServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SubscriptionServiceRef = AutoDisposeProviderRef<SubscriptionService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
