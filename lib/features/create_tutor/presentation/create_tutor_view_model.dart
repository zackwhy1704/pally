import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/shared/models/avatar.dart';
import 'package:pally/shared/models/mochi_character.dart';
import 'package:pally/app/api_client.dart';

part 'create_tutor_view_model.g.dart';

enum CreateTutorStep { character, name, subject, grade }

@immutable
class CreateTutorState {
  const CreateTutorState({
    this.selectedCharacter,
    this.name = '',
    this.subject,
    this.gradeLevel,
    this.curriculumType,
    this.step = CreateTutorStep.character,
    this.isLoading = false,
    this.error,
  });

  final MochiCharacter? selectedCharacter;
  final String name;
  final String? subject;
  final String? gradeLevel;
  final String? curriculumType;
  final CreateTutorStep step;
  final bool isLoading;
  final String? error;

  bool get canCreate =>
      selectedCharacter != null &&
      name.trim().isNotEmpty &&
      subject != null &&
      subject!.trim().isNotEmpty;

  int get stepIndex => step.index;

  String get trimmedName => name.trim();

  CreateTutorState copyWith({
    MochiCharacter? selectedCharacter,
    String? name,
    String? subject,
    Object? gradeLevel = _sentinel,
    Object? curriculumType = _sentinel,
    CreateTutorStep? step,
    bool? isLoading,
    Object? error = _sentinel,
  }) {
    return CreateTutorState(
      selectedCharacter: selectedCharacter ?? this.selectedCharacter,
      name: name ?? this.name,
      subject: subject ?? this.subject,
      gradeLevel: gradeLevel == _sentinel ? this.gradeLevel : gradeLevel as String?,
      curriculumType: curriculumType == _sentinel ? this.curriculumType : curriculumType as String?,
      step: step ?? this.step,
      isLoading: isLoading ?? this.isLoading,
      error: error == _sentinel ? this.error : error as String?,
    );
  }
}

const _sentinel = Object();

@riverpod
class CreateTutorViewModel extends _$CreateTutorViewModel {
  @override
  CreateTutorState build() => const CreateTutorState();

  void selectCharacter(MochiCharacter character) {
    state = state.copyWith(
      selectedCharacter: character,
      subject: character.defaultSubject,
    );
  }

  void setName(String name) {
    state = state.copyWith(name: name);
  }

  void setSubject(String subject) {
    state = state.copyWith(subject: subject);
  }

  void setGradeLevel(String? grade) {
    state = state.copyWith(gradeLevel: grade);
  }

  void setCurriculumType(String? curriculum) {
    state = state.copyWith(curriculumType: curriculum);
  }

  void nextStep() {
    if (state.step.index < CreateTutorStep.values.length - 1) {
      state = state.copyWith(
        step: CreateTutorStep.values[state.step.index + 1],
      );
    }
  }

  void previousStep() {
    if (state.step.index > 0) {
      state = state.copyWith(
        step: CreateTutorStep.values[state.step.index - 1],
      );
    }
  }

  Future<String?> createAvatar() async {
    if (!state.canCreate) return null;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final dio = ref.read(dioProvider);
      final request = CreateAvatarRequest(
        name: state.trimmedName,
        character: state.selectedCharacter!,
        subject: state.subject!.trim(),
        gradeLevel: state.gradeLevel,
        curriculumType: state.curriculumType,
      );
      final response = await dio.post<Map<String, dynamic>>(
        '/api/v1/avatars',
        data: request.toJson(),
      );
      final avatar = Avatar.fromJson(response.data!);
      state = state.copyWith(isLoading: false);
      return avatar.id;
    } on DioException catch (e) {
      // Never fabricate a stub-new-{ts} id on network failure. Returning
      // a fake id makes creation LOOK successful but subsequent chat /
      // upload / quiz calls all 404 because no avatar exists. Surface a
      // real error and let the user stay on this screen to retry.
      final isNetwork = e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown;
      final message = isNetwork
          ? 'No internet connection. Check your WiFi and try again.'
          : (e.message ?? 'Could not create tutor. Please try again.');
      state = state.copyWith(isLoading: false, error: message);
      return null;
    }
  }
}
