import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pally/core/theme/app_colors.dart';

part 'avatar.freezed.dart';
part 'avatar.g.dart';

/// v2 character roster — matches Figma "Pally · 小伴 — Flutter UI v2"
enum AvatarCharacter {
  mochi, // beige dumpling bear  — Science
  zap, // purple robot         — Maths
  finn, // brown fox            — History
  boba, // green alien          — English
  puddi, // pink owl             — Art
  byte, // teal coder robot     — Coding
  nori, // blue cloud ghost     — Geography
  chimi, // red bear             — Languages
  lumis; // golden star (RARE)   — Music

  String get displayName {
    switch (this) {
      case AvatarCharacter.mochi:
        return 'Mochi';
      case AvatarCharacter.zap:
        return 'Zap';
      case AvatarCharacter.finn:
        return 'Finn';
      case AvatarCharacter.boba:
        return 'Boba';
      case AvatarCharacter.puddi:
        return 'Puddi';
      case AvatarCharacter.byte:
        return 'Byte';
      case AvatarCharacter.nori:
        return 'Nori';
      case AvatarCharacter.chimi:
        return 'Chimi';
      case AvatarCharacter.lumis:
        return 'Lumis';
    }
  }

  String get defaultSubject {
    switch (this) {
      case AvatarCharacter.mochi:
        return 'Science';
      case AvatarCharacter.zap:
        return 'Maths';
      case AvatarCharacter.finn:
        return 'History';
      case AvatarCharacter.boba:
        return 'English';
      case AvatarCharacter.puddi:
        return 'Art';
      case AvatarCharacter.byte:
        return 'Coding';
      case AvatarCharacter.nori:
        return 'Geography';
      case AvatarCharacter.chimi:
        return 'Languages';
      case AvatarCharacter.lumis:
        return 'Music';
    }
  }

  bool get isRare => this == AvatarCharacter.lumis;

  Color get bgColor {
    switch (this) {
      case AvatarCharacter.mochi:
        return AppColors.amberL;
      case AvatarCharacter.zap:
        return AppColors.purpleL;
      case AvatarCharacter.finn:
        return AppColors.coralL;
      case AvatarCharacter.boba:
        return AppColors.greenL;
      case AvatarCharacter.puddi:
        return AppColors.pinkL;
      case AvatarCharacter.byte:
        return AppColors.tealL;
      case AvatarCharacter.nori:
        return AppColors.tealL;
      case AvatarCharacter.chimi:
        return AppColors.coralL;
      case AvatarCharacter.lumis:
        return AppColors.goldL;
    }
  }

  Color get primaryColor {
    switch (this) {
      case AvatarCharacter.mochi:
        return AppColors.amber;
      case AvatarCharacter.zap:
        return AppColors.purple;
      case AvatarCharacter.finn:
        return AppColors.coral;
      case AvatarCharacter.boba:
        return AppColors.green;
      case AvatarCharacter.puddi:
        return AppColors.pink;
      case AvatarCharacter.byte:
        return AppColors.teal;
      case AvatarCharacter.nori:
        return AppColors.teal;
      case AvatarCharacter.chimi:
        return AppColors.coral;
      case AvatarCharacter.lumis:
        return AppColors.gold;
    }
  }
}

// ── JSON converters ──────────────────────────────────────────────────────────
// Backend CharacterType enum: MOCHI, ZAP, FINN, BOBA, PUDDI, BYTE, NORI, CHIMI, LUMIS

AvatarCharacter _characterFromJson(Object? json) {
  final s = (json as String? ?? '').toUpperCase();
  return AvatarCharacter.values.firstWhere(
    (e) => e.name.toUpperCase() == s,
    orElse: () => AvatarCharacter.zap,
  );
}

String _characterToJson(AvatarCharacter c) => c.name.toUpperCase();

String _subjectFromJson(Object? json) {
  final s = (json as String?) ?? '';
  switch (s.toUpperCase()) {
    case 'MATHS':
      return 'Maths';
    case 'SCIENCE':
      return 'Science';
    case 'ENGLISH':
      return 'English';
    case 'HISTORY':
      return 'History';
    case 'CODING':
      return 'Coding';
    case 'ART':
      return 'Art';
    case 'GEOGRAPHY':
      return 'Geography';
    case 'LANGUAGES':
      return 'Languages';
    case 'MUSIC':
      return 'Music';
    default:
      return s;
  }
}

String _subjectToJson(String s) => s.toUpperCase().replaceAll(' ', '_');

bool _hasKnowledgeFromJson(Object? count) => ((count as int?) ?? 0) > 0;

// ── Pedagogy mode ─────────────────────────────────────────────────────────────

enum PedagogyMode { socratic }

PedagogyMode _pedagogyFromJson(Object? v) => PedagogyMode.socratic;

String _pedagogyToJson(PedagogyMode m) => 'SOCRATIC';

// ── Models ───────────────────────────────────────────────────────────────────

@freezed
class Avatar with _$Avatar {
  const factory Avatar({
    required String id,
    required String name,
    @JsonKey(
        name: 'characterType',
        fromJson: _characterFromJson,
        toJson: _characterToJson)
    required AvatarCharacter character,
    @JsonKey(fromJson: _subjectFromJson, toJson: _subjectToJson)
    required String subject,
    @JsonKey(name: 'wikiPageCount', fromJson: _hasKnowledgeFromJson)
    @Default(false)
    bool hasKnowledge,
    @Default(0) int fileCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    @JsonKey(fromJson: _pedagogyFromJson, toJson: _pedagogyToJson)
    @Default(PedagogyMode.socratic)
    PedagogyMode pedagogyMode,
    String? gradeLevel,
    String? curriculumType,
  }) = _Avatar;

  factory Avatar.fromJson(Map<String, dynamic> json) => _$AvatarFromJson(json);
}

@freezed
class CreateAvatarRequest with _$CreateAvatarRequest {
  const factory CreateAvatarRequest({
    required String name,
    @JsonKey(
        name: 'characterType',
        fromJson: _characterFromJson,
        toJson: _characterToJson)
    required AvatarCharacter character,
    @JsonKey(toJson: _subjectToJson, fromJson: _subjectFromJson)
    required String subject,
    String? gradeLevel,
    String? curriculumType,
  }) = _CreateAvatarRequest;

  factory CreateAvatarRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateAvatarRequestFromJson(json);
}
