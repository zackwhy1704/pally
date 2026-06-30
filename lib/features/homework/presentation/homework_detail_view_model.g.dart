// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'homework_detail_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$homeworkDetailViewModelHash() =>
    r'360161a5d3d1d016c12e626553d537ffd9985469';

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

abstract class _$HomeworkDetailViewModel
    extends BuildlessAutoDisposeAsyncNotifier<HomeworkSubmission> {
  late final String avatarId;
  late final String submissionId;

  FutureOr<HomeworkSubmission> build(
    String avatarId,
    String submissionId,
  );
}

/// Loads a single homework submission so the student can read the teacher's
/// RELEASED feedback. The teacher feedback/grade only appear in the response
/// once the teacher releases — we never synthesise them client-side.
///
/// Copied from [HomeworkDetailViewModel].
@ProviderFor(HomeworkDetailViewModel)
const homeworkDetailViewModelProvider = HomeworkDetailViewModelFamily();

/// Loads a single homework submission so the student can read the teacher's
/// RELEASED feedback. The teacher feedback/grade only appear in the response
/// once the teacher releases — we never synthesise them client-side.
///
/// Copied from [HomeworkDetailViewModel].
class HomeworkDetailViewModelFamily
    extends Family<AsyncValue<HomeworkSubmission>> {
  /// Loads a single homework submission so the student can read the teacher's
  /// RELEASED feedback. The teacher feedback/grade only appear in the response
  /// once the teacher releases — we never synthesise them client-side.
  ///
  /// Copied from [HomeworkDetailViewModel].
  const HomeworkDetailViewModelFamily();

  /// Loads a single homework submission so the student can read the teacher's
  /// RELEASED feedback. The teacher feedback/grade only appear in the response
  /// once the teacher releases — we never synthesise them client-side.
  ///
  /// Copied from [HomeworkDetailViewModel].
  HomeworkDetailViewModelProvider call(
    String avatarId,
    String submissionId,
  ) {
    return HomeworkDetailViewModelProvider(
      avatarId,
      submissionId,
    );
  }

  @override
  HomeworkDetailViewModelProvider getProviderOverride(
    covariant HomeworkDetailViewModelProvider provider,
  ) {
    return call(
      provider.avatarId,
      provider.submissionId,
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
  String? get name => r'homeworkDetailViewModelProvider';
}

/// Loads a single homework submission so the student can read the teacher's
/// RELEASED feedback. The teacher feedback/grade only appear in the response
/// once the teacher releases — we never synthesise them client-side.
///
/// Copied from [HomeworkDetailViewModel].
class HomeworkDetailViewModelProvider
    extends AutoDisposeAsyncNotifierProviderImpl<HomeworkDetailViewModel,
        HomeworkSubmission> {
  /// Loads a single homework submission so the student can read the teacher's
  /// RELEASED feedback. The teacher feedback/grade only appear in the response
  /// once the teacher releases — we never synthesise them client-side.
  ///
  /// Copied from [HomeworkDetailViewModel].
  HomeworkDetailViewModelProvider(
    String avatarId,
    String submissionId,
  ) : this._internal(
          () => HomeworkDetailViewModel()
            ..avatarId = avatarId
            ..submissionId = submissionId,
          from: homeworkDetailViewModelProvider,
          name: r'homeworkDetailViewModelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$homeworkDetailViewModelHash,
          dependencies: HomeworkDetailViewModelFamily._dependencies,
          allTransitiveDependencies:
              HomeworkDetailViewModelFamily._allTransitiveDependencies,
          avatarId: avatarId,
          submissionId: submissionId,
        );

  HomeworkDetailViewModelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.avatarId,
    required this.submissionId,
  }) : super.internal();

  final String avatarId;
  final String submissionId;

  @override
  FutureOr<HomeworkSubmission> runNotifierBuild(
    covariant HomeworkDetailViewModel notifier,
  ) {
    return notifier.build(
      avatarId,
      submissionId,
    );
  }

  @override
  Override overrideWith(HomeworkDetailViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: HomeworkDetailViewModelProvider._internal(
        () => create()
          ..avatarId = avatarId
          ..submissionId = submissionId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        avatarId: avatarId,
        submissionId: submissionId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<HomeworkDetailViewModel,
      HomeworkSubmission> createElement() {
    return _HomeworkDetailViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is HomeworkDetailViewModelProvider &&
        other.avatarId == avatarId &&
        other.submissionId == submissionId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, avatarId.hashCode);
    hash = _SystemHash.combine(hash, submissionId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin HomeworkDetailViewModelRef
    on AutoDisposeAsyncNotifierProviderRef<HomeworkSubmission> {
  /// The parameter `avatarId` of this provider.
  String get avatarId;

  /// The parameter `submissionId` of this provider.
  String get submissionId;
}

class _HomeworkDetailViewModelProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<HomeworkDetailViewModel,
        HomeworkSubmission> with HomeworkDetailViewModelRef {
  _HomeworkDetailViewModelProviderElement(super.provider);

  @override
  String get avatarId => (origin as HomeworkDetailViewModelProvider).avatarId;
  @override
  String get submissionId =>
      (origin as HomeworkDetailViewModelProvider).submissionId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
