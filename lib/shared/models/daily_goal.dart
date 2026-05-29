import 'package:freezed_annotation/freezed_annotation.dart';

part 'daily_goal.freezed.dart';
part 'daily_goal.g.dart';

@freezed
class DailyGoal with _$DailyGoal {
  const factory DailyGoal({
    required String goalType,
    required int goalTarget,
    required int goalProgress,
    required bool met,
  }) = _DailyGoal;

  factory DailyGoal.fromJson(Map<String, dynamic> json) =>
      _$DailyGoalFromJson(json);
}
