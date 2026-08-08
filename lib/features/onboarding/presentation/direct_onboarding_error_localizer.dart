import 'package:pally/l10n/app_localizations.dart';
import 'package:pally/features/onboarding/presentation/direct_onboarding_view_model.dart';

/// Resolves a typed [DirectOnboardingError] to display wording at RENDER
/// time. The view-model owns the error IDENTITY (kind + optional backend
/// detail); this surface owns the words — the same PR-G3/PR-I/PR-K2 pattern
/// used by every other typed VM error in this app.
String localizedDirectOnboardingError(AppLocalizations l, DirectOnboardingError e) =>
    switch (e.kind) {
      DirectOnboardingErrorKind.noInternet => l.uploadErrNoInternet,
      DirectOnboardingErrorKind.wrongPassword => l.onboardErrWrongPassword,
      DirectOnboardingErrorKind.accountExists => l.onboardErrAccountExists,
      DirectOnboardingErrorKind.invalidEmail => l.onboardErrInvalidEmail,
      DirectOnboardingErrorKind.parentEmailInvalid =>
        l.onboardErrParentEmailInvalid,
      DirectOnboardingErrorKind.parentEmailMissing =>
        l.onboardErrParentEmailMissing,
      DirectOnboardingErrorKind.consentPending => l.onboardErrConsentPending,
      DirectOnboardingErrorKind.rateLimited => l.onboardErrRateLimited,
      DirectOnboardingErrorKind.serverError => l.onboardErrServerError,
      DirectOnboardingErrorKind.serverMessage =>
        e.detail ?? l.onboardErrServerMessageFallback,
      DirectOnboardingErrorKind.unknown =>
        e.detail ?? l.completeProfileErrGeneric,
      DirectOnboardingErrorKind.consentEmailFailed =>
        l.onboardErrConsentEmailFailed,
      DirectOnboardingErrorKind.signUpRequired => l.onboardErrSignUpRequired,
      DirectOnboardingErrorKind.fileReadFailed => l.onboardErrFileReadFailed,
      DirectOnboardingErrorKind.uploadFailed => l.onboardErrUploadFailed,
      DirectOnboardingErrorKind.resendRateLimited =>
        l.onboardErrResendRateLimited,
      DirectOnboardingErrorKind.resendFailed => l.onboardErrResendFailed,
      DirectOnboardingErrorKind.termsNotAccepted =>
        l.onboardErrTermsNotAccepted,
    };
