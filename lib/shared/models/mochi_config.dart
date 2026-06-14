import 'package:pally/core/utils/json_reader.dart';

/// Canonical set of Mochi accessories the web customiser can select.
/// Any unknown/missing value falls back to [none] per the network
/// null-tolerance rules (CLAUDE.md PART 16).
const Set<String> kMochiAccessories = {
  'none',
  'bow',
  'cap',
  'glasses',
  'crown',
  'headband',
};

/// Canonical set of Mochi auras the web customiser can select.
const Set<String> kMochiAuras = {
  'none',
  'sparkle',
  'fire',
  'chill',
  'electric',
  'bloom',
};

/// Number of body colour variants (matches web `BODY_VARIANTS.length`).
const int kMochiBodyVariantCount = 12;

/// A centre-designed class Mochi look: body colour index + accessory + aura.
///
/// This mirrors the web `MochiConfig` shape exactly:
/// `{ body: int 0-11, accessory: string, aura: string }`.
/// Eyes and cheeks are baked into the base art, so this config only controls
/// the three customisable layers.
///
/// All fields are network-sourced, so [fromJson] is fully null-tolerant:
/// missing/unknown values collapse to safe defaults (body=0, accessory='none',
/// aura='none') and any extra/legacy keys (e.g. old `eyeStyle`,
/// `cheekVariant`) are ignored.
class MochiConfig {
  const MochiConfig({
    this.body = 0,
    this.accessory = 'none',
    this.aura = 'none',
  });

  /// Body colour index into the variant table. Clamped to [0, 11].
  final int body;

  /// Accessory key, one of [kMochiAccessories]. Unknown → 'none'.
  final String accessory;

  /// Aura key, one of [kMochiAuras]. Unknown → 'none'.
  final String aura;

  factory MochiConfig.fromJson(Map<String, dynamic> json) {
    // body: optional int, defaulting to 0, then clamped to a valid index.
    final rawBody = json.optional<int>('body', 0);
    final body = rawBody < 0
        ? 0
        : (rawBody >= kMochiBodyVariantCount
            ? kMochiBodyVariantCount - 1
            : rawBody);

    final rawAccessory = json.optional<String>('accessory', 'none');
    final accessory =
        kMochiAccessories.contains(rawAccessory) ? rawAccessory : 'none';

    final rawAura = json.optional<String>('aura', 'none');
    final aura = kMochiAuras.contains(rawAura) ? rawAura : 'none';

    return MochiConfig(body: body, accessory: accessory, aura: aura);
  }

  Map<String, dynamic> toJson() => {
        'body': body,
        'accessory': accessory,
        'aura': aura,
      };

  @override
  bool operator ==(Object other) =>
      other is MochiConfig &&
      other.body == body &&
      other.accessory == accessory &&
      other.aura == aura;

  @override
  int get hashCode => Object.hash(body, accessory, aura);

  @override
  String toString() =>
      'MochiConfig(body: $body, accessory: $accessory, aura: $aura)';
}
