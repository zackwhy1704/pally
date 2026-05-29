// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo_preview_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$photoPreviewViewModelHash() =>
    r'842773e0670cdeacc5c94677c52018ae3872eb78';

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

abstract class _$PhotoPreviewViewModel
    extends BuildlessAutoDisposeNotifier<PhotoPreviewState> {
  late final String photoPath;

  PhotoPreviewState build(
    String photoPath,
  );
}

/// See also [PhotoPreviewViewModel].
@ProviderFor(PhotoPreviewViewModel)
const photoPreviewViewModelProvider = PhotoPreviewViewModelFamily();

/// See also [PhotoPreviewViewModel].
class PhotoPreviewViewModelFamily extends Family<PhotoPreviewState> {
  /// See also [PhotoPreviewViewModel].
  const PhotoPreviewViewModelFamily();

  /// See also [PhotoPreviewViewModel].
  PhotoPreviewViewModelProvider call(
    String photoPath,
  ) {
    return PhotoPreviewViewModelProvider(
      photoPath,
    );
  }

  @override
  PhotoPreviewViewModelProvider getProviderOverride(
    covariant PhotoPreviewViewModelProvider provider,
  ) {
    return call(
      provider.photoPath,
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
  String? get name => r'photoPreviewViewModelProvider';
}

/// See also [PhotoPreviewViewModel].
class PhotoPreviewViewModelProvider extends AutoDisposeNotifierProviderImpl<
    PhotoPreviewViewModel, PhotoPreviewState> {
  /// See also [PhotoPreviewViewModel].
  PhotoPreviewViewModelProvider(
    String photoPath,
  ) : this._internal(
          () => PhotoPreviewViewModel()..photoPath = photoPath,
          from: photoPreviewViewModelProvider,
          name: r'photoPreviewViewModelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$photoPreviewViewModelHash,
          dependencies: PhotoPreviewViewModelFamily._dependencies,
          allTransitiveDependencies:
              PhotoPreviewViewModelFamily._allTransitiveDependencies,
          photoPath: photoPath,
        );

  PhotoPreviewViewModelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.photoPath,
  }) : super.internal();

  final String photoPath;

  @override
  PhotoPreviewState runNotifierBuild(
    covariant PhotoPreviewViewModel notifier,
  ) {
    return notifier.build(
      photoPath,
    );
  }

  @override
  Override overrideWith(PhotoPreviewViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: PhotoPreviewViewModelProvider._internal(
        () => create()..photoPath = photoPath,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        photoPath: photoPath,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<PhotoPreviewViewModel, PhotoPreviewState>
      createElement() {
    return _PhotoPreviewViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PhotoPreviewViewModelProvider &&
        other.photoPath == photoPath;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, photoPath.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PhotoPreviewViewModelRef
    on AutoDisposeNotifierProviderRef<PhotoPreviewState> {
  /// The parameter `photoPath` of this provider.
  String get photoPath;
}

class _PhotoPreviewViewModelProviderElement
    extends AutoDisposeNotifierProviderElement<PhotoPreviewViewModel,
        PhotoPreviewState> with PhotoPreviewViewModelRef {
  _PhotoPreviewViewModelProviderElement(super.provider);

  @override
  String get photoPath => (origin as PhotoPreviewViewModelProvider).photoPath;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
