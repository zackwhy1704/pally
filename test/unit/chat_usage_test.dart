import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/chat/providers/chat_usage_provider.dart';

/// Locks the "designed-moment" UI rules:
///  - never warn premium users (no cap to hit),
///  - never warn when remaining > 5 (don't crowd the input prematurely),
///  - clamp at 0 so a stale counter past the cap doesn't render
///    "-3 messages left today".
void main() {
  group('ChatUsage', () {
    test('premium never warns, remaining is null', () {
      const u = ChatUsage(isPremium: true, used: 100, limit: null);
      expect(u.shouldWarn, isFalse);
      expect(u.remaining, isNull);
    });

    test('free with plenty remaining does not warn', () {
      const u = ChatUsage(isPremium: false, used: 5, limit: 20);
      expect(u.remaining, 15);
      expect(u.shouldWarn, isFalse);
    });

    test('free at the 5-left threshold warns', () {
      const u = ChatUsage(isPremium: false, used: 15, limit: 20);
      expect(u.remaining, 5);
      expect(u.shouldWarn, isTrue);
    });

    test('free at 1 left warns', () {
      const u = ChatUsage(isPremium: false, used: 19, limit: 20);
      expect(u.remaining, 1);
      expect(u.shouldWarn, isTrue);
    });

    test('free over cap clamps remaining to zero', () {
      const u = ChatUsage(isPremium: false, used: 25, limit: 20);
      expect(u.remaining, 0);
      expect(u.shouldWarn, isTrue);
    });

    test('null limit (loading state) never warns', () {
      const u = ChatUsage(isPremium: false, used: 100, limit: null);
      expect(u.shouldWarn, isFalse);
      expect(u.remaining, isNull);
    });
  });
}
