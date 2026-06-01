import 'package:freezed_annotation/freezed_annotation.dart';

part 'achievement.freezed.dart';
part 'achievement.g.dart';

@freezed
class Achievement with _$Achievement {
  const factory Achievement({
    @Default('') String id,
    @Default('') String name,
    @Default('') String description,
    @Default('MILESTONE') String category, // STREAK | MASTERY | CURIOSITY | MILESTONE
    @Default('COMMON') String rarity,      // COMMON | RARE | EPIC | LEGENDARY
    @Default(0) int target,
    @Default(0) int progress,
    @Default(false) bool earned,
    String? earnedAt,
  }) = _Achievement;

  factory Achievement.fromJson(Map<String, dynamic> json) =>
      _$AchievementFromJson(json);
}

@freezed
class AchievementList with _$AchievementList {
  const factory AchievementList({
    @Default([]) List<Achievement> achievements,
    @Default(0) int earnedCount,
    @Default(0) int totalCount,
  }) = _AchievementList;

  factory AchievementList.fromJson(Map<String, dynamic> json) =>
      _$AchievementListFromJson(json);
}
