import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/features/onboarding/presentation/direct_onboarding_view_model.dart';

/// Pins the fix for the "manual onboarding upload always fails" launch-blocker: a 19MB book
/// cannot finish a SEND in the global BaseOptions sendTimeout (15s), so the onboarding upload
/// MUST override it to match its two sibling upload paths (2 min). This test captures the
/// actual RequestOptions the POST /files uses and asserts the 2-min sendTimeout — it FAILS on
/// the 15s BaseOptions default (no override) and PASSES with the override.
class _CapturingAdapter implements HttpClientAdapter {
  RequestOptions? captured;
  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    if (options.path.contains('/files')) captured = options;
    // Return a SEGMENTED body so uploadFile returns early (no compile poll to hang the test).
    return ResponseBody.fromString(
      '{"chunks":[{"chunkId":"c1","title":"t","pageFrom":1,"pageTo":2}]}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType]
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _AvatarSetVM extends DirectOnboardingViewModel {
  @override
  DirectOnboardingState build() =>
      const DirectOnboardingState(step: 3, avatarId: 'av-1');
}

void main() {
  test('onboarding upload uses a 2-min sendTimeout, not the 15s BaseOptions default',
      () async {
    final tmp = File(
        '${Directory.systemTemp.path}/onb_${DateTime.now().microsecondsSinceEpoch}.txt')
      ..writeAsStringSync('hello');
    addTearDown(() {
      if (tmp.existsSync()) tmp.deleteSync();
    });

    final adapter = _CapturingAdapter();
    // A Dio whose GLOBAL default is the bad 15s — only a per-request override beats it.
    final dio = Dio(BaseOptions(sendTimeout: const Duration(seconds: 15)))
      ..httpClientAdapter = adapter;

    final container = ProviderContainer(overrides: [
      dioProvider.overrideWithValue(dio),
      directOnboardingViewModelProvider.overrideWith(_AvatarSetVM.new),
    ]);
    addTearDown(container.dispose);

    final vm = container.read(directOnboardingViewModelProvider.notifier);
    await vm.uploadFile(PlatformFile(name: 't.txt', path: tmp.path, size: 5));

    expect(adapter.captured, isNotNull,
        reason: 'the POST /files must have been sent');
    expect(adapter.captured!.sendTimeout, const Duration(minutes: 2));
    expect(adapter.captured!.receiveTimeout, const Duration(minutes: 3));
  });
}
