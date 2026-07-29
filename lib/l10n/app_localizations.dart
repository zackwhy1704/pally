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

  /// Generic loading placeholder (keep the ellipsis …).
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get commonLoading;

  /// Generic error toast fallback.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get commonSomethingWrong;

  /// Error toast when the chat tab can't load the avatar list. Keep 'Mochis'.
  ///
  /// In en, this message translates to:
  /// **'Could not load Mochis.'**
  String get chatCouldNotLoadMochis;

  /// Empty-state subtitle on the chat tab. Keep 'Mochi'.
  ///
  /// In en, this message translates to:
  /// **'Create a Mochi from the Home tab first.'**
  String get chatCreateMochiFirst;

  /// Subtitle under a centre-class avatar name in the chat header.
  ///
  /// In en, this message translates to:
  /// **'Centre-curated answers only'**
  String get chatCentreCuratedOnly;

  /// Chat overflow-menu item — go to Teach. Keep 'Mochi'.
  ///
  /// In en, this message translates to:
  /// **'Teach Mochi'**
  String get chatMenuTeach;

  /// Chat overflow-menu item — upload material.
  ///
  /// In en, this message translates to:
  /// **'Add knowledge'**
  String get chatMenuAddKnowledge;

  /// Chat overflow-menu item — delete the avatar. Keep 'Mochi'.
  ///
  /// In en, this message translates to:
  /// **'Delete Mochi'**
  String get chatMenuDelete;

  /// Fallback shown when a chat reply errors out (Mochi speaking).
  ///
  /// In en, this message translates to:
  /// **'Hmm, I lost my train of thought. Ask me again!'**
  String get chatLostTrain;

  /// Status on a message that failed to send; tap retries.
  ///
  /// In en, this message translates to:
  /// **'Not synced — tap to retry'**
  String get chatNotSynced;

  /// Status on a message that is being sent (keep ellipsis).
  ///
  /// In en, this message translates to:
  /// **'Sending…'**
  String get chatSending;

  /// Banner when a free user hits the daily chat cap.
  ///
  /// In en, this message translates to:
  /// **'Daily chats done — come back tomorrow or go Premium.'**
  String get chatDailyDone;

  /// Banner counting a free user's remaining daily chat messages.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 message left today} other{{count} messages left today}}'**
  String chatMessagesLeftToday(int count);

  /// Chat text-field placeholder when sending is allowed (keep ellipsis).
  ///
  /// In en, this message translates to:
  /// **'Ask anything…'**
  String get chatInputHint;

  /// Chat text-field placeholder while a reply is streaming (keep ellipsis).
  ///
  /// In en, this message translates to:
  /// **'Please wait…'**
  String get chatInputHintWait;

  /// Camera button label — snap a homework photo.
  ///
  /// In en, this message translates to:
  /// **'Snap'**
  String get chatSnap;

  /// Empty chat placeholder title.
  ///
  /// In en, this message translates to:
  /// **'Start the conversation!'**
  String get chatEmptyTitle;

  /// Empty chat placeholder subtitle. Keep 'Mochi' and the 📷 emoji.
  ///
  /// In en, this message translates to:
  /// **'Ask your Mochi anything, or tap 📷 to snap a homework question!'**
  String get chatEmptySubtitle;

  /// Daily chat disclaimer banner. Keep 'Mochi'.
  ///
  /// In en, this message translates to:
  /// **'Mochi can make mistakes — always double-check your work!'**
  String get chatDisclaimer;

  /// Tip shown on a numeric answer.
  ///
  /// In en, this message translates to:
  /// **'Double-check the numbers against your worksheet'**
  String get chatDoubleCheckNumbers;

  /// Badge indicating an answer was verified by the calculator.
  ///
  /// In en, this message translates to:
  /// **'checked with calculator'**
  String get chatCheckedWithCalculator;

  /// Generic reconnect hint under an error.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again.'**
  String get commonCheckConnection;

  /// Tooltip on the homework icon in the module list app bar.
  ///
  /// In en, this message translates to:
  /// **'Homework'**
  String get moduleHomeworkTooltip;

  /// Error title when the module list fails to load.
  ///
  /// In en, this message translates to:
  /// **'Could not load modules.'**
  String get moduleCouldNotLoad;

  /// Inline error when a build is attempted with no notes.
  ///
  /// In en, this message translates to:
  /// **'No notes to build lessons from yet.'**
  String get moduleNoNotesToBuild;

  /// Inline error when lesson generation fails.
  ///
  /// In en, this message translates to:
  /// **'Could not build lessons. Check your connection and try again.'**
  String get moduleBuildFailed;

  /// Empty-state title on the module list.
  ///
  /// In en, this message translates to:
  /// **'No lessons yet'**
  String get moduleNoLessonsYet;

  /// Empty-state body for a centre-class avatar (has materials).
  ///
  /// In en, this message translates to:
  /// **'Generate lessons from your class materials.'**
  String get moduleGenerateFromMaterials;

  /// Empty-state body for a personal avatar that has notes.
  ///
  /// In en, this message translates to:
  /// **'Your notes are in — let\'s build your first lesson.'**
  String get moduleNotesInBuildFirst;

  /// Primary button (centre) to generate lessons.
  ///
  /// In en, this message translates to:
  /// **'Generate lessons'**
  String get moduleGenerateLessons;

  /// Primary button (personal) to build the first lesson.
  ///
  /// In en, this message translates to:
  /// **'Build my first lesson'**
  String get moduleBuildFirstLesson;

  /// No-notes empty-state body for a personal avatar.
  ///
  /// In en, this message translates to:
  /// **'Add your notes and I\'ll build your first lesson from them.'**
  String get moduleAddNotesCta;

  /// Stage badge — the LEARN stage of the loop.
  ///
  /// In en, this message translates to:
  /// **'LEARN'**
  String get moduleStageLearn;

  /// Stage badge — the TEST stage.
  ///
  /// In en, this message translates to:
  /// **'TEST'**
  String get moduleStageTest;

  /// Stage badge — the PROVE stage.
  ///
  /// In en, this message translates to:
  /// **'PROVE'**
  String get moduleStageProve;

  /// Stage badge — a completed module.
  ///
  /// In en, this message translates to:
  /// **'COMPLETE'**
  String get moduleStageComplete;

  /// Module row CTA when the module is COMPLETE.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get moduleCtaReview;

  /// Module row CTA when the module is at the LEARN stage.
  ///
  /// In en, this message translates to:
  /// **'Start learning'**
  String get moduleCtaStartLearning;

  /// Module row CTA for an in-progress module.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get moduleCtaContinue;

  /// Badge on a teacher-reviewed module in the player.
  ///
  /// In en, this message translates to:
  /// **'Teacher-reviewed'**
  String get moduleTeacherReviewed;

  /// Friendly card shown when a module is recompiling. Keep 'Mochi'.
  ///
  /// In en, this message translates to:
  /// **'Mochi is refreshing this lesson — check back soon.'**
  String get moduleRefreshing;

  /// Button on the refreshing card, returns to the Library.
  ///
  /// In en, this message translates to:
  /// **'Go to Library'**
  String get moduleGoToLibrary;

  /// Fallback for an unrecognized module stage.
  ///
  /// In en, this message translates to:
  /// **'Unknown stage'**
  String get moduleUnknownStage;

  /// Header for the confidence self-rating on a quiz question.
  ///
  /// In en, this message translates to:
  /// **'Confidence'**
  String get quizConfidence;

  /// Error message on the quiz screen.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong — try again.'**
  String get quizErrorRetry;

  /// Button on the last quiz question.
  ///
  /// In en, this message translates to:
  /// **'Finish Quiz'**
  String get quizFinish;

  /// Button to advance to the next quiz question.
  ///
  /// In en, this message translates to:
  /// **'Next Question'**
  String get quizNextQuestion;

  /// Targeting badge shown when a question revisits a weak concept.
  ///
  /// In en, this message translates to:
  /// **'Reviewing your weak spot: {concept}.'**
  String quizReviewingWeakSpot(String concept);

  /// Note shown after answering, before the reveal.
  ///
  /// In en, this message translates to:
  /// **'Answer locked in — you\'ll see your results at the end.'**
  String get quizAnswerLocked;

  /// Verdict when the answer is right.
  ///
  /// In en, this message translates to:
  /// **'Correct!'**
  String get quizCorrect;

  /// Verdict when the answer is wrong.
  ///
  /// In en, this message translates to:
  /// **'Not quite'**
  String get quizNotQuite;

  /// Quiz results summary line.
  ///
  /// In en, this message translates to:
  /// **'You got {score} out of {total} correct.'**
  String quizScoreResult(int score, int total);

  /// Title on the quiz results screen.
  ///
  /// In en, this message translates to:
  /// **'Quiz Complete!'**
  String get quizComplete;

  /// Button returning from quiz results. Keep 'Mochi'.
  ///
  /// In en, this message translates to:
  /// **'Back to Mochi'**
  String get quizBackToMochi;

  /// Shows the correct option after reveal.
  ///
  /// In en, this message translates to:
  /// **'Answer: {answer}'**
  String quizAnswerLabel(String answer);

  /// Prompt for the confidence self-rating.
  ///
  /// In en, this message translates to:
  /// **'How sure are you?'**
  String get quizHowSure;

  /// Confidence option — low.
  ///
  /// In en, this message translates to:
  /// **'Not sure'**
  String get quizConfNotSure;

  /// Confidence option — medium.
  ///
  /// In en, this message translates to:
  /// **'Kinda'**
  String get quizConfKinda;

  /// Confidence option — high.
  ///
  /// In en, this message translates to:
  /// **'Very sure'**
  String get quizConfVerySure;

  /// Result matrix cell — correct + confident.
  ///
  /// In en, this message translates to:
  /// **'Mastered'**
  String get quizResultMastered;

  /// Result matrix cell — wrong + confident.
  ///
  /// In en, this message translates to:
  /// **'Misconception'**
  String get quizResultMisconception;

  /// Result matrix cell — correct + unsure.
  ///
  /// In en, this message translates to:
  /// **'Lucky guess'**
  String get quizResultLuckyGuess;

  /// Result matrix cell — wrong + unsure.
  ///
  /// In en, this message translates to:
  /// **'Known gap'**
  String get quizResultKnownGap;

  /// Priority-review pointer on the results screen.
  ///
  /// In en, this message translates to:
  /// **'Focus next: {topic}'**
  String quizFocusNext(String topic);

  /// Re-teach nudge naming one tricky concept.
  ///
  /// In en, this message translates to:
  /// **'I noticed {display} is tricky for you — I\'ll bring it back soon.'**
  String quizTrickyOne(String display);

  /// Re-teach nudge for multiple tricky topics.
  ///
  /// In en, this message translates to:
  /// **'I noticed some topics were tricky — I\'ll bring them back soon.'**
  String get quizTrickySome;

  /// Loading message while the quiz is generated (keep ellipsis).
  ///
  /// In en, this message translates to:
  /// **'Building your quiz…'**
  String get quizBuilding;

  /// Empty-state title when no quiz is available.
  ///
  /// In en, this message translates to:
  /// **'No quiz today'**
  String get quizNoQuizToday;

  /// Empty-state body prompting an upload. Keep 'Mochi'.
  ///
  /// In en, this message translates to:
  /// **'Upload some notes so Mochi can build your first quiz!'**
  String get quizUploadNotesCta;

  /// Bottom-nav tab: Home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// Bottom-nav tab: Library.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get navLibrary;

  /// Bottom-nav tab: Groups.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get navGroups;

  /// Bottom-nav tab: Me (profile/settings).
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get navMe;

  /// Home greeting heading. Keep the emoji.
  ///
  /// In en, this message translates to:
  /// **'Welcome back! 👋'**
  String get homeWelcomeBack;

  /// Home greeting subtitle.
  ///
  /// In en, this message translates to:
  /// **'Ready to keep learning?'**
  String get homeReadyToLearn;

  /// Button to create a new avatar. Keep 'Mochi'.
  ///
  /// In en, this message translates to:
  /// **'New Mochi'**
  String get homeNewMochi;

  /// Home section header for centre-class avatars.
  ///
  /// In en, this message translates to:
  /// **'MY CLASSES'**
  String get homeSectionMyClasses;

  /// Home section header for personal avatars. Keep 'Mochis'.
  ///
  /// In en, this message translates to:
  /// **'YOUR MOCHIS'**
  String get homeSectionYourMochis;

  /// Level badge in the home header. Keep the star.
  ///
  /// In en, this message translates to:
  /// **'⭐ Level {level}'**
  String homeLevelBadge(int level);

  /// XP bar label at the max level. Keep the star.
  ///
  /// In en, this message translates to:
  /// **'MAX LEVEL ⭐'**
  String get homeMaxLevel;

  /// XP progress toward the next level.
  ///
  /// In en, this message translates to:
  /// **'{xpInto} / {xpSpan} XP'**
  String homeXpProgress(int xpInto, int xpSpan);

  /// Error toast when the avatar list fails to load. Keep 'Mochis'.
  ///
  /// In en, this message translates to:
  /// **'Could not load Mochis. Pull down to retry.'**
  String get homeCouldNotLoadMochis;

  /// Error title on home. Keep 'Mochis'.
  ///
  /// In en, this message translates to:
  /// **'Could not load your Mochis.'**
  String get homeCouldNotLoadYourMochis;

  /// Error body on home.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and pull down to retry.'**
  String get homeCheckConnectionPull;

  /// Under-13 consent-pending message on home. Keep 'Mochi'.
  ///
  /// In en, this message translates to:
  /// **'Ask a grown-up to approve your account to make a Mochi.'**
  String get homeConsentApprove;

  /// Button to resend the parental consent email.
  ///
  /// In en, this message translates to:
  /// **'Resend email'**
  String get homeResendEmail;

  /// Collapsed consent-banner chip on home.
  ///
  /// In en, this message translates to:
  /// **'Awaiting parental approval — tap for options'**
  String get homeConsentCollapsedChip;

  /// Consent-banner title on home.
  ///
  /// In en, this message translates to:
  /// **'Waiting for parental approval'**
  String get homeConsentWaitingTitle;

  /// Consent-banner body naming the masked parent email.
  ///
  /// In en, this message translates to:
  /// **'A consent email was sent to {email}. AI features unlock once your parent approves.'**
  String homeConsentEmailSent(String email);

  /// Sign-out link in the consent banner.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get homeConsentSignOut;

  /// Avatar long-press sheet action.
  ///
  /// In en, this message translates to:
  /// **'Manage knowledge'**
  String get homeManageKnowledge;

  /// Error when activating a Mochi fails.
  ///
  /// In en, this message translates to:
  /// **'Could not activate — try again.'**
  String get homeCouldNotActivate;

  /// Title of the slot-locked sheet, naming the Mochi.
  ///
  /// In en, this message translates to:
  /// **'{name} is locked'**
  String homeMochiLocked(String name);

  /// Inconsistent-state message in the activate dialog. Keep 'Mochi'.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong — this Mochi should be active. Pull to refresh.'**
  String get homeActivateError;

  /// Free-plan active-Mochi cap explanation. Keep 'Mochi'/'Mochis' and the blank line.
  ///
  /// In en, this message translates to:
  /// **'{cap, plural, =1{You have 1 active Mochi on your free plan. Deactivate another Mochi first, then activate this one.\n\nYou can swap once every 24 hours.} other{You have {cap} active Mochis on your free plan. Deactivate another Mochi first, then activate this one.\n\nYou can swap once every 24 hours.}}'**
  String homeActivateCapMessage(int cap);

  /// Button label while activating (keep ellipsis).
  ///
  /// In en, this message translates to:
  /// **'Activating…'**
  String get homeActivating;

  /// Activate button naming the Mochi.
  ///
  /// In en, this message translates to:
  /// **'Activate {name}'**
  String homeActivateAvatar(String name);

  /// Close button on the activate dialog.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get homeClose;

  /// Default nudge — flashcards due.
  ///
  /// In en, this message translates to:
  /// **'You have flashcards due today!'**
  String get homeNudgeFlashcards;

  /// Default nudge — streak.
  ///
  /// In en, this message translates to:
  /// **'Keep your streak going!'**
  String get homeNudgeStreak;

  /// Prefilled chat message from a weak-concept nudge.
  ///
  /// In en, this message translates to:
  /// **'Can we review {concept}? I keep getting it wrong'**
  String homeReteachMessage(String concept);

  /// Fallback for {concept} in homeReteachMessage when the concept is unknown ('review this').
  ///
  /// In en, this message translates to:
  /// **'this'**
  String get homeReteachThis;

  /// Home banner header above the in-progress module.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE LEARNING'**
  String get homeContinueLearning;

  /// Due-cards banner count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 flashcard due} other{{count} flashcards due}}'**
  String homeFlashcardsDue(int count);

  /// Due-cards banner CTA naming the Mochi.
  ///
  /// In en, this message translates to:
  /// **'Start with {name} — 2-min review'**
  String homeStartReview(String name);

  /// Home assignment-banner header.
  ///
  /// In en, this message translates to:
  /// **'ASSIGNMENTS'**
  String get homeAssignments;

  /// Assignment status chip — overdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get homeAssignmentOverdue;

  /// Assignment due date.
  ///
  /// In en, this message translates to:
  /// **'Due: {date}'**
  String homeAssignmentDue(String date);

  /// Assignment kind.
  ///
  /// In en, this message translates to:
  /// **'Pre-class'**
  String get homeAssignmentPreClass;

  /// Assignment kind.
  ///
  /// In en, this message translates to:
  /// **'Post-class'**
  String get homeAssignmentPostClass;

  /// Assignment kind.
  ///
  /// In en, this message translates to:
  /// **'Revision'**
  String get homeAssignmentRevision;

  /// Assignment kind.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get homeAssignmentCustom;

  /// New-user empty home greeting.
  ///
  /// In en, this message translates to:
  /// **'Hi {name}! 👋'**
  String homeEmptyHi(String name);

  /// New-user empty home subtitle. Keep 'Mochi'.
  ///
  /// In en, this message translates to:
  /// **'Let\'s set up your first Mochi'**
  String get homeEmptySetupFirst;

  /// Empty home card title. Keep 'Mochis'.
  ///
  /// In en, this message translates to:
  /// **'No Mochis yet!'**
  String get homeEmptyNoMochis;

  /// Empty home card body. Keep 'Mochi' + emoji.
  ///
  /// In en, this message translates to:
  /// **'Create your first Mochi and start learning something amazing 🚀'**
  String get homeEmptyCreate;

  /// Empty home hint line.
  ///
  /// In en, this message translates to:
  /// **'Pick a buddy, teach it your notes, ask it anything!'**
  String get homeEmptyPickBuddy;

  /// Empty home primary CTA. Keep 'Mochi' + emoji.
  ///
  /// In en, this message translates to:
  /// **'+ Create My First Mochi ✨'**
  String get homeEmptyCreateButton;

  /// Empty home secondary CTA to redeem a class code. Keep the emoji + spacing.
  ///
  /// In en, this message translates to:
  /// **'🎟️  Have a code? Enter or scan it'**
  String get homeEmptyHaveCode;

  /// Empty home feature chip. Keep the emoji.
  ///
  /// In en, this message translates to:
  /// **'🧠 Learn from your notes'**
  String get homeEmptyChipLearn;

  /// Empty home feature chip. Keep the emoji.
  ///
  /// In en, this message translates to:
  /// **'💬 Ask any question'**
  String get homeEmptyChipAsk;

  /// Empty home feature chip. Keep the emoji and 'XP'.
  ///
  /// In en, this message translates to:
  /// **'⭐ Earn XP & rewards'**
  String get homeEmptyChipEarn;
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
