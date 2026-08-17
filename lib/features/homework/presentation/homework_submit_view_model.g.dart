// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'homework_submit_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$homeworkSubmitViewModelHash() =>
    r'd2ca900e1299aec688bce6ea09889841754a037d';

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

abstract class _$HomeworkSubmitViewModel
    extends BuildlessAutoDisposeNotifier<HomeworkSubmitState> {
  late final String avatarId;

  HomeworkSubmitState build(
    String avatarId,
  );
}

/// See also [HomeworkSubmitViewModel].
@ProviderFor(HomeworkSubmitViewModel)
const homeworkSubmitViewModelProvider = HomeworkSubmitViewModelFamily();

/// See also [HomeworkSubmitViewModel].
class HomeworkSubmitViewModelFamily extends Family<HomeworkSubmitState> {
  /// See also [HomeworkSubmitViewModel].
  const HomeworkSubmitViewModelFamily();

  /// See also [HomeworkSubmitViewModel].
  HomeworkSubmitViewModelProvider call(
    String avatarId,
  ) {
    return HomeworkSubmitViewModelProvider(
      avatarId,
    );
  }

  @override
  HomeworkSubmitViewModelProvider getProviderOverride(
    covariant HomeworkSubmitViewModelProvider provider,
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
  String? get name => r'homeworkSubmitViewModelProvider';
}

/// See also [HomeworkSubmitViewModel].
class HomeworkSubmitViewModelProvider extends AutoDisposeNotifierProviderImpl<
    HomeworkSubmitViewModel, HomeworkSubmitState> {
  /// See also [HomeworkSubmitViewModel].
  HomeworkSubmitViewModelProvider(
    String avatarId,
  ) : this._internal(
          () => HomeworkSubmitViewModel()..avatarId = avatarId,
          from: homeworkSubmitViewModelProvider,
          name: r'homeworkSubmitViewModelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$homeworkSubmitViewModelHash,
          dependencies: HomeworkSubmitViewModelFamily._dependencies,
          allTransitiveDependencies:
              HomeworkSubmitViewModelFamily._allTransitiveDependencies,
          avatarId: avatarId,
        );

  HomeworkSubmitViewModelProvider._internal(
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
  HomeworkSubmitState runNotifierBuild(
    covariant HomeworkSubmitViewModel notifier,
  ) {
    return notifier.build(
      avatarId,
    );
  }

  @override
  Override overrideWith(HomeworkSubmitViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: HomeworkSubmitViewModelProvider._internal(
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
  AutoDisposeNotifierProviderElement<HomeworkSubmitViewModel,
      HomeworkSubmitState> createElement() {
    return _HomeworkSubmitViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is HomeworkSubmitViewModelProvider &&
        other.avatarId == avatarId;
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
mixin HomeworkSubmitViewModelRef
    on AutoDisposeNotifierProviderRef<HomeworkSubmitState> {
  /// The parameter `avatarId` of this provider.
  String get avatarId;
}

class _HomeworkSubmitViewModelProviderElement
    extends AutoDisposeNotifierProviderElement<HomeworkSubmitViewModel,
        HomeworkSubmitState> with HomeworkSubmitViewModelRef {
  _HomeworkSubmitViewModelProviderElement(super.provider);

  @override
  String get avatarId => (origin as HomeworkSubmitViewModelProvider).avatarId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
