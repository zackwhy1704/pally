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

  /// Progress indicator under the dots on the onboarding carousel, e.g. '1 of 3'.
  ///
  /// In en, this message translates to:
  /// **'{current} of {total}'**
  String onboardingPageProgress(int current, int total);

  /// Advance button on onboarding carousel pages 1 and 2. Keep the arrow.
  ///
  /// In en, this message translates to:
  /// **'Next →'**
  String get onboardingNext;

  /// Final onboarding button that finishes the tour. Keep the arrow.
  ///
  /// In en, this message translates to:
  /// **'Let\'s go →'**
  String get onboardingLetsGo;

  /// Onboarding page 1 heading. Mochi speaks in first person.
  ///
  /// In en, this message translates to:
  /// **'I learn from your material — not the whole internet.'**
  String get onboardingPage1Title;

  /// Onboarding page 1 body paragraph.
  ///
  /// In en, this message translates to:
  /// **'Upload your notes, slides, or lecture decks and I build a brain around exactly what you\'re studying — for a quiz, a final, a module, or just to get it.'**
  String get onboardingPage1Body;

  /// Onboarding page 1, positive example row title.
  ///
  /// In en, this message translates to:
  /// **'Your notes & slides'**
  String get onboardingContrastOk1Title;

  /// Onboarding page 1, positive example row subtitle.
  ///
  /// In en, this message translates to:
  /// **'I learn exactly what you\'re covering'**
  String get onboardingContrastOk1Sub;

  /// Onboarding page 1, second positive example row title.
  ///
  /// In en, this message translates to:
  /// **'Your lecture decks & readings'**
  String get onboardingContrastOk2Title;

  /// Onboarding page 1, second positive example row subtitle.
  ///
  /// In en, this message translates to:
  /// **'Same source material, sharper answers'**
  String get onboardingContrastOk2Sub;

  /// Onboarding page 1, negative example row title.
  ///
  /// In en, this message translates to:
  /// **'Random internet articles'**
  String get onboardingContrastBadTitle;

  /// Onboarding page 1, negative example row subtitle.
  ///
  /// In en, this message translates to:
  /// **'Generic info that might not match your course'**
  String get onboardingContrastBadSub;

  /// Onboarding page 2 heading.
  ///
  /// In en, this message translates to:
  /// **'Give me one subject at a time — I go deep.'**
  String get onboardingPage2Title;

  /// Onboarding page 2 body. 'Mochi' is the mascot name — do NOT translate. 'Sec 3' is a Singapore school level.
  ///
  /// In en, this message translates to:
  /// **'Make a separate Mochi for each subject or module. Each one only knows its stuff, so the answers stay sharp — whether it\'s Sec 3 Chemistry or a uni economics module.'**
  String get onboardingPage2Body;

  /// Onboarding page 2, positive card title. Keep 'Mochi'.
  ///
  /// In en, this message translates to:
  /// **'One subject per Mochi'**
  String get onboardingFocusOkTitle;

  /// Onboarding page 2, positive card subtitle.
  ///
  /// In en, this message translates to:
  /// **'Deep, accurate answers for that course'**
  String get onboardingFocusOkSub;

  /// Onboarding page 2, negative card title. Keep 'Mochi'.
  ///
  /// In en, this message translates to:
  /// **'Everything in one Mochi'**
  String get onboardingFocusBadTitle;

  /// Onboarding page 2, negative card subtitle.
  ///
  /// In en, this message translates to:
  /// **'Mixed knowledge = muddled answers'**
  String get onboardingFocusBadSub;

  /// Onboarding page 3 heading.
  ///
  /// In en, this message translates to:
  /// **'I remember how you learn.'**
  String get onboardingPage3Title;

  /// Onboarding page 3 body.
  ///
  /// In en, this message translates to:
  /// **'When you get something wrong, I notice — and I bring it back until it clicks. The more we study, the better I fit you.'**
  String get onboardingPage3Body;

  /// Onboarding page 3, memory beat 1.
  ///
  /// In en, this message translates to:
  /// **'Tricky topics come back until they stick'**
  String get onboardingBeat1;

  /// Onboarding page 3, memory beat 2.
  ///
  /// In en, this message translates to:
  /// **'Easy things get spaced out — no time wasted'**
  String get onboardingBeat2;

  /// Onboarding page 3, memory beat 3.
  ///
  /// In en, this message translates to:
  /// **'The more you study, the better it fits you'**
  String get onboardingBeat3;

  /// Onboarding page 3 closing positioning quote (italic). Keep 'Mochi'; keep the curly quotes.
  ///
  /// In en, this message translates to:
  /// **'“Not a generic AI — a Mochi that knows your notes.”'**
  String get onboardingThesis;

  /// Library screen app-bar title (the home hub listing the student's Mochis).
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get libraryTitle;

  /// Section header above centre-class avatars in the library.
  ///
  /// In en, this message translates to:
  /// **'My classes'**
  String get libraryMyClasses;

  /// Swipe-action label to leave a centre class.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get libraryLeave;

  /// Swipe-action label to delete a personal Mochi.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get libraryDelete;

  /// Success toast after deleting a Mochi. {name} is the Mochi's name (not translated).
  ///
  /// In en, this message translates to:
  /// **'{name} deleted'**
  String libraryAvatarDeleted(String name);

  /// Error toast when deleting a Mochi fails.
  ///
  /// In en, this message translates to:
  /// **'Delete failed. Try again.'**
  String get libraryDeleteFailed;

  /// Confirmation dialog title for leaving a class.
  ///
  /// In en, this message translates to:
  /// **'Leave this class?'**
  String get libraryLeaveClassTitle;

  /// Confirmation dialog body for leaving a class. {name} is the class name. 'Mochi'/'Mochis' is the mascot name — do NOT translate.
  ///
  /// In en, this message translates to:
  /// **'You\'ll lose access to {name}\'s materials and class Mochi. Your personal Mochis stay. You can rejoin with the class code.'**
  String libraryLeaveClassBody(String name);

  /// Success toast after leaving a class. {name} is the class name.
  ///
  /// In en, this message translates to:
  /// **'Left {name}'**
  String libraryLeftClass(String name);

  /// Avatar row status while the brain is compiling. Keep the emoji + 'Mochi'.
  ///
  /// In en, this message translates to:
  /// **'📖 Mochi is reading your chapters…'**
  String get libraryStatusCompiling;

  /// Avatar row status showing how many wiki/brain pages exist. Keep the 🧠 emoji.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{🧠 {count} brain page} other{🧠 {count} brain pages}}'**
  String libraryStatusBrainPages(int count);

  /// Avatar row status while the brain is being built from uploaded files. Keep the ⏳ emoji and trailing ellipsis.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{⏳ Building brain from {count} file…} other{⏳ Building brain from {count} files…}}'**
  String libraryStatusBuilding(int count);

  /// Avatar row status when the Mochi has no uploaded material yet. Keep the 📂 emoji.
  ///
  /// In en, this message translates to:
  /// **'📂 No notes yet — teach me your material!'**
  String get libraryStatusNoNotes;

  /// Empty-library placeholder title. Keep 'Mochis'.
  ///
  /// In en, this message translates to:
  /// **'No Mochis yet'**
  String get libraryEmptyTitle;

  /// Empty-library placeholder subtitle. Keep 'Mochi'.
  ///
  /// In en, this message translates to:
  /// **'Create a Mochi from the Home tab to see it here.'**
  String get libraryEmptySubtitle;

  /// Avatar-hub hero card title — the LEARN stage (opens the module list).
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get hubLearn;

  /// Hero card subtitle when modules exist: module count + average mastery. The separator is a middle dot (·).
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} module · {mastery}% mastery} other{{count} modules · {mastery}% mastery}}'**
  String hubModulesSubtitle(int count, int mastery);

  /// Hero card subtitle when the avatar has no modules yet.
  ///
  /// In en, this message translates to:
  /// **'Start your first module'**
  String get hubStartFirstModule;

  /// Avatar-hub section header grouping Quiz + Cards.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get hubSectionPractice;

  /// Avatar-hub section header for the PROVE stage (Teach).
  ///
  /// In en, this message translates to:
  /// **'Prove it'**
  String get hubSectionProveIt;

  /// Avatar-hub section header grouping Chat / Notes / Upload.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get hubSectionTools;

  /// Hub row title — flashcards.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get hubCards;

  /// Hub row subtitle for Cards.
  ///
  /// In en, this message translates to:
  /// **'Quick recall practice'**
  String get hubCardsSubtitle;

  /// Hub row title — the Teach-back (PROVE) feature.
  ///
  /// In en, this message translates to:
  /// **'Teach'**
  String get hubTeach;

  /// Hub row subtitle for Teach. Keep 'Mochi'.
  ///
  /// In en, this message translates to:
  /// **'Explain it back to Mochi'**
  String get hubTeachSubtitle;

  /// Hub row title — chat with the Mochi.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get hubChat;

  /// Hub row subtitle for Chat. Keep 'Mochi'.
  ///
  /// In en, this message translates to:
  /// **'Ask Mochi anything'**
  String get hubChatSubtitle;

  /// Hub row title — view compiled notes/wiki.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get hubNotes;

  /// Hub row subtitle for Notes.
  ///
  /// In en, this message translates to:
  /// **'Review your material'**
  String get hubNotesSubtitle;

  /// Hub row title — upload more material.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get hubUpload;

  /// Hub row subtitle for Upload.
  ///
  /// In en, this message translates to:
  /// **'Add more material'**
  String get hubUploadSubtitle;

  /// Badge on a centre-class avatar in the hub header.
  ///
  /// In en, this message translates to:
  /// **'Class'**
  String get hubClassBadge;

  /// No-notes call-to-action description on the hub for a personal Mochi.
  ///
  /// In en, this message translates to:
  /// **'Upload your notes to unlock quizzes, cards and teaching.'**
  String get hubUploadNotesCta;

  /// Hub row title — the daily quiz.
  ///
  /// In en, this message translates to:
  /// **'Quiz'**
  String get hubQuiz;

  /// Quiz row subtitle, default state.
  ///
  /// In en, this message translates to:
  /// **'Test yourself with MCQs'**
  String get hubQuizSubtitleDefault;

  /// Quiz row subtitle when today's quiz is done. Separator is a middle dot (·).
  ///
  /// In en, this message translates to:
  /// **'Done today · free play anytime'**
  String get hubQuizSubtitleDoneToday;

  /// Quiz row subtitle showing mastery progress. Separator is a middle dot (·).
  ///
  /// In en, this message translates to:
  /// **'Test yourself · {mastered}/{total} mastered'**
  String hubQuizSubtitleMastered(int mastered, int total);
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
