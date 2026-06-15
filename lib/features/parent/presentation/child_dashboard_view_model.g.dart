// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'child_dashboard_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$childDashboardHash() => r'cb64b2f90f87452183b966b04199e16d60ca9ca4';

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

/// See also [childDashboard].
@ProviderFor(childDashboard)
const childDashboardProvider = ChildDashboardFamily();

/// See also [childDashboard].
class ChildDashboardFamily extends Family<AsyncValue<ChildDashboard>> {
  /// See also [childDashboard].
  const ChildDashboardFamily();

  /// See also [childDashboard].
  ChildDashboardProvider call(
    String childId,
  ) {
    return ChildDashboardProvider(
      childId,
    );
  }

  @override
  ChildDashboardProvider getProviderOverride(
    covariant ChildDashboardProvider provider,
  ) {
    return call(
      provider.childId,
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
  String? get name => r'childDashboardProvider';
}

/// See also [childDashboard].
class ChildDashboardProvider extends AutoDisposeFutureProvider<ChildDashboard> {
  /// See also [childDashboard].
  ChildDashboardProvider(
    String childId,
  ) : this._internal(
          (ref) => childDashboard(
            ref as ChildDashboardRef,
            childId,
          ),
          from: childDashboardProvider,
          name: r'childDashboardProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$childDashboardHash,
          dependencies: ChildDashboardFamily._dependencies,
          allTransitiveDependencies:
              ChildDashboardFamily._allTransitiveDependencies,
          childId: childId,
        );

  ChildDashboardProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.childId,
  }) : super.internal();

  final String childId;

  @override
  Override overrideWith(
    FutureOr<ChildDashboard> Function(ChildDashboardRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ChildDashboardProvider._internal(
        (ref) => create(ref as ChildDashboardRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        childId: childId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<ChildDashboard> createElement() {
    return _ChildDashboardProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChildDashboardProvider && other.childId == childId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, childId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ChildDashboardRef on AutoDisposeFutureProviderRef<ChildDashboard> {
  /// The parameter `childId` of this provider.
  String get childId;
}

class _ChildDashboardProviderElement
    extends AutoDisposeFutureProviderElement<ChildDashboard>
    with ChildDashboardRef {
  _ChildDashboardProviderElement(super.provider);

  @override
  String get childId => (origin as ChildDashboardProvider).childId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
