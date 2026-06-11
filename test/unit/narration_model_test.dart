import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pally/shared/models/narration.dart';

void main() {
  group('Narration model', () {
    test('fromJson parses a READY narration with segments', () {
      final json = {
        'id': 'nar-123',
        'status': 'READY',
        'segments': [
          {
            'cardIndex': 0,
            'scriptText': 'Hello world',
            'audioUrl': 'https://example.com/a.mp3',
            'durationMs': 3000,
          },
          {
            'cardIndex': 1,
            'scriptText': 'Second card',
            'audioUrl': 'https://example.com/b.mp3',
            'durationMs': 4500,
          },
        ],
      };

      final narration = Narration.fromJson(json);

      expect(narration.id, 'nar-123');
      expect(narration.status, 'READY');
      expect(narration.segments.length, 2);
      expect(narration.segments[0].cardIndex, 0);
      expect(narration.segments[0].scriptText, 'Hello world');
      expect(narration.segments[0].audioUrl, 'https://example.com/a.mp3');
      expect(narration.segments[0].durationMs, 3000);
      expect(narration.segments[1].cardIndex, 1);
    });

    test('fromJson handles empty segments list', () {
      final json = {
        'id': 'nar-empty',
        'status': 'PENDING',
        'segments': <dynamic>[],
      };

      final narration = Narration.fromJson(json);

      expect(narration.id, 'nar-empty');
      expect(narration.status, 'PENDING');
      expect(narration.segments, isEmpty);
    });

    test('fromJson uses defaults for missing fields', () {
      final narration = Narration.fromJson(const <String, dynamic>{});

      expect(narration.id, '');
      expect(narration.status, 'PENDING');
      expect(narration.segments, isEmpty);
    });

    test('NarrationSegment uses defaults for missing fields', () {
      final segment =
          NarrationSegment.fromJson(const <String, dynamic>{});

      expect(segment.cardIndex, 0);
      expect(segment.scriptText, '');
      expect(segment.audioUrl, '');
      expect(segment.durationMs, 0);
    });

    test('toJson roundtrip preserves data', () {
      const original = Narration(
        id: 'rt-1',
        status: 'READY',
        segments: [
          NarrationSegment(
            cardIndex: 2,
            scriptText: 'Test script',
            audioUrl: 'https://cdn.test/audio.mp3',
            durationMs: 7000,
          ),
        ],
      );

      // Go through actual JSON encoding/decoding to ensure the roundtrip
      // works as it would with a network response.
      final jsonString = jsonEncode(original.toJson());
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      final restored = Narration.fromJson(decoded);

      expect(restored.id, original.id);
      expect(restored.status, original.status);
      expect(restored.segments.length, 1);
      expect(restored.segments[0].cardIndex, 2);
      expect(restored.segments[0].audioUrl, 'https://cdn.test/audio.mp3');
    });
  });
}
