import 'package:freezed_annotation/freezed_annotation.dart';

part 'streak_status.freezed.dart';
part 'streak_status.g.dart';

@freezed
class StreakStatus with _$StreakStatus {
  const factory StreakStatus({
    required int streakDays,
    required int longestStreak,
    required int freezes,
    required List<bool> last7,
    required int nextMilestone,
    required int daysToMilestone,
    @Default(<int>[]) List<int> milestonesReached,
    @Default(<int>[3, 7, 14, 30, 60, 100, 365]) List<int> ladder,
  }) = _StreakStatus;

  factory StreakStatus.fromJson(Map<String, dynamic> json) =>
      _$StreakStatusFromJson(json);
}
