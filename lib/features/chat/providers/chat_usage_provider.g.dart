// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_usage_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$chatUsageNotifierHash() => r'82ab509734fcea7f04304fd019f99c1592bd60af';

/// Polls the backend's /usage/today endpoint. Best-effort: a failure leaves
/// state null and the chat just doesn't show the hint — never an error.
///
/// Copied from [ChatUsageNotifier].
@ProviderFor(ChatUsageNotifier)
final chatUsageNotifierProvider =
    AutoDisposeNotifierProvider<ChatUsageNotifier, ChatUsage?>.internal(
  ChatUsageNotifier.new,
  name: r'chatUsageNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$chatUsageNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ChatUsageNotifier = AutoDisposeNotifier<ChatUsage?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
