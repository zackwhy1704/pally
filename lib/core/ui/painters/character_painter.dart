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
    case MochiCharacter.mochi:
      // The starter Mochi renders from base.png everywhere; the painter
      // fallback is only hit if the asset somehow fails to load. Reuse
      // the round-bear MochiPainter as a visually-on-brand fallback.
      return MochiPainter(size);
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
    // aroundTheWorld series — rendered via Image.asset; painter is a
    // fallback if asset fails (use the base Mochi painter).
    case MochiCharacter.atwBeret:
    case MochiCharacter.atwGlobeRider:
    case MochiCharacter.atwKebaya:
    case MochiCharacter.atwLionCity:
    case MochiCharacter.atwPharaoh:
    case MochiCharacter.atwSakura:
    case MochiCharacter.atwSombrero:
      return MochiPainter(size);
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
    return Image.asset(
      character.assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}
