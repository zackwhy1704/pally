import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/features/avatar_hub/presentation/avatar_hub_screen.dart';
import 'package:pally/features/home/presentation/home_view_model.dart';
import 'package:pally/features/quiz/providers/quiz_status_provider.dart';
import 'package:pally/shared/models/avatar.dart';
import 'package:pally/shared/models/mochi_character.dart';

/// Pins the module-player lesson applied to the hub: the module list is fetched
/// ONCE per hub open (in the VM's async build), NOT on every widget rebuild —
/// the exact bug class that made module_player re-POST /start on each frame.
class _CountingAdapter implements HttpClientAdapter {
  int moduleCalls = 0;
  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    if (options.path.contains('/modules')) moduleCalls++;
    return ResponseBody.fromString('[]', 200, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType]
    });
  }

  @override
  void close({bool force = false}) {}
}

class _StubHomeVM extends HomeViewModel {
  _StubHomeVM(this.avatars);
  final List<Avatar> avatars;
  @override
  Future<List<Avatar>> build() async => avatars;
}

void main() {
  testWidgets('hub fetches the module list once per open, not per rebuild',
      (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(420, 1600);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final adapter = _CountingAdapter();
    final dio = Dio()..httpClientAdapter = adapter;
    final avatar = Avatar(
      id: 'av1',
      name: 'Sakura',
      character: MochiCharacter.mochi,
      subject: 'MATHS',
      wikiPageCount: 3,
    );

    final router = GoRouter(initialLocation: '/avatar/av1', routes: [
      GoRoute(
        path: '/avatar/:avatarId',
        builder: (c, s) =>
            AvatarHubScreen(avatarId: s.pathParameters['avatarId']!),
      ),
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dioProvider.overrideWithValue(dio),
          homeViewModelProvider.overrideWith(() => _StubHomeVM([avatar])),
          // Isolate the /modules count — don't let the quiz row's fetch touch dio.
          quizStatusProvider('av1').overrideWith((ref) async =>
              const QuizStatus(
                  takenToday: false, totalTopics: 0, masteredTopics: 0)),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    // Several extra frames — the widget rebuilds, the fetch must NOT re-fire.
    await tester.pumpAndSettle();
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(adapter.moduleCalls, 1,
        reason: 'module list must be fetched exactly once per hub open');
  });
}
