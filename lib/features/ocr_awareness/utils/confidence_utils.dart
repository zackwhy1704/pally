import 'package:flutter/material.dart';

abstract class ConfidenceUtils {
  static Color colorFor(double confidence) {
    if (confidence >= 0.85) return const Color(0xFF2EC770);
    if (confidence >= 0.70) return const Color(0xFF00BAA3);
    if (confidence >= 0.50) return const Color(0xFFFFB81A);
    return const Color(0xFFEF5350);
  }

  static String badgeLabel(double confidence) {
    if (confidence >= 0.85) return 'great';
    if (confidence >= 0.70) return 'good';
    if (confidence >= 0.50) return 'ok';
    return 'risky';
  }

  static String badgeText(double confidence) {
    if (confidence >= 0.85) return '${(confidence * 100).round()}% ✓';
    if (confidence >= 0.70) return '${(confidence * 100).round()}%';
    if (confidence >= 0.50) return '${(confidence * 100).round()}% ⚠';
    return '${(confidence * 100).round()}% ✗';
  }

  static bool requiresWarning(String detectedType) {
    return const {'diagram', 'graph', 'chart', 'formula', 'equation', 'symbol'}
        .contains(detectedType.toLowerCase());
  }

  static String warningNote(String detectedType) {
    final type = detectedType.toLowerCase();
    if (type == 'diagram' || type == 'graph' || type == 'chart') {
      return 'This image contains a diagram or chart. Text reading may miss visual elements.';
    }
    if (type == 'formula' || type == 'equation' || type == 'symbol') {
      return 'Maths symbols and equations may not be read perfectly by OCR.';
    }
    return 'Some content in this image may not be read accurately.';
  }

  static String fixInstruction(String detectedType) {
    final type = detectedType.toLowerCase();
    if (type == 'diagram' || type == 'graph' || type == 'chart') {
      return 'Tap "Fix text manually" to describe what the diagram shows.';
    }
    if (type == 'formula' || type == 'equation' || type == 'symbol') {
      return 'Tap "Fix text manually" to correct any misread symbols.';
    }
    return 'Tap "Fix text manually" to review and correct the text.';
  }
}
