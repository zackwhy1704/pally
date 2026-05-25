import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/shared/models/avatar.dart';
import 'package:pally/app/api_client.dart';

part 'create_tutor_view_model.g.dart';

enum CreateTutorStep { character, name, subject }

@immutable
class CreateTutorState {
  const CreateTutorState({
    this.selectedCharacter,
    this.name = '',
    this.subject,
    this.step = CreateTutorStep.character,
    this.isLoading = false,
    this.error,
  });

  final AvatarCharacter? selectedCharacter;
  final String name;
  final String? subject;
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
    AvatarCharacter? selectedCharacter,
    String? name,
    String? subject,
    CreateTutorStep? step,
    bool? isLoading,
    Object? error = _sentinel,
  }) {
    return CreateTutorState(
      selectedCharacter: selectedCharacter ?? this.selectedCharacter,
      name: name ?? this.name,
      subject: subject ?? this.subject,
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

  void selectCharacter(AvatarCharacter character) {
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
      );
      final response = await dio.post<Map<String, dynamic>>(
        '/api/v1/avatars',
        data: request.toJson(),
      );
      final avatar = Avatar.fromJson(response.data!);
      state = state.copyWith(isLoading: false);
      return avatar.id;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown) {
        state = state.copyWith(isLoading: false);
        return 'stub-new-${DateTime.now().millisecondsSinceEpoch}';
      }
      state = state.copyWith(
        isLoading: false,
        error: e.message ?? 'Failed to create tutor',
      );
      return null;
    }
  }
}
