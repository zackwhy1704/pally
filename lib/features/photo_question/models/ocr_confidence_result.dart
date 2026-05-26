import 'dart:io';

class OcrItemResult {
  const OcrItemResult({
    required this.questionLabel,
    required this.detectedType,
    required this.confidence,
    this.warningNote,
  });

  final String questionLabel;
  final String detectedType;
  final double confidence;
  final String? warningNote;

  static OcrItemResult fromText(String rawText, int index) {
    final lower = rawText.toLowerCase();
    final double conf;
    final String type;
    String? warning;

    if (_hasDiagramKeywords(lower)) {
      type = 'Diagram / graph';
      conf = 0.18;
      warning = 'Diagrams are hard to read — describe it in your own words';
    } else if (_hasMathSymbols(rawText)) {
      type = 'Maths symbols';
      conf = 0.65;
      warning = 'Some symbols may have been misread — check the formula';
    } else if (_hasTablePattern(lower)) {
      type = 'Data table';
      conf = 0.52;
      warning = 'Tables can lose formatting — verify the numbers';
    } else if (rawText.trim().length < 20) {
      type = 'Short text';
      conf = 0.72;
    } else {
      type = 'Printed text';
      conf = 0.93;
    }

    return OcrItemResult(
      questionLabel: 'Q$index',
      detectedType: type,
      confidence: conf,
      warningNote: warning,
    );
  }

  static bool _hasDiagramKeywords(String text) {
    const kw = [
      'diagram',
      'graph',
      'chart',
      'triangle',
      'circle',
      'square',
      'rectangle',
      'draw',
      'figure',
      'sketch',
    ];
    return kw.any(text.contains);
  }

  static bool _hasMathSymbols(String text) {
    return text.contains('²') ||
        text.contains('÷') ||
        text.contains('√') ||
        text.contains('×') ||
        text.contains('^') ||
        text.contains('∑') ||
        text.contains('∫') ||
        text.contains('π');
  }

  static bool _hasTablePattern(String text) {
    return text.contains('table') ||
        text.contains('grid') ||
        text.contains('column') ||
        (RegExp(r'\|\s*\|').hasMatch(text));
  }
}

class OcrConfidenceResult {
  const OcrConfidenceResult({
    required this.photoFile,
    required this.items,
  });

  final File photoFile;
  final List<OcrItemResult> items;

  double get overallConfidence =>
      items.isEmpty ? 1.0 : items.map((i) => i.confidence).reduce((a, b) => a + b) / items.length;

  bool get hasLowConfidence => items.any((i) => i.confidence < 0.85);

  static OcrConfidenceResult fromOcrTexts(
      File photoFile, List<String> rawTexts) {
    final items = rawTexts.asMap().entries.map((e) {
      return OcrItemResult.fromText(e.value, e.key + 1);
    }).toList();
    return OcrConfidenceResult(photoFile: photoFile, items: items);
  }
}
