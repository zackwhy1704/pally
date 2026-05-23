import 'package:flutter/material.dart';
import 'package:pally/shared/models/avatar.dart';
import 'package:pally/core/ui/painters/mochi_painter.dart';
import 'package:pally/core/ui/painters/zap_painter.dart';
import 'package:pally/core/ui/painters/finn_painter.dart';
import 'package:pally/core/ui/painters/boba_painter.dart';
import 'package:pally/core/ui/painters/puddi_painter.dart';
import 'package:pally/core/ui/painters/byte_painter.dart';
import 'package:pally/core/ui/painters/nori_painter.dart';
import 'package:pally/core/ui/painters/chimi_painter.dart';
import 'package:pally/core/ui/painters/lumis_painter.dart';

/// Returns the correct [CustomPainter] for [character] at [size].
CustomPainter characterPainterFor(AvatarCharacter character, double size) {
  switch (character) {
    case AvatarCharacter.mochi:
      return MochiPainter(size);
    case AvatarCharacter.zap:
      return ZapPainter(size);
    case AvatarCharacter.finn:
      return FinnPainter(size);
    case AvatarCharacter.boba:
      return BobaPainter(size);
    case AvatarCharacter.puddi:
      return PuddiPainter(size);
    case AvatarCharacter.byte:
      return BytePainter(size);
    case AvatarCharacter.nori:
      return NoriPainter(size);
    case AvatarCharacter.chimi:
      return ChimiPainter(size);
    case AvatarCharacter.lumis:
      return LumisPainter(size);
  }
}

/// Convenience widget that renders the character painter inside a
/// [SizedBox] of [size] × [size].
class CharacterWidget extends StatelessWidget {
  const CharacterWidget({
    super.key,
    required this.character,
    required this.size,
  });

  final AvatarCharacter character;
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
