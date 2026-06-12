/// Layered accessory scaffold for centre-customized Mochis.
///
/// The centre admin can pick accessory slot ids (eyewear / clothes / shoes) per
/// class; those ids ride on the avatar as [Avatar.cosmeticEyewear] etc. This
/// resolver maps a slot id to an overlay PNG that composites on top of the base
/// character art.
///
/// IMPORTANT: deep accessory swapping is **inert until layered art is
/// commissioned** — separated body + accessory PNGs sharing one rig. Until
/// those assets ship, every lookup returns null, so [CharacterWidget] renders
/// exactly the single base image it does today. The pipeline is built and
/// waiting; only the art is missing.
abstract final class MochiCosmetics {
  /// Maps an eyewear slot id to its overlay asset, or null if no art exists.
  static String? eyewearAsset(String? slotId) => _resolve(_eyewear, slotId);

  /// Maps a clothes slot id to its overlay asset, or null if no art exists.
  static String? clothesAsset(String? slotId) => _resolve(_clothes, slotId);

  /// Maps a shoes slot id to its overlay asset, or null if no art exists.
  static String? shoesAsset(String? slotId) => _resolve(_shoes, slotId);

  static String? _resolve(Map<String, String> catalog, String? slotId) {
    if (slotId == null || slotId.isEmpty) return null;
    return catalog[slotId];
  }

  /// True only when at least one cosmetic catalog has art. Any cosmetic-picker
  /// surface MUST check this first and render nothing while it's false — the
  /// catalogs are server/art-driven and empty today, so no picker may be shown.
  static bool get hasAnyCosmetics =>
      _eyewear.isNotEmpty || _clothes.isNotEmpty || _shoes.isNotEmpty;

  // ── Catalogs — empty until layered art is commissioned ────────────────────
  // When art lands, add entries like:
  //   'round_glasses': 'assets/images/cosmetics/eyewear_round_glasses.png',
  static const Map<String, String> _eyewear = {};
  static const Map<String, String> _clothes = {};
  static const Map<String, String> _shoes = {};
}
