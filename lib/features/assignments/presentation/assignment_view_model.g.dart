// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assignment_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$assignmentViewModelHash() =>
    r'f831bde0f6554e9eac5049306fc31ce919413914';

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

abstract class _$AssignmentViewModel
    extends BuildlessAutoDisposeAsyncNotifier<List<Assignment>> {
  late final String avatarId;

  FutureOr<List<Assignment>> build(
    String avatarId,
  );
}

/// See also [AssignmentViewModel].
@ProviderFor(AssignmentViewModel)
const assignmentViewModelProvider = AssignmentViewModelFamily();

/// See also [AssignmentViewModel].
class AssignmentViewModelFamily extends Family<AsyncValue<List<Assignment>>> {
  /// See also [AssignmentViewModel].
  const AssignmentViewModelFamily();

  /// See also [AssignmentViewModel].
  AssignmentViewModelProvider call(
    String avatarId,
  ) {
    return AssignmentViewModelProvider(
      avatarId,
    );
  }

  @override
  AssignmentViewModelProvider getProviderOverride(
    covariant AssignmentViewModelProvider provider,
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
  String? get name => r'assignmentViewModelProvider';
}

/// See also [AssignmentViewModel].
class AssignmentViewModelProvider extends AutoDisposeAsyncNotifierProviderImpl<
    AssignmentViewModel, List<Assignment>> {
  /// See also [AssignmentViewModel].
  AssignmentViewModelProvider(
    String avatarId,
  ) : this._internal(
          () => AssignmentViewModel()..avatarId = avatarId,
          from: assignmentViewModelProvider,
          name: r'assignmentViewModelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$assignmentViewModelHash,
          dependencies: AssignmentViewModelFamily._dependencies,
          allTransitiveDependencies:
              AssignmentViewModelFamily._allTransitiveDependencies,
          avatarId: avatarId,
        );

  AssignmentViewModelProvider._internal(
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
  FutureOr<List<Assignment>> runNotifierBuild(
    covariant AssignmentViewModel notifier,
  ) {
    return notifier.build(
      avatarId,
    );
  }

  @override
  Override overrideWith(AssignmentViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: AssignmentViewModelProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<AssignmentViewModel, List<Assignment>>
      createElement() {
    return _AssignmentViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AssignmentViewModelProvider && other.avatarId == avatarId;
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
mixin AssignmentViewModelRef
    on AutoDisposeAsyncNotifierProviderRef<List<Assignment>> {
  /// The parameter `avatarId` of this provider.
  String get avatarId;
}

class _AssignmentViewModelProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<AssignmentViewModel,
        List<Assignment>> with AssignmentViewModelRef {
  _AssignmentViewModelProviderElement(super.provider);

  @override
  String get avatarId => (origin as AssignmentViewModelProvider).avatarId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
