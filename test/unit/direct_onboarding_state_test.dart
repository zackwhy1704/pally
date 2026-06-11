import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/onboarding/presentation/direct_onboarding_view_model.dart';

void main() {
  group('DirectOnboardingState', () {
    test('initial state has step 1 and no selections', () {
      const state = DirectOnboardingState();

      expect(state.step, 1);
      expect(state.isLoading, false);
      expect(state.error, isNull);
      expect(state.avatarId, isNull);
      expect(state.selectedSubject, isNull);
      expect(state.selectedLevel, isNull);
      expect(state.uploadStage, DirectUploadStage.idle);
      expect(state.firstModuleId, isNull);
      expect(state.firstModuleTitle, isNull);
    });

    test('copyWith updates step correctly', () {
      const state = DirectOnboardingState();
      final updated = state.copyWith(step: 2);

      expect(updated.step, 2);
      expect(updated.isLoading, false);
    });

    test('copyWith updates subject and level', () {
      const state = DirectOnboardingState();
      final updated = state.copyWith(
        selectedSubject: 'MATHS',
        selectedLevel: 'P5',
      );

      expect(updated.selectedSubject, 'MATHS');
      expect(updated.selectedLevel, 'P5');
    });

    test('copyWith can set avatarId and move to step 3', () {
      const state = DirectOnboardingState(step: 2);
      final updated = state.copyWith(
        step: 3,
        avatarId: 'avatar-123',
      );

      expect(updated.step, 3);
      expect(updated.avatarId, 'avatar-123');
    });

    test('copyWith can set upload stage to ready with module info', () {
      const state = DirectOnboardingState(
        step: 3,
        avatarId: 'avatar-123',
      );
      final updated = state.copyWith(
        uploadStage: DirectUploadStage.ready,
        firstModuleId: 'mod-1',
        firstModuleTitle: 'Fractions',
      );

      expect(updated.uploadStage, DirectUploadStage.ready);
      expect(updated.firstModuleId, 'mod-1');
      expect(updated.firstModuleTitle, 'Fractions');
    });

    test('copyWith clears nullable fields with explicit null', () {
      const state = DirectOnboardingState(
        error: 'Some error',
        avatarId: 'avatar-123',
      );
      final updated = state.copyWith(error: null, avatarId: null);

      expect(updated.error, isNull);
      expect(updated.avatarId, isNull);
    });
  });

  group('DirectUploadStage', () {
    test('all stages are distinct', () {
      final stages = DirectUploadStage.values;
      expect(stages.length, 6);
      expect(stages.toSet().length, 6);
    });
  });

  group('subjectLabel', () {
    test('returns correct labels for known subjects', () {
      expect(subjectLabel('MATHS'), 'Maths');
      expect(subjectLabel('SCIENCE'), 'Science');
      expect(subjectLabel('ENGLISH'), 'English');
      expect(subjectLabel('CODING'), 'Coding');
    });

    test('returns raw value for unknown subjects', () {
      expect(subjectLabel('ASTRONOMY'), 'ASTRONOMY');
    });
  });

  group('directOnboardingSubjects', () {
    test('contains expected subjects', () {
      expect(directOnboardingSubjects, contains('MATHS'));
      expect(directOnboardingSubjects, contains('SCIENCE'));
      expect(directOnboardingSubjects, contains('ENGLISH'));
      expect(directOnboardingSubjects, contains('CODING'));
    });
  });

  group('directOnboardingLevels', () {
    test('contains expected levels', () {
      expect(directOnboardingLevels, contains('P3'));
      expect(directOnboardingLevels, contains('Sec 1'));
      expect(directOnboardingLevels, contains('JC2'));
    });
  });
}
