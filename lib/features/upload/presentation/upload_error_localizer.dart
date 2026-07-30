import 'package:pally/l10n/app_localizations.dart';
import 'package:pally/features/upload/presentation/upload_view_model.dart';

/// Resolves typed upload errors/warnings/estimates to display strings at RENDER
/// time. The view-model owns the error IDENTITY (kind + dynamic fields); this
/// surface owns the WORDING. Lives in the upload feature (not core/i18n) so the
/// upload-domain types never leak into core — the same layering rule the typed
/// errors exist to respect.

/// Localize an [UploadError]. serverMessage is the backend's own (already
/// content_language-localized) wording — passed through verbatim, never re-translated.
String localizedUploadError(AppLocalizations l, UploadError e) {
  final f = e.fileName ?? '';
  return switch (e.kind) {
    UploadErrorKind.couldNotRead => l.uploadErrCouldNotRead(f),
    UploadErrorKind.empty => l.uploadErrEmpty(f),
    UploadErrorKind.tooLargeClient =>
      l.uploadErrTooLarge(f, e.detail ?? ''),
    UploadErrorKind.unsupportedType =>
      l.uploadErrUnsupported(f, e.detail ?? ''),
    UploadErrorKind.corrupted400 => l.uploadErrCorrupted(f),
    UploadErrorKind.sessionExpired => l.uploadErrSession,
    UploadErrorKind.planLimit => l.uploadErrPlanLimit,
    UploadErrorKind.noPermission => l.uploadErrNoPermission,
    UploadErrorKind.duplicate => l.uploadErrDuplicate(
        f, e.detail ?? l.uploadExistingFileFallback, l.mascotName),
    UploadErrorKind.similar => l.uploadErrSimilar(
        f, e.detail ?? l.uploadExistingNotesFallback, l.mascotName),
    UploadErrorKind.tooLarge413 => l.uploadErrTooLarge413(f),
    UploadErrorKind.unsupported415 => l.uploadErrUnsupported415(f),
    UploadErrorKind.tooMany => l.uploadErrTooMany,
    UploadErrorKind.processing500 => l.uploadErrProcessing(f),
    UploadErrorKind.serverBusy502 => l.uploadErrServerBusy(f),
    UploadErrorKind.mochiBusy503 => l.uploadErrMochiBusy(l.mascotName),
    UploadErrorKind.stillWorking504 => l.uploadErrStillWorking(l.mascotName),
    UploadErrorKind.timeout => l.uploadErrTimeout(f),
    UploadErrorKind.noInternet => l.uploadErrNoInternet,
    UploadErrorKind.failed => l.uploadErrFailed(f),
    UploadErrorKind.unexpected => l.uploadErrUnexpected(f),
    UploadErrorKind.serverMessage => e.detail ?? l.uploadErrFailed(f),
  };
}

String localizedUploadWarning(AppLocalizations l, UploadWarningKind kind) =>
    switch (kind) {
      UploadWarningKind.backupReader => l.uploadWarnBackup,
      UploadWarningKind.lowText => l.uploadWarnLowText,
    };

String localizedUploadEstimate(AppLocalizations l, UploadEstimate est) =>
    switch (est) {
      UploadEstimate.short => l.uploadEstShort,
      UploadEstimate.medium => l.uploadEstMedium,
      UploadEstimate.long => l.uploadEstLong,
    };
