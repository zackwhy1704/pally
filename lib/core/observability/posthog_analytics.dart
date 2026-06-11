import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:pally/core/observability/observability.dart';

/// PostHog-backed analytics implementation.
///
/// Replaces [NoopAnalytics] in release builds to forward all events,
/// screen views, and identity calls to PostHog.
class PostHogAnalytics implements Analytics {
  const PostHogAnalytics();

  @override
  void event(String name, {Map<String, Object?> props = const {}}) {
    Posthog().capture(eventName: name, properties: _stripNulls(props));
  }

  @override
  void screen(String name, {Map<String, Object?> props = const {}}) {
    Posthog().screen(screenName: name, properties: _stripNulls(props));
  }

  @override
  void identify(String uid, {Map<String, Object?> props = const {}}) {
    Posthog().identify(userId: uid, userProperties: _stripNulls(props));
  }

  /// PostHog SDK expects `Map<String, Object>` (non-nullable values).
  /// Strip null entries to satisfy the type contract.
  static Map<String, Object> _stripNulls(Map<String, Object?> input) {
    final result = <String, Object>{};
    for (final entry in input.entries) {
      if (entry.value != null) result[entry.key] = entry.value!;
    }
    return result;
  }

  @override
  void reset() {
    Posthog().reset();
  }
}
