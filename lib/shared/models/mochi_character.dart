import 'package:flutter/material.dart';

enum MochiCharacter {
  mochi,
  pencil,
  science,
  pe,
  art,
  lunchbox,
  library,
  headmaster,
  goldstar,
  // ── Around the World series (centre / special edition) ────────────────
  atwBeret,
  atwGlobeRider,
  atwKebaya,
  atwLionCity,
  atwPharaoh,
  atwSakura,
  atwSombrero,
  atwKilt;

  String get displayName => switch (this) {
    MochiCharacter.mochi => 'Mochi',
    MochiCharacter.pencil => 'Pencil Mochi',
    MochiCharacter.science => 'Science Mochi',
    MochiCharacter.pe => 'PE Mochi',
    MochiCharacter.art => 'Art Mochi',
    MochiCharacter.lunchbox => 'Lunch Box Mochi',
    MochiCharacter.library => 'Library Mochi',
    MochiCharacter.headmaster => 'Headmaster Mochi',
    MochiCharacter.goldstar => 'Gold Star Mochi',
    MochiCharacter.atwBeret => 'Beret Mochi',
    MochiCharacter.atwGlobeRider => 'Globe Rider',
    MochiCharacter.atwKebaya => 'Kebaya Mochi',
    MochiCharacter.atwLionCity => 'Lion City Mochi',
    MochiCharacter.atwPharaoh => 'Pharaoh Mochi',
    MochiCharacter.atwSakura => 'Sakura Mochi',
    MochiCharacter.atwSombrero => 'Sombrero Mochi',
    MochiCharacter.atwKilt => 'Kilt Mochi',
  };

  String get assetPath => switch (this) {
    MochiCharacter.mochi => 'assets/images/base.png',
    MochiCharacter.pencil => 'assets/images/mochi_school_1.png',
    MochiCharacter.science => 'assets/images/mochi_school_2.png',
    MochiCharacter.pe => 'assets/images/mochi_school_3.png',
    MochiCharacter.art => 'assets/images/mochi_school_4.png',
    MochiCharacter.lunchbox => 'assets/images/mochi_school_5.png',
    MochiCharacter.library => 'assets/images/mochi_school_7.png',
    MochiCharacter.headmaster => 'assets/images/mochi_school_6.png',
    MochiCharacter.goldstar => 'assets/images/mochi_school_premium.png',
    MochiCharacter.atwBeret => 'assets/images/aroundTheWorld_Beret_normal.png',
    MochiCharacter.atwGlobeRider => 'assets/images/aroundTheWorld_GlobeRider_rare.png',
    MochiCharacter.atwKebaya => 'assets/images/aroundTheWorld_Kebaya_normal.png',
    MochiCharacter.atwLionCity => 'assets/images/aroundTheWorld_LionCity_secret.png',
    MochiCharacter.atwPharaoh => 'assets/images/aroundTheWorld_Pharaoh_normal.png',
    MochiCharacter.atwSakura => 'assets/images/aroundTheWorld_Sakura_normal.png',
    MochiCharacter.atwSombrero => 'assets/images/aroundTheWorld_Sombrero_normal.png',
    MochiCharacter.atwKilt => 'assets/images/aroundTheWorld_kilt_normal.png',
  };

  String get defaultSubject => switch (this) {
    MochiCharacter.mochi => 'General',
    MochiCharacter.pencil => 'English',
    MochiCharacter.science => 'Science',
    MochiCharacter.pe => 'Physical Education',
    MochiCharacter.art => 'Art',
    MochiCharacter.lunchbox => 'Health',
    MochiCharacter.library => 'Literature',
    MochiCharacter.headmaster => 'General',
    MochiCharacter.goldstar => 'General',
    MochiCharacter.atwBeret ||
    MochiCharacter.atwGlobeRider ||
    MochiCharacter.atwKebaya ||
    MochiCharacter.atwLionCity ||
    MochiCharacter.atwPharaoh ||
    MochiCharacter.atwSakura ||
    MochiCharacter.atwKilt ||
    MochiCharacter.atwSombrero => 'General',
  };

  /// Only the starter "Mochi" is free for every account. All eight school
  /// Mochis (the 6 commons + Headmaster + Gold Star) live in the mystery
  /// box now — locked until pulled. Mirrors backend acquisition state.
  bool get isLockedByDefault => this != MochiCharacter.mochi;

