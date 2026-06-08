import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/core/ui/painters/character_painter.dart';
import 'package:pally/shared/models/avatar.dart';
import 'package:pally/shared/models/mochi_character.dart';
import 'package:pally/shared/models/mochi_cosmetics.dart';

Avatar _avatar({
  MochiCharacter character = MochiCharacter.atwSakura,
  String? cosmeticEyewear,
  String? cosmeticClothes,
  String? cosmeticShoes,
}) =>
    Avatar(
      id: 'a1',
      name: 'Class Mochi',
      character: character,
      subject: 'MATHS',
      cosmeticEyewear: cosmeticEyewear,
      cosmeticClothes: cosmeticClothes,
      cosmeticShoes: cosmeticShoes,
    );

void main() {
  group('MochiCosmetics resolver', () {
    test('returns null for null or empty slot ids', () {
      expect(MochiCosmetics.eyewearAsset(null), isNull);
      expect(MochiCosmetics.clothesAsset(''), isNull);
      expect(MochiCosmetics.shoesAsset(null), isNull);
    });

    test('returns null for unknown slot ids until art is commissioned', () {
      // No layered art exists yet — every catalog is empty, so any slot id
      // resolves to null and rendering stays inert.
      expect(MochiCosmetics.eyewearAsset('round_glasses'), isNull);
      expect(MochiCosmetics.clothesAsset('lab_coat'), isNull);
      expect(MochiCosmetics.shoesAsset('sneakers'), isNull);
    });
  });

  group('CharacterWidget rendering', () {
    // Asset bytes aren't available in the widget-test bundle, so Image.asset
    // records a benign "unable to load asset" exception during paint. We assert
    // on the widget *structure* (which exists regardless of load success) and
    // drain those expected exceptions so they don't fail the test.
    void drainAssetExceptions(WidgetTester tester) {
      while (tester.takeException() != null) {}
    }

    testWidgets('renders a single base image when no cosmetics are set',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: CharacterWidget(character: MochiCharacter.atwSakura, size: 64),
      ));
      // Exactly the base image, no Stack overlay.
      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(Stack), findsNothing);
      drainAssetExceptions(tester);
    });

    testWidgets('forAvatar with empty cosmetic slots stays a single base image',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: CharacterWidget.forAvatar(
          _avatar(cosmeticEyewear: 'round_glasses', cosmeticClothes: 'lab_coat'),
          64,
        ),
      ));
      // Slots are set but unresolved (no art) → single base image, fully
      // backward compatible.
      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(Stack), findsNothing);
      drainAssetExceptions(tester);
    });

    testWidgets('composites a Stack of layers when overlay assets are provided',
        (tester) async {
      // Drive the layered path directly with concrete asset paths (proves the
      // scaffold works the moment real art is wired into the catalogs).
      await tester.pumpWidget(const MaterialApp(
        home: CharacterWidget(
          character: MochiCharacter.atwSakura,
          size: 64,
          clothesAsset: 'assets/images/base.png',
          eyewearAsset: 'assets/images/base.png',
        ),
      ));
      expect(find.byType(Stack), findsOneWidget);
      // base + clothes + eyewear = 3 images.
      expect(find.byType(Image), findsNWidgets(3));
      drainAssetExceptions(tester);
    });
  });
}
