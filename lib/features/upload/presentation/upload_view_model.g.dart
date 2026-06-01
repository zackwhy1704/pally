// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$uploadViewModelHash() => r'945e71ea211ea22ccdd45e8d79bcd039045ad1ad';

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

abstract class _$UploadViewModel
    extends BuildlessAutoDisposeNotifier<UploadState> {
  late final String avatarId;

  UploadState build(
    String avatarId,
  );
}

/// See also [UploadViewModel].
@ProviderFor(UploadViewModel)
const uploadViewModelProvider = UploadViewModelFamily();

/// See also [UploadViewModel].
class UploadViewModelFamily extends Family<UploadState> {
  /// See also [UploadViewModel].
  const UploadViewModelFamily();

  /// See also [UploadViewModel].
  UploadViewModelProvider call(
    String avatarId,
  ) {
    return UploadViewModelProvider(
      avatarId,
    );
  }

  @override
  UploadViewModelProvider getProviderOverride(
    covariant UploadViewModelProvider provider,
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
  String? get name => r'uploadViewModelProvider';
}

/// See also [UploadViewModel].
class UploadViewModelProvider
    extends AutoDisposeNotifierProviderImpl<UploadViewModel, UploadState> {
  /// See also [UploadViewModel].
  UploadViewModelProvider(
    String avatarId,
  ) : this._internal(
          () => UploadViewModel()..avatarId = avatarId,
          from: uploadViewModelProvider,
          name: r'uploadViewModelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$uploadViewModelHash,
          dependencies: UploadViewModelFamily._dependencies,
          allTransitiveDependencies:
              UploadViewModelFamily._allTransitiveDependencies,
          avatarId: avatarId,
        );

  UploadViewModelProvider._internal(
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
  UploadState runNotifierBuild(
    covariant UploadViewModel notifier,
  ) {
    return notifier.build(
      avatarId,
    );
  }

  @override
  Override overrideWith(UploadViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: UploadViewModelProvider._internal(
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
  AutoDisposeNotifierProviderElement<UploadViewModel, UploadState>
      createElement() {
    return _UploadViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UploadViewModelProvider && other.avatarId == avatarId;
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
mixin UploadViewModelRef on AutoDisposeNotifierProviderRef<UploadState> {
  /// The parameter `avatarId` of this provider.
  String get avatarId;
}

class _UploadViewModelProviderElement
    extends AutoDisposeNotifierProviderElement<UploadViewModel, UploadState>
    with UploadViewModelRef {
  _UploadViewModelProviderElement(super.provider);

  @override
  String get avatarId => (origin as UploadViewModelProvider).avatarId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
