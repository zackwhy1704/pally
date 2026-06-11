// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam_prep_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$examPrepViewModelHash() => r'd29256b6f474a9ead568e5fca62060b44155ed01';

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

abstract class _$ExamPrepViewModel
    extends BuildlessAutoDisposeAsyncNotifier<ExamPrep> {
  late final String avatarId;

  FutureOr<ExamPrep> build(
    String avatarId,
  );
}

/// See also [ExamPrepViewModel].
@ProviderFor(ExamPrepViewModel)
const examPrepViewModelProvider = ExamPrepViewModelFamily();

/// See also [ExamPrepViewModel].
class ExamPrepViewModelFamily extends Family<AsyncValue<ExamPrep>> {
  /// See also [ExamPrepViewModel].
  const ExamPrepViewModelFamily();

  /// See also [ExamPrepViewModel].
  ExamPrepViewModelProvider call(
    String avatarId,
  ) {
    return ExamPrepViewModelProvider(
      avatarId,
    );
  }

  @override
  ExamPrepViewModelProvider getProviderOverride(
    covariant ExamPrepViewModelProvider provider,
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
  String? get name => r'examPrepViewModelProvider';
}

/// See also [ExamPrepViewModel].
class ExamPrepViewModelProvider
    extends AutoDisposeAsyncNotifierProviderImpl<ExamPrepViewModel, ExamPrep> {
  /// See also [ExamPrepViewModel].
  ExamPrepViewModelProvider(
    String avatarId,
  ) : this._internal(
          () => ExamPrepViewModel()..avatarId = avatarId,
          from: examPrepViewModelProvider,
          name: r'examPrepViewModelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$examPrepViewModelHash,
          dependencies: ExamPrepViewModelFamily._dependencies,
          allTransitiveDependencies:
              ExamPrepViewModelFamily._allTransitiveDependencies,
          avatarId: avatarId,
        );

  ExamPrepViewModelProvider._internal(
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
  FutureOr<ExamPrep> runNotifierBuild(
    covariant ExamPrepViewModel notifier,
  ) {
    return notifier.build(
      avatarId,
    );
  }

  @override
  Override overrideWith(ExamPrepViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: ExamPrepViewModelProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<ExamPrepViewModel, ExamPrep>
      createElement() {
    return _ExamPrepViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ExamPrepViewModelProvider && other.avatarId == avatarId;
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
mixin ExamPrepViewModelRef on AutoDisposeAsyncNotifierProviderRef<ExamPrep> {
  /// The parameter `avatarId` of this provider.
  String get avatarId;
}

class _ExamPrepViewModelProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<ExamPrepViewModel, ExamPrep>
    with ExamPrepViewModelRef {
  _ExamPrepViewModelProviderElement(super.provider);

  @override
  String get avatarId => (origin as ExamPrepViewModelProvider).avatarId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
