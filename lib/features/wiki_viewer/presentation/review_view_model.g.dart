// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$reviewViewModelHash() => r'6657c5c36ed9badba671083864d698504f614155';

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

abstract class _$ReviewViewModel
    extends BuildlessAutoDisposeNotifier<ReviewState> {
  late final String pageId;

  ReviewState build(
    String pageId,
  );
}

/// See also [ReviewViewModel].
@ProviderFor(ReviewViewModel)
const reviewViewModelProvider = ReviewViewModelFamily();

/// See also [ReviewViewModel].
class ReviewViewModelFamily extends Family<ReviewState> {
  /// See also [ReviewViewModel].
  const ReviewViewModelFamily();

  /// See also [ReviewViewModel].
  ReviewViewModelProvider call(
    String pageId,
  ) {
    return ReviewViewModelProvider(
      pageId,
    );
  }

  @override
  ReviewViewModelProvider getProviderOverride(
    covariant ReviewViewModelProvider provider,
  ) {
    return call(
      provider.pageId,
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
  String? get name => r'reviewViewModelProvider';
}

/// See also [ReviewViewModel].
class ReviewViewModelProvider
    extends AutoDisposeNotifierProviderImpl<ReviewViewModel, ReviewState> {
  /// See also [ReviewViewModel].
  ReviewViewModelProvider(
    String pageId,
  ) : this._internal(
          () => ReviewViewModel()..pageId = pageId,
          from: reviewViewModelProvider,
          name: r'reviewViewModelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$reviewViewModelHash,
          dependencies: ReviewViewModelFamily._dependencies,
          allTransitiveDependencies:
              ReviewViewModelFamily._allTransitiveDependencies,
          pageId: pageId,
        );

  ReviewViewModelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.pageId,
  }) : super.internal();

  final String pageId;

  @override
  ReviewState runNotifierBuild(
    covariant ReviewViewModel notifier,
  ) {
    return notifier.build(
      pageId,
    );
  }

  @override
  Override overrideWith(ReviewViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: ReviewViewModelProvider._internal(
        () => create()..pageId = pageId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        pageId: pageId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<ReviewViewModel, ReviewState>
      createElement() {
    return _ReviewViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ReviewViewModelProvider && other.pageId == pageId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, pageId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ReviewViewModelRef on AutoDisposeNotifierProviderRef<ReviewState> {
  /// The parameter `pageId` of this provider.
  String get pageId;
}

class _ReviewViewModelProviderElement
    extends AutoDisposeNotifierProviderElement<ReviewViewModel, ReviewState>
    with ReviewViewModelRef {
  _ReviewViewModelProviderElement(super.provider);

  @override
  String get pageId => (origin as ReviewViewModelProvider).pageId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
