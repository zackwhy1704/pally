// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'classroom_session_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$classroomSessionViewModelHash() =>
    r'4aba5e2f9f3de2f98b58bed10b13334444b473fc';

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

abstract class _$ClassroomSessionViewModel
    extends BuildlessAutoDisposeNotifier<ClassroomSessionState> {
  late final String avatarId;

  ClassroomSessionState build(
    String avatarId,
  );
}

/// Server-authoritative live classroom session. Every mutation either loads
/// or REPLACES [ClassroomSessionState.state] wholesale from a server
/// response/SSE event — never derived locally, same authority pattern as
/// the solo boss battle.
///
/// Copied from [ClassroomSessionViewModel].
@ProviderFor(ClassroomSessionViewModel)
const classroomSessionViewModelProvider = ClassroomSessionViewModelFamily();

/// Server-authoritative live classroom session. Every mutation either loads
/// or REPLACES [ClassroomSessionState.state] wholesale from a server
/// response/SSE event — never derived locally, same authority pattern as
/// the solo boss battle.
///
/// Copied from [ClassroomSessionViewModel].
class ClassroomSessionViewModelFamily extends Family<ClassroomSessionState> {
  /// Server-authoritative live classroom session. Every mutation either loads
  /// or REPLACES [ClassroomSessionState.state] wholesale from a server
  /// response/SSE event — never derived locally, same authority pattern as
  /// the solo boss battle.
  ///
  /// Copied from [ClassroomSessionViewModel].
  const ClassroomSessionViewModelFamily();

  /// Server-authoritative live classroom session. Every mutation either loads
  /// or REPLACES [ClassroomSessionState.state] wholesale from a server
  /// response/SSE event — never derived locally, same authority pattern as
  /// the solo boss battle.
  ///
  /// Copied from [ClassroomSessionViewModel].
  ClassroomSessionViewModelProvider call(
    String avatarId,
  ) {
    return ClassroomSessionViewModelProvider(
      avatarId,
    );
  }

  @override
  ClassroomSessionViewModelProvider getProviderOverride(
    covariant ClassroomSessionViewModelProvider provider,
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
  String? get name => r'classroomSessionViewModelProvider';
}

/// Server-authoritative live classroom session. Every mutation either loads
/// or REPLACES [ClassroomSessionState.state] wholesale from a server
/// response/SSE event — never derived locally, same authority pattern as
/// the solo boss battle.
///
/// Copied from [ClassroomSessionViewModel].
class ClassroomSessionViewModelProvider extends AutoDisposeNotifierProviderImpl<
    ClassroomSessionViewModel, ClassroomSessionState> {
  /// Server-authoritative live classroom session. Every mutation either loads
  /// or REPLACES [ClassroomSessionState.state] wholesale from a server
  /// response/SSE event — never derived locally, same authority pattern as
  /// the solo boss battle.
  ///
  /// Copied from [ClassroomSessionViewModel].
  ClassroomSessionViewModelProvider(
    String avatarId,
  ) : this._internal(
          () => ClassroomSessionViewModel()..avatarId = avatarId,
          from: classroomSessionViewModelProvider,
          name: r'classroomSessionViewModelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$classroomSessionViewModelHash,
          dependencies: ClassroomSessionViewModelFamily._dependencies,
          allTransitiveDependencies:
              ClassroomSessionViewModelFamily._allTransitiveDependencies,
          avatarId: avatarId,
        );

  ClassroomSessionViewModelProvider._internal(
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
  ClassroomSessionState runNotifierBuild(
    covariant ClassroomSessionViewModel notifier,
  ) {
    return notifier.build(
      avatarId,
    );
  }

  @override
  Override overrideWith(ClassroomSessionViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: ClassroomSessionViewModelProvider._internal(
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
  AutoDisposeNotifierProviderElement<ClassroomSessionViewModel,
      ClassroomSessionState> createElement() {
    return _ClassroomSessionViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ClassroomSessionViewModelProvider &&
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
mixin ClassroomSessionViewModelRef
    on AutoDisposeNotifierProviderRef<ClassroomSessionState> {
  /// The parameter `avatarId` of this provider.
  String get avatarId;
}

class _ClassroomSessionViewModelProviderElement
    extends AutoDisposeNotifierProviderElement<ClassroomSessionViewModel,
        ClassroomSessionState> with ClassroomSessionViewModelRef {
  _ClassroomSessionViewModelProviderElement(super.provider);

  @override
  String get avatarId => (origin as ClassroomSessionViewModelProvider).avatarId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
