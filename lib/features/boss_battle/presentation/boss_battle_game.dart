import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';

/// Pure rendering — this component tree NEVER computes hp/defeated/outcome.
/// [updateBattleState] is called by [BossBattleScreen] every time the server
/// response changes, and only visualizes the numbers it's handed. Every
/// animation here (hit punch, miss shake, defeat sequence) is a per-frame
/// cosmetic reaction to a server-confirmed outcome, driven by [update] — it
/// never decides HP, correctness, or defeat itself.
class BossBattleGame extends FlameGame {
  BossBattleGame({required int hpMax, required int hpRemaining})
      : _hpMax = hpMax,
        _hpRemaining = hpRemaining,
        _hpFillWidthPx = 0;

  int _hpMax;
  int _hpRemaining;

  static const double _barWidth = 220;
  static const double _barHeight = 18;
  static const Color _bossIdleColor = Color(0xFFFF6660); // AppColors.coral
  static const Color _hitFlashColor = Color(0xFFFFD100); // AppColors.gold
  static const Color _missFlashColor = Color(0xFF6B618A); // AppColors.text2
  static const Color _hpFillColor = Color(0xFF2EC870); // AppColors.green
  static const Color _hpBgColor = Color(0xFFE0DAF0); // AppColors.outline

  static const double _hitPunchDuration = 0.35;
  static const double _missShakeDuration = 0.35;
  static const double _hpBarLerpDuration = 0.4;
  static const double _defeatDuration = 1.1;

  late final RectangleComponent _bossBox;
  late final RectangleComponent _hpBarFill;
  late Vector2 _bossHomePosition;

  double _hpFillWidthPx; // current animated width, lerps toward target
  double _hitPunchTimer = 0;
  double _missShakeTimer = 0;
  double _defeatTimer = 0;
  Completer<void>? _defeatCompleter;

  double get _hpFraction =>
      _hpMax == 0 ? 0 : (_hpRemaining / _hpMax).clamp(0.0, 1.0);

  @override
  Future<void> onLoad() async {
    final center = size / 2;

    _bossBox = RectangleComponent(
      size: Vector2(120, 120),
      paint: Paint()..color = _bossIdleColor,
      anchor: Anchor.center,
      position: Vector2(center.x, center.y - 40),
    );
    _bossHomePosition = _bossBox.position.clone();
    add(_bossBox);

    add(RectangleComponent(
      size: Vector2(_barWidth, _barHeight),
      paint: Paint()..color = _hpBgColor,
      anchor: Anchor.centerLeft,
      position: Vector2(center.x - _barWidth / 2, center.y + 70),
    ));

    _hpFillWidthPx = _barWidth * _hpFraction;
    _hpBarFill = RectangleComponent(
      size: Vector2(_hpFillWidthPx, _barHeight),
      paint: Paint()..color = _hpFillColor,
      anchor: Anchor.centerLeft,
      position: Vector2(center.x - _barWidth / 2, center.y + 70),
    );
    add(_hpBarFill);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Smoothly close the gap between the rendered HP bar and the current
    // server-truth target — a snap-to-value bar reads as broken, not fast.
    final targetPx = _barWidth * _hpFraction;
    if ((_hpFillWidthPx - targetPx).abs() > 0.5) {
      final step = (_barWidth / _hpBarLerpDuration) * dt;
      _hpFillWidthPx = _hpFillWidthPx > targetPx
          ? math.max(targetPx, _hpFillWidthPx - step)
          : math.min(targetPx, _hpFillWidthPx + step);
      _hpBarFill.size = Vector2(_hpFillWidthPx, _barHeight);
    }

    if (_hitPunchTimer > 0) {
      _hitPunchTimer = math.max(0, _hitPunchTimer - dt);
      final t = _hitPunchTimer / _hitPunchDuration; // 1 → 0
      _bossBox.scale = Vector2.all(1.0 + 0.35 * t);
      _bossBox.paint.color =
          Color.lerp(_bossIdleColor, _hitFlashColor, t) ?? _bossIdleColor;
      if (_hitPunchTimer == 0) {
        _bossBox.scale = Vector2.all(1.0);
        _bossBox.paint.color = _bossIdleColor;
      }
    }

    if (_missShakeTimer > 0) {
      _missShakeTimer = math.max(0, _missShakeTimer - dt);
      final t = _missShakeTimer / _missShakeDuration; // 1 → 0
      final shakeX = math.sin(t * math.pi * 6) * 8 * t;
      _bossBox.position = _bossHomePosition + Vector2(shakeX, 0);
      _bossBox.paint.color =
          Color.lerp(_bossIdleColor, _missFlashColor, t) ?? _bossIdleColor;
      if (_missShakeTimer == 0) {
        _bossBox.position = _bossHomePosition.clone();
        _bossBox.paint.color = _bossIdleColor;
      }
    }

    if (_defeatTimer > 0) {
      _defeatTimer = math.max(0, _defeatTimer - dt);
      final t = 1 - (_defeatTimer / _defeatDuration); // 0 → 1
      // Spin + shrink + fade to nothing over the sequence.
      _bossBox.scale = Vector2.all((1.0 - t).clamp(0.0, 1.0));
      _bossBox.angle = t * math.pi * 2;
      _bossBox.paint.color =
          (Color.lerp(_hitFlashColor, _bossIdleColor, t) ?? _bossIdleColor)
              .withAlpha(((1.0 - t) * 255).round().clamp(0, 255));
      if (_defeatTimer == 0) {
        _defeatCompleter?.complete();
        _defeatCompleter = null;
      }
    }
  }

  /// Re-renders the HP bar to the given server-truth numbers and arms a
  /// cosmetic hit-punch/miss-shake for the outcome of the most recent
  /// attack. [hitLanded] null = no attack yet (initial render, no flash).
  void updateBattleState({
    required int hpRemaining,
    required int hpMax,
    bool? hitLanded,
  }) {
    _hpRemaining = hpRemaining;
    _hpMax = hpMax;

    if (hitLanded == true) {
      _hitPunchTimer = _hitPunchDuration;
    } else if (hitLanded == false) {
      _missShakeTimer = _missShakeDuration;
    }
  }

  /// Plays the boss's defeat animation (spin + shrink + fade) and resolves
  /// once it finishes. [BossBattleScreen] awaits this before swapping to the
  /// victory card — a presentation-timing decision, not a game-state one;
  /// hp/defeated truth was already server-confirmed before this is called.
  Future<void> playDefeatSequence() {
    final completer = Completer<void>();
    _defeatCompleter = completer;
    _defeatTimer = _defeatDuration;
    return completer.future;
  }
}
