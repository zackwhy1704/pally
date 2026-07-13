// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'avatar_hub_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$avatarHubViewModelHash() =>
    r'2978776416297cc4c60b4399d6442b329ecdd9dd';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$AvatarHubViewModel
    extends BuildlessAutoDisposeAsyncNotifier<AvatarHubData> {
  late final String avatarId;

  FutureOr<AvatarHubData> build(
    String avatarId,
  );
}

/// The Avatar Hub's single fetch-on-open view model.
///
/// Fetch discipline (the module-player lesson): the awaited fetch IS the async
/// `build` return — NOT a fire-and-forget side effect kicked off from a sync
/// `build()`/rebuild path. `module_player_view_model.dart:172` used a sync
/// `build()` that called `_loadModule()` (a GET + `/start` POST) and, being
/// autoDispose, re-fired it on every reconstruction. Here Riverpod caches the
/// resulting `AsyncValue` and only re-runs `build` on invalidation (a
/// RefreshIndicator → `ref.invalidate`), never on a widget rebuild. No
/// side-effectful call is ever made from a widget build path.
///
/// One new fetch on open (the module list); the avatar identity is read from the
/// already-warm home avatar list, and quiz status is composed lazily by the Quiz
/// row itself (see `_QuizHubRow`) rather than blocking the hero on it.
///
/// Copied from [AvatarHubViewModel].
@ProviderFor(AvatarHubViewModel)
const avatarHubViewModelProvider = AvatarHubViewModelFamily();

/// The Avatar Hub's single fetch-on-open view model.
///
/// Fetch discipline (the module-player lesson): the awaited fetch IS the async
/// `build` return — NOT a fire-and-forget side effect kicked off from a sync
/// `build()`/rebuild path. `module_player_view_model.dart:172` used a sync
/// `build()` that called `_loadModule()` (a GET + `/start` POST) and, being
/// autoDispose, re-fired it on every reconstruction. Here Riverpod caches the
/// resulting `AsyncValue` and only re-runs `build` on invalidation (a
/// RefreshIndicator → `ref.invalidate`), never on a widget rebuild. No
/// side-effectful call is ever made from a widget build path.
///
/// One new fetch on open (the module list); the avatar identity is read from the
/// already-warm home avatar list, and quiz status is composed lazily by the Quiz
/// row itself (see `_QuizHubRow`) rather than blocking the hero on it.
///
/// Copied from [AvatarHubViewModel].
class AvatarHubViewModelFamily extends Family<AsyncValue<AvatarHubData>> {
  /// The Avatar Hub's single fetch-on-open view model.
  ///
  /// Fetch discipline (the module-player lesson): the awaited fetch IS the async
  /// `build` return — NOT a fire-and-forget side effect kicked off from a sync
  /// `build()`/rebuild path. `module_player_view_model.dart:172` used a sync
  /// `build()` that called `_loadModule()` (a GET + `/start` POST) and, being
  /// autoDispose, re-fired it on every reconstruction. Here Riverpod caches the
  /// resulting `AsyncValue` and only re-runs `build` on invalidation (a
  /// RefreshIndicator → `ref.invalidate`), never on a widget rebuild. No
  /// side-effectful call is ever made from a widget build path.
  ///
  /// One new fetch on open (the module list); the avatar identity is read from the
  /// already-warm home avatar list, and quiz status is composed lazily by the Quiz
  /// row itself (see `_QuizHubRow`) rather than blocking the hero on it.
  ///
  /// Copied from [AvatarHubViewModel].
  const AvatarHubViewModelFamily();

  /// The Avatar Hub's single fetch-on-open view model.
  ///
  /// Fetch discipline (the module-player lesson): the awaited fetch IS the async
  /// `build` return — NOT a fire-and-forget side effect kicked off from a sync
  /// `build()`/rebuild path. `module_player_view_model.dart:172` used a sync
  /// `build()` that called `_loadModule()` (a GET + `/start` POST) and, being
  /// autoDispose, re-fired it on every reconstruction. Here Riverpod caches the
  /// resulting `AsyncValue` and only re-runs `build` on invalidation (a
  /// RefreshIndicator → `ref.invalidate`), never on a widget rebuild. No
  /// side-effectful call is ever made from a widget build path.
  ///
  /// One new fetch on open (the module list); the avatar identity is read from the
  /// already-warm home avatar list, and quiz status is composed lazily by the Quiz
  /// row itself (see `_QuizHubRow`) rather than blocking the hero on it.
  ///
  /// Copied from [AvatarHubViewModel].
  AvatarHubViewModelProvider call(
    String avatarId,
  ) {
    return AvatarHubViewModelProvider(
      avatarId,
    );
  }

