import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/features/home/presentation/home_view_model.dart';
import 'package:pally/features/library/presentation/library_view_model.dart';
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
    Object? selectedCharacter = _sentinel,
    String? name,
    Object? subject = _sentinel,
    Object? gradeLevel = _sentinel,
    Object? curriculumType = _sentinel,
    CreateTutorStep? step,
    bool? isLoading,
    Object? error = _sentinel,
  }) {
    return CreateTutorState(
      selectedCharacter: selectedCharacter == _sentinel
          ? this.selectedCharacter
          : selectedCharacter as MochiCharacter?,
      name: name ?? this.name,
      subject: subject == _sentinel ? this.subject : subject as String?,
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

  void selectCharacter(MochiCharacter? character) {
    state = state.copyWith(
      selectedCharacter: character,
      subject: character?.defaultSubject,
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
      // Invalidate the home and library lists so they re-fetch immediately
      // when the user lands back on those screens — no manual pull-to-refresh needed.
      ref.invalidate(homeViewModelProvider);
      ref.invalidate(libraryViewModelProvider);
      return avatar.id;
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false);
      // 402 UPGRADE_REQUIRED: the global Dio interceptor already routes to
      // the paywall — don't show an additional error toast here.
      if (e.response?.statusCode == 402) return null;
      // 403 CONSENT_REQUIRED: interceptor shows the consent-gate sheet.
      if (e.response?.statusCode == 403) return null;
      // Real failure: surface an actionable error so the user can retry.
      final isNetwork = e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown;
      final message = isNetwork
          ? 'No internet connection. Check your WiFi and try again.'
          : (e.message ?? 'Could not create Mochi. Please try again.');
      state = state.copyWith(error: message);
      return null;
    }
  }
}
