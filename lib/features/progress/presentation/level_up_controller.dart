import 'package:flutter/material.dart';
import 'package:pally/features/progress/presentation/level_up_overlay.dart';

/// Single entry point for level-up celebration. Call from any screen after
/// an XP-crediting backend response so quiz / photo / chat / teach all
/// celebrate identically.
///
/// Idempotency is the caller's job: pass `levelledUp: true` only on the
/// frame that crossed the threshold. The controller just gates on truthy
/// flags + a mounted context.
class LevelUpController {
  LevelUpController._();

  static Future<void> maybeCelebrate(
    BuildContext context, {
    required bool levelledUp,
    required int newLevel,
  }) async {
    if (!levelledUp || newLevel <= 0) return;
    if (!context.mounted) return;
    await LevelUpOverlay.show(context, newLevel);
  }
}
