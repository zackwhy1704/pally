import 'package:freezed_annotation/freezed_annotation.dart';

part 'daily_goal.freezed.dart';
part 'daily_goal.g.dart';

@freezed
class DailyGoal with _$DailyGoal {
  const factory DailyGoal({
    @Default('QUIZ') String goalType,
    @Default(0) int goalTarget,
    @Default(0) int goalProgress,
    @Default(false) bool met,
  }) = _DailyGoal;

  factory DailyGoal.fromJson(Map<String, dynamic> json) =>
      _$DailyGoalFromJson(json);
}
