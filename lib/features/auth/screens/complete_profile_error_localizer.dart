import 'package:pally/l10n/app_localizations.dart';
import 'package:pally/features/auth/screens/complete_profile_view_model.dart';

/// Resolves a typed [CompleteProfileError] to wording at RENDER time — the VM
/// owns identity, the surface owns words (PR-G3 layering). authFailed carries
/// the backend/AuthException message verbatim.
String localizedCompleteProfileError(AppLocalizations l, CompleteProfileError e) =>
    switch (e.kind) {
      CompleteProfileErrorKind.selectAge => l.completeProfileErrSelectAge,
      CompleteProfileErrorKind.parentEmail => l.completeProfileErrParentEmail,
      CompleteProfileErrorKind.authFailed =>
        e.detail ?? l.completeProfileErrGeneric,
      CompleteProfileErrorKind.generic => l.completeProfileErrGeneric,
    };
