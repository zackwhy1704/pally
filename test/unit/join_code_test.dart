import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/join/data/join_code.dart';

void main() {
  group('JoinCode.parse — self-describing QR payloads', () {
    test('APX:CLASS:CODE parses as a class with no round-trip', () {
      final jc = JoinCode.parse('APX:CLASS:5K7Q2X')!;
      expect(jc.kind, JoinKind.classroom);
      expect(jc.code, '5K7Q2X');
    });

    test('APX:GROUP:CODE parses as a group', () {
      final jc = JoinCode.parse('APX:GROUP:EXAM01')!;
      expect(jc.kind, JoinKind.group);
      expect(jc.code, 'EXAM01');
    });

    test('APX:PARENTCLAIM:CODE parses as a parent claim', () {
      final jc = JoinCode.parse('APX:PARENTCLAIM:ABC123')!;
      expect(jc.kind, JoinKind.parentClaim);
      expect(jc.code, 'ABC123');
    });

    test('payload is case-insensitive and trimmed', () {
      final jc = JoinCode.parse('  apx:class:5k7q2x  ')!;
      expect(jc.kind, JoinKind.classroom);
      expect(jc.code, '5K7Q2X');
    });

    test('unknown type segment falls back to unknown kind, code kept', () {
      final jc = JoinCode.parse('APX:WHAT:ZZZ999')!;
      expect(jc.kind, JoinKind.unknown);
      expect(jc.code, 'ZZZ999');
    });

    test('extra payload segments after the code are ignored', () {
      final jc = JoinCode.parse('APX:CLASS:5K7Q2X:Ms Tan')!;
      expect(jc.kind, JoinKind.classroom);
      expect(jc.code, '5K7Q2X');
    });
  });

  group('JoinCode.parse — bare codes (manual entry)', () {
    test('a plain code is unknown kind, normalised upper-case', () {
      final jc = JoinCode.parse('exam01')!;
      expect(jc.kind, JoinKind.unknown);
      expect(jc.code, 'EXAM01');
    });

    test('internal/edge whitespace is stripped', () {
      final jc = JoinCode.parse('  5k7 q2x ')!;
      expect(jc.code, '5K7Q2X');
    });
  });

  group('JoinCode.parse — invalid input never throws', () {
    test('empty / whitespace-only returns null', () {
      expect(JoinCode.parse(''), isNull);
      expect(JoinCode.parse('   '), isNull);
    });

    test('malformed APX payload (no code) returns null', () {
      expect(JoinCode.parse('APX:CLASS'), isNull);
      expect(JoinCode.parse('APX:CLASS:'), isNull);
    });
  });
}
