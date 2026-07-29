import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh')
  ];

  /// Settings row label and the title of the language-picker sheet. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Shown under the title in the language picker. States that the UI language (a person's preferred_locale) is separate from the avatar's teaching/content language, so switching the UI does not re-translate existing lessons. 'Mochi' is the mascot name and must NOT be translated.
  ///
  /// In en, this message translates to:
  /// **'Choose the language for the app\'s buttons and menus. This does not change the language your Mochi teaches in.'**
  String get languagePickerSubtitle;

  /// Greeting heading at the top of the sign-in form. Keep the waving-hand emoji.
  ///
  /// In en, this message translates to:
  /// **'Welcome back! 👋'**
  String get signInWelcomeBack;

  /// Field label above the email input on the sign-in screen.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get signInEmailLabel;

  /// Placeholder text inside the email input (an example address). Also used in the forgot-password dialog.
  ///
  /// In en, this message translates to:
  /// **'your@email.com'**
  String get signInEmailHint;

  /// Field label above the password input on the sign-in screen.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get signInPasswordLabel;

  /// Link below the password field that opens the reset-password dialog.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get signInForgotPassword;

  /// Primary button that submits the sign-in form.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signInButton;

  /// Divider label between password sign-in and biometric sign-in.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get signInOr;

  /// Label on the biometric sign-in button.
  ///
  /// In en, this message translates to:
  /// **'Use Biometrics'**
  String get signInUseBiometrics;

  /// Sub-label under the biometric button naming the platform methods. 'Face ID' and 'Touch ID' are Apple product names — keep them in English.
  ///
  /// In en, this message translates to:
  /// **'Face ID / Touch ID'**
  String get signInFaceTouchId;

  /// Hint shown when biometrics are supported but not yet registered for this account.
  ///
  /// In en, this message translates to:
  /// **'Sign in once to enable biometric login'**
  String get signInEnableBiometricHint;

  /// Prompt in the pinned footer, before the Create Account button.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get signInNoAccount;

  /// Footer button that goes to the sign-up flow. Keep the sparkles emoji.
  ///
  /// In en, this message translates to:
  /// **'Create Account ✨'**
  String get signInCreateAccount;

  /// The system biometric prompt's reason string. 'Apalchi' is the product name — keep it.
  ///
  /// In en, this message translates to:
  /// **'Sign in to Apalchi'**
  String get signInBiometricReason;

  /// Error shown when the user submits sign-in with an empty email or password.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email and password'**
  String get signInErrorEmptyCredentials;

  /// Error shown when biometric sign-in is tapped on a device without biometric hardware/support.
  ///
  /// In en, this message translates to:
  /// **'Biometrics not available on this device'**
  String get signInErrorBiometricsUnavailable;

  /// Error shown when biometric sign-in is tapped but no biometric credential is registered yet.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your password first — biometrics will be enabled in Settings'**
  String get signInErrorBiometricsNotRegistered;

  /// Error shown when biometric sign-in has no prior signed-in user to verify against.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your password first'**
  String get signInErrorPasswordFirst;

  /// Biometric sheet title while waiting for the fingerprint/face scan.
  ///
  /// In en, this message translates to:
  /// **'Scanning...'**
  String get biometricScanning;

  /// Biometric sheet title on a successful scan. Keep the sparkles emoji.
  ///
  /// In en, this message translates to:
  /// **'Verified! ✨'**
  String get biometricVerified;

  /// Biometric sheet title when the scan fails.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t verify'**
  String get biometricCouldntVerify;

  /// Biometric sheet subtitle while scanning.
  ///
  /// In en, this message translates to:
  /// **'Place your finger or look at your camera'**
  String get biometricScanningHint;

  /// Biometric sheet subtitle after a successful scan, while completing sign-in.
  ///
  /// In en, this message translates to:
  /// **'Signing you in...'**
  String get biometricSigningIn;

  /// Biometric sheet subtitle when the scan fails.
  ///
  /// In en, this message translates to:
  /// **'Face or fingerprint not recognised'**
  String get biometricNotRecognised;

  /// Biometric sheet button to fall back to password sign-in.
  ///
  /// In en, this message translates to:
  /// **'Use password instead'**
  String get biometricUsePassword;

  /// Generic retry button (biometric failure).
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get commonTryAgain;

  /// Generic cancel button (biometric sheet, dialogs).
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// Title of the reset-password dialog.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get forgotPasswordTitle;

  /// Button in the reset-password dialog that sends the reset email.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get forgotPasswordSend;

  /// Confirmation snackbar after a reset link is sent.
  ///
  /// In en, this message translates to:
  /// **'Check your email for a reset link'**
  String get forgotPasswordSent;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
