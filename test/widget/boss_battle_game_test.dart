import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/boss_battle/presentation/boss_battle_game.dart';

/// Proves the Phase 1 polish's animations are real per-frame reactions to
/// server-confirmed outcomes, not a no-op — the game only visualizes numbers
/// it's handed, so these tests drive it through GameWidget's real frame loop
/// (tester.pump) rather than asserting on internal timers directly.
void main() {
  Future<BossBattleGame> pumpGame(WidgetTester tester, BossBattleGame game) async {
    await tester.pumpWidget(MaterialApp(
      home: SizedBox(width: 400, height: 300, child: GameWidget(game: game)),
    ));
    await tester.pump(); // let onLoad settle
    return game;
  }

  testWidgets('hit landed: boss scales up then returns to its resting scale',
      (tester) async {
    final game = await pumpGame(tester, BossBattleGame(hpMax: 3, hpRemaining: 3));

    game.updateBattleState(hpRemaining: 2, hpMax: 3, hitLanded: true);
    await tester.pump(const Duration(milliseconds: 60));
    final midScale = game.children.whereType<PositionComponent>().first.scale.x;
    expect(midScale, greaterThan(1.0),
        reason: 'a real hit punch scales the boss up mid-animation');

    await tester.pump(const Duration(milliseconds: 400)); // past the 0.35s duration
    final endScale = game.children.whereType<PositionComponent>().first.scale.x;
    expect(endScale, closeTo(1.0, 0.001),
        reason: 'the punch settles back to resting scale, not stuck scaled-up');
  });

  testWidgets('miss: boss shifts position mid-shake then returns home',
      (tester) async {
    final game = await pumpGame(tester, BossBattleGame(hpMax: 3, hpRemaining: 3));
    final boss = game.children.whereType<PositionComponent>().first;
    final homeX = boss.position.x;

    game.updateBattleState(hpRemaining: 3, hpMax: 3, hitLanded: false);
    await tester.pump(const Duration(milliseconds: 30));
    // Mid-shake the boss must have actually moved off its home position.
    expect(boss.position.x, isNot(closeTo(homeX, 0.01)),
        reason: 'a real miss-shake displaces the boss mid-animation');

    await tester.pump(const Duration(milliseconds: 400)); // past the 0.35s duration
    expect(boss.position.x, closeTo(homeX, 0.01),
        reason: 'the shake settles back home, not stuck offset');
  });

  testWidgets('HP bar interpolates toward the target rather than snapping instantly',
      (tester) async {
    final game = await pumpGame(tester, BossBattleGame(hpMax: 3, hpRemaining: 3));
    final components = game.children.whereType<PositionComponent>().toList();
    // Second RectangleComponent added in onLoad is the HP fill bar.
    final hpBar = components[2];
    final widthAtFull = hpBar.size.x;

    game.updateBattleState(hpRemaining: 0, hpMax: 3, hitLanded: true);
    await tester.pump(const Duration(milliseconds: 60));
    final widthShortlyAfter = hpBar.size.x;
    expect(widthShortlyAfter, greaterThan(0),
        reason: 'a real interpolation has not yet reached the new target after one frame');
    expect(widthShortlyAfter, lessThan(widthAtFull),
        reason: 'the bar should already be shrinking toward 0');

    await tester.pump(const Duration(milliseconds: 500)); // past the 0.4s lerp duration
    expect(hpBar.size.x, closeTo(0, 0.5),
        reason: 'the bar eventually reaches the server-truth target (hp=0)');
  });

  testWidgets('playDefeatSequence resolves only after the sequence plays out',
      (tester) async {
    final game = await pumpGame(tester, BossBattleGame(hpMax: 3, hpRemaining: 0));

    bool completed = false;
    game.playDefeatSequence().then((_) => completed = true);

    await tester.pump(const Duration(milliseconds: 300));
    expect(completed, isFalse,
        reason: 'the sequence has a real duration — it must not resolve immediately');

    await tester.pump(const Duration(milliseconds: 1000)); // past the 1.1s total
    expect(completed, isTrue,
        reason: 'the sequence must resolve once it actually finishes playing');
  });
}
