import 'package:freezed_annotation/freezed_annotation.dart';

part 'coverage_summary.freezed.dart';
part 'coverage_summary.g.dart';

@freezed
class CoverageBucket with _$CoverageBucket {
  const factory CoverageBucket({
    @Default(0) int mastered,
    @Default(0) int total,
  }) = _CoverageBucket;

  factory CoverageBucket.fromJson(Map<String, dynamic> json) =>
      _$CoverageBucketFromJson(json);
}

@freezed
class SubjectCoverage with _$SubjectCoverage {
  const factory SubjectCoverage({
    @Default('') String subject,
    @Default(0) int mastered,
    @Default(0) int total,
  }) = _SubjectCoverage;

  factory SubjectCoverage.fromJson(Map<String, dynamic> json) =>
      _$SubjectCoverageFromJson(json);
}

@freezed
class CoverageSummary with _$CoverageSummary {
  const factory CoverageSummary({
    @Default(CoverageBucket()) CoverageBucket overall,
    @Default([]) List<SubjectCoverage> bySubject,
  }) = _CoverageSummary;

  factory CoverageSummary.fromJson(Map<String, dynamic> json) =>
      _$CoverageSummaryFromJson(json);
}
