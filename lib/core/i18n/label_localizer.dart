import 'package:pally/l10n/app_localizations.dart';

/// Localizers for the fixed enum-ish labels the backend stores as English/codes:
/// subjects, education stages, and plan tiers. These live in shared data (not one
/// screen), so localization goes through a resolver that takes [AppLocalizations]
/// — one switch on the canonical code, the ARB holds the per-locale strings, and
/// NO language conditional sits in the data layer (B-EXT.2 stays green).
///
/// **Free-text passthrough is the load-bearing rule.** A subject can be free-text
/// (a teacher types their own subject in create-tutor), so an unknown value is
/// returned UNCHANGED — we never machine-translate a teacher's own words, and we
/// never leave a KNOWN subject as English. The canonical English `subjectLabel` /
/// `levelLabel` / `prettyTier` functions stay as the source-of-truth + backend-
/// adjacent form; these localize only at DISPLAY time.

String _key(String s) => s.trim().toUpperCase().replaceAll(RegExp(r'[ /]+'), '_');

/// Localize a subject label. Accepts the backend code ('MATHS') or the title-cased
/// display label ('Maths') — both normalize to the same key. Unknown (free-text)
/// subjects pass through verbatim.
String localizedSubject(AppLocalizations l, String subject) => switch (_key(subject)) {
      'MATHS' || 'MATH' || 'MATHEMATICS' => l.subjectMaths,
      'SCIENCE' => l.subjectScience,
      'ENGLISH' => l.subjectEnglish,
      'HISTORY' => l.subjectHistory,
      'CODING' => l.subjectCoding,
      'ART' => l.subjectArt,
      'GEOGRAPHY' => l.subjectGeography,
      'LANGUAGES' => l.subjectLanguages,
      'MUSIC' => l.subjectMusic,
      'PHYSICAL_EDUCATION' || 'PE' => l.subjectPhysicalEducation,
      'HEALTH' => l.subjectHealth,
      'LITERATURE' => l.subjectLiterature,
      'GENERAL' => l.subjectGeneral,
      _ => subject, // free-text (teacher's own words) — never translated
    };

/// Localize an education-stage label. Unknown stages pass through verbatim.
String localizedLevel(AppLocalizations l, String level) => switch (_key(level)) {
      'PRIMARY' || 'PRIMARY_SCHOOL' => l.levelPrimary,
      'SECONDARY' || 'SECONDARY_SCHOOL' => l.levelSecondary,
      'HIGH_SCHOOL' => l.levelHighSchool,
      'UNIVERSITY' || 'UNIVERSITY_ADULT' => l.levelUniversity,
      _ => level,
    };

/// Localize the age-range hint under a stage. Unknown stages yield '' (as before).
String localizedLevelSubtitle(AppLocalizations l, String level) => switch (_key(level)) {
      'PRIMARY' => l.levelPrimarySubtitle,
      'SECONDARY' => l.levelSecondarySubtitle,
      'HIGH_SCHOOL' => l.levelHighSchoolSubtitle,
      'UNIVERSITY' => l.levelUniversitySubtitle,
      _ => '',
    };

/// Localize a plan tier. Null/blank → the "Premium" default (mirrors `prettyTier`).
/// Unknown tiers title-case through, untranslated.
String localizedTier(AppLocalizations l, String? raw) {
  if (raw == null || raw.trim().isEmpty) return l.tierPremium;
  return switch (raw.trim().toLowerCase()) {
    'premium' => l.tierPremium,
    'max' => l.tierMax,
    'pro' => l.tierPro,
    'free' => l.tierFree,
    'family' => l.tierFamily,
    'trial' => l.tierTrial,
    'centre' => l.tierCentre,
    _ => raw[0].toUpperCase() + raw.substring(1).toLowerCase(),
  };
}

/// Localize a cosmetic rarity tier ('COMMON'/'RARE'/'SECRET'/'STANDARD' — the
/// SAME closed vocabulary appears independently on [MochiRarityDisplay.label],
/// the collection screen's backend-provided `CollectionEntry.rarity`, and the
/// shop's mystery-box odds — one resolver instead of three copies. Unknown
/// codes (a future rarity tier the client hasn't caught up to) pass through
/// title-cased, never crash.
String localizedRarity(AppLocalizations l, String rarity) => switch (_key(rarity)) {
      'COMMON' || 'STANDARD' => l.rarityCommon,
      'RARE' => l.rarityRare,
      'SECRET' => l.raritySecret,
      _ => rarity.isEmpty
          ? rarity
          : rarity[0].toUpperCase() + rarity.substring(1).toLowerCase(),
    };
