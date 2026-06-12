// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$classChallengesViewModelHash() =>
    r'8e06a75dfe1dbcb35d5961cc650987c9b609620f';

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

abstract class _$ClassChallengesViewModel
    extends BuildlessAutoDisposeAsyncNotifier<List<Challenge>> {
  late final String classId;

  FutureOr<List<Challenge>> build(
    String classId,
  );
}

/// Lists the open/recent challenges for a class. Returns an empty list on any
/// failure (e.g. a peer group with no class) so the feed degrades silently.
///
/// Copied from [ClassChallengesViewModel].
@ProviderFor(ClassChallengesViewModel)
const classChallengesViewModelProvider = ClassChallengesViewModelFamily();

/// Lists the open/recent challenges for a class. Returns an empty list on any
/// failure (e.g. a peer group with no class) so the feed degrades silently.
///
/// Copied from [ClassChallengesViewModel].
class ClassChallengesViewModelFamily
    extends Family<AsyncValue<List<Challenge>>> {
  /// Lists the open/recent challenges for a class. Returns an empty list on any
  /// failure (e.g. a peer group with no class) so the feed degrades silently.
  ///
  /// Copied from [ClassChallengesViewModel].
  const ClassChallengesViewModelFamily();

  /// Lists the open/recent challenges for a class. Returns an empty list on any
  /// failure (e.g. a peer group with no class) so the feed degrades silently.
  ///
  /// Copied from [ClassChallengesViewModel].
  ClassChallengesViewModelProvider call(
    String classId,
  ) {
    return ClassChallengesViewModelProvider(
      classId,
    );
  }

  @override
  ClassChallengesViewModelProvider getProviderOverride(
    covariant ClassChallengesViewModelProvider provider,
  ) {
    return call(
      provider.classId,
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
  String? get name => r'classChallengesViewModelProvider';
}

/// Lists the open/recent challenges for a class. Returns an empty list on any
/// failure (e.g. a peer group with no class) so the feed degrades silently.
///
/// Copied from [ClassChallengesViewModel].
class ClassChallengesViewModelProvider
    extends AutoDisposeAsyncNotifierProviderImpl<ClassChallengesViewModel,
        List<Challenge>> {
  /// Lists the open/recent challenges for a class. Returns an empty list on any
  /// failure (e.g. a peer group with no class) so the feed degrades silently.
  ///
  /// Copied from [ClassChallengesViewModel].
  ClassChallengesViewModelProvider(
    String classId,
  ) : this._internal(
          () => ClassChallengesViewModel()..classId = classId,
          from: classChallengesViewModelProvider,
          name: r'classChallengesViewModelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$classChallengesViewModelHash,
          dependencies: ClassChallengesViewModelFamily._dependencies,
          allTransitiveDependencies:
              ClassChallengesViewModelFamily._allTransitiveDependencies,
          classId: classId,
        );

  ClassChallengesViewModelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.classId,
  }) : super.internal();

  final String classId;

  @override
  FutureOr<List<Challenge>> runNotifierBuild(
    covariant ClassChallengesViewModel notifier,
  ) {
    return notifier.build(
      classId,
    );
  }

  @override
  Override overrideWith(ClassChallengesViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: ClassChallengesViewModelProvider._internal(
        () => create()..classId = classId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        classId: classId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<ClassChallengesViewModel,
      List<Challenge>> createElement() {
    return _ClassChallengesViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ClassChallengesViewModelProvider &&
        other.classId == classId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, classId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ClassChallengesViewModelRef
    on AutoDisposeAsyncNotifierProviderRef<List<Challenge>> {
  /// The parameter `classId` of this provider.
  String get classId;
}

class _ClassChallengesViewModelProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<ClassChallengesViewModel,
        List<Challenge>> with ClassChallengesViewModelRef {
  _ClassChallengesViewModelProviderElement(super.provider);

  @override
  String get classId => (origin as ClassChallengesViewModelProvider).classId;
}

String _$challengeViewModelHash() =>
    r'59b2badab70b048b72731db62b056e34d9598677';

abstract class _$ChallengeViewModel
    extends BuildlessAutoDisposeAsyncNotifier<Challenge> {
  late final String challengeId;

  FutureOr<Challenge> build(
    String challengeId,
  );
}

/// Loads + submits a single class challenge. Keyed by challengeId so the group
/// feed can host multiple cards independently.
///
/// Copied from [ChallengeViewModel].
@ProviderFor(ChallengeViewModel)
const challengeViewModelProvider = ChallengeViewModelFamily();

/// Loads + submits a single class challenge. Keyed by challengeId so the group
/// feed can host multiple cards independently.
///
/// Copied from [ChallengeViewModel].
class ChallengeViewModelFamily extends Family<AsyncValue<Challenge>> {
  /// Loads + submits a single class challenge. Keyed by challengeId so the group
  /// feed can host multiple cards independently.
  ///
  /// Copied from [ChallengeViewModel].
  const ChallengeViewModelFamily();

  /// Loads + submits a single class challenge. Keyed by challengeId so the group
  /// feed can host multiple cards independently.
  ///
  /// Copied from [ChallengeViewModel].
  ChallengeViewModelProvider call(
    String challengeId,
  ) {
    return ChallengeViewModelProvider(
      challengeId,
    );
  }

  @override
  ChallengeViewModelProvider getProviderOverride(
    covariant ChallengeViewModelProvider provider,
  ) {
    return call(
      provider.challengeId,
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
  String? get name => r'challengeViewModelProvider';
}

/// Loads + submits a single class challenge. Keyed by challengeId so the group
/// feed can host multiple cards independently.
///
/// Copied from [ChallengeViewModel].
class ChallengeViewModelProvider extends AutoDisposeAsyncNotifierProviderImpl<
    ChallengeViewModel, Challenge> {
  /// Loads + submits a single class challenge. Keyed by challengeId so the group
  /// feed can host multiple cards independently.
  ///
  /// Copied from [ChallengeViewModel].
  ChallengeViewModelProvider(
    String challengeId,
  ) : this._internal(
          () => ChallengeViewModel()..challengeId = challengeId,
          from: challengeViewModelProvider,
          name: r'challengeViewModelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$challengeViewModelHash,
          dependencies: ChallengeViewModelFamily._dependencies,
          allTransitiveDependencies:
              ChallengeViewModelFamily._allTransitiveDependencies,
          challengeId: challengeId,
        );

  ChallengeViewModelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.challengeId,
  }) : super.internal();

  final String challengeId;

  @override
  FutureOr<Challenge> runNotifierBuild(
    covariant ChallengeViewModel notifier,
  ) {
    return notifier.build(
      challengeId,
    );
  }

  @override
  Override overrideWith(ChallengeViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: ChallengeViewModelProvider._internal(
        () => create()..challengeId = challengeId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        challengeId: challengeId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<ChallengeViewModel, Challenge>
      createElement() {
    return _ChallengeViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChallengeViewModelProvider &&
        other.challengeId == challengeId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, challengeId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ChallengeViewModelRef on AutoDisposeAsyncNotifierProviderRef<Challenge> {
  /// The parameter `challengeId` of this provider.
  String get challengeId;
}

class _ChallengeViewModelProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<ChallengeViewModel,
        Challenge> with ChallengeViewModelRef {
  _ChallengeViewModelProviderElement(super.provider);

  @override
  String get challengeId => (origin as ChallengeViewModelProvider).challengeId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
