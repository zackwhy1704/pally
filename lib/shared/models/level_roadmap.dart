import 'package:freezed_annotation/freezed_annotation.dart';

part 'level_roadmap.freezed.dart';
part 'level_roadmap.g.dart';

@freezed
class LevelReward with _$LevelReward {
  const factory LevelReward({
    @Default(0) int level,
    @Default('') String label,
    @Default('COSMETIC') String kind, // COSMETIC | FUNCTIONAL | BADGE | MYSTERY
    @Default(false) bool unlocked,
  }) = _LevelReward;

  factory LevelReward.fromJson(Map<String, dynamic> json) =>
      _$LevelRewardFromJson(json);
}

@freezed
class LevelRoadmap with _$LevelRoadmap {
  const factory LevelRoadmap({
    @Default(1) int currentLevel,
    @Default(30) int maxLevel,
    @Default([]) List<LevelReward> rewards,
  }) = _LevelRoadmap;

  factory LevelRoadmap.fromJson(Map<String, dynamic> json) =>
      _$LevelRoadmapFromJson(json);
}
