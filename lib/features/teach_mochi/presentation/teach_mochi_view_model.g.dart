// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teach_mochi_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$teachMochiViewModelHash() =>
    r'42cbc30cd0176725dd3e34179a4cdbe2308026e9';

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

abstract class _$TeachMochiViewModel
    extends BuildlessAutoDisposeNotifier<TeachState> {
  late final String avatarId;

  TeachState build(
    String avatarId,
  );
}

/// See also [TeachMochiViewModel].
@ProviderFor(TeachMochiViewModel)
const teachMochiViewModelProvider = TeachMochiViewModelFamily();

/// See also [TeachMochiViewModel].
class TeachMochiViewModelFamily extends Family<TeachState> {
  /// See also [TeachMochiViewModel].
  const TeachMochiViewModelFamily();

  /// See also [TeachMochiViewModel].
  TeachMochiViewModelProvider call(
    String avatarId,
  ) {
    return TeachMochiViewModelProvider(
      avatarId,
    );
  }

  @override
  TeachMochiViewModelProvider getProviderOverride(
    covariant TeachMochiViewModelProvider provider,
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
  String? get name => r'teachMochiViewModelProvider';
}

/// See also [TeachMochiViewModel].
class TeachMochiViewModelProvider
    extends AutoDisposeNotifierProviderImpl<TeachMochiViewModel, TeachState> {
  /// See also [TeachMochiViewModel].
  TeachMochiViewModelProvider(
    String avatarId,
  ) : this._internal(
          () => TeachMochiViewModel()..avatarId = avatarId,
          from: teachMochiViewModelProvider,
          name: r'teachMochiViewModelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$teachMochiViewModelHash,
          dependencies: TeachMochiViewModelFamily._dependencies,
          allTransitiveDependencies:
              TeachMochiViewModelFamily._allTransitiveDependencies,
          avatarId: avatarId,
        );

  TeachMochiViewModelProvider._internal(
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
  TeachState runNotifierBuild(
    covariant TeachMochiViewModel notifier,
  ) {
    return notifier.build(
      avatarId,
    );
  }

  @override
  Override overrideWith(TeachMochiViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: TeachMochiViewModelProvider._internal(
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
  AutoDisposeNotifierProviderElement<TeachMochiViewModel, TeachState>
      createElement() {
    return _TeachMochiViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TeachMochiViewModelProvider && other.avatarId == avatarId;
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
mixin TeachMochiViewModelRef on AutoDisposeNotifierProviderRef<TeachState> {
  /// The parameter `avatarId` of this provider.
  String get avatarId;
}

class _TeachMochiViewModelProviderElement
    extends AutoDisposeNotifierProviderElement<TeachMochiViewModel, TeachState>
    with TeachMochiViewModelRef {
  _TeachMochiViewModelProviderElement(super.provider);

  @override
  String get avatarId => (origin as TeachMochiViewModelProvider).avatarId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
