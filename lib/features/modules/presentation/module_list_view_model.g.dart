// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'module_list_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$avatarHasNotesHash() => r'016fdcdfb2b6c693bea1995f8fb6f5e0c856d608';

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

/// Whether the avatar has any compiled wiki pages — drives the module empty
/// state's single CTA (no notes → "Upload notes"; notes but no modules →
/// "Build my first lesson"). Reads wikiPageCount off the avatar DTO.
///
/// Copied from [avatarHasNotes].
@ProviderFor(avatarHasNotes)
const avatarHasNotesProvider = AvatarHasNotesFamily();

/// Whether the avatar has any compiled wiki pages — drives the module empty
/// state's single CTA (no notes → "Upload notes"; notes but no modules →
/// "Build my first lesson"). Reads wikiPageCount off the avatar DTO.
///
/// Copied from [avatarHasNotes].
class AvatarHasNotesFamily extends Family<AsyncValue<bool>> {
  /// Whether the avatar has any compiled wiki pages — drives the module empty
  /// state's single CTA (no notes → "Upload notes"; notes but no modules →
  /// "Build my first lesson"). Reads wikiPageCount off the avatar DTO.
  ///
  /// Copied from [avatarHasNotes].
  const AvatarHasNotesFamily();

  /// Whether the avatar has any compiled wiki pages — drives the module empty
  /// state's single CTA (no notes → "Upload notes"; notes but no modules →
  /// "Build my first lesson"). Reads wikiPageCount off the avatar DTO.
  ///
  /// Copied from [avatarHasNotes].
  AvatarHasNotesProvider call(
    String avatarId,
  ) {
    return AvatarHasNotesProvider(
      avatarId,
    );
  }

  @override
  AvatarHasNotesProvider getProviderOverride(
    covariant AvatarHasNotesProvider provider,
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
  String? get name => r'avatarHasNotesProvider';
}

/// Whether the avatar has any compiled wiki pages — drives the module empty
/// state's single CTA (no notes → "Upload notes"; notes but no modules →
/// "Build my first lesson"). Reads wikiPageCount off the avatar DTO.
///
/// Copied from [avatarHasNotes].
class AvatarHasNotesProvider extends AutoDisposeFutureProvider<bool> {
  /// Whether the avatar has any compiled wiki pages — drives the module empty
  /// state's single CTA (no notes → "Upload notes"; notes but no modules →
  /// "Build my first lesson"). Reads wikiPageCount off the avatar DTO.
  ///
  /// Copied from [avatarHasNotes].
  AvatarHasNotesProvider(
    String avatarId,
  ) : this._internal(
          (ref) => avatarHasNotes(
            ref as AvatarHasNotesRef,
            avatarId,
          ),
          from: avatarHasNotesProvider,
          name: r'avatarHasNotesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$avatarHasNotesHash,
          dependencies: AvatarHasNotesFamily._dependencies,
          allTransitiveDependencies:
              AvatarHasNotesFamily._allTransitiveDependencies,
          avatarId: avatarId,
        );

  AvatarHasNotesProvider._internal(
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
    FutureOr<bool> Function(AvatarHasNotesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AvatarHasNotesProvider._internal(
        (ref) => create(ref as AvatarHasNotesRef),
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
  AutoDisposeFutureProviderElement<bool> createElement() {
    return _AvatarHasNotesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AvatarHasNotesProvider && other.avatarId == avatarId;
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
mixin AvatarHasNotesRef on AutoDisposeFutureProviderRef<bool> {
  /// The parameter `avatarId` of this provider.
  String get avatarId;
}

class _AvatarHasNotesProviderElement
    extends AutoDisposeFutureProviderElement<bool> with AvatarHasNotesRef {
  _AvatarHasNotesProviderElement(super.provider);

  @override
  String get avatarId => (origin as AvatarHasNotesProvider).avatarId;
}

String _$moduleListViewModelHash() =>
    r'6a2452822163368d1042b0408d851208dc97891b';

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
