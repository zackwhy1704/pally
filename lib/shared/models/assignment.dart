import 'package:freezed_annotation/freezed_annotation.dart';

part 'assignment.freezed.dart';
part 'assignment.g.dart';

@freezed
class Assignment with _$Assignment {
  const factory Assignment({
    required String id,
    required String title,
    @Default('PRE_CLASS') String type,
    required String dueDate,
    @Default('PENDING') String status,
    @Default([]) List<AssignmentModule> modules,
  }) = _Assignment;

  factory Assignment.fromJson(Map<String, dynamic> json) =>
      _$AssignmentFromJson(json);
}

@freezed
class AssignmentModule with _$AssignmentModule {
  const factory AssignmentModule({
    required String id,
    required String title,
    @Default('LEARN') String stage,
  }) = _AssignmentModule;

  factory AssignmentModule.fromJson(Map<String, dynamic> json) =>
      _$AssignmentModuleFromJson(json);
}
