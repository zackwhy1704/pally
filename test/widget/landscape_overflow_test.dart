import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/features/auth/screens/centre_block_screen.dart';
import 'package:pally/features/upload/presentation/upload_screen.dart';
import 'package:pally/features/upload/presentation/upload_view_model.dart';

/// These tests guard the landscape / large-text-scale overflow regression that
/// motivated the shared [AdaptiveCenter] widget. Each fixed centred column used
/// to throw a RenderFlex overflow when the viewport got short (landscape phone)
/// or the text grew (accessibility scale). AdaptiveCenter scrolls instead, so
/// the build must produce NO layout exception in either profile.

/// A Dio that fails fast so any incidental network call (e.g. the consent
/// screen's status poll) falls into its catch branch instead of hanging.
Dio _stubDio() {
  final dio = Dio(BaseOptions(baseUrl: 'http://localhost:1'));
  dio.httpClientAdapter = _ThrowingAdapter();
  return dio;
}

class _ThrowingAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<List<int>>? requestStream, Future<void>? cancelFuture) async {
    throw DioException(requestOptions: options);
  }
}

/// Upload VM stub pinned to a terminal stage so [UploadScreen] renders the
/// private `_TerminalScreen` (the success result page) without any network.
class _StubUploadVm extends UploadViewModel {
  @override
  UploadState build(String avatarId) =>
      const UploadState(uploadStage: UploadStage.compileSuccess);
}

/// Pumps [child] under a [size] viewport at [scale] text scale and asserts the
/// frame produced no layout exception. Mirrors the existing overflow harness.
Future<void> _pumpAt(
  WidgetTester tester,
  Widget child, {
  required Size size,
  required double scale,
  List<Override> overrides = const [],
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [dioProvider.overrideWithValue(_stubDio()), ...overrides],
      child: MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            size: size,
            textScaler: TextScaler.linear(scale),
          ),
          child: child,
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  expect(tester.takeException(), isNull);
}

void main() {
  // 800x360 = landscape phone (short height is what overflows a centred column).
  const landscape = Size(800, 360);
  // 800x600 portrait-ish but pumped at 1.5x text scale to stress vertical room.
  const tallText = Size(800, 600);

  group('CentreBlockScreen', () {
    testWidgets('does not overflow in landscape', (tester) async {
      await _pumpAt(tester, const CentreBlockScreen(),
          size: landscape, scale: 1.0);
    });
    testWidgets('does not overflow at large text scale', (tester) async {
      await _pumpAt(tester, const CentreBlockScreen(),
          size: tallText, scale: 1.5);
    });
  });

  group('UploadScreen terminal result (_TerminalScreen)', () {
    final overrides = [
      uploadViewModelProvider('a1').overrideWith(_StubUploadVm.new),
    ];
    testWidgets('does not overflow in landscape', (tester) async {
      await _pumpAt(tester, const UploadScreen(avatarId: 'a1'),
          size: landscape, scale: 1.0, overrides: overrides);
    });
    testWidgets('does not overflow at large text scale', (tester) async {
      await _pumpAt(tester, const UploadScreen(avatarId: 'a1'),
          size: tallText, scale: 1.5, overrides: overrides);
    });
  });
}
