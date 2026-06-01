import 'package:freezed_annotation/freezed_annotation.dart';

part 'upload_result.freezed.dart';
part 'upload_result.g.dart';

enum UploadStatus { pending, processing, ready, failed }

@freezed
class UploadResult with _$UploadResult {
  const factory UploadResult({
    @Default('') String id,
    @Default('') String avatarId,
    @Default('') String fileName,
    @Default(UploadStatus.processing) UploadStatus status,
    @Default(0) int pageCount,
    @Default(<String>[]) List<String> wikiPageTitles,
    String? errorMessage,
    DateTime? uploadedAt,
  }) = _UploadResult;

  factory UploadResult.fromJson(Map<String, dynamic> json) =>
      _$UploadResultFromJson(json);
}

@freezed
class RelevanceCheckResponse with _$RelevanceCheckResponse {
  const factory RelevanceCheckResponse({
    @Default(true) bool isRelevant,
    @Default(1.0) double score,
    String? reason,
  }) = _RelevanceCheckResponse;

  factory RelevanceCheckResponse.fromJson(Map<String, dynamic> json) =>
      _$RelevanceCheckResponseFromJson(json);
}
