// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'groups_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$groupListViewModelHash() =>
    r'e3b55d0e41f8f6ded0e18d4ce058cc2df09cebae';

/// See also [GroupListViewModel].
@ProviderFor(GroupListViewModel)
final groupListViewModelProvider = AutoDisposeAsyncNotifierProvider<
    GroupListViewModel, List<StudyGroup>>.internal(
  GroupListViewModel.new,
  name: r'groupListViewModelProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$groupListViewModelHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$GroupListViewModel = AutoDisposeAsyncNotifier<List<StudyGroup>>;
String _$groupDetailViewModelHash() =>
    r'be7c99904b077c8d557fa2e9b65a66af9195e55c';

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

abstract class _$GroupDetailViewModel
    extends BuildlessAutoDisposeAsyncNotifier<GroupDetail> {
  late final String groupId;

  FutureOr<GroupDetail> build(
    String groupId,
  );
}

/// See also [GroupDetailViewModel].
@ProviderFor(GroupDetailViewModel)
const groupDetailViewModelProvider = GroupDetailViewModelFamily();

/// See also [GroupDetailViewModel].
class GroupDetailViewModelFamily extends Family<AsyncValue<GroupDetail>> {
  /// See also [GroupDetailViewModel].
  const GroupDetailViewModelFamily();

  /// See also [GroupDetailViewModel].
  GroupDetailViewModelProvider call(
    String groupId,
  ) {
    return GroupDetailViewModelProvider(
      groupId,
    );
  }

  @override
  GroupDetailViewModelProvider getProviderOverride(
    covariant GroupDetailViewModelProvider provider,
  ) {
    return call(
      provider.groupId,
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
  String? get name => r'groupDetailViewModelProvider';
}

/// See also [GroupDetailViewModel].
class GroupDetailViewModelProvider extends AutoDisposeAsyncNotifierProviderImpl<
    GroupDetailViewModel, GroupDetail> {
  /// See also [GroupDetailViewModel].
  GroupDetailViewModelProvider(
    String groupId,
  ) : this._internal(
          () => GroupDetailViewModel()..groupId = groupId,
          from: groupDetailViewModelProvider,
          name: r'groupDetailViewModelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$groupDetailViewModelHash,
          dependencies: GroupDetailViewModelFamily._dependencies,
          allTransitiveDependencies:
              GroupDetailViewModelFamily._allTransitiveDependencies,
          groupId: groupId,
        );

  GroupDetailViewModelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.groupId,
  }) : super.internal();

  final String groupId;

  @override
  FutureOr<GroupDetail> runNotifierBuild(
    covariant GroupDetailViewModel notifier,
  ) {
    return notifier.build(
      groupId,
    );
  }

  @override
  Override overrideWith(GroupDetailViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: GroupDetailViewModelProvider._internal(
        () => create()..groupId = groupId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        groupId: groupId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<GroupDetailViewModel, GroupDetail>
      createElement() {
    return _GroupDetailViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupDetailViewModelProvider && other.groupId == groupId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, groupId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin GroupDetailViewModelRef
    on AutoDisposeAsyncNotifierProviderRef<GroupDetail> {
  /// The parameter `groupId` of this provider.
  String get groupId;
}

class _GroupDetailViewModelProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<GroupDetailViewModel,
        GroupDetail> with GroupDetailViewModelRef {
  _GroupDetailViewModelProviderElement(super.provider);

  @override
  String get groupId => (origin as GroupDetailViewModelProvider).groupId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
