import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/app/api_client.dart';

part 'self_consent_view_model.g.dart';

@riverpod
class SelfConsentViewModel extends _$SelfConsentViewModel {
  @override
  FutureOr<void> build() {}

  Future<void> submitConsent() async {
    state = const AsyncLoading();
    final dio = ref.read(dioProvider);
    try {
      await dio.post<void>('/api/v1/consent/self');
    } catch (_) {
      // best-effort: consent recording is fire-and-forget; always proceed
    }
    state = const AsyncData(null);
  }
}
