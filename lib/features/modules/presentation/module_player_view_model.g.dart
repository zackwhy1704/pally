// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'module_player_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$modulePlayerViewModelHash() =>
    r'5e822e26a59665f3931428c5fcb764a0cc07fa5e';

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

abstract class _$ModulePlayerViewModel
    extends BuildlessAutoDisposeNotifier<ModulePlayerState> {
  late final String avatarId;
  late final String moduleId;

  ModulePlayerState build(
    String avatarId,
    String moduleId,
  );
}

/// See also [ModulePlayerViewModel].
@ProviderFor(ModulePlayerViewModel)
const modulePlayerViewModelProvider = ModulePlayerViewModelFamily();

/// See also [ModulePlayerViewModel].
class ModulePlayerViewModelFamily extends Family<ModulePlayerState> {
  /// See also [ModulePlayerViewModel].
  const ModulePlayerViewModelFamily();

  /// See also [ModulePlayerViewModel].
  ModulePlayerViewModelProvider call(
    String avatarId,
    String moduleId,
  ) {
    return ModulePlayerViewModelProvider(
      avatarId,
      moduleId,
    );
  }

  @override
  ModulePlayerViewModelProvider getProviderOverride(
    covariant ModulePlayerViewModelProvider provider,
  ) {
    return call(
      provider.avatarId,
      provider.moduleId,
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
  String? get name => r'modulePlayerViewModelProvider';
}

/// See also [ModulePlayerViewModel].
class ModulePlayerViewModelProvider extends AutoDisposeNotifierProviderImpl<
    ModulePlayerViewModel, ModulePlayerState> {
  /// See also [ModulePlayerViewModel].
  ModulePlayerViewModelProvider(
    String avatarId,
    String moduleId,
  ) : this._internal(
          () => ModulePlayerViewModel()
            ..avatarId = avatarId
            ..moduleId = moduleId,
          from: modulePlayerViewModelProvider,
          name: r'modulePlayerViewModelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$modulePlayerViewModelHash,
          dependencies: ModulePlayerViewModelFamily._dependencies,
          allTransitiveDependencies:
              ModulePlayerViewModelFamily._allTransitiveDependencies,
          avatarId: avatarId,
          moduleId: moduleId,
        );

  ModulePlayerViewModelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.avatarId,
    required this.moduleId,
  }) : super.internal();

  final String avatarId;
  final String moduleId;

  @override
  ModulePlayerState runNotifierBuild(
    covariant ModulePlayerViewModel notifier,
  ) {
    return notifier.build(
      avatarId,
      moduleId,
    );
  }

  @override
  Override overrideWith(ModulePlayerViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: ModulePlayerViewModelProvider._internal(
        () => create()
          ..avatarId = avatarId
          ..moduleId = moduleId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        avatarId: avatarId,
        moduleId: moduleId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<ModulePlayerViewModel, ModulePlayerState>
      createElement() {
    return _ModulePlayerViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ModulePlayerViewModelProvider &&
        other.avatarId == avatarId &&
        other.moduleId == moduleId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, avatarId.hashCode);
    hash = _SystemHash.combine(hash, moduleId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ModulePlayerViewModelRef
    on AutoDisposeNotifierProviderRef<ModulePlayerState> {
  /// The parameter `avatarId` of this provider.
  String get avatarId;

  /// The parameter `moduleId` of this provider.
  String get moduleId;
}

class _ModulePlayerViewModelProviderElement
    extends AutoDisposeNotifierProviderElement<ModulePlayerViewModel,
        ModulePlayerState> with ModulePlayerViewModelRef {
  _ModulePlayerViewModelProviderElement(super.provider);

  @override
  String get avatarId => (origin as ModulePlayerViewModelProvider).avatarId;
  @override
  String get moduleId => (origin as ModulePlayerViewModelProvider).moduleId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
