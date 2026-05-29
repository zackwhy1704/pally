import 'package:freezed_annotation/freezed_annotation.dart';

part 'achievement.freezed.dart';
part 'achievement.g.dart';

@freezed
class Achievement with _$Achievement {
  const factory Achievement({
    required String id,
    required String name,
    required String description,
    required String category, // STREAK | MASTERY | CURIOSITY | MILESTONE
    required String rarity,   // COMMON | RARE | EPIC | LEGENDARY
    required int target,
    required int progress,
    required bool earned,
    String? earnedAt,
  }) = _Achievement;

  factory Achievement.fromJson(Map<String, dynamic> json) =>
      _$AchievementFromJson(json);
}

@freezed
class AchievementList with _$AchievementList {
  const factory AchievementList({
    required List<Achievement> achievements,
    required int earnedCount,
    required int totalCount,
  }) = _AchievementList;

  factory AchievementList.fromJson(Map<String, dynamic> json) =>
      _$AchievementListFromJson(json);
}
