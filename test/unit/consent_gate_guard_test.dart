import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/consent/data/consent_gate_guard.dart';

void main() {
  group('ConsentGateGuard', () {
    test('three parallel triggers show exactly ONE gate', () {
      final guard = ConsentGateGuard();
      var shown = 0;
      final completers = <Completer<void>>[];
      Future<void> show() {
        shown++;
        final c = Completer<void>();
        completers.add(c);
        return c.future;
      }

      // Simulate the dashboard's parallel 403 storm.
      guard.runOnce(show);
      guard.runOnce(show);
      guard.runOnce(show);

      expect(shown, 1, reason: 'only one sheet may open for parallel 403s');
      expect(guard.isOpen, isTrue);
    });

    test('closing the gate resets the flag so a later gate can show', () async {
      final guard = ConsentGateGuard();
      var shown = 0;
      Completer<void>? current;
      Future<void> show() {
        shown++;
        current = Completer<void>();
        return current!.future;
      }

      guard.runOnce(show);
      expect(shown, 1);

      // Close it (sheet dismissed).
      current!.complete();
      await Future<void>.delayed(Duration.zero); // let whenComplete run
      expect(guard.isOpen, isFalse);

      // A later genuine gate shows again.
      guard.runOnce(show);
      expect(shown, 2);
    });

    test('a synchronous throw never wedges the gate shut', () {
      final guard = ConsentGateGuard();
      guard.runOnce(() => throw StateError('no context'));
      expect(guard.isOpen, isFalse, reason: 'must recover so a later gate opens');
    });
  });
}
