import 'package:flutter/material.dart';
import 'package:pally/l10n/app_localizations.dart';

enum MochiCharacter {
  mochi,
  pencil,
  science,
  pe,
  art,
  lunchbox,
  library,
  headmaster,
  goldstar;

  // Cosmetic character names — user-decided (2026-07-30): translate the
  // descriptor, using {mascot} (小伴) as the compound suffix, same convention
  // as every other mascot-bearing string in the app. Takes AppLocalizations
  // (was a bare getter) since MochiCharacter has no BuildContext of its own;
  // every call site now threads `l` through.
  String displayName(AppLocalizations l) => switch (this) {
    MochiCharacter.mochi => l.mascotName,
    MochiCharacter.pencil => l.mochiNamePencil(l.mascotName),
    MochiCharacter.science => l.mochiNameScience(l.mascotName),
    MochiCharacter.pe => l.mochiNamePe(l.mascotName),
    MochiCharacter.art => l.mochiNameArt(l.mascotName),
    MochiCharacter.lunchbox => l.mochiNameLunchbox(l.mascotName),
    MochiCharacter.library => l.mochiNameLibrary(l.mascotName),
    MochiCharacter.headmaster => l.mochiNameHeadmaster(l.mascotName),
    MochiCharacter.goldstar => l.mochiNameGoldstar(l.mascotName),
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
  };

  /// Only the starter "Mochi" is free for every account. All eight school
  /// Mochis (the 6 commons + Headmaster + Gold Star) live in the mystery
  /// box now — locked until pulled. Mirrors backend acquisition state.
  bool get isLockedByDefault => this != MochiCharacter.mochi;

  MochiRarity get rarity => switch (this) {
    MochiCharacter.goldstar => MochiRarity.secret,
    MochiCharacter.headmaster => MochiRarity.rare,
    _ => MochiRarity.standard,
  };

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
