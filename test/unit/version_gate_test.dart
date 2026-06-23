import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/app_update/version_gate.dart';

void main() {
  group('compareSemver', () {
    test('equal versions return 0', () {
      expect(compareSemver('1.2.3', '1.2.3'), 0);
    });

    test('compares numerically, not lexically', () {
      expect(compareSemver('1.9.0', '1.10.0'), lessThan(0));
      expect(compareSemver('1.10.0', '1.9.0'), greaterThan(0));
    });

    test('lower version is negative, higher is positive', () {
      expect(compareSemver('1.2.0', '1.2.3'), lessThan(0));
      expect(compareSemver('2.0.0', '1.9.9'), greaterThan(0));
    });

    test('missing trailing segments are treated as 0', () {
      expect(compareSemver('1.2', '1.2.0'), 0);
      expect(compareSemver('1.2', '1.2.1'), lessThan(0));
    });

    test('strips build (+) and pre-release (-) suffixes', () {
      expect(compareSemver('1.0.0+5', '1.0.0'), 0);
      expect(compareSemver('1.0.0-beta', '1.0.0'), 0);
    });
  });

  group('isUpdateRequired', () {
    test('true only when the running version is strictly below the minimum', () {
      expect(isUpdateRequired('1.0.0', '1.2.0'), isTrue);
      expect(isUpdateRequired('1.2.0', '1.2.0'), isFalse); // equal → allowed
      expect(isUpdateRequired('1.3.0', '1.2.0'), isFalse); // newer → allowed
    });
  });
}
