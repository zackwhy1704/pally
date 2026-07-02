import 'package:flutter_test/flutter_test.dart';
import 'package:pally/core/utils/text_format.dart';

/// Pins the ONE canonical email mask so onboarding + the consent sheet can never
/// diverge again (they once produced "j***n@" vs "jo***@" for the same address).
void main() {
  test('maskEmail keeps the first two chars of the local part', () {
    expect(maskEmail('john@gmail.com'), 'jo***@gmail.com');
    expect(maskEmail('aisha.tan@school.edu.sg'), 'ai***@school.edu.sg');
  });

  test('maskEmail handles short local parts and malformed input', () {
    expect(maskEmail('a@x.com'), 'a***@x.com');
    expect(maskEmail('jo@x.com'), 'j***@x.com');
    expect(maskEmail('not-an-email'), 'not-an-email');
    expect(maskEmail('@x.com'), '@x.com');
  });
}