  @override
  AvatarHubViewModelProvider getProviderOverride(
    covariant AvatarHubViewModelProvider provider,
  ) {
    return call(
      provider.avatarId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'avatarHubViewModelProvider';
}

/// The Avatar Hub's single fetch-on-open view model.
///
/// Fetch discipline (the module-player lesson): the awaited fetch IS the async
/// `build` return — NOT a fire-and-forget side effect kicked off from a sync
/// `build()`/rebuild path. `module_player_view_model.dart:172` used a sync
/// `build()` that called `_loadModule()` (a GET + `/start` POST) and, being
/// autoDispose, re-fired it on every reconstruction. Here Riverpod caches the
/// resulting `AsyncValue` and only re-runs `build` on invalidation (a
/// RefreshIndicator → `ref.invalidate`), never on a widget rebuild. No
/// side-effectful call is ever made from a widget build path.
///
/// One new fetch on open (the module list); the avatar identity is read from the
/// already-warm home avatar list, and quiz status is composed lazily by the Quiz
/// row itself (see `_QuizHubRow`) rather than blocking the hero on it.
///
/// Copied from [AvatarHubViewModel].
class AvatarHubViewModelProvider extends AutoDisposeAsyncNotifierProviderImpl<
    AvatarHubViewModel, AvatarHubData> {
  /// The Avatar Hub's single fetch-on-open view model.
  ///
  /// Fetch discipline (the module-player lesson): the awaited fetch IS the async
  /// `build` return — NOT a fire-and-forget side effect kicked off from a sync
  /// `build()`/rebuild path. `module_player_view_model.dart:172` used a sync
  /// `build()` that called `_loadModule()` (a GET + `/start` POST) and, being
  /// autoDispose, re-fired it on every reconstruction. Here Riverpod caches the
  /// resulting `AsyncValue` and only re-runs `build` on invalidation (a
  /// RefreshIndicator → `ref.invalidate`), never on a widget rebuild. No
  /// side-effectful call is ever made from a widget build path.
  ///
  /// One new fetch on open (the module list); the avatar identity is read from the
  /// already-warm home avatar list, and quiz status is composed lazily by the Quiz
  /// row itself (see `_QuizHubRow`) rather than blocking the hero on it.
  ///
  /// Copied from [AvatarHubViewModel].
  AvatarHubViewModelProvider(
    String avatarId,
  ) : this._internal(
          () => AvatarHubViewModel()..avatarId = avatarId,
          from: avatarHubViewModelProvider,
          name: r'avatarHubViewModelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$avatarHubViewModelHash,
          dependencies: AvatarHubViewModelFamily._dependencies,
          allTransitiveDependencies:
              AvatarHubViewModelFamily._allTransitiveDependencies,
          avatarId: avatarId,
        );

  AvatarHubViewModelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.avatarId,
  }) : super.internal();

  final String avatarId;

  @override
  FutureOr<AvatarHubData> runNotifierBuild(
    covariant AvatarHubViewModel notifier,
  ) {
    return notifier.build(
      avatarId,
    );
  }

  @override
  Override overrideWith(AvatarHubViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: AvatarHubViewModelProvider._internal(
        () => create()..avatarId = avatarId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        avatarId: avatarId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<AvatarHubViewModel, AvatarHubData>
      createElement() {
    return _AvatarHubViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AvatarHubViewModelProvider && other.avatarId == avatarId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, avatarId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AvatarHubViewModelRef
    on AutoDisposeAsyncNotifierProviderRef<AvatarHubData> {
  /// The parameter `avatarId` of this provider.
  String get avatarId;
}

class _AvatarHubViewModelProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<AvatarHubViewModel,
        AvatarHubData> with AvatarHubViewModelRef {
  _AvatarHubViewModelProviderElement(super.provider);

  @override
  String get avatarId => (origin as AvatarHubViewModelProvider).avatarId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
