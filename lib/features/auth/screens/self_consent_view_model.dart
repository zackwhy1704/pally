import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/utils/logger.dart';

part 'self_consent_view_model.g.dart';

@riverpod
class SelfConsentViewModel extends _$SelfConsentViewModel {
  @override
  FutureOr<void> build() {}

  Future<void> submitConsent() async {
    if (state.isLoading) return;
    state = const AsyncLoading();
    final dio = ref.read(dioProvider);
    try {
      await dio.post<void>('/api/v1/consent/self');
    } catch (e) {
      // We still proceed so a transient network blip doesn't strand a 13–17
      // self-consenter — but this is NOT silent: a failed POST means the consent
      // artifact the backend gate checks may be missing, so surface it loudly for
      // monitoring. (Whether a sole consent gate should hard-block on failure is
      // a compliance decision — see report.)
      appLog.e('[Consent] self-consent POST failed — artifact may be missing',
          error: e);
    }
    state = const AsyncData(null);
  }
}
