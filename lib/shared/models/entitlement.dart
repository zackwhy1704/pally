import 'package:freezed_annotation/freezed_annotation.dart';

part 'entitlement.freezed.dart';
part 'entitlement.g.dart';

/// Converts a raw backend tier string to display-ready title case.
/// e.g. "max" → "Max", "pro" → "Pro", null → "Premium".
String prettyTier(String? raw) {
  if (raw == null || raw.isEmpty) return 'Premium';
  const map = {
    'max': 'Max',
    'pro': 'Pro',
    'free': 'Free',
    'family': 'Family',
    'trial': 'Trial',
    'centre': 'Centre',
  };
  return map[raw.toLowerCase()] ??
      raw[0].toUpperCase() + raw.substring(1).toLowerCase();
}

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
