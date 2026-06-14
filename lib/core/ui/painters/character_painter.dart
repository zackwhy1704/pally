import 'package:flutter/material.dart';
import 'package:pally/shared/models/avatar.dart';
import 'package:pally/shared/models/mochi_character.dart';
import 'package:pally/shared/models/mochi_cosmetics.dart';
import 'package:pally/core/ui/painters/class_uniform_mochi_painter.dart';
import 'package:pally/core/ui/mochi_avatar.dart';
import 'package:pally/core/ui/painters/mochi_painter.dart';
import 'package:pally/core/ui/painters/chimi_painter.dart';
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
      // BUGFIX: previously fell back to MochiPainter, making Pencil render
      // identically to the starter Mochi. ChimiPainter (the warm-red scarf
      // bear) was implemented but never wired into the dispatcher.
      return ChimiPainter(size);
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
    this.eyewearAsset,
    this.clothesAsset,
    this.shoesAsset,
  });

  /// Renders an avatar's art with the correct renderer for its [Avatar.kind].
  ///
  /// CENTRE_CLASS avatars with a centre-designed [Avatar.mochiConfig] render
  /// the custom class Mochi (body colour + accessory + aura) via [MochiAvatar];
  /// CENTRE_CLASS avatars without a config fall back to the parameterised
  /// uniform Mochi via [ClassUniformAvatar]; PERSONAL avatars render
  /// collectible character art with their centre cosmetic slots resolved to
  /// overlay assets (every slot is null until layered art is commissioned, so
  /// personal avatars render identically to the plain base-image constructor).
  static Widget forAvatar(Avatar avatar, double size, {Key? key}) {
    final mochiConfig = avatar.mochiConfig;
    if (avatar.kind == AvatarKind.centreClass && mochiConfig != null) {
      return MochiAvatar(key: key, config: mochiConfig, size: size);
    }
    if (avatar.isCentreClass) {
      return ClassUniformAvatar(
        key: key,
        appearance: avatar.appearance!,
        // Render the class avatar's own character untouched beneath the
        // ring + corner tag (works for vector painters and image assets).
        character: avatar.character,
        size: size,
      );
    }
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
