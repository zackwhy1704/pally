import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/features/onboarding/presentation/direct_onboarding_error_localizer.dart';
import 'package:pally/features/onboarding/presentation/direct_onboarding_view_model.dart';
import 'package:pally/l10n/app_localizations.dart';

/// Pins DirectOnboardingViewModel.friendlyError's status-code → typed-KIND
/// mapping. The VM used to bake raw English strings straight into
/// DirectOnboardingState.error (rendered verbatim by a bare SnackBar
/// Text(next.error!)) — the exact PallyError-adjacent anti-pattern this app's
/// other typed VM errors (CreateTutorError/UploadError) exist to avoid. This
/// also caught a second, separate bug while auditing: subjectLabel/levelLabel/
/// levelSubtitle were a dead SECOND copy of label_localizer's resolvers,
/// called from nowhere — deleted rather than localized.
DioException _dio(int status, Object? body) => DioException(
      requestOptions: RequestOptions(path: '/onboard/quick'),
      response: Response(
        requestOptions: RequestOptions(path: '/onboard/quick'),
        statusCode: status,
        data: body,
      ),
    );

DioException _connError() => DioException(
      requestOptions: RequestOptions(path: '/onboard/quick'),
      type: DioExceptionType.connectionError,
    );

DirectOnboardingViewModel _vm() {
  final container = ProviderContainer(
    overrides: [dioProvider.overrideWithValue(Dio())],
  );
  addTearDown(container.dispose);
  return container.read(directOnboardingViewModelProvider.notifier);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('connection error/timeout maps to noInternet', () {
    final e = _vm().friendlyError(_connError());
    expect(e.kind, DirectOnboardingErrorKind.noInternet);
  });

  test('401 maps to wrongPassword', () {
    final e = _vm().friendlyError(_dio(401, {'error': 'bad credentials'}));
    expect(e.kind, DirectOnboardingErrorKind.wrongPassword);
  });

  test('409 maps to accountExists', () {
    final e = _vm().friendlyError(_dio(409, {'error': 'duplicate'}));
    expect(e.kind, DirectOnboardingErrorKind.accountExists);
  });

  test('400 with "valid email" server text maps to invalidEmail', () {
    final e =
        _vm().friendlyError(_dio(400, {'error': 'not a valid email address'}));
    expect(e.kind, DirectOnboardingErrorKind.invalidEmail);
  });

  test('400 with "parent"/"guardian" server text maps to '
      'parentEmailInvalid', () {
    final e = _vm().friendlyError(_dio(400, {'error': 'parent email rejected'}));
    expect(e.kind, DirectOnboardingErrorKind.parentEmailInvalid);
  });

  test('403 maps to consentPending', () {
    final e = _vm().friendlyError(_dio(403, {'error': 'pending'}));
    expect(e.kind, DirectOnboardingErrorKind.consentPending);
  });

  test('422 maps to serverMessage and CARRIES the backend text verbatim', () {
    final e = _vm().friendlyError(_dio(422, {'error': 'exact backend wording'}));
    expect(e.kind, DirectOnboardingErrorKind.serverMessage);
    expect(e.detail, 'exact backend wording');
  });

  test('429 maps to rateLimited', () {
    final e = _vm().friendlyError(_dio(429, null));
    expect(e.kind, DirectOnboardingErrorKind.rateLimited);
  });

  test('500 maps to serverError', () {
    final e = _vm().friendlyError(_dio(500, null));
    expect(e.kind, DirectOnboardingErrorKind.serverError);
  });

  test('an unmapped status whose body mentions "consent" still routes to '
      'consentPending (the catch-all keyword sniff)', () {
    final e = _vm().friendlyError(_dio(418, {'error': 'awaiting consent'}));
    expect(e.kind, DirectOnboardingErrorKind.consentPending);
  });

  test('a genuinely unknown failure carries the backend detail through '
      '"unknown", never a fabricated message', () {
    final e = _vm().friendlyError(_dio(418, {'error': 'teapot'}));
    expect(e.kind, DirectOnboardingErrorKind.unknown);
    expect(e.detail, 'teapot');
  });

  group('localizedDirectOnboardingError', () {
    late AppLocalizations en;
    late AppLocalizations zh;
    setUpAll(() async {
      en = await AppLocalizations.delegate.load(const Locale('en'));
      zh = await AppLocalizations.delegate.load(const Locale('zh'));
    });

    test('every kind resolves to non-empty text in both locales', () {
      for (final kind in DirectOnboardingErrorKind.values) {
        final e = DirectOnboardingError(kind);
        expect(localizedDirectOnboardingError(en, e), isNotEmpty,
            reason: '$kind (en)');
        expect(localizedDirectOnboardingError(zh, e), isNotEmpty,
            reason: '$kind (zh)');
      }
    });

    test('serverMessage/unknown pass the backend detail through VERBATIM, '
        'never re-translated', () {
      const detail = 'Some exact backend sentence.';
      expect(
          localizedDirectOnboardingError(zh,
              const DirectOnboardingError(DirectOnboardingErrorKind.serverMessage,
                  detail: detail)),
          detail);
      expect(
          localizedDirectOnboardingError(zh,
              const DirectOnboardingError(DirectOnboardingErrorKind.unknown,
                  detail: detail)),
          detail);
    });
  });
}
