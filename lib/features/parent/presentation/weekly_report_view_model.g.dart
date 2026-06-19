// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weekly_report_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$weeklyReportListViewModelHash() =>
    r'20f6276eb1f444535698073e5a9759b796d60044';

/// See also [WeeklyReportListViewModel].
@ProviderFor(WeeklyReportListViewModel)
final weeklyReportListViewModelProvider = AutoDisposeAsyncNotifierProvider<
    WeeklyReportListViewModel, List<WeeklyReportSummary>>.internal(
  WeeklyReportListViewModel.new,
  name: r'weeklyReportListViewModelProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$weeklyReportListViewModelHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$WeeklyReportListViewModel
    = AutoDisposeAsyncNotifier<List<WeeklyReportSummary>>;
String _$weeklyReportDetailViewModelHash() =>
    r'f854dda319c65a7a11875a69f5d1f7361fad1e5e';

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

abstract class _$WeeklyReportDetailViewModel
    extends BuildlessAutoDisposeAsyncNotifier<WeeklyReportDetail> {
  late final String weekId;

  FutureOr<WeeklyReportDetail> build(
    String weekId,
  );
}

/// See also [WeeklyReportDetailViewModel].
@ProviderFor(WeeklyReportDetailViewModel)
const weeklyReportDetailViewModelProvider = WeeklyReportDetailViewModelFamily();

/// See also [WeeklyReportDetailViewModel].
class WeeklyReportDetailViewModelFamily
    extends Family<AsyncValue<WeeklyReportDetail>> {
  /// See also [WeeklyReportDetailViewModel].
  const WeeklyReportDetailViewModelFamily();

  /// See also [WeeklyReportDetailViewModel].
  WeeklyReportDetailViewModelProvider call(
    String weekId,
  ) {
    return WeeklyReportDetailViewModelProvider(
      weekId,
    );
  }

  @override
  WeeklyReportDetailViewModelProvider getProviderOverride(
    covariant WeeklyReportDetailViewModelProvider provider,
  ) {
    return call(
      provider.weekId,
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
  String? get name => r'weeklyReportDetailViewModelProvider';
}

/// See also [WeeklyReportDetailViewModel].
class WeeklyReportDetailViewModelProvider
    extends AutoDisposeAsyncNotifierProviderImpl<WeeklyReportDetailViewModel,
        WeeklyReportDetail> {
  /// See also [WeeklyReportDetailViewModel].
  WeeklyReportDetailViewModelProvider(
    String weekId,
  ) : this._internal(
          () => WeeklyReportDetailViewModel()..weekId = weekId,
          from: weeklyReportDetailViewModelProvider,
          name: r'weeklyReportDetailViewModelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$weeklyReportDetailViewModelHash,
          dependencies: WeeklyReportDetailViewModelFamily._dependencies,
          allTransitiveDependencies:
              WeeklyReportDetailViewModelFamily._allTransitiveDependencies,
          weekId: weekId,
        );

  WeeklyReportDetailViewModelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.weekId,
  }) : super.internal();

  final String weekId;

  @override
  FutureOr<WeeklyReportDetail> runNotifierBuild(
    covariant WeeklyReportDetailViewModel notifier,
  ) {
    return notifier.build(
      weekId,
    );
  }

  @override
  Override overrideWith(WeeklyReportDetailViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: WeeklyReportDetailViewModelProvider._internal(
        () => create()..weekId = weekId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        weekId: weekId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<WeeklyReportDetailViewModel,
      WeeklyReportDetail> createElement() {
    return _WeeklyReportDetailViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WeeklyReportDetailViewModelProvider &&
        other.weekId == weekId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, weekId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin WeeklyReportDetailViewModelRef
    on AutoDisposeAsyncNotifierProviderRef<WeeklyReportDetail> {
  /// The parameter `weekId` of this provider.
  String get weekId;
}

class _WeeklyReportDetailViewModelProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<WeeklyReportDetailViewModel,
        WeeklyReportDetail> with WeeklyReportDetailViewModelRef {
  _WeeklyReportDetailViewModelProviderElement(super.provider);

  @override
  String get weekId => (origin as WeeklyReportDetailViewModelProvider).weekId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
