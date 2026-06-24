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
    /// Which backend node served this request (null if backend hasn't upgraded).
    String? servedBy,
    /// True when the backend fell back to a secondary text extractor.
    @Default(false) bool degraded,
    /// Pages compiled so far (for partial-progress display during chunked compile).
    @Default(0) int pagesCompiled,
    /// Total pages expected (null until the backend reports it).
    int? pagesTotal,
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
    /// A2: false when the upload isn't study material at all (receipt/selfie/blank).
    @Default(true) bool studyMaterial,
  }) = _RelevanceCheckResponse;

  factory RelevanceCheckResponse.fromJson(Map<String, dynamic> json) =>
      _$RelevanceCheckResponseFromJson(json);
}
