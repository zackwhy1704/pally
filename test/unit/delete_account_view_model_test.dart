import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/features/account_deletion/application/delete_account_view_model.dart';

class _MockDio extends Mock implements Dio {}

/// The delete VM drives an irreversible request: it re-auths, surfaces the
/// backend's specific guard messages (never the wrong generic mapping), and only
/// advances to the scheduled state on a real success.
void main() {
  setUpAll(() => registerFallbackValue(RequestOptions(path: '/')));

  late _MockDio dio;
  late ProviderContainer container;

  DeleteAccountViewModel vm() =>
      container.read(deleteAccountViewModelProvider.notifier);
  DeleteAccountState read() => container.read(deleteAccountViewModelProvider);

  setUp(() {
    dio = _MockDio();
    container = ProviderContainer(
      overrides: [dioProvider.overrideWithValue(dio)],
    );
    container.listen(deleteAccountViewModelProvider, (_, __) {},
        fireImmediately: true);
  });

  tearDown(() => container.dispose());

  Response<dynamic> _ok(Map<String, dynamic> data) => Response<dynamic>(
        requestOptions: RequestOptions(path: '/'),
        statusCode: 200,
        data: data,
      );

  DioException _err(int status, Map<String, dynamic> body) => DioException(
        requestOptions: RequestOptions(path: '/'),
        response: Response<dynamic>(
          requestOptions: RequestOptions(path: '/'),
          statusCode: status,
          data: body,
        ),
        type: DioExceptionType.badResponse,
      );

  test('starts on the consequences step', () {
    expect(read().step, DeleteAccountStep.consequences);
  });

  test('proceed/back move between consequences and re-auth', () {
    vm().proceedToReauth();
    expect(read().step, DeleteAccountStep.reauth);
    vm().backToConsequences();
    expect(read().step, DeleteAccountStep.consequences);
  });

  test('no password and no code → inline error, no POST', () async {
    await vm().requestDeletion(password: '', code: '');
    expect(read().error, isNotNull);
    expect(read().step, DeleteAccountStep.consequences);
    verifyNever(() => dio.post<dynamic>(any(),
        data: any(named: 'data'), options: any(named: 'options')));
  });

  test('a successful request advances to scheduled with graceEndsAt + IAP flag',
      () async {
    when(() => dio.post<dynamic>('/api/v1/account/delete',
            data: any(named: 'data'), options: any(named: 'options')))
        .thenAnswer((_) async => _ok({
              'graceEndsAt': '2026-07-23T10:00:00Z',
              'needsManualCancellation': true,
            }));

    await vm().requestDeletion(password: 'hunter2');

    expect(read().step, DeleteAccountStep.scheduled);
    expect(read().graceEndsAt, DateTime.parse('2026-07-23T10:00:00Z'));
    expect(read().needsManualCancellation, isTrue);
    expect(read().error, isNull);
  });

  test('409 CENTRE_NOT_EMPTY surfaces the BACKEND message, stays on re-auth',
      () async {
    vm().proceedToReauth();
    when(() => dio.post<dynamic>('/api/v1/account/delete',
            data: any(named: 'data'), options: any(named: 'options')))
        .thenThrow(_err(409, {
      'data': {'code': 'CENTRE_NOT_EMPTY'},
      'error': 'Please transfer or close your centre before deleting your account.',
    }));

    await vm().requestDeletion(password: 'hunter2');

    // NOT the generic PallyError 409 ("slot locked") — the specific guard copy.
    expect(read().error, contains('transfer or close your centre'));
    expect(read().step, DeleteAccountStep.reauth);
  });

  test('401 wrong password surfaces the backend message', () async {
    when(() => dio.post<dynamic>('/api/v1/account/delete',
            data: any(named: 'data'), options: any(named: 'options')))
        .thenThrow(_err(401, {'error': 'Incorrect password'}));

    await vm().requestDeletion(password: 'wrong');

    expect(read().error, 'Incorrect password');
    expect(read().step, DeleteAccountStep.consequences);
  });

  test('sendCode flips codeSent on success', () async {
    when(() => dio.post<dynamic>('/api/v1/account/delete/send-code',
        options: any(named: 'options'))).thenAnswer((_) async => _ok({}));

    await vm().sendCode();

    expect(read().codeSent, isTrue);
  });
}
