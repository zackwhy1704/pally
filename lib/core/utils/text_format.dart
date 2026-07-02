// Shared display formatters. One home for text-formatting so copies can't
// diverge (two separate maskEmail impls once rendered the SAME parent email
// differently on onboarding vs the consent sheet — a visible inconsistency).

/// Masks an email for display: keeps the first 2 characters of the local part,
/// e.g. "john@gmail.com" → "jo***@gmail.com". Returns the input unchanged when
/// it has no usable local part. This is the ONE canonical masking rule — never
/// re-implement it inline.
String maskEmail(String email) {
  final at = email.indexOf('@');
  if (at <= 0) return email;
  final name = email.substring(0, at);
  final keep = name.length <= 2 ? name.substring(0, 1) : name.substring(0, 2);
  return '$keep***${email.substring(at)}';
}
