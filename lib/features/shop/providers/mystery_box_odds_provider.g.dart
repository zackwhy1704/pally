// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mystery_box_odds_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$mysteryBoxOddsNotifierHash() =>
    r'499b1e751a33de621ca9866f3122bbb0c21ff303';

/// Reads /shop/open-box/odds — the rates come straight from the live
/// catalog so adding/removing a Mochi updates the UI without a deploy.
/// Falls back to the spec's static numbers on error so the kid never
/// sees a blank box.
///
/// Copied from [MysteryBoxOddsNotifier].
@ProviderFor(MysteryBoxOddsNotifier)
final mysteryBoxOddsNotifierProvider = AutoDisposeAsyncNotifierProvider<
    MysteryBoxOddsNotifier, List<MysteryBoxOdds>>.internal(
  MysteryBoxOddsNotifier.new,
  name: r'mysteryBoxOddsNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$mysteryBoxOddsNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MysteryBoxOddsNotifier
    = AutoDisposeAsyncNotifier<List<MysteryBoxOdds>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
