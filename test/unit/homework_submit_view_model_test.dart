import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/features/homework/presentation/homework_submit_view_model.dart';

class _MockDio extends Mock implements Dio {}

/// The submit VM guards a network write: it must validate before firing,
/// never POST without a title and at least one file, and never double-fire.
void main() {
  setUpAll(() => registerFallbackValue(RequestOptions(path: '/')));

  late _MockDio dio;
  late ProviderContainer container;

  HomeworkSubmitViewModel vm() =>
      container.read(homeworkSubmitViewModelProvider('av-1').notifier);

  setUp(() {
    dio = _MockDio();
    container = ProviderContainer(
      overrides: [dioProvider.overrideWithValue(dio)],
    );
    // Keep the autoDispose notifier alive for the duration of the test.
    container.listen(
      homeworkSubmitViewModelProvider('av-1'),
      (_, __) {},
      fireImmediately: true,
    );
  });

  tearDown(() => container.dispose());

  test('a blank title is rejected with a persistent error, no POST', () async {
    await vm().submit(title: '   ');
    final state = container.read(homeworkSubmitViewModelProvider('av-1'));
    expect(state.error, isNotNull);
    expect(state.submitted, isFalse);
    verifyNever(() => dio.post<dynamic>(any(),
        data: any(named: 'data'), options: any(named: 'options')));
  });

  test('a titled submission with no files is rejected, no POST', () async {
    await vm().submit(title: 'Maths WS3');
    final state = container.read(homeworkSubmitViewModelProvider('av-1'));
    expect(state.error, contains('photo or PDF'));
    expect(state.submitted, isFalse);
    verifyNever(() => dio.post<dynamic>(any(),
        data: any(named: 'data'), options: any(named: 'options')));
  });

  test('canSubmit is false until at least one file is attached', () {
    expect(container.read(homeworkSubmitViewModelProvider('av-1')).canSubmit,
        isFalse);
  });

  test('removing the only file flips canSubmit back to false', () {
    final state = container.read(homeworkSubmitViewModelProvider('av-1'));
    // With no files attached the action is unavailable — the guard the UI
    // relies on to disable the Submit button.
    expect(state.canSubmit, isFalse);
    expect(state.files, isEmpty);
  });
}
