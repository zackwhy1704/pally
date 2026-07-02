/// A single area the tutor is focusing on for this student (from their compiled
/// weakness brain).
class WeaknessArea {
  const WeaknessArea({required this.title, required this.summary});
  final String title;
  final String summary;

  factory WeaknessArea.fromJson(Map<String, dynamic> j) => WeaknessArea(
        title: (j['title'] ?? '').toString(),
        summary: (j['summary'] ?? '').toString(),
      );
}

/// The student-facing weakness focus view: what Mochi is focusing on + recent
/// wins. [enabled] mirrors the backend pilot flag so the UI stays hidden when off.
class WeaknessFocus {
  const WeaknessFocus({
    required this.enabled,
    required this.focusAreas,
    required this.recentWins,
  });

  final bool enabled;
  final List<WeaknessArea> focusAreas;
  final List<String> recentWins;

  /// Only worth rendering when the pilot is on AND there's something to show.
  bool get hasContent =>
      enabled && (focusAreas.isNotEmpty || recentWins.isNotEmpty);

  static const empty =
      WeaknessFocus(enabled: false, focusAreas: [], recentWins: []);

  factory WeaknessFocus.fromJson(Map<String, dynamic> j) {
    final areasRaw = j['focusAreas'];
    final winsRaw = j['recentWins'];
    return WeaknessFocus(
      enabled: j['enabled'] == true,
      focusAreas: areasRaw is List
          ? areasRaw
              .whereType<Map>()
              .map((m) => WeaknessArea.fromJson(m.cast<String, dynamic>()))
              .toList()
          : const [],
      recentWins:
          winsRaw is List ? winsRaw.map((e) => e.toString()).toList() : const [],
    );
  }
}
