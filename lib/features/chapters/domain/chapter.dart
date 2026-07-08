/// A pickable chapter chunk of a large upload (mirrors the backend GET /chapters
/// contract and the memoly web model — the two clients share one interaction design).
enum ChapterState { locked, compiling, compiled }

ChapterState _chapterStateFrom(String? s) => switch (s) {
      'COMPILED' => ChapterState.compiled,
      'COMPILING' => ChapterState.compiling,
      _ => ChapterState.locked,
    };

class Chapter {
  final String chunkId;
  final String parentFileId;
  final String title;
  final int pageFrom;
  final int pageTo;
  final int pageCount;
  final ChapterState state;

  const Chapter({
    required this.chunkId,
    required this.parentFileId,
    required this.title,
    required this.pageFrom,
    required this.pageTo,
    required this.pageCount,
    required this.state,
  });

  bool get isLocked => state == ChapterState.locked;

  factory Chapter.fromJson(Map<String, dynamic> j) => Chapter(
        chunkId: (j['chunkId'] ?? '') as String,
        parentFileId: (j['parentFileId'] ?? '') as String,
        title: (j['title'] as String?)?.trim().isNotEmpty == true
            ? j['title'] as String
            : 'Chapter',
        pageFrom: (j['pageFrom'] as num?)?.toInt() ?? 0,
        pageTo: (j['pageTo'] as num?)?.toInt() ?? 0,
        pageCount: (j['pageCount'] as num?)?.toInt() ?? 0,
        state: _chapterStateFrom(j['state'] as String?),
      );
}

/// The GET /chapters payload: the chapters + the chunk-compile allowance (one
/// source for the "N of M compiles left" counter — so the client never guesses it).
class ChaptersResult {
  final int allowanceUsed;

  /// -1 = unlimited.
  final int allowanceLimit;
  final List<Chapter> chapters;

  const ChaptersResult({
    required this.allowanceUsed,
    required this.allowanceLimit,
    required this.chapters,
  });

  bool get unlimited => allowanceLimit < 0;

  /// Remaining compiles this window (a large sentinel when unlimited).
  int get remaining =>
      unlimited ? 1 << 30 : (allowanceLimit - allowanceUsed).clamp(0, allowanceLimit);

  List<Chapter> get locked => chapters.where((c) => c.isLocked).toList();

  factory ChaptersResult.fromJson(Map<String, dynamic> j) => ChaptersResult(
        allowanceUsed: (j['allowanceUsed'] as num?)?.toInt() ?? 0,
        allowanceLimit: (j['allowanceLimit'] as num?)?.toInt() ?? 0,
        chapters: (j['chapters'] as List?)
                ?.whereType<Map<String, dynamic>>()
                .map(Chapter.fromJson)
                .toList() ??
            const [],
      );
}
