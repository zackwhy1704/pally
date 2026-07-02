import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Architecture guards (dependency-free source scan). They keep two recurring
/// leaks from growing: screens that fetch, and DioException handling scattered
/// outside the data layer. Legacy offenders are allow-listed so the tests are
/// GREEN today — the point is NO NEW violations. As each is migrated (screen →
/// view model; catch → central interceptor/mapper), delete its allow-list line;
/// the lists must only ever SHRINK.

// STEP 1b — screens must NOT fetch (Dio/API belongs in view models).
const _screenFetchAllow = {
  'features/brain_health/presentation/brain_health_screen.dart',
  'features/centre/presentation/centre_join_screen.dart',
  'features/home/presentation/home_screen.dart',
  'features/library/presentation/library_screen.dart',
  'features/settings/presentation/learning_style_screen.dart',
  'features/settings/presentation/settings_screen.dart',
  'features/wiki_viewer/presentation/wiki_viewer_screen.dart',
};

// STEP 1c — DioException handling belongs in the data/api layer, not everywhere.
const _dioCatchAllow = {
  'core/services/feature_flags.dart',
  'features/assignments/presentation/assignment_detail_view_model.dart',
  'features/assignments/presentation/assignment_view_model.dart',
  'features/auth/screens/splash_view_model.dart',
  'features/auth/services/auth_service.dart',
  'features/avatar_picker/screens/avatar_picker_screen.dart',
  'features/centre/presentation/centre_join_screen.dart',
  'features/chat/presentation/chat_view_model.dart',
  'features/consent/presentation/parental_consent_pending_sheet.dart',
  'features/create_tutor/presentation/create_tutor_view_model.dart',
  'features/exam_prep/presentation/exam_prep_view_model.dart',
  'features/flashcards/presentation/flashcard_view_model.dart',
  'features/groups/presentation/challenge_view_model.dart',
  'features/groups/presentation/groups_view_model.dart',
  'features/home/presentation/home_screen.dart',
  'features/home/presentation/home_view_model.dart',
  'features/home/widgets/assignment_banner.dart',
  'features/home/widgets/module_progress_banner.dart',
  'features/homework/presentation/homework_detail_view_model.dart',
  'features/homework/presentation/homework_list_view_model.dart',
  'features/homework/presentation/homework_submit_view_model.dart',
  'features/join/presentation/join_controller.dart',
  'features/library/presentation/library_screen.dart',
  'features/library/presentation/library_view_model.dart',
  'features/modules/presentation/module_list_view_model.dart',
  'features/modules/presentation/module_player_view_model.dart',
  'features/onboarding/presentation/direct_onboarding_view_model.dart',
  'features/progress/presentation/achievements_provider.dart',
  'features/progress/presentation/coverage_provider.dart',
  'features/progress/presentation/daily_goal_provider.dart',
  'features/progress/presentation/level_roadmap_provider.dart',
  'features/progress/presentation/progress_view_model.dart',
  'features/progress/presentation/streak_status_provider.dart',
  'features/quiz/presentation/quiz_view_model.dart',
  'features/quiz/providers/quiz_status_provider.dart',
  'features/referral/referral_service.dart',
  'features/settings/presentation/learning_style_screen.dart',
  'features/settings/presentation/settings_screen.dart',
  'features/shop/providers/unlocked_characters_provider.dart',
  'features/study_plan/presentation/study_plan_view_model.dart',
  'features/subscription/entitlement_provider.dart',
  'features/subscription/widgets/web_upgrade_cta.dart',
  'features/teach_mochi/presentation/teach_mochi_view_model.dart',
  'features/upload/presentation/upload_view_model.dart',
};

List<File> _dartFiles() => Directory('lib')
    .listSync(recursive: true)
    .whereType<File>()
    .where((f) => f.path.endsWith('.dart') && !f.path.endsWith('.g.dart'))
    .toList();

String _rel(File f) => f.path.replaceFirst('lib/', '');

void main() {
  final fetch = RegExp(r'dioProvider|DioException|\.get<|\.post<|\.put<|\.delete<');

  test('screens do not fetch (Dio/API belongs in view models)', () {
    final offenders = <String>[];
    for (final f in _dartFiles()) {
      final rel = _rel(f);
      final isScreen = rel.contains('/presentation/') && rel.endsWith('_screen.dart');
      if (!isScreen) continue;
      if (fetch.hasMatch(f.readAsStringSync()) && !_screenFetchAllow.contains(rel)) {
        offenders.add(rel);
      }
    }
    expect(offenders, isEmpty,
        reason: 'NEW screen doing its own fetch — move it to a view model, '
            'do not extend the allow-list:\n${offenders.join('\n')}');
  });

  test('DioException is not handled outside the data/api layer', () {
    final offenders = <String>[];
    for (final f in _dartFiles()) {
      final rel = _rel(f);
      if (rel.contains('/data/') || rel == 'app/api_client.dart') continue;
      if (f.readAsStringSync().contains('on DioException') && !_dioCatchAllow.contains(rel)) {
        offenders.add(rel);
      }
    }
    expect(offenders, isEmpty,
        reason: 'NEW scattered DioException catch — centralize in the interceptor/'
            'ApiError mapper, do not extend the allow-list:\n${offenders.join('\n')}');
  });
}
