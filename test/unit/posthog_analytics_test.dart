import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/core/observability/observability.dart';
import 'package:pally/core/observability/observability_providers.dart';
import 'package:pally/core/observability/noop_observability.dart';

/// Records all calls for assertion.
class FakeAnalytics implements Analytics {
  final List<_Call> calls = [];

  @override
  void event(String name, {Map<String, Object?> props = const {}}) {
    calls.add(_Call('event', name, props));
  }

  @override
  void screen(String name, {Map<String, Object?> props = const {}}) {
    calls.add(_Call('screen', name, props));
  }

  @override
  void identify(String uid, {Map<String, Object?> props = const {}}) {
    calls.add(_Call('identify', uid, props));
  }

  @override
  void reset() {
    calls.add(const _Call('reset', '', {}));
  }
}

class _Call {
  const _Call(this.method, this.name, this.props);
  final String method;
  final String name;
  final Map<String, Object?> props;
}

void main() {
  group('analyticsProvider', () {
    test('returns Analytics from provider', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final analytics = container.read(analyticsProvider);
      // In test mode (debug), it returns NoopAnalytics or PostHogAnalytics
      // depending on SentryObservability.isActive. In test, it should be Noop.
      expect(analytics, isA<Analytics>());
    });

    test('analyticsProvider can be overridden with FakeAnalytics', () {
      final fake = FakeAnalytics();
      final container = ProviderContainer(
        overrides: [analyticsProvider.overrideWithValue(fake)],
      );
      addTearDown(container.dispose);

      final analytics = container.read(analyticsProvider);
      expect(analytics, same(fake));

      analytics.event('test_event', props: {'key': 'value'});
      analytics.screen('test_screen');
      analytics.identify('user-1', props: {'email': 'a@b.com'});
      analytics.reset();

      expect(fake.calls, hasLength(4));
      expect(fake.calls[0].method, 'event');
      expect(fake.calls[0].name, 'test_event');
      expect(fake.calls[0].props, {'key': 'value'});
      expect(fake.calls[1].method, 'screen');
      expect(fake.calls[1].name, 'test_screen');
      expect(fake.calls[2].method, 'identify');
      expect(fake.calls[2].name, 'user-1');
      expect(fake.calls[3].method, 'reset');
    });
  });

  group('AnalyticsEvents constants', () {
    test('module event names are defined', () {
      expect(AnalyticsEvents.moduleStarted, 'module_started');
      expect(AnalyticsEvents.moduleStageCompleted, 'module_stage_completed');
      expect(AnalyticsEvents.moduleCompleted, 'module_completed');
      expect(AnalyticsEvents.assignmentStarted, 'assignment_started');
      expect(AnalyticsEvents.assignmentCompleted, 'assignment_completed');
      expect(AnalyticsEvents.examPrepViewed, 'exam_prep_viewed');
      expect(AnalyticsEvents.narrationPlayed, 'narration_played');
      expect(AnalyticsEvents.onboardingCompleted, 'onboarding_completed');
    });

    test('legacy event names are still defined', () {
      expect(AnalyticsEvents.signIn, 'sign_in');
      expect(AnalyticsEvents.uploadNote, 'upload_note');
      expect(AnalyticsEvents.messageSent, 'message_sent');
      expect(AnalyticsEvents.quizComplete, 'quiz_complete');
    });
  });

  group('NoopAnalytics', () {
    test('does not throw on any method call', () {
      const noop = NoopAnalytics();
      expect(() => noop.event('x', props: {'a': null}), returnsNormally);
      expect(() => noop.screen('x'), returnsNormally);
      expect(() => noop.identify('u'), returnsNormally);
      expect(() => noop.reset(), returnsNormally);
    });
  });
}
