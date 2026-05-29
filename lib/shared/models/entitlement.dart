import 'package:freezed_annotation/freezed_annotation.dart';

part 'entitlement.freezed.dart';
part 'entitlement.g.dart';

@freezed
class Entitlement with _$Entitlement {
  const factory Entitlement({
    required bool isPremium,
    required String source, // SELF | PARENT | CENTRE | NONE
    String? plan,
    String? status,
    String? trialEndsAt,
  }) = _Entitlement;

  factory Entitlement.fromJson(Map<String, dynamic> json) =>
      _$EntitlementFromJson(json);
}
