import 'package:freezed_annotation/freezed_annotation.dart';

part 'progress_summary.freezed.dart';
part 'progress_summary.g.dart';

@freezed
class WeakTopic with _$WeakTopic {
  const factory WeakTopic({
    required String topic,
    required double mastery,
  }) = _WeakTopic;

  factory WeakTopic.fromJson(Map<String, dynamic> json) =>
      _$WeakTopicFromJson(json);
}

@freezed
class ProgressSummary with _$ProgressSummary {
  const factory ProgressSummary({
    required int level,
    required int xp,
    required int xpToNextLevel,
    @Default(0) int streakDays,
    @Default([]) List<int> weekMinutes,
    @Default([]) List<WeakTopic> weakTopics,
    @Default([]) List<String> badges,
  }) = _ProgressSummary;

  factory ProgressSummary.fromJson(Map<String, dynamic> json) =>
      _$ProgressSummaryFromJson(json);
}
