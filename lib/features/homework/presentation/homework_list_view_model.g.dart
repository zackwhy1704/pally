// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'homework_list_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$homeworkListViewModelHash() =>
    r'8619a39b15910949b380ed91f537909f4e85812a';

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

abstract class _$HomeworkListViewModel
    extends BuildlessAutoDisposeAsyncNotifier<List<HomeworkSubmission>> {
  late final String avatarId;

  FutureOr<List<HomeworkSubmission>> build(
    String avatarId,
  );
}

/// Loads the student's OWN homework submissions for a centre class avatar.
/// Read-only list; the submit flow lives in [HomeworkSubmitViewModel].
///
/// Copied from [HomeworkListViewModel].
@ProviderFor(HomeworkListViewModel)
const homeworkListViewModelProvider = HomeworkListViewModelFamily();

/// Loads the student's OWN homework submissions for a centre class avatar.
/// Read-only list; the submit flow lives in [HomeworkSubmitViewModel].
///
/// Copied from [HomeworkListViewModel].
class HomeworkListViewModelFamily
    extends Family<AsyncValue<List<HomeworkSubmission>>> {
  /// Loads the student's OWN homework submissions for a centre class avatar.
  /// Read-only list; the submit flow lives in [HomeworkSubmitViewModel].
  ///
  /// Copied from [HomeworkListViewModel].
  const HomeworkListViewModelFamily();

  /// Loads the student's OWN homework submissions for a centre class avatar.
  /// Read-only list; the submit flow lives in [HomeworkSubmitViewModel].
  ///
  /// Copied from [HomeworkListViewModel].
  HomeworkListViewModelProvider call(
    String avatarId,
  ) {
    return HomeworkListViewModelProvider(
      avatarId,
    );
  }

  @override
  HomeworkListViewModelProvider getProviderOverride(
    covariant HomeworkListViewModelProvider provider,
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
  String? get name => r'homeworkListViewModelProvider';
}

/// Loads the student's OWN homework submissions for a centre class avatar.
/// Read-only list; the submit flow lives in [HomeworkSubmitViewModel].
///
/// Copied from [HomeworkListViewModel].
class HomeworkListViewModelProvider
    extends AutoDisposeAsyncNotifierProviderImpl<HomeworkListViewModel,
        List<HomeworkSubmission>> {
  /// Loads the student's OWN homework submissions for a centre class avatar.
  /// Read-only list; the submit flow lives in [HomeworkSubmitViewModel].
  ///
  /// Copied from [HomeworkListViewModel].
  HomeworkListViewModelProvider(
    String avatarId,
  ) : this._internal(
          () => HomeworkListViewModel()..avatarId = avatarId,
          from: homeworkListViewModelProvider,
          name: r'homeworkListViewModelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$homeworkListViewModelHash,
          dependencies: HomeworkListViewModelFamily._dependencies,
          allTransitiveDependencies:
              HomeworkListViewModelFamily._allTransitiveDependencies,
          avatarId: avatarId,
        );

  HomeworkListViewModelProvider._internal(
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
  FutureOr<List<HomeworkSubmission>> runNotifierBuild(
    covariant HomeworkListViewModel notifier,
  ) {
    return notifier.build(
      avatarId,
    );
  }

  @override
  Override overrideWith(HomeworkListViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: HomeworkListViewModelProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<HomeworkListViewModel,
      List<HomeworkSubmission>> createElement() {
    return _HomeworkListViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is HomeworkListViewModelProvider && other.avatarId == avatarId;
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
mixin HomeworkListViewModelRef
    on AutoDisposeAsyncNotifierProviderRef<List<HomeworkSubmission>> {
  /// The parameter `avatarId` of this provider.
  String get avatarId;
}

class _HomeworkListViewModelProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<HomeworkListViewModel,
        List<HomeworkSubmission>> with HomeworkListViewModelRef {
  _HomeworkListViewModelProviderElement(super.provider);

  @override
  String get avatarId => (origin as HomeworkListViewModelProvider).avatarId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
