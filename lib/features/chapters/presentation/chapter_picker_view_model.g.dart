// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chapter_picker_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$chapterPickerViewModelHash() =>
    r'96dae99584fd27aa51318da560998288cd076d2f';

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

abstract class _$ChapterPickerViewModel
    extends BuildlessAutoDisposeAsyncNotifier<ChaptersResult> {
  late final String avatarId;

  FutureOr<ChaptersResult> build(
    String avatarId,
  );
}

/// Loads an avatar's chapter chunks + the compile allowance, and picks chapters to
/// compile. Screens render this state; they never call the API themselves.
///
/// Copied from [ChapterPickerViewModel].
@ProviderFor(ChapterPickerViewModel)
const chapterPickerViewModelProvider = ChapterPickerViewModelFamily();

/// Loads an avatar's chapter chunks + the compile allowance, and picks chapters to
/// compile. Screens render this state; they never call the API themselves.
///
/// Copied from [ChapterPickerViewModel].
class ChapterPickerViewModelFamily extends Family<AsyncValue<ChaptersResult>> {
  /// Loads an avatar's chapter chunks + the compile allowance, and picks chapters to
  /// compile. Screens render this state; they never call the API themselves.
  ///
  /// Copied from [ChapterPickerViewModel].
  const ChapterPickerViewModelFamily();

  /// Loads an avatar's chapter chunks + the compile allowance, and picks chapters to
  /// compile. Screens render this state; they never call the API themselves.
  ///
  /// Copied from [ChapterPickerViewModel].
  ChapterPickerViewModelProvider call(
    String avatarId,
  ) {
    return ChapterPickerViewModelProvider(
      avatarId,
    );
  }

  @override
  ChapterPickerViewModelProvider getProviderOverride(
    covariant ChapterPickerViewModelProvider provider,
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
  String? get name => r'chapterPickerViewModelProvider';
}

/// Loads an avatar's chapter chunks + the compile allowance, and picks chapters to
/// compile. Screens render this state; they never call the API themselves.
///
/// Copied from [ChapterPickerViewModel].
class ChapterPickerViewModelProvider
    extends AutoDisposeAsyncNotifierProviderImpl<ChapterPickerViewModel,
        ChaptersResult> {
  /// Loads an avatar's chapter chunks + the compile allowance, and picks chapters to
  /// compile. Screens render this state; they never call the API themselves.
  ///
  /// Copied from [ChapterPickerViewModel].
  ChapterPickerViewModelProvider(
    String avatarId,
  ) : this._internal(
          () => ChapterPickerViewModel()..avatarId = avatarId,
          from: chapterPickerViewModelProvider,
          name: r'chapterPickerViewModelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$chapterPickerViewModelHash,
          dependencies: ChapterPickerViewModelFamily._dependencies,
          allTransitiveDependencies:
              ChapterPickerViewModelFamily._allTransitiveDependencies,
          avatarId: avatarId,
        );

  ChapterPickerViewModelProvider._internal(
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
  FutureOr<ChaptersResult> runNotifierBuild(
    covariant ChapterPickerViewModel notifier,
  ) {
    return notifier.build(
      avatarId,
    );
  }

  @override
  Override overrideWith(ChapterPickerViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: ChapterPickerViewModelProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<ChapterPickerViewModel,
      ChaptersResult> createElement() {
    return _ChapterPickerViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChapterPickerViewModelProvider &&
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
mixin ChapterPickerViewModelRef
    on AutoDisposeAsyncNotifierProviderRef<ChaptersResult> {
  /// The parameter `avatarId` of this provider.
  String get avatarId;
}

class _ChapterPickerViewModelProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<ChapterPickerViewModel,
        ChaptersResult> with ChapterPickerViewModelRef {
  _ChapterPickerViewModelProviderElement(super.provider);

  @override
  String get avatarId => (origin as ChapterPickerViewModelProvider).avatarId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
