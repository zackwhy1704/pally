// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'no_notes_cta.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$avatarIsCentreClassHash() =>
    r'92639cb299656f06c069528bcf1926a292cc5e0f';

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

/// Whether an avatar is a centre-managed class (CENTRE_CLASS) vs a child's own
/// personal Mochi. Students can upload to their personal Mochi but NOT to a
/// centre class — only the teacher/centre adds materials there.
///
/// Fast path: reads synchronously from the already-loaded home list so there is
/// never a second network round-trip when the user navigated here from home.
/// Slow path: if home is not loaded yet, falls back to a direct avatar fetch.
/// Defaults to `false` (personal) on any error so the worst case is showing the
/// upload button to a personal avatar, never hiding it from one who needs it.
///
/// Copied from [avatarIsCentreClass].
@ProviderFor(avatarIsCentreClass)
const avatarIsCentreClassProvider = AvatarIsCentreClassFamily();

/// Whether an avatar is a centre-managed class (CENTRE_CLASS) vs a child's own
/// personal Mochi. Students can upload to their personal Mochi but NOT to a
/// centre class — only the teacher/centre adds materials there.
///
/// Fast path: reads synchronously from the already-loaded home list so there is
/// never a second network round-trip when the user navigated here from home.
/// Slow path: if home is not loaded yet, falls back to a direct avatar fetch.
/// Defaults to `false` (personal) on any error so the worst case is showing the
/// upload button to a personal avatar, never hiding it from one who needs it.
///
/// Copied from [avatarIsCentreClass].
class AvatarIsCentreClassFamily extends Family<AsyncValue<bool>> {
  /// Whether an avatar is a centre-managed class (CENTRE_CLASS) vs a child's own
  /// personal Mochi. Students can upload to their personal Mochi but NOT to a
  /// centre class — only the teacher/centre adds materials there.
  ///
  /// Fast path: reads synchronously from the already-loaded home list so there is
  /// never a second network round-trip when the user navigated here from home.
  /// Slow path: if home is not loaded yet, falls back to a direct avatar fetch.
  /// Defaults to `false` (personal) on any error so the worst case is showing the
  /// upload button to a personal avatar, never hiding it from one who needs it.
  ///
  /// Copied from [avatarIsCentreClass].
  const AvatarIsCentreClassFamily();

  /// Whether an avatar is a centre-managed class (CENTRE_CLASS) vs a child's own
  /// personal Mochi. Students can upload to their personal Mochi but NOT to a
  /// centre class — only the teacher/centre adds materials there.
  ///
  /// Fast path: reads synchronously from the already-loaded home list so there is
  /// never a second network round-trip when the user navigated here from home.
  /// Slow path: if home is not loaded yet, falls back to a direct avatar fetch.
  /// Defaults to `false` (personal) on any error so the worst case is showing the
  /// upload button to a personal avatar, never hiding it from one who needs it.
  ///
  /// Copied from [avatarIsCentreClass].
  AvatarIsCentreClassProvider call(
    String avatarId,
  ) {
    return AvatarIsCentreClassProvider(
      avatarId,
    );
  }

  @override
  AvatarIsCentreClassProvider getProviderOverride(
    covariant AvatarIsCentreClassProvider provider,
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
  String? get name => r'avatarIsCentreClassProvider';
}

/// Whether an avatar is a centre-managed class (CENTRE_CLASS) vs a child's own
/// personal Mochi. Students can upload to their personal Mochi but NOT to a
/// centre class — only the teacher/centre adds materials there.
///
/// Fast path: reads synchronously from the already-loaded home list so there is
/// never a second network round-trip when the user navigated here from home.
/// Slow path: if home is not loaded yet, falls back to a direct avatar fetch.
/// Defaults to `false` (personal) on any error so the worst case is showing the
/// upload button to a personal avatar, never hiding it from one who needs it.
///
/// Copied from [avatarIsCentreClass].
class AvatarIsCentreClassProvider extends AutoDisposeFutureProvider<bool> {
  /// Whether an avatar is a centre-managed class (CENTRE_CLASS) vs a child's own
  /// personal Mochi. Students can upload to their personal Mochi but NOT to a
  /// centre class — only the teacher/centre adds materials there.
  ///
  /// Fast path: reads synchronously from the already-loaded home list so there is
  /// never a second network round-trip when the user navigated here from home.
  /// Slow path: if home is not loaded yet, falls back to a direct avatar fetch.
  /// Defaults to `false` (personal) on any error so the worst case is showing the
  /// upload button to a personal avatar, never hiding it from one who needs it.
  ///
  /// Copied from [avatarIsCentreClass].
  AvatarIsCentreClassProvider(
    String avatarId,
  ) : this._internal(
          (ref) => avatarIsCentreClass(
            ref as AvatarIsCentreClassRef,
            avatarId,
          ),
          from: avatarIsCentreClassProvider,
          name: r'avatarIsCentreClassProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$avatarIsCentreClassHash,
          dependencies: AvatarIsCentreClassFamily._dependencies,
          allTransitiveDependencies:
              AvatarIsCentreClassFamily._allTransitiveDependencies,
          avatarId: avatarId,
        );

  AvatarIsCentreClassProvider._internal(
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
    FutureOr<bool> Function(AvatarIsCentreClassRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AvatarIsCentreClassProvider._internal(
        (ref) => create(ref as AvatarIsCentreClassRef),
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
    return _AvatarIsCentreClassProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AvatarIsCentreClassProvider && other.avatarId == avatarId;
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
mixin AvatarIsCentreClassRef on AutoDisposeFutureProviderRef<bool> {
  /// The parameter `avatarId` of this provider.
  String get avatarId;
}

class _AvatarIsCentreClassProviderElement
    extends AutoDisposeFutureProviderElement<bool> with AvatarIsCentreClassRef {
  _AvatarIsCentreClassProviderElement(super.provider);

  @override
  String get avatarId => (origin as AvatarIsCentreClassProvider).avatarId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
