// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'brain_map_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$brainMapViewModelHash() => r'3b3e27e1a5cf7f2f5b97bb241f0c36ebbf487198';

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

abstract class _$BrainMapViewModel
    extends BuildlessAutoDisposeAsyncNotifier<BrainMapState> {
  late final String avatarId;

  FutureOr<BrainMapState> build(
    String avatarId,
  );
}

/// See also [BrainMapViewModel].
@ProviderFor(BrainMapViewModel)
const brainMapViewModelProvider = BrainMapViewModelFamily();

/// See also [BrainMapViewModel].
class BrainMapViewModelFamily extends Family<AsyncValue<BrainMapState>> {
  /// See also [BrainMapViewModel].
  const BrainMapViewModelFamily();

  /// See also [BrainMapViewModel].
  BrainMapViewModelProvider call(
    String avatarId,
  ) {
    return BrainMapViewModelProvider(
      avatarId,
    );
  }

  @override
  BrainMapViewModelProvider getProviderOverride(
    covariant BrainMapViewModelProvider provider,
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
  String? get name => r'brainMapViewModelProvider';
}

/// See also [BrainMapViewModel].
class BrainMapViewModelProvider extends AutoDisposeAsyncNotifierProviderImpl<
    BrainMapViewModel, BrainMapState> {
  /// See also [BrainMapViewModel].
  BrainMapViewModelProvider(
    String avatarId,
  ) : this._internal(
          () => BrainMapViewModel()..avatarId = avatarId,
          from: brainMapViewModelProvider,
          name: r'brainMapViewModelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$brainMapViewModelHash,
          dependencies: BrainMapViewModelFamily._dependencies,
          allTransitiveDependencies:
              BrainMapViewModelFamily._allTransitiveDependencies,
          avatarId: avatarId,
        );

  BrainMapViewModelProvider._internal(
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
  FutureOr<BrainMapState> runNotifierBuild(
    covariant BrainMapViewModel notifier,
  ) {
    return notifier.build(
      avatarId,
    );
  }

  @override
  Override overrideWith(BrainMapViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: BrainMapViewModelProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<BrainMapViewModel, BrainMapState>
      createElement() {
    return _BrainMapViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BrainMapViewModelProvider && other.avatarId == avatarId;
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
mixin BrainMapViewModelRef
    on AutoDisposeAsyncNotifierProviderRef<BrainMapState> {
  /// The parameter `avatarId` of this provider.
  String get avatarId;
}

class _BrainMapViewModelProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<BrainMapViewModel,
        BrainMapState> with BrainMapViewModelRef {
  _BrainMapViewModelProviderElement(super.provider);

  @override
  String get avatarId => (origin as BrainMapViewModelProvider).avatarId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
