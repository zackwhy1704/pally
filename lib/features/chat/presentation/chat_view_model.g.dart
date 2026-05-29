// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$chatViewModelHash() => r'13e2d67a412a57c0640109508538df80efa0e0c1';

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

abstract class _$ChatViewModel extends BuildlessAutoDisposeNotifier<ChatState> {
  late final String avatarId;

  ChatState build(
    String avatarId,
  );
}

/// See also [ChatViewModel].
@ProviderFor(ChatViewModel)
const chatViewModelProvider = ChatViewModelFamily();

/// See also [ChatViewModel].
class ChatViewModelFamily extends Family<ChatState> {
  /// See also [ChatViewModel].
  const ChatViewModelFamily();

  /// See also [ChatViewModel].
  ChatViewModelProvider call(
    String avatarId,
  ) {
    return ChatViewModelProvider(
      avatarId,
    );
  }

  @override
  ChatViewModelProvider getProviderOverride(
    covariant ChatViewModelProvider provider,
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
  String? get name => r'chatViewModelProvider';
}

/// See also [ChatViewModel].
class ChatViewModelProvider
    extends AutoDisposeNotifierProviderImpl<ChatViewModel, ChatState> {
  /// See also [ChatViewModel].
  ChatViewModelProvider(
    String avatarId,
  ) : this._internal(
          () => ChatViewModel()..avatarId = avatarId,
          from: chatViewModelProvider,
          name: r'chatViewModelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$chatViewModelHash,
          dependencies: ChatViewModelFamily._dependencies,
          allTransitiveDependencies:
              ChatViewModelFamily._allTransitiveDependencies,
          avatarId: avatarId,
        );

  ChatViewModelProvider._internal(
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
  ChatState runNotifierBuild(
    covariant ChatViewModel notifier,
  ) {
    return notifier.build(
      avatarId,
    );
  }

  @override
  Override overrideWith(ChatViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: ChatViewModelProvider._internal(
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
  AutoDisposeNotifierProviderElement<ChatViewModel, ChatState> createElement() {
    return _ChatViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChatViewModelProvider && other.avatarId == avatarId;
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
mixin ChatViewModelRef on AutoDisposeNotifierProviderRef<ChatState> {
  /// The parameter `avatarId` of this provider.
  String get avatarId;
}

class _ChatViewModelProviderElement
    extends AutoDisposeNotifierProviderElement<ChatViewModel, ChatState>
    with ChatViewModelRef {
  _ChatViewModelProviderElement(super.provider);

  @override
  String get avatarId => (origin as ChatViewModelProvider).avatarId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
