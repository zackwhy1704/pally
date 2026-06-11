import 'package:freezed_annotation/freezed_annotation.dart';

part 'narration.freezed.dart';
part 'narration.g.dart';

@freezed
class Narration with _$Narration {
  const factory Narration({
    @Default('') String id,
    @Default('PENDING') String status,
    @Default([]) List<NarrationSegment> segments,
  }) = _Narration;

  factory Narration.fromJson(Map<String, dynamic> json) =>
      _$NarrationFromJson(json);
}

@freezed
class NarrationSegment with _$NarrationSegment {
  const factory NarrationSegment({
    @Default(0) int cardIndex,
    @Default('') String scriptText,
    @Default('') String audioUrl,
    @Default(0) int durationMs,
  }) = _NarrationSegment;

  factory NarrationSegment.fromJson(Map<String, dynamic> json) =>
      _$NarrationSegmentFromJson(json);
}
