import 'package:flutter/material.dart';
import 'package:pally/shared/models/mochi_character.dart';
import 'package:pally/core/ui/painters/mochi_painter.dart';
import 'package:pally/core/ui/painters/zap_painter.dart';
import 'package:pally/core/ui/painters/finn_painter.dart';
import 'package:pally/core/ui/painters/boba_painter.dart';
import 'package:pally/core/ui/painters/puddi_painter.dart';
import 'package:pally/core/ui/painters/byte_painter.dart';
import 'package:pally/core/ui/painters/nori_painter.dart';
import 'package:pally/core/ui/painters/lumis_painter.dart';

CustomPainter characterPainterFor(MochiCharacter character, double size) {
  switch (character) {
    case MochiCharacter.pencil:
      return MochiPainter(size);
    case MochiCharacter.science:
      return ZapPainter(size);
    case MochiCharacter.pe:
      return FinnPainter(size);
    case MochiCharacter.art:
      return BobaPainter(size);
    case MochiCharacter.lunchbox:
      return PuddiPainter(size);
    case MochiCharacter.library:
      return BytePainter(size);
    case MochiCharacter.headmaster:
      return NoriPainter(size);
    case MochiCharacter.goldstar:
      return LumisPainter(size);
  }
}

class CharacterWidget extends StatelessWidget {
  const CharacterWidget({
    super.key,
    required this.character,
    required this.size,
  });

  final MochiCharacter character;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: characterPainterFor(character, size),
      ),
    );
  }
}
