// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$quizViewModelHash() => r'02354f62ce415293a813337bf45e71b45a55d9f6';

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

abstract class _$QuizViewModel extends BuildlessAutoDisposeNotifier<QuizState> {
  late final String avatarId;

  QuizState build(
    String avatarId,
  );
}

/// See also [QuizViewModel].
@ProviderFor(QuizViewModel)
const quizViewModelProvider = QuizViewModelFamily();

/// See also [QuizViewModel].
class QuizViewModelFamily extends Family<QuizState> {
  /// See also [QuizViewModel].
  const QuizViewModelFamily();

  /// See also [QuizViewModel].
  QuizViewModelProvider call(
    String avatarId,
  ) {
    return QuizViewModelProvider(
      avatarId,
    );
  }

  @override
  QuizViewModelProvider getProviderOverride(
    covariant QuizViewModelProvider provider,
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
  String? get name => r'quizViewModelProvider';
}

/// See also [QuizViewModel].
class QuizViewModelProvider
    extends AutoDisposeNotifierProviderImpl<QuizViewModel, QuizState> {
  /// See also [QuizViewModel].
  QuizViewModelProvider(
    String avatarId,
  ) : this._internal(
          () => QuizViewModel()..avatarId = avatarId,
          from: quizViewModelProvider,
          name: r'quizViewModelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$quizViewModelHash,
          dependencies: QuizViewModelFamily._dependencies,
          allTransitiveDependencies:
              QuizViewModelFamily._allTransitiveDependencies,
          avatarId: avatarId,
        );

  QuizViewModelProvider._internal(
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
  QuizState runNotifierBuild(
    covariant QuizViewModel notifier,
  ) {
    return notifier.build(
      avatarId,
    );
  }

  @override
  Override overrideWith(QuizViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: QuizViewModelProvider._internal(
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
  AutoDisposeNotifierProviderElement<QuizViewModel, QuizState> createElement() {
    return _QuizViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is QuizViewModelProvider && other.avatarId == avatarId;
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
mixin QuizViewModelRef on AutoDisposeNotifierProviderRef<QuizState> {
  /// The parameter `avatarId` of this provider.
  String get avatarId;
}

class _QuizViewModelProviderElement
    extends AutoDisposeNotifierProviderElement<QuizViewModel, QuizState>
    with QuizViewModelRef {
  _QuizViewModelProviderElement(super.provider);

  @override
  String get avatarId => (origin as QuizViewModelProvider).avatarId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
