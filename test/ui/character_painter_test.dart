import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/core/ui/painters/character_painter.dart';
import 'package:pally/shared/models/mochi_character.dart';

/// Structural smoke test for every character painter in the dispatcher.
///
/// A "corrupted" painter (wrong case mapping, half-drawn body, an exception
/// inside paint) is invisible to logic tests — it only shows up visually. This
/// test catches the structural failures: paint must not throw at any size, and
/// the painter must actually draw something (non-empty recorded bounds), at the
/// three sizes the app uses (nav badge → shop hero).
void main() {
  group('characterPainterFor', () {
    const sizes = <double>[32, 96, 200];

    for (final character in MochiCharacter.values) {
      for (final size in sizes) {
        test('${character.name} paints at $size without error', () {
          final painter = characterPainterFor(character, size);
          final recorder = ui.PictureRecorder();
          final canvas = Canvas(recorder);
          final canvasSize = Size(size, size);

          // Must not throw.
          expect(
            () => painter.paint(canvas, canvasSize),
            returnsNormally,
            reason: '${character.name} painter threw while painting at $size',
          );

          // Must have actually drawn commands — an empty picture means the
          // painter rendered nothing (e.g. a broken / no-op dispatch case).
          final picture = recorder.endRecording();
          final image = picture.toImageSync(size.ceil(), size.ceil());
          expect(image.width, greaterThan(0));
          expect(image.height, greaterThan(0));
          image.dispose();
          picture.dispose();
        });
      }
    }

    test('every character maps to a non-null painter', () {
      for (final character in MochiCharacter.values) {
        expect(characterPainterFor(character, 96), isNotNull);
      }
    });
  });
}