  MochiRarity get rarity => switch (this) {
    MochiCharacter.goldstar || MochiCharacter.atwLionCity => MochiRarity.secret,
    MochiCharacter.headmaster || MochiCharacter.atwGlobeRider => MochiRarity.rare,
    _ => MochiRarity.standard,
  };

  /// All aroundTheWorld series characters.
  static const aroundTheWorld = [
    MochiCharacter.atwBeret,
    MochiCharacter.atwGlobeRider,
    MochiCharacter.atwKebaya,
    MochiCharacter.atwLionCity,
    MochiCharacter.atwPharaoh,
    MochiCharacter.atwSakura,
    MochiCharacter.atwSombrero,
    MochiCharacter.atwKilt,
  ];

  Color get bgColor => switch (this) {
    MochiCharacter.mochi => const Color(0xFFFFF6F0),
    MochiCharacter.pencil => const Color(0xFFFFF9E6),
    MochiCharacter.science => const Color(0xFFF0FDF9),
    MochiCharacter.pe => const Color(0xFFFFF0F0),
    MochiCharacter.art => const Color(0xFFF5F0FF),
    MochiCharacter.lunchbox => const Color(0xFFFFF5E6),
    MochiCharacter.library => const Color(0xFFE6F4FF),
    MochiCharacter.headmaster => const Color(0xFFFFFBE6),
    MochiCharacter.goldstar => const Color(0xFFFFFCE6),
    MochiCharacter.atwBeret => const Color(0xFFFFF0F5),
    MochiCharacter.atwGlobeRider => const Color(0xFFE8F4FD),
    MochiCharacter.atwKebaya => const Color(0xFFFCF0FF),
    MochiCharacter.atwLionCity => const Color(0xFFFFF5E0),
    MochiCharacter.atwPharaoh => const Color(0xFFFFFAE6),
    MochiCharacter.atwSakura => const Color(0xFFFFF0F5),
    MochiCharacter.atwSombrero => const Color(0xFFFFF8E6),
    MochiCharacter.atwKilt => const Color(0xFFE8F5E9),
  };

  Color get accentColor => switch (this) {
    MochiCharacter.mochi => const Color(0xFFE8B89C),
    MochiCharacter.pencil => const Color(0xFFFFB81A),
    MochiCharacter.science => const Color(0xFF00BAA3),
    MochiCharacter.pe => const Color(0xFFEF5350),
    MochiCharacter.art => const Color(0xFF7042ED),
    MochiCharacter.lunchbox => const Color(0xFFFF8C42),
    MochiCharacter.library => const Color(0xFF2196F3),
    MochiCharacter.headmaster => const Color(0xFFF5A623),
    MochiCharacter.goldstar => const Color(0xFFFFD700),
    MochiCharacter.atwBeret => const Color(0xFFE91E8C),
    MochiCharacter.atwGlobeRider => const Color(0xFF1565C0),
    MochiCharacter.atwKebaya => const Color(0xFF8E24AA),
    MochiCharacter.atwLionCity => const Color(0xFFE65100),
    MochiCharacter.atwPharaoh => const Color(0xFFB8860B),
    MochiCharacter.atwSakura => const Color(0xFFE91E8C),
    MochiCharacter.atwSombrero => const Color(0xFF6D4C41),
    MochiCharacter.atwKilt => const Color(0xFF2E7D32),
  };

  Color get primaryColor => accentColor;

  String get jsonValue => name.toUpperCase();

  static MochiCharacter fromJson(String s) => MochiCharacter.values.firstWhere(
    (c) => c.jsonValue == s.toUpperCase(),
    orElse: () => MochiCharacter.pencil,
  );
}

enum MochiRarity { standard, rare, secret }

extension MochiRarityDisplay on MochiRarity {
  String get label => switch (this) {
    MochiRarity.standard => 'COMMON',
    MochiRarity.rare => 'RARE',
    MochiRarity.secret => 'SECRET',
  };

  Color get badgeColor => switch (this) {
    MochiRarity.standard => const Color(0xFF00BBA4), // teal for COMMON
    MochiRarity.rare => const Color(0xFF7042ED),
    MochiRarity.secret => const Color(0xFF1A1A2E),
  };
}
