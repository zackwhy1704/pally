import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/core/ui/painters/character_painter.dart';
import 'package:pally/core/ui/painters/class_uniform_mochi_painter.dart';
import 'package:pally/shared/models/avatar.dart';
import 'package:pally/shared/models/mochi_character.dart';

/// Builds a CENTRE_CLASS avatar with a class uniform appearance.
Avatar _classAvatar({
  String bandColorHex = '#7042ED',
  String subjectGlyph = 'math',
  String initials = 'P5',
}) =>
    Avatar(
      id: 'c1',
      name: 'P5 Maths',
      character: MochiCharacter.mochi,
      subject: 'MATHS',
      kind: AvatarKind.centreClass,
      appearance: ClassAppearance(
        bandColorHex: bandColorHex,
        subjectGlyph: subjectGlyph,
        initials: initials,
      ),
    );

/// Builds a personal collectible avatar (no class appearance).
Avatar _personalAvatar({MochiCharacter character = MochiCharacter.goldstar}) =>
    Avatar(
      id: 'p1',
      name: 'Sakura',
      character: character,
      subject: 'SCIENCE',
    );

void main() {
  // Asset bytes aren't bundled in widget tests, so Image.asset records a benign
  // load exception during paint. Drain those so structural assertions pass.
  void drainAssetExceptions(WidgetTester tester) {
    while (tester.takeException() != null) {}
  }

  group('classGlyphIcon mapping', () {
    test('maps known subject glyph keys to their icons', () {
      expect(classGlyphIcon('math'), Icons.calculate);
      expect(classGlyphIcon('science'), Icons.science);
      expect(classGlyphIcon('coding'), Icons.code);
      expect(classGlyphIcon('pe'), Icons.sports_soccer);
    });

    test('unknown or missing glyph key falls back to a neutral book icon', () {
      expect(classGlyphIcon('quantum_basket_weaving'), Icons.menu_book);
      expect(classGlyphIcon(''), Icons.menu_book);
      expect(classGlyphIcon(null), Icons.menu_book);
    });
  });

  group('parseBandColor', () {
    test('parses a #RRGGBB hex string into an opaque colour', () {
      expect(parseBandColor('#7042ED'), const Color(0xFF7042ED));
      expect(parseBandColor('7042ED'), const Color(0xFF7042ED));
    });

    test('malformed or empty hex falls back to brand purple', () {
      expect(parseBandColor(''), const Color(0xFF7042ED));
      expect(parseBandColor('not-a-colour'), const Color(0xFF7042ED));
      expect(parseBandColor(null), const Color(0xFF7042ED));
    });
  });

  group('Avatar.isCentreClass', () {
    test('true only when kind is CENTRE_CLASS and appearance is present', () {
      expect(_classAvatar().isCentreClass, isTrue);
      expect(_personalAvatar().isCentreClass, isFalse);
    });

    test('kind defaults to PERSONAL when backend omits it', () {
      final a = Avatar.fromJson({
        'id': 'x',
        'name': 'No Kind',
        'characterType': 'MOCHI',
        'subject': 'MATHS',
      });
      expect(a.kind, AvatarKind.personal);
      expect(a.isCentreClass, isFalse);
    });

    test('parses CENTRE_CLASS kind + appearance from backend JSON', () {
      final a = Avatar.fromJson({
        'id': 'c',
        'name': 'P5 Maths',
        'characterType': 'MOCHI',
        'subject': 'MATHS',
        'kind': 'CENTRE_CLASS',
        'appearance': {
          'bandColorHex': '#00BBA4',
          'subjectGlyph': 'science',
          'initials': 'P5',
        },
      });
      expect(a.kind, AvatarKind.centreClass);
      expect(a.isCentreClass, isTrue);
      expect(a.appearance!.bandColorHex, '#00BBA4');
      expect(a.appearance!.subjectGlyph, 'science');
      expect(a.appearance!.initials, 'P5');
    });
  });

  group('ClassUniformAvatar — ring + corner tag (base untouched)', () {
    testWidgets('at large size shows initials in the corner tag, not a glyph',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: Center(
            child: ClassUniformAvatar(
              appearance: ClassAppearance(
                bandColorHex: '#FF6660',
                subjectGlyph: 'art',
                initials: 'AB',
              ),
              size: 120,
            ),
          ),
        ),
      ));

      // >= 64px: initials are legible and shown in the tag…
      expect(find.text('AB'), findsOneWidget);
      // …so the glyph is NOT drawn (tag shows initials OR glyph, never both).
      expect(find.byIcon(Icons.palette), findsNothing);
      // The ring + tag carry the parsed colour.
      final coloured = tester
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .where((d) =>
              d.decoration is BoxDecoration &&
              ((d.decoration as BoxDecoration).border?.top.color ==
                      const Color(0xFFFF6660) ||
                  (d.decoration as BoxDecoration).color ==
                      const Color(0xFFFF6660)));
      expect(coloured, isNotEmpty);
      // The base character renders untouched via CharacterWidget.
      expect(find.byType(CharacterWidget), findsOneWidget);
      drainAssetExceptions(tester);
    });

    testWidgets('at nav size (<64px) the tag is glyph-only — initials hidden',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: ClassUniformAvatar(
            appearance: ClassAppearance(
              bandColorHex: '#7042ED',
              subjectGlyph: 'science',
              initials: 'P5',
            ),
            size: 36,
          ),
        ),
      ));
      // Initials illegible at nav size → hidden; glyph shown instead.
      expect(find.text('P5'), findsNothing);
      expect(find.byIcon(Icons.science), findsOneWidget);
      drainAssetExceptions(tester);
    });

    testWidgets('unknown glyph key falls back to the neutral book icon',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: ClassUniformAvatar(
            appearance: ClassAppearance(
              bandColorHex: '#7042ED',
              subjectGlyph: 'totally_unknown_key',
              // No initials → tag always shows the glyph regardless of size.
              initials: '',
            ),
            size: 80,
          ),
        ),
      ));
      expect(find.byIcon(Icons.menu_book), findsOneWidget);
      drainAssetExceptions(tester);
    });
  });

  group('CharacterWidget.forAvatar dispatch', () {
    testWidgets('CENTRE_CLASS avatar renders the uniform, not collectible art',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: CharacterWidget.forAvatar(_classAvatar(), 100)),
      ));

      // The uniform wrapper is used. forAvatar returns ClassUniformAvatar
      // (no top-level CharacterWidget); the base character renders via an
      // INNER CharacterWidget so the body stays pixel-identical to a personal
      // avatar of the same character.
      expect(find.byType(ClassUniformAvatar), findsOneWidget);
      expect(find.byType(CharacterWidget), findsOneWidget);
      // At 100px (>=64) the tag shows the class initials, glyph hidden.
      expect(find.text('P5'), findsOneWidget);
      expect(find.byIcon(Icons.calculate), findsNothing);
      drainAssetExceptions(tester);
    });

    testWidgets('PERSONAL avatar renders collectible art, not the uniform',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: CharacterWidget.forAvatar(_personalAvatar(), 100)),
      ));
      expect(find.byType(ClassUniformAvatar), findsNothing);
      expect(find.byType(CharacterWidget), findsOneWidget);
      drainAssetExceptions(tester);
    });
  });

  group('economy isolation — personal-only surfaces never include classes', () {
    // The create-tutor picker, shop, and collection are driven by static
    // character lists / unlocked-characters, not the avatar list, so a class
    // avatar can never appear there. This guards the filter contract: any code
    // that partitions an avatar list for a personal surface must drop classes.
    test('filtering an avatar list to PERSONAL drops every class avatar', () {
      final mixed = <Avatar>[
        _personalAvatar(),
        _classAvatar(initials: 'P3'),
        _personalAvatar(character: MochiCharacter.pencil),
        _classAvatar(initials: 'P6'),
      ];

      final personalOnly =
          mixed.where((a) => a.kind == AvatarKind.personal).toList();
      final classOnly = mixed.where((a) => a.isCentreClass).toList();

      expect(personalOnly, hasLength(2));
      expect(personalOnly.every((a) => !a.isCentreClass), isTrue);
      expect(classOnly, hasLength(2));
    });
  });
}
