import 'package:freezed_annotation/freezed_annotation.dart';

part 'entitlement.freezed.dart';
part 'entitlement.g.dart';

@freezed
class Entitlement with _$Entitlement {
  const factory Entitlement({
    @Default(false) bool isPremium,
    @Default('NONE') String source, // SELF | PARENT | CENTRE | NONE
    String? plan,
    String? status,
    String? trialEndsAt,
  }) = _Entitlement;

  factory Entitlement.fromJson(Map<String, dynamic> json) =>
      _$EntitlementFromJson(json);
}
