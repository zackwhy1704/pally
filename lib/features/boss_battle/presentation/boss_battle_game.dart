import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';

/// Pure rendering — this component tree NEVER computes hp/defeated/outcome.
/// [updateBattleState] is called by [BossBattleScreen] every time the server
/// response changes, and only visualizes the numbers it's handed.
class BossBattleGame extends FlameGame {
  BossBattleGame({required int hpMax, required int hpRemaining})
      : _hpMax = hpMax,
        _hpRemaining = hpRemaining;

  int _hpMax;
  int _hpRemaining;

  static const double _barWidth = 220;
  static const double _barHeight = 18;
  static const Color _bossIdleColor = Color(0xFFFF6660); // AppColors.coral
  static const Color _hitFlashColor = Color(0xFFFFD100); // AppColors.gold
  static const Color _missFlashColor = Color(0xFF6B618A); // AppColors.text2
  static const Color _hpFillColor = Color(0xFF2EC870); // AppColors.green
  static const Color _hpBgColor = Color(0xFFE0DAF0); // AppColors.outline

  late final RectangleComponent _bossBox;
  late final RectangleComponent _hpBarFill;

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
    add(_bossBox);

    add(RectangleComponent(
      size: Vector2(_barWidth, _barHeight),
      paint: Paint()..color = _hpBgColor,
      anchor: Anchor.centerLeft,
      position: Vector2(center.x - _barWidth / 2, center.y + 70),
    ));

    _hpBarFill = RectangleComponent(
      size: Vector2(_barWidth * _hpFraction, _barHeight),
      paint: Paint()..color = _hpFillColor,
      anchor: Anchor.centerLeft,
      position: Vector2(center.x - _barWidth / 2, center.y + 70),
    );
    add(_hpBarFill);
  }

  /// Re-renders the HP bar to the given server-truth numbers and plays a
  /// cosmetic flash for the outcome of the most recent attack. [hitLanded]
  /// null = no attack yet (initial render, no flash).
  void updateBattleState({
    required int hpRemaining,
    required int hpMax,
    bool? hitLanded,
  }) {
    _hpRemaining = hpRemaining;
    _hpMax = hpMax;
    _hpBarFill.size = Vector2(_barWidth * _hpFraction, _barHeight);

    if (hitLanded == null) return;
    _bossBox.paint.color = hitLanded ? _hitFlashColor : _missFlashColor;
    Future.delayed(const Duration(milliseconds: 220), () {
      // The game may have been unmounted (screen popped) between the flash
      // and this callback — guard before touching the component tree.
      if (isMounted) {
        _bossBox.paint.color = _bossIdleColor;
      }
    });
  }
}
