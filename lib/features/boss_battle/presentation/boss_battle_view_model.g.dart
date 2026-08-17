// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'boss_battle_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$bossBattleViewModelHash() =>
    r'8c4429c5060fc2a553c3b34120ed3ea1140973a4';

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

abstract class _$BossBattleViewModel
    extends BuildlessAutoDisposeNotifier<BossBattleState> {
  late final String avatarId;

  BossBattleState build(
    String avatarId,
  );
}

/// Server-authoritative boss battle. Every mutation here either loads or
/// REPLACES [BossBattleState.boss] wholesale from a server response — this
/// view model never derives hp/defeated locally (same authority pattern as
/// the server-graded quiz submit).
///
/// Copied from [BossBattleViewModel].
@ProviderFor(BossBattleViewModel)
const bossBattleViewModelProvider = BossBattleViewModelFamily();

/// Server-authoritative boss battle. Every mutation here either loads or
/// REPLACES [BossBattleState.boss] wholesale from a server response — this
/// view model never derives hp/defeated locally (same authority pattern as
/// the server-graded quiz submit).
///
/// Copied from [BossBattleViewModel].
class BossBattleViewModelFamily extends Family<BossBattleState> {
  /// Server-authoritative boss battle. Every mutation here either loads or
  /// REPLACES [BossBattleState.boss] wholesale from a server response — this
  /// view model never derives hp/defeated locally (same authority pattern as
  /// the server-graded quiz submit).
  ///
  /// Copied from [BossBattleViewModel].
  const BossBattleViewModelFamily();

  /// Server-authoritative boss battle. Every mutation here either loads or
  /// REPLACES [BossBattleState.boss] wholesale from a server response — this
  /// view model never derives hp/defeated locally (same authority pattern as
  /// the server-graded quiz submit).
  ///
  /// Copied from [BossBattleViewModel].
  BossBattleViewModelProvider call(
    String avatarId,
  ) {
    return BossBattleViewModelProvider(
      avatarId,
    );
  }

  @override
  BossBattleViewModelProvider getProviderOverride(
    covariant BossBattleViewModelProvider provider,
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
  String? get name => r'bossBattleViewModelProvider';
}

/// Server-authoritative boss battle. Every mutation here either loads or
/// REPLACES [BossBattleState.boss] wholesale from a server response — this
/// view model never derives hp/defeated locally (same authority pattern as
/// the server-graded quiz submit).
///
/// Copied from [BossBattleViewModel].
class BossBattleViewModelProvider extends AutoDisposeNotifierProviderImpl<
    BossBattleViewModel, BossBattleState> {
  /// Server-authoritative boss battle. Every mutation here either loads or
  /// REPLACES [BossBattleState.boss] wholesale from a server response — this
  /// view model never derives hp/defeated locally (same authority pattern as
  /// the server-graded quiz submit).
  ///
  /// Copied from [BossBattleViewModel].
  BossBattleViewModelProvider(
    String avatarId,
  ) : this._internal(
          () => BossBattleViewModel()..avatarId = avatarId,
          from: bossBattleViewModelProvider,
          name: r'bossBattleViewModelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$bossBattleViewModelHash,
          dependencies: BossBattleViewModelFamily._dependencies,
          allTransitiveDependencies:
              BossBattleViewModelFamily._allTransitiveDependencies,
          avatarId: avatarId,
        );

  BossBattleViewModelProvider._internal(
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
  BossBattleState runNotifierBuild(
    covariant BossBattleViewModel notifier,
  ) {
    return notifier.build(
      avatarId,
    );
  }

  @override
  Override overrideWith(BossBattleViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: BossBattleViewModelProvider._internal(
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
  AutoDisposeNotifierProviderElement<BossBattleViewModel, BossBattleState>
      createElement() {
    return _BossBattleViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BossBattleViewModelProvider && other.avatarId == avatarId;
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
mixin BossBattleViewModelRef
    on AutoDisposeNotifierProviderRef<BossBattleState> {
  /// The parameter `avatarId` of this provider.
  String get avatarId;
}

class _BossBattleViewModelProviderElement
    extends AutoDisposeNotifierProviderElement<BossBattleViewModel,
        BossBattleState> with BossBattleViewModelRef {
  _BossBattleViewModelProviderElement(super.provider);

  @override
  String get avatarId => (origin as BossBattleViewModelProvider).avatarId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
