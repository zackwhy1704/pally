import 'package:freezed_annotation/freezed_annotation.dart';

part 'level_roadmap.freezed.dart';
part 'level_roadmap.g.dart';

@freezed
class LevelReward with _$LevelReward {
  const factory LevelReward({
    required int level,
    required String label,
    required String kind, // COSMETIC | FUNCTIONAL | BADGE | MYSTERY
    required bool unlocked,
  }) = _LevelReward;

  factory LevelReward.fromJson(Map<String, dynamic> json) =>
      _$LevelRewardFromJson(json);
}

@freezed
class LevelRoadmap with _$LevelRoadmap {
  const factory LevelRoadmap({
    required int currentLevel,
    required int maxLevel,
    required List<LevelReward> rewards,
  }) = _LevelRoadmap;

  factory LevelRoadmap.fromJson(Map<String, dynamic> json) =>
      _$LevelRoadmapFromJson(json);
}
