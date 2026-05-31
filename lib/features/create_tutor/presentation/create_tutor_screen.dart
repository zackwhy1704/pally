import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/app/router.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/features/create_tutor/presentation/character_picker_step.dart';
import 'package:pally/features/create_tutor/presentation/name_step.dart';
import 'package:pally/features/create_tutor/presentation/grade_step.dart';
import 'package:pally/features/create_tutor/presentation/subject_step.dart';
import 'package:pally/core/ui/pally_toast.dart';
import 'package:pally/features/create_tutor/presentation/create_tutor_view_model.dart';
import 'package:pally/features/home/widgets/how_pally_is_different.dart';

class CreateTutorScreen extends ConsumerWidget {
  const CreateTutorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(createTutorViewModelProvider);
    final vm = ref.read(createTutorViewModelProvider.notifier);

    ref.listen<CreateTutorState>(createTutorViewModelProvider, (_, next) {
      if (next.error != null) {
        PallyToast.error(context, next.error!);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            if (state.stepIndex > 0) {
              vm.previousStep();
            } else {
              const HomeRoute().go(context);
            }
          },
        ),
        title: const Text('Create Tutor'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: _StepIndicator(
            currentStep: state.stepIndex,
            totalSteps: 4,
          ),
        ),
      ),
      body: SafeArea(
        child: switch (state.step) {
          CreateTutorStep.character => CharacterPickerStep(
              selectedCharacter: state.selectedCharacter,
              onSelect: vm.selectCharacter,
              onNext: vm.nextStep,
            ),
          CreateTutorStep.name => NameStep(
              name: state.name,
              selectedCharacter: state.selectedCharacter,
              onNameChanged: vm.setName,
              onNext: state.name.trim().isNotEmpty ? vm.nextStep : null,
            ),
          CreateTutorStep.subject => SubjectStep(
              subject: state.subject,
              selectedCharacter: state.selectedCharacter,
              tutorName: state.trimmedName,
              onSubjectChanged: vm.setSubject,
              isLoading: false,
              canCreate: state.canCreate,
              error: state.error,
              onCreate: state.canCreate ? vm.nextStep : null,
            ),
          CreateTutorStep.grade => GradeStep(
              gradeLevel: state.gradeLevel,
              curriculumType: state.curriculumType,
              tutorName: state.trimmedName,
              selectedCharacter: state.selectedCharacter,
              onGradeChanged: vm.setGradeLevel,
              onCurriculumChanged: vm.setCurriculumType,
              isLoading: state.isLoading,
              onCreate: state.canCreate
                  ? () async {
                      final id = await vm.createAvatar();
                      if (id != null && context.mounted) {
                        const HomeRoute().go(context);
                        // Show "How Pally is different" once after first tutor creation.
                        await HowPallyIsDifferent.maybeShow(context);
                      }
                    }
                  : null,
            ),
        },
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({
    required this.currentStep,
    required this.totalSteps,
  });

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: List.generate(totalSteps, (i) {
          final isActive = i <= currentStep;
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: i < totalSteps - 1 ? 4 : 0),
              decoration: BoxDecoration(
                color: isActive ? AppColors.purple : AppColors.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}
