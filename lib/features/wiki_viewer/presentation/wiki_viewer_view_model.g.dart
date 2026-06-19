// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wiki_viewer_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$wikiViewerViewModelHash() =>
    r'e4cc381e2bb285cafc6e7ca893c41b73db919198';

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

abstract class _$WikiViewerViewModel
    extends BuildlessAutoDisposeNotifier<WikiViewerState> {
  late final String avatarId;

  WikiViewerState build(
    String avatarId,
  );
}

/// See also [WikiViewerViewModel].
@ProviderFor(WikiViewerViewModel)
const wikiViewerViewModelProvider = WikiViewerViewModelFamily();

/// See also [WikiViewerViewModel].
class WikiViewerViewModelFamily extends Family<WikiViewerState> {
  /// See also [WikiViewerViewModel].
  const WikiViewerViewModelFamily();

  /// See also [WikiViewerViewModel].
  WikiViewerViewModelProvider call(
    String avatarId,
  ) {
    return WikiViewerViewModelProvider(
      avatarId,
    );
  }

  @override
  WikiViewerViewModelProvider getProviderOverride(
    covariant WikiViewerViewModelProvider provider,
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
  String? get name => r'wikiViewerViewModelProvider';
}

/// See also [WikiViewerViewModel].
class WikiViewerViewModelProvider extends AutoDisposeNotifierProviderImpl<
    WikiViewerViewModel, WikiViewerState> {
  /// See also [WikiViewerViewModel].
  WikiViewerViewModelProvider(
    String avatarId,
  ) : this._internal(
          () => WikiViewerViewModel()..avatarId = avatarId,
          from: wikiViewerViewModelProvider,
          name: r'wikiViewerViewModelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$wikiViewerViewModelHash,
          dependencies: WikiViewerViewModelFamily._dependencies,
          allTransitiveDependencies:
              WikiViewerViewModelFamily._allTransitiveDependencies,
          avatarId: avatarId,
        );

  WikiViewerViewModelProvider._internal(
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
  WikiViewerState runNotifierBuild(
    covariant WikiViewerViewModel notifier,
  ) {
    return notifier.build(
      avatarId,
    );
  }

  @override
  Override overrideWith(WikiViewerViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: WikiViewerViewModelProvider._internal(
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
  AutoDisposeNotifierProviderElement<WikiViewerViewModel, WikiViewerState>
      createElement() {
    return _WikiViewerViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WikiViewerViewModelProvider && other.avatarId == avatarId;
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
mixin WikiViewerViewModelRef
    on AutoDisposeNotifierProviderRef<WikiViewerState> {
  /// The parameter `avatarId` of this provider.
  String get avatarId;
}

class _WikiViewerViewModelProviderElement
    extends AutoDisposeNotifierProviderElement<WikiViewerViewModel,
        WikiViewerState> with WikiViewerViewModelRef {
  _WikiViewerViewModelProviderElement(super.provider);

  @override
  String get avatarId => (origin as WikiViewerViewModelProvider).avatarId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
