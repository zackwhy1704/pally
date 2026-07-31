/// Shared email-format check. Was duplicated identically across
/// complete_profile_screen.dart and direct_onboarding_screen.dart before the
/// forgot-password dialog needed the same pattern as a third site — one
/// definition now, not three (or four).
///
/// Requires TLD ≥ 2 chars; rejects single-char TLDs like .c
final emailFormatRegex =
    RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$');

/// Convenience predicate — trims before matching, same as every existing
/// call site already did inline.
bool isValidEmailFormat(String email) => emailFormatRegex.hasMatch(email.trim());
