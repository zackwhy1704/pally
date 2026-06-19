// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assignment_detail_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$assignmentDetailViewModelHash() =>
    r'9e2eb9a2421695d1fd4f7e85a04c9cdb045d46f8';

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

abstract class _$AssignmentDetailViewModel
    extends BuildlessAutoDisposeAsyncNotifier<AssignmentDetail> {
  late final String avatarId;
  late final String assignmentId;

  FutureOr<AssignmentDetail> build(
    String avatarId,
    String assignmentId,
  );
}

/// A2 — loads a single student assignment so the UI can render the per-question
/// answer-compare view. The `modelAnswer` field only appears in the response
/// when the teacher has released answers; we never synthesise one client-side.
///
/// Copied from [AssignmentDetailViewModel].
@ProviderFor(AssignmentDetailViewModel)
const assignmentDetailViewModelProvider = AssignmentDetailViewModelFamily();

/// A2 — loads a single student assignment so the UI can render the per-question
/// answer-compare view. The `modelAnswer` field only appears in the response
/// when the teacher has released answers; we never synthesise one client-side.
///
/// Copied from [AssignmentDetailViewModel].
class AssignmentDetailViewModelFamily
    extends Family<AsyncValue<AssignmentDetail>> {
  /// A2 — loads a single student assignment so the UI can render the per-question
  /// answer-compare view. The `modelAnswer` field only appears in the response
  /// when the teacher has released answers; we never synthesise one client-side.
  ///
  /// Copied from [AssignmentDetailViewModel].
  const AssignmentDetailViewModelFamily();

  /// A2 — loads a single student assignment so the UI can render the per-question
  /// answer-compare view. The `modelAnswer` field only appears in the response
  /// when the teacher has released answers; we never synthesise one client-side.
  ///
  /// Copied from [AssignmentDetailViewModel].
  AssignmentDetailViewModelProvider call(
    String avatarId,
    String assignmentId,
  ) {
    return AssignmentDetailViewModelProvider(
      avatarId,
      assignmentId,
    );
  }

  @override
  AssignmentDetailViewModelProvider getProviderOverride(
    covariant AssignmentDetailViewModelProvider provider,
  ) {
    return call(
      provider.avatarId,
      provider.assignmentId,
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
  String? get name => r'assignmentDetailViewModelProvider';
}

/// A2 — loads a single student assignment so the UI can render the per-question
/// answer-compare view. The `modelAnswer` field only appears in the response
/// when the teacher has released answers; we never synthesise one client-side.
///
/// Copied from [AssignmentDetailViewModel].
class AssignmentDetailViewModelProvider
    extends AutoDisposeAsyncNotifierProviderImpl<AssignmentDetailViewModel,
        AssignmentDetail> {
  /// A2 — loads a single student assignment so the UI can render the per-question
  /// answer-compare view. The `modelAnswer` field only appears in the response
  /// when the teacher has released answers; we never synthesise one client-side.
  ///
  /// Copied from [AssignmentDetailViewModel].
  AssignmentDetailViewModelProvider(
    String avatarId,
    String assignmentId,
  ) : this._internal(
          () => AssignmentDetailViewModel()
            ..avatarId = avatarId
            ..assignmentId = assignmentId,
          from: assignmentDetailViewModelProvider,
          name: r'assignmentDetailViewModelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$assignmentDetailViewModelHash,
          dependencies: AssignmentDetailViewModelFamily._dependencies,
          allTransitiveDependencies:
              AssignmentDetailViewModelFamily._allTransitiveDependencies,
          avatarId: avatarId,
          assignmentId: assignmentId,
        );

  AssignmentDetailViewModelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.avatarId,
    required this.assignmentId,
  }) : super.internal();

  final String avatarId;
  final String assignmentId;

  @override
  FutureOr<AssignmentDetail> runNotifierBuild(
    covariant AssignmentDetailViewModel notifier,
  ) {
    return notifier.build(
      avatarId,
      assignmentId,
    );
  }

  @override
  Override overrideWith(AssignmentDetailViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: AssignmentDetailViewModelProvider._internal(
        () => create()
          ..avatarId = avatarId
          ..assignmentId = assignmentId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        avatarId: avatarId,
        assignmentId: assignmentId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<AssignmentDetailViewModel,
      AssignmentDetail> createElement() {
    return _AssignmentDetailViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AssignmentDetailViewModelProvider &&
        other.avatarId == avatarId &&
        other.assignmentId == assignmentId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, avatarId.hashCode);
    hash = _SystemHash.combine(hash, assignmentId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AssignmentDetailViewModelRef
    on AutoDisposeAsyncNotifierProviderRef<AssignmentDetail> {
  /// The parameter `avatarId` of this provider.
  String get avatarId;

  /// The parameter `assignmentId` of this provider.
  String get assignmentId;
}

class _AssignmentDetailViewModelProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<AssignmentDetailViewModel,
        AssignmentDetail> with AssignmentDetailViewModelRef {
  _AssignmentDetailViewModelProviderElement(super.provider);

  @override
  String get avatarId => (origin as AssignmentDetailViewModelProvider).avatarId;
  @override
  String get assignmentId =>
      (origin as AssignmentDetailViewModelProvider).assignmentId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
