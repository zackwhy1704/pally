import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/core/ui/mochi_avatar.dart';
import 'package:pally/core/ui/painters/character_painter.dart';
import 'package:pally/core/ui/painters/class_uniform_mochi_painter.dart';
import 'package:pally/shared/models/avatar.dart';
import 'package:pally/shared/models/mochi_character.dart';
import 'package:pally/shared/models/mochi_config.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: Center(child: child)));

void main() {
  group('cssFilterColorMatrix', () {
    test('body 0 (hue 0, saturate 1, brightness 1) is the identity matrix', () {
      final m = cssFilterColorMatrix(hueDegrees: 0, saturate: 1, brightness: 1);
      const identity = <double>[
        1, 0, 0, 0, 0, //
        0, 1, 0, 0, 0, //
        0, 0, 1, 0, 0, //
        0, 0, 0, 1, 0, //
      ];
      expect(m.length, 20);
      for (var i = 0; i < 20; i++) {
        expect(m[i], closeTo(identity[i], 1e-9), reason: 'index $i');
      }
    });

    test('brightness scales the diagonal', () {
      final m = cssFilterColorMatrix(hueDegrees: 0, saturate: 1, brightness: 1.5);
      expect(m[0], closeTo(1.5, 1e-9)); // R←R
      expect(m[6], closeTo(1.5, 1e-9)); // G←G
      expect(m[12], closeTo(1.5, 1e-9)); // B←B
    });

    test('a full hue rotation (360deg) returns to identity', () {
      final m = cssFilterColorMatrix(hueDegrees: 360, saturate: 1, brightness: 1);
      const identity = <double>[
        1, 0, 0, 0, 0, //
        0, 1, 0, 0, 0, //
        0, 0, 1, 0, 0, //
        0, 0, 0, 1, 0, //
      ];
      for (var i = 0; i < 20; i++) {
        expect(m[i], closeTo(identity[i], 1e-6), reason: 'index $i');
      }
    });

    test('grayscale-style saturate(0) collapses rows to luminance weights', () {
      final m = cssFilterColorMatrix(hueDegrees: 0, saturate: 0, brightness: 1);
      // Each RGB output row becomes the luminance coefficients.
      expect(m[0], closeTo(0.213, 1e-9));
      expect(m[1], closeTo(0.715, 1e-9));
      expect(m[2], closeTo(0.072, 1e-9));
    });
  });

  group('MochiAvatar renders', () {
    for (final size in const [48.0, 96.0, 140.0]) {
      testWidgets('without exception at size $size', (tester) async {
        await tester.pumpWidget(_wrap(
          MochiAvatar(
            config: const MochiConfig(
                body: 6, accessory: 'glasses', aura: 'electric'),
            size: size,
          ),
        ));
        expect(tester.takeException(), isNull);
        expect(find.byType(MochiAvatar), findsOneWidget);
      });
    }

    testWidgets('body 0 / no accessory / no aura renders cleanly', (tester) async {
      await tester.pumpWidget(_wrap(
        const MochiAvatar(config: MochiConfig(), size: 96),
      ));
      expect(tester.takeException(), isNull);
    });

    testWidgets('every accessory and aura combination renders', (tester) async {
      for (final acc in kMochiAccessories) {
        for (final aura in kMochiAuras) {
          await tester.pumpWidget(_wrap(
            MochiAvatar(
              config: MochiConfig(body: 3, accessory: acc, aura: aura),
              size: 80,
            ),
          ));
          expect(tester.takeException(), isNull,
              reason: 'accessory=$acc aura=$aura');
        }
      }
    });

    testWidgets('animate=true runs the breathing controller', (tester) async {
      await tester.pumpWidget(_wrap(
        const MochiAvatar(config: MochiConfig(body: 2), size: 96, animate: true),
      ));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
      // Settle the repeating animation so the test can tear down.
      await tester.pumpWidget(_wrap(const SizedBox.shrink()));
    });
  });

  group('CharacterWidget.forAvatar dispatch', () {
    Avatar baseAvatar({
      AvatarKind kind = AvatarKind.personal,
      MochiConfig? mochiConfig,
      ClassAppearance? appearance,
    }) =>
        Avatar(
          id: 'a1',
          name: 'Class Mochi',
          character: MochiCharacter.mochi,
          subject: 'Maths',
          kind: kind,
          mochiConfig: mochiConfig,
          appearance: appearance,
        );

    testWidgets('CENTRE_CLASS with mochiConfig renders MochiAvatar',
        (tester) async {
      final avatar = baseAvatar(
        kind: AvatarKind.centreClass,
        mochiConfig: const MochiConfig(body: 5, accessory: 'crown', aura: 'fire'),
      );
      await tester.pumpWidget(_wrap(CharacterWidget.forAvatar(avatar, 100)));
      expect(find.byType(MochiAvatar), findsOneWidget);
      expect(find.byType(ClassUniformAvatar), findsNothing);
    });

    testWidgets(
        'CENTRE_CLASS without mochiConfig but with appearance falls back to '
        'ClassUniformAvatar', (tester) async {
      final avatar = baseAvatar(
        kind: AvatarKind.centreClass,
        appearance: const ClassAppearance(
            bandColorHex: '#7042ED', subjectGlyph: 'math', initials: 'P5'),
      );
      await tester.pumpWidget(_wrap(CharacterWidget.forAvatar(avatar, 100)));
      expect(find.byType(ClassUniformAvatar), findsOneWidget);
      expect(find.byType(MochiAvatar), findsNothing);
    });

    testWidgets('PERSONAL avatar renders neither Mochi/uniform special widget',
        (tester) async {
      final avatar = baseAvatar();
      await tester.pumpWidget(_wrap(CharacterWidget.forAvatar(avatar, 100)));
      expect(tester.takeException(), isNull);
      expect(find.byType(MochiAvatar), findsNothing);
      expect(find.byType(ClassUniformAvatar), findsNothing);
      expect(find.byType(CharacterWidget), findsOneWidget);
    });
  });
}
