import 'package:flutter/material.dart';
import 'package:pally/shared/models/avatar.dart';
import 'package:pally/shared/models/mochi_character.dart';
import 'package:pally/shared/models/mochi_cosmetics.dart';
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
    case MochiCharacter.atwKilt:
      return MochiPainter(size);
  }
}

class CharacterWidget extends StatelessWidget {
  const CharacterWidget({
    super.key,
    required this.character,
    required this.size,
    this.eyewearAsset,
    this.clothesAsset,
    this.shoesAsset,
  });

  /// Renders an avatar with its centre cosmetic slots resolved to overlay
  /// assets. Until layered art is commissioned every slot resolves to null,
  /// so this renders identically to the plain base-image constructor.
  factory CharacterWidget.forAvatar(Avatar avatar, double size, {Key? key}) {
    return CharacterWidget(
      key: key,
      character: avatar.character,
      size: size,
      eyewearAsset: MochiCosmetics.eyewearAsset(avatar.cosmeticEyewear),
      clothesAsset: MochiCosmetics.clothesAsset(avatar.cosmeticClothes),
      shoesAsset: MochiCosmetics.shoesAsset(avatar.cosmeticShoes),
    );
  }

  final MochiCharacter character;
  final double size;

  /// Optional accessory overlay assets (centre cosmetics). Null = no overlay.
  /// When all three are null the widget renders the single base image exactly
  /// as before — fully backward compatible.
  final String? eyewearAsset;
  final String? clothesAsset;
  final String? shoesAsset;

  @override
  Widget build(BuildContext context) {
    final base = Image.asset(
      character.assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
    );

    // Fast path: no cosmetics → just the base image (today's behaviour).
    if (eyewearAsset == null && clothesAsset == null && shoesAsset == null) {
      return base;
    }

    // Layered path: composite base → clothes → shoes → eyewear so accessories
    // sit on top of the body. Each layer fills the same box as the base.
    Widget layer(String asset) => Image.asset(
          asset,
          width: size,
          height: size,
          fit: BoxFit.contain,
        );

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          base,
          if (clothesAsset != null) layer(clothesAsset!),
          if (shoesAsset != null) layer(shoesAsset!),
          if (eyewearAsset != null) layer(eyewearAsset!),
        ],
      ),
    );
  }
}
