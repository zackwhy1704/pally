import 'package:pally/l10n/app_localizations.dart';
import 'package:pally/features/account_deletion/application/delete_account_view_model.dart';

/// Resolves a typed [DeleteAccountError] to wording at RENDER time (PR-G3
/// layering). serverMessage is the backend guard's own copy (401/409) or the
/// shared PallyError mapping — passed through verbatim.
String localizedDeleteAccountError(AppLocalizations l, DeleteAccountError e) =>
    switch (e.kind) {
      DeleteAccountErrorKind.enterCredential =>
        l.deleteAccountErrEnterCredential,
      DeleteAccountErrorKind.serverMessage =>
        e.detail ?? l.deleteAccountErrEnterCredential,
    };
