// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coverage_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CoverageBucketImpl _$$CoverageBucketImplFromJson(Map<String, dynamic> json) =>
    _$CoverageBucketImpl(
      mastered: (json['mastered'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$CoverageBucketImplToJson(
        _$CoverageBucketImpl instance) =>
    <String, dynamic>{
      'mastered': instance.mastered,
      'total': instance.total,
    };

_$SubjectCoverageImpl _$$SubjectCoverageImplFromJson(
        Map<String, dynamic> json) =>
    _$SubjectCoverageImpl(
      subject: json['subject'] as String? ?? '',
      mastered: (json['mastered'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$SubjectCoverageImplToJson(
        _$SubjectCoverageImpl instance) =>
    <String, dynamic>{
      'subject': instance.subject,
      'mastered': instance.mastered,
      'total': instance.total,
    };

_$CoverageSummaryImpl _$$CoverageSummaryImplFromJson(
        Map<String, dynamic> json) =>
    _$CoverageSummaryImpl(
      overall: json['overall'] == null
          ? const CoverageBucket()
          : CoverageBucket.fromJson(json['overall'] as Map<String, dynamic>),
      bySubject: (json['bySubject'] as List<dynamic>?)
              ?.map((e) => SubjectCoverage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$CoverageSummaryImplToJson(
        _$CoverageSummaryImpl instance) =>
    <String, dynamic>{
      'overall': instance.overall,
      'bySubject': instance.bySubject,
    };
