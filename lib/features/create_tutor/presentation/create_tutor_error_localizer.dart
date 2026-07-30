import 'package:pally/l10n/app_localizations.dart';
import 'package:pally/features/create_tutor/presentation/create_tutor_view_model.dart';

/// Resolves a typed [CreateTutorError] to display wording at RENDER time. The
/// view-model owns the error identity (kind + optional backend detail); this
/// surface owns the words. Lives in the feature (not core/i18n) so the
/// create-tutor type never leaks into core — mirrors upload_error_localizer.
String localizedCreateTutorError(AppLocalizations l, CreateTutorError e) =>
    switch (e.kind) {
      CreateTutorErrorKind.noInternet => l.uploadErrNoInternet,
      CreateTutorErrorKind.createFailed =>
        e.detail ?? l.createTutorErrFailed(l.mascotName),
    };
