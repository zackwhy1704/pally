import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/modules/presentation/module_player_view_model.dart';

/// Pins the module-submit request-body contract. The backend binds an OBJECT
/// (@RequestBody SubmitModuleAnswersRequest{submissions, durationSeconds}) and reads
/// durationSeconds from the BODY. Sending a bare list — as the app did — 400s
/// ("Cannot deserialize ... from Array value") and never advances the stage.
void main() {
  group('buildModuleSubmitBody', () {
    final submissions = [
      {'itemId': 'a', 'response': 'viewed:true'},
      {'itemId': 'b', 'response': 'B'},
    ];

    test('is a JSON OBJECT, not a bare list (the bug that 400ed)', () {
      final body = buildModuleSubmitBody(submissions: submissions, durationSeconds: 15);
      expect(body, isA<Map<String, dynamic>>());
      expect(body, isNot(isA<List>()));
    });

    test('carries submissions as a list under the submissions key', () {
      final body = buildModuleSubmitBody(submissions: submissions, durationSeconds: 15);
      expect(body['submissions'], isA<List>());
      expect((body['submissions'] as List).length, 2);
      expect(body['submissions'], same(submissions));
    });

    test('carries durationSeconds in the BODY (backend has no @RequestParam for it)', () {
      final body = buildModuleSubmitBody(submissions: submissions, durationSeconds: 42);
      expect(body['durationSeconds'], 42);
    });
  });
}
