// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'module_list_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$moduleAvatarInfoHash() => r'f6eaa90db48989c4479028cd4160dec31f54b7dc';

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

/// Reads avatar info (notes presence + centre/personal kind) reactively from
/// the home cache so the module-list empty state renders correctly and updates
/// when the home list refreshes. Returns null while loading or on error so the
/// empty state never flashes an incorrect centre/personal guess.
///
/// Copied from [moduleAvatarInfo].
@ProviderFor(moduleAvatarInfo)
const moduleAvatarInfoProvider = ModuleAvatarInfoFamily();

/// Reads avatar info (notes presence + centre/personal kind) reactively from
/// the home cache so the module-list empty state renders correctly and updates
/// when the home list refreshes. Returns null while loading or on error so the
/// empty state never flashes an incorrect centre/personal guess.
///
/// Copied from [moduleAvatarInfo].
class ModuleAvatarInfoFamily extends Family<ModuleAvatarInfo?> {
  /// Reads avatar info (notes presence + centre/personal kind) reactively from
  /// the home cache so the module-list empty state renders correctly and updates
  /// when the home list refreshes. Returns null while loading or on error so the
  /// empty state never flashes an incorrect centre/personal guess.
  ///
  /// Copied from [moduleAvatarInfo].
  const ModuleAvatarInfoFamily();

  /// Reads avatar info (notes presence + centre/personal kind) reactively from
  /// the home cache so the module-list empty state renders correctly and updates
  /// when the home list refreshes. Returns null while loading or on error so the
  /// empty state never flashes an incorrect centre/personal guess.
  ///
  /// Copied from [moduleAvatarInfo].
  ModuleAvatarInfoProvider call(
    String avatarId,
  ) {
    return ModuleAvatarInfoProvider(
      avatarId,
    );
  }

  @override
  ModuleAvatarInfoProvider getProviderOverride(
    covariant ModuleAvatarInfoProvider provider,
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
  String? get name => r'moduleAvatarInfoProvider';
}

/// Reads avatar info (notes presence + centre/personal kind) reactively from
/// the home cache so the module-list empty state renders correctly and updates
/// when the home list refreshes. Returns null while loading or on error so the
/// empty state never flashes an incorrect centre/personal guess.
///
/// Copied from [moduleAvatarInfo].
class ModuleAvatarInfoProvider extends AutoDisposeProvider<ModuleAvatarInfo?> {
  /// Reads avatar info (notes presence + centre/personal kind) reactively from
  /// the home cache so the module-list empty state renders correctly and updates
  /// when the home list refreshes. Returns null while loading or on error so the
  /// empty state never flashes an incorrect centre/personal guess.
  ///
  /// Copied from [moduleAvatarInfo].
  ModuleAvatarInfoProvider(
    String avatarId,
  ) : this._internal(
          (ref) => moduleAvatarInfo(
            ref as ModuleAvatarInfoRef,
            avatarId,
          ),
          from: moduleAvatarInfoProvider,
          name: r'moduleAvatarInfoProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$moduleAvatarInfoHash,
          dependencies: ModuleAvatarInfoFamily._dependencies,
          allTransitiveDependencies:
              ModuleAvatarInfoFamily._allTransitiveDependencies,
          avatarId: avatarId,
        );

  ModuleAvatarInfoProvider._internal(
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
  Override overrideWith(
    ModuleAvatarInfo? Function(ModuleAvatarInfoRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ModuleAvatarInfoProvider._internal(
        (ref) => create(ref as ModuleAvatarInfoRef),
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
  AutoDisposeProviderElement<ModuleAvatarInfo?> createElement() {
    return _ModuleAvatarInfoProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ModuleAvatarInfoProvider && other.avatarId == avatarId;
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
mixin ModuleAvatarInfoRef on AutoDisposeProviderRef<ModuleAvatarInfo?> {
  /// The parameter `avatarId` of this provider.
  String get avatarId;
}

class _ModuleAvatarInfoProviderElement
    extends AutoDisposeProviderElement<ModuleAvatarInfo?>
    with ModuleAvatarInfoRef {
  _ModuleAvatarInfoProviderElement(super.provider);

  @override
  String get avatarId => (origin as ModuleAvatarInfoProvider).avatarId;
}

String _$moduleListViewModelHash() =>
    r'9d2929a13f2ac845a6b4a54ad97f6996d0ebb7b4';

abstract class _$ModuleListViewModel
    extends BuildlessAutoDisposeAsyncNotifier<List<LearningModule>> {
  late final String avatarId;

  FutureOr<List<LearningModule>> build(
    String avatarId,
  );
}

/// See also [ModuleListViewModel].
@ProviderFor(ModuleListViewModel)
const moduleListViewModelProvider = ModuleListViewModelFamily();

/// See also [ModuleListViewModel].
class ModuleListViewModelFamily
    extends Family<AsyncValue<List<LearningModule>>> {
  /// See also [ModuleListViewModel].
  const ModuleListViewModelFamily();

  /// See also [ModuleListViewModel].
  ModuleListViewModelProvider call(
    String avatarId,
  ) {
    return ModuleListViewModelProvider(
      avatarId,
    );
  }

  @override
  ModuleListViewModelProvider getProviderOverride(
    covariant ModuleListViewModelProvider provider,
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
  String? get name => r'moduleListViewModelProvider';
}

/// See also [ModuleListViewModel].
class ModuleListViewModelProvider extends AutoDisposeAsyncNotifierProviderImpl<
    ModuleListViewModel, List<LearningModule>> {
  /// See also [ModuleListViewModel].
  ModuleListViewModelProvider(
    String avatarId,
  ) : this._internal(
          () => ModuleListViewModel()..avatarId = avatarId,
          from: moduleListViewModelProvider,
          name: r'moduleListViewModelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$moduleListViewModelHash,
          dependencies: ModuleListViewModelFamily._dependencies,
          allTransitiveDependencies:
              ModuleListViewModelFamily._allTransitiveDependencies,
          avatarId: avatarId,
        );

  ModuleListViewModelProvider._internal(
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
  FutureOr<List<LearningModule>> runNotifierBuild(
    covariant ModuleListViewModel notifier,
  ) {
    return notifier.build(
      avatarId,
    );
  }

  @override
  Override overrideWith(ModuleListViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: ModuleListViewModelProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<ModuleListViewModel,
      List<LearningModule>> createElement() {
    return _ModuleListViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ModuleListViewModelProvider && other.avatarId == avatarId;
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
mixin ModuleListViewModelRef
    on AutoDisposeAsyncNotifierProviderRef<List<LearningModule>> {
  /// The parameter `avatarId` of this provider.
  String get avatarId;
}

class _ModuleListViewModelProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<ModuleListViewModel,
        List<LearningModule>> with ModuleListViewModelRef {
  _ModuleListViewModelProviderElement(super.provider);

  @override
  String get avatarId => (origin as ModuleListViewModelProvider).avatarId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
