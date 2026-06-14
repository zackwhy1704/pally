import 'package:flutter_test/flutter_test.dart';
import 'package:pally/shared/models/mochi_config.dart';

void main() {
  group('MochiConfig.fromJson', () {
    test('parses a full {body, accessory, aura} payload', () {
      final c = MochiConfig.fromJson(const {
        'body': 5,
        'accessory': 'crown',
        'aura': 'fire',
      });
      expect(c.body, 5);
      expect(c.accessory, 'crown');
      expect(c.aura, 'fire');
    });

    test('defaults to body=0, accessory=none, aura=none on empty map', () {
      final c = MochiConfig.fromJson(const {});
      expect(c.body, 0);
      expect(c.accessory, 'none');
      expect(c.aura, 'none');
    });

    test('defaults each field independently when individually missing', () {
      final c = MochiConfig.fromJson(const {'body': 3});
      expect(c.body, 3);
      expect(c.accessory, 'none');
      expect(c.aura, 'none');
    });

    test('coerces a numeric body from a JSON num', () {
      // Backends sometimes emit ints as JSON numbers (double on the wire).
      final c = MochiConfig.fromJson(<String, dynamic>{'body': 7.0});
      expect(c.body, 7);
    });

    test('clamps an out-of-range body index into [0, 11]', () {
      expect(MochiConfig.fromJson(const {'body': 99}).body, 11);
      expect(MochiConfig.fromJson(const {'body': -4}).body, 0);
    });

    test('falls back to none for an unknown accessory', () {
      final c = MochiConfig.fromJson(const {'accessory': 'jetpack'});
      expect(c.accessory, 'none');
    });

    test('falls back to none for an unknown aura', () {
      final c = MochiConfig.fromJson(const {'aura': 'plasma'});
      expect(c.aura, 'none');
    });

    test('ignores unknown/legacy keys (eyeStyle, cheekVariant)', () {
      final c = MochiConfig.fromJson(const {
        'body': 2,
        'accessory': 'bow',
        'aura': 'bloom',
        'eyeStyle': 'wink',
        'cheekVariant': 'rosy',
      });
      expect(c.body, 2);
      expect(c.accessory, 'bow');
      expect(c.aura, 'bloom');
    });

    test('round-trips through toJson', () {
      const c = MochiConfig(body: 8, accessory: 'glasses', aura: 'chill');
      final back = MochiConfig.fromJson(c.toJson());
      expect(back, c);
    });

    test('value equality holds for identical configs', () {
      expect(
        const MochiConfig(body: 1, accessory: 'cap', aura: 'electric'),
        const MochiConfig(body: 1, accessory: 'cap', aura: 'electric'),
      );
    });
  });
}
