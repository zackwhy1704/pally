import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/core/ui/mochi_avatar.dart';
import 'package:pally/shared/models/mochi_config.dart';

void main() {
  testWidgets('MochiAvatar renders distinct customized centre looks',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          backgroundColor: const Color(0xFF0d0d0d),
          body: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                MochiAvatar(
                    config: MochiConfig(body: 3, accessory: 'crown', aura: 'sparkle'),
                    size: 120, animate: false),
                SizedBox(width: 16),
                MochiAvatar(
                    config: MochiConfig(body: 7, accessory: 'glasses', aura: 'electric'),
                    size: 120, animate: false),
                SizedBox(width: 16),
                MochiAvatar(
                    config: MochiConfig(body: 0, accessory: 'bow', aura: 'chill'),
                    size: 120, animate: false),
              ],
            ),
          ),
        ),
      ),
    );
    // let the asset image decode
    await tester.runAsync(() async => Future.delayed(const Duration(milliseconds: 300)));
    await tester.pumpAndSettle();
    await expectLater(
        find.byType(Row), matchesGoldenFile('mochi_avatar_render.png'));
  });
}
