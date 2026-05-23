// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flashcard_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$flashCardViewModelHash() =>
    r'5eab03728944c7f86931225e92b28eaef999a738';

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

abstract class _$FlashCardViewModel
    extends BuildlessAutoDisposeNotifier<FlashCardState> {
  late final String avatarId;

  FlashCardState build(
    String avatarId,
  );
}

/// See also [FlashCardViewModel].
@ProviderFor(FlashCardViewModel)
const flashCardViewModelProvider = FlashCardViewModelFamily();

/// See also [FlashCardViewModel].
class FlashCardViewModelFamily extends Family<FlashCardState> {
  /// See also [FlashCardViewModel].
  const FlashCardViewModelFamily();

  /// See also [FlashCardViewModel].
  FlashCardViewModelProvider call(
    String avatarId,
  ) {
    return FlashCardViewModelProvider(
      avatarId,
    );
  }

  @override
  FlashCardViewModelProvider getProviderOverride(
    covariant FlashCardViewModelProvider provider,
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
  String? get name => r'flashCardViewModelProvider';
}

/// See also [FlashCardViewModel].
class FlashCardViewModelProvider extends AutoDisposeNotifierProviderImpl<
    FlashCardViewModel, FlashCardState> {
  /// See also [FlashCardViewModel].
  FlashCardViewModelProvider(
    String avatarId,
  ) : this._internal(
          () => FlashCardViewModel()..avatarId = avatarId,
          from: flashCardViewModelProvider,
          name: r'flashCardViewModelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$flashCardViewModelHash,
          dependencies: FlashCardViewModelFamily._dependencies,
          allTransitiveDependencies:
              FlashCardViewModelFamily._allTransitiveDependencies,
          avatarId: avatarId,
        );

  FlashCardViewModelProvider._internal(
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
  FlashCardState runNotifierBuild(
    covariant FlashCardViewModel notifier,
  ) {
    return notifier.build(
      avatarId,
    );
  }

  @override
  Override overrideWith(FlashCardViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: FlashCardViewModelProvider._internal(
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
  AutoDisposeNotifierProviderElement<FlashCardViewModel, FlashCardState>
      createElement() {
    return _FlashCardViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FlashCardViewModelProvider && other.avatarId == avatarId;
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
mixin FlashCardViewModelRef on AutoDisposeNotifierProviderRef<FlashCardState> {
  /// The parameter `avatarId` of this provider.
  String get avatarId;
}

class _FlashCardViewModelProviderElement
    extends AutoDisposeNotifierProviderElement<FlashCardViewModel,
        FlashCardState> with FlashCardViewModelRef {
  _FlashCardViewModelProviderElement(super.provider);

  @override
  String get avatarId => (origin as FlashCardViewModelProvider).avatarId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
