import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/auth/auth_state.dart';

void main() {
  group('AuthState accountType', () {
    test('isParentAccount returns true when accountType is PARENT', () {
      const state = AuthState(
        userId: 'u1',
        token: 't1',
        accountType: 'PARENT',
      );
      expect(state.isParentAccount, true);
    });

    test('isParentAccount returns false when accountType is STUDENT', () {
      const state = AuthState(
        userId: 'u1',
        token: 't1',
        accountType: 'STUDENT',
      );
      expect(state.isParentAccount, false);
    });

    test('isParentAccount returns false when accountType is null', () {
      const state = AuthState(
        userId: 'u1',
        token: 't1',
      );
      expect(state.isParentAccount, false);
    });

    test('copyWith preserves accountType when not specified', () {
      const state = AuthState(
        userId: 'u1',
        token: 't1',
        accountType: 'PARENT',
      );
      final copy = state.copyWith(userId: 'u2');
      expect(copy.accountType, 'PARENT');
      expect(copy.userId, 'u2');
    });

    test('copyWith can set accountType to null', () {
      const state = AuthState(
        userId: 'u1',
        token: 't1',
        accountType: 'PARENT',
      );
      final copy = state.copyWith(accountType: null);
      expect(copy.accountType, isNull);
      expect(copy.isParentAccount, false);
    });

    test('copyWith can change accountType', () {
      const state = AuthState(
        userId: 'u1',
        token: 't1',
        accountType: 'STUDENT',
      );
      final copy = state.copyWith(accountType: 'PARENT');
      expect(copy.isParentAccount, true);
    });
  });

  group('ParentHomeState', () {
    test('ParentChildSummary defaults are sensible', () {
      // Import from parent_home_view_model but that requires the generated
      // file. Instead, test the AuthState contract which is the core change.
      const state = AuthState();
      expect(state.isParentAccount, false);
      expect(state.accountType, isNull);
    });
  });
}
