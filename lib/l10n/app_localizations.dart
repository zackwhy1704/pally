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

  /// The mascot's display name. SINGLE SOURCE OF TRUTH — every user-facing reference to the mascot resolves through this via a {mascot} placeholder, never a literal. Renaming the mascot = editing this one value. en 'Mochi' / zh '小伴'.
  ///
  /// In en, this message translates to:
  /// **'Mochi'**
  String get mascotName;

  /// Settings row label and the title of the language-picker sheet. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Shown under the title in the language picker. States that the UI language (a person's preferred_locale) is separate from the avatar's teaching/content language, so switching the UI does not re-translate existing lessons. 'Mochi' is the mascot name and must NOT be translated.
  ///
  /// In en, this message translates to:
  /// **'Choose the language for the app\'s buttons and menus. This does not change the language your {mascot} teaches in.'**
  String languagePickerSubtitle(String mascot);

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
  /// **'Make a separate {mascot} for each subject or module. Each one only knows its stuff, so the answers stay sharp — whether it\'s Sec 3 Chemistry or a uni economics module.'**
  String onboardingPage2Body(String mascot);

  /// Onboarding page 2, positive card title. Keep 'Mochi'.
  ///
  /// In en, this message translates to:
  /// **'One subject per {mascot}'**
  String onboardingFocusOkTitle(String mascot);

  /// Onboarding page 2, positive card subtitle.
  ///
  /// In en, this message translates to:
  /// **'Deep, accurate answers for that course'**
  String get onboardingFocusOkSub;

  /// Onboarding page 2, negative card title. Keep 'Mochi'.
  ///
  /// In en, this message translates to:
  /// **'Everything in one {mascot}'**
  String onboardingFocusBadTitle(String mascot);

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
  /// **'“Not a generic AI — a {mascot} that knows your notes.”'**
  String onboardingThesis(String mascot);

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
  /// **'You\'ll lose access to {name}\'s materials and class {mascot}. Your personal {mascot}s stay. You can rejoin with the class code.'**
  String libraryLeaveClassBody(String name, String mascot);

  /// Success toast after leaving a class. {name} is the class name.
  ///
  /// In en, this message translates to:
  /// **'Left {name}'**
  String libraryLeftClass(String name);

  /// Avatar row status while the brain is compiling. Keep the emoji + 'Mochi'.
  ///
  /// In en, this message translates to:
  /// **'📖 {mascot} is reading your chapters…'**
  String libraryStatusCompiling(String mascot);

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
  /// **'No {mascot}s yet'**
  String libraryEmptyTitle(String mascot);

  /// Empty-library placeholder subtitle. Keep 'Mochi'.
  ///
  /// In en, this message translates to:
  /// **'Create a {mascot} from the Home tab to see it here.'**
  String libraryEmptySubtitle(String mascot);

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
  /// **'Explain it back to {mascot}'**
  String hubTeachSubtitle(String mascot);

  /// Hub row title — chat with the Mochi.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get hubChat;

  /// Hub row subtitle for Chat. Keep 'Mochi'.
  ///
  /// In en, this message translates to:
  /// **'Ask {mascot} anything'**
  String hubChatSubtitle(String mascot);

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
  /// **'Could not load {mascot}s.'**
  String chatCouldNotLoadMochis(String mascot);

  /// Empty-state subtitle on the chat tab. Keep 'Mochi'.
  ///
  /// In en, this message translates to:
  /// **'Create a {mascot} from the Home tab first.'**
  String chatCreateMochiFirst(String mascot);

  /// Subtitle under a centre-class avatar name in the chat header.
  ///
  /// In en, this message translates to:
  /// **'Centre-curated answers only'**
  String get chatCentreCuratedOnly;

  /// Chat overflow-menu item — go to Teach. Keep 'Mochi'.
  ///
  /// In en, this message translates to:
  /// **'Teach {mascot}'**
  String chatMenuTeach(String mascot);

  /// Chat overflow-menu item — upload material.
  ///
  /// In en, this message translates to:
  /// **'Add knowledge'**
  String get chatMenuAddKnowledge;

  /// Chat overflow-menu item — delete the avatar. Keep 'Mochi'.
  ///
  /// In en, this message translates to:
  /// **'Delete {mascot}'**
  String chatMenuDelete(String mascot);

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
  /// **'Ask your {mascot} anything, or tap 📷 to snap a homework question!'**
  String chatEmptySubtitle(String mascot);

  /// Daily chat disclaimer banner. Keep 'Mochi'.
  ///
  /// In en, this message translates to:
  /// **'{mascot} can make mistakes — always double-check your work!'**
  String chatDisclaimer(String mascot);

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
  /// **'{mascot} is refreshing this lesson — check back soon.'**
  String moduleRefreshing(String mascot);

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
  /// **'Back to {mascot}'**
  String quizBackToMochi(String mascot);

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
  /// **'Upload some notes so {mascot} can build your first quiz!'**
  String quizUploadNotesCta(String mascot);

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
  /// **'New {mascot}'**
  String homeNewMochi(String mascot);

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
  /// **'Could not load {mascot}s. Pull down to retry.'**
  String homeCouldNotLoadMochis(String mascot);

  /// Error title on home. Keep 'Mochis'.
  ///
  /// In en, this message translates to:
  /// **'Could not load your {mascot}s.'**
  String homeCouldNotLoadYourMochis(String mascot);

  /// Error body on home.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and pull down to retry.'**
  String get homeCheckConnectionPull;

  /// Under-13 consent-pending message on home. Keep 'Mochi'.
  ///
  /// In en, this message translates to:
  /// **'Ask a grown-up to approve your account to make a {mascot}.'**
  String homeConsentApprove(String mascot);

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
  /// **'Something went wrong — this {mascot} should be active. Pull to refresh.'**
  String homeActivateError(String mascot);

  /// Free-plan active-Mochi cap explanation. Keep 'Mochi'/'Mochis' and the blank line.
  ///
  /// In en, this message translates to:
  /// **'{cap, plural, =1{You have 1 active {mascot} on your free plan. Deactivate another {mascot} first, then activate this one.\n\nYou can swap once every 24 hours.} other{You have {cap} active {mascot}s on your free plan. Deactivate another {mascot} first, then activate this one.\n\nYou can swap once every 24 hours.}}'**
  String homeActivateCapMessage(int cap, String mascot);

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
  /// **'Let\'s set up your first {mascot}'**
  String homeEmptySetupFirst(String mascot);

  /// Empty home card title. Keep 'Mochis'.
  ///
  /// In en, this message translates to:
  /// **'No {mascot}s yet!'**
  String homeEmptyNoMochis(String mascot);

  /// Empty home card body. Keep 'Mochi' + emoji.
  ///
  /// In en, this message translates to:
  /// **'Create your first {mascot} and start learning something amazing 🚀'**
  String homeEmptyCreate(String mascot);

  /// Empty home hint line.
  ///
  /// In en, this message translates to:
  /// **'Pick a buddy, teach it your notes, ask it anything!'**
  String get homeEmptyPickBuddy;

  /// Empty home primary CTA. Keep 'Mochi' + emoji.
  ///
  /// In en, this message translates to:
  /// **'+ Create My First {mascot} ✨'**
  String homeEmptyCreateButton(String mascot);

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

  /// Advance to the next card in a LEARN/TEST module.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get moduleNext;

  /// Last-card CTA in a LEARN module → moves to TEST.
  ///
  /// In en, this message translates to:
  /// **'Ready to test yourself'**
  String get moduleReadyToTest;

  /// Last-card CTA in a TEST module → moves to PROVE.
  ///
  /// In en, this message translates to:
  /// **'Time to prove you understand'**
  String get moduleTimeToProve;

  /// LEARN card position indicator.
  ///
  /// In en, this message translates to:
  /// **'Card {cardNumber} of {total}'**
  String moduleCardOf(int cardNumber, int total);

  /// Fallback title for a LEARN card when the generated title is missing.
  ///
  /// In en, this message translates to:
  /// **'Card {n}'**
  String moduleCardFallback(int n);

  /// Header above the key-terms list on a LEARN card.
  ///
  /// In en, this message translates to:
  /// **'Key terms'**
  String get moduleKeyTerms;

  /// Header on the module-complete celebration screen.
  ///
  /// In en, this message translates to:
  /// **'Module complete!'**
  String get moduleComplete;

  /// XP-earned badge on module-complete. Keep the leading '+' and 'XP'.
  ///
  /// In en, this message translates to:
  /// **'+{xp} XP'**
  String moduleXpEarned(int xp);

  /// Label above the mastery meter on the module-complete screen.
  ///
  /// In en, this message translates to:
  /// **'Your mastery'**
  String get moduleYourMastery;

  /// Label for the weakest-concept callout on module-complete.
  ///
  /// In en, this message translates to:
  /// **'Focus area'**
  String get moduleFocusArea;

  /// Suggestion naming the weakest concept (concept is student material — keep it verbatim).
  ///
  /// In en, this message translates to:
  /// **'Review \"{concept}\" to improve your mastery.'**
  String moduleReviewToImprove(String concept);

  /// Button returning from module-complete to the module list.
  ///
  /// In en, this message translates to:
  /// **'Back to modules'**
  String get moduleBackToModules;

  /// Banner shown when a completed module is replayed in revision mode.
  ///
  /// In en, this message translates to:
  /// **'Revision mode — fresh questions to check your progress.'**
  String get moduleRevisionMode;

  /// Muddiest-point survey title, shown after PROVE.
  ///
  /// In en, this message translates to:
  /// **'Which part was hardest?'**
  String get moduleWhichHardest;

  /// Muddiest-point survey helper text.
  ///
  /// In en, this message translates to:
  /// **'Tap the one that felt the muddiest. This helps your tutor know what to review next.'**
  String get moduleMuddiestHint;

  /// Skip the muddiest-point survey.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get moduleSkip;

  /// Provenance chip. The title is the student's own wiki page — keep it verbatim.
  ///
  /// In en, this message translates to:
  /// **'From your notes: {title}'**
  String moduleFromYourNotes(String title);

  /// Weak-topic chip on a revisited card. Concept is student material — keep it verbatim.
  ///
  /// In en, this message translates to:
  /// **'That\'s a comeback — {concept} got you last time.'**
  String moduleComeback(String concept);

  /// PROVE-stage button submitting every written answer.
  ///
  /// In en, this message translates to:
  /// **'Submit all answers'**
  String get moduleSubmitAllAnswers;

  /// PROVE banner naming the targeted concept. Keep concept verbatim.
  ///
  /// In en, this message translates to:
  /// **'Focusing on {concept} — this tripped you up in the Test.'**
  String moduleFocusingOn(String concept);

  /// PROVE question position.
  ///
  /// In en, this message translates to:
  /// **'Question {number}'**
  String moduleQuestionNumber(int number);

  /// Placeholder in the PROVE free-text answer field. Keep the ellipsis.
  ///
  /// In en, this message translates to:
  /// **'Write your answer (1-3 sentences)...'**
  String get moduleAnswerHint;

  /// Self-assessment instructions. Keep 'Mochi'.
  ///
  /// In en, this message translates to:
  /// **'Compare what you wrote to the reference. Be honest — this just helps {mascot} learn what to revisit.'**
  String moduleCompareReference(String mascot);

  /// Self-assessment screen title.
  ///
  /// In en, this message translates to:
  /// **'Mark your own answers'**
  String get moduleMarkOwnAnswers;

  /// Self-assessment choice (Yes / Partly / No).
  ///
  /// In en, this message translates to:
  /// **'Partly'**
  String get modulePartly;

  /// Self-assessment choice (Yes / Partly / No).
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get moduleNo;

  /// Label above the student's own answer in self-assessment.
  ///
  /// In en, this message translates to:
  /// **'Your answer'**
  String get moduleYourAnswer;

  /// Label above the reference answer in self-assessment.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get moduleReference;

  /// Self-assessment prompt asking the student to self-grade.
  ///
  /// In en, this message translates to:
  /// **'Did you get it?'**
  String get moduleDidYouGetIt;

  /// Empty state when a TEST module has no cards.
  ///
  /// In en, this message translates to:
  /// **'No items'**
  String get moduleNoItems;

  /// HOT_TAKE card prompt.
  ///
  /// In en, this message translates to:
  /// **'True or False?'**
  String get moduleTrueOrFalse;

  /// HOT_TAKE agree button.
  ///
  /// In en, this message translates to:
  /// **'Agree'**
  String get moduleAgree;

  /// HOT_TAKE disagree button.
  ///
  /// In en, this message translates to:
  /// **'Disagree'**
  String get moduleDisagree;

  /// HOT_TAKE verdict-in-flight state. Keep the ellipsis.
  ///
  /// In en, this message translates to:
  /// **'Checking your answer…'**
  String get moduleCheckingAnswer;

  /// HOT_TAKE fallback when the verdict fetch fails; the answer is still saved.
  ///
  /// In en, this message translates to:
  /// **'Answer recorded — couldn\'t load feedback right now.'**
  String get moduleFeedbackUnavailable;

  /// SPOT_MISTAKE card title.
  ///
  /// In en, this message translates to:
  /// **'Spot the mistake'**
  String get moduleSpotTheMistake;

  /// SPOT_MISTAKE answer-field placeholder. Keep the ellipsis.
  ///
  /// In en, this message translates to:
  /// **'What\'s wrong here? Type what you spotted...'**
  String get moduleSpotHint;

  /// SPOT_MISTAKE button revealing the correct answer.
  ///
  /// In en, this message translates to:
  /// **'Reveal the error'**
  String get moduleRevealError;

  /// Label above the revealed error in SPOT_MISTAKE.
  ///
  /// In en, this message translates to:
  /// **'The error:'**
  String get moduleTheError;

  /// Label above the correct solution in SPOT_MISTAKE.
  ///
  /// In en, this message translates to:
  /// **'Correct solution:'**
  String get moduleCorrectSolution;

  /// SPOT_MISTAKE self-check prompt after the reveal.
  ///
  /// In en, this message translates to:
  /// **'Were you right?'**
  String get moduleWereYouRight;

  /// SPOT_MISTAKE self-check affirmative (paired with 'Not quite').
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get moduleYes;

  /// CHALLENGE card title.
  ///
  /// In en, this message translates to:
  /// **'Challenge'**
  String get moduleChallenge;

  /// CHALLENGE answer-field placeholder. Keep the ellipsis.
  ///
  /// In en, this message translates to:
  /// **'Type your answer...'**
  String get moduleTypeYourAnswer;

  /// CHALLENGE submit button.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get moduleSubmit;

  /// Label above the submitted answer in CHALLENGE (note trailing colon).
  ///
  /// In en, this message translates to:
  /// **'Your answer:'**
  String get moduleYourAnswerColon;

  /// Label above the explanation in CHALLENGE (note trailing colon).
  ///
  /// In en, this message translates to:
  /// **'Explanation:'**
  String get moduleExplanation;

  /// Button that reveals the answer on a short-answer TEST card.
  ///
  /// In en, this message translates to:
  /// **'Answer'**
  String get moduleAnswer;

  /// Settings screen app-bar title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Settings section header.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get settingsSectionSubscription;

  /// Settings section header.
  ///
  /// In en, this message translates to:
  /// **'Referral'**
  String get settingsSectionReferral;

  /// Settings section header.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get settingsSectionProfile;

  /// Settings section header.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsSectionNotifications;

  /// Settings section header.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get settingsSectionSecurity;

  /// Settings section header.
  ///
  /// In en, this message translates to:
  /// **'Learning'**
  String get settingsSectionLearning;

  /// Settings section header.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsSectionAbout;

  /// Settings section header.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsSectionAccount;

  /// Profile display-name field label.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get settingsDisplayName;

  /// Save the display name.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get settingsSave;

  /// Success toast after saving the name.
  ///
  /// In en, this message translates to:
  /// **'Name updated!'**
  String get settingsNameUpdated;

  /// Error toast when saving the name fails.
  ///
  /// In en, this message translates to:
  /// **'Could not save name — check your connection'**
  String get settingsNameSaveFailed;

  /// Notifications toggle for the daily quiz reminder.
  ///
  /// In en, this message translates to:
  /// **'Daily quiz reminder'**
  String get settingsDailyReminder;

  /// Row that opens the reminder time picker.
  ///
  /// In en, this message translates to:
  /// **'Reminder time'**
  String get settingsReminderTime;

  /// Security toggle for biometric login.
  ///
  /// In en, this message translates to:
  /// **'Biometric Login'**
  String get settingsBiometricLogin;

  /// Subtitle when biometrics aren't supported.
  ///
  /// In en, this message translates to:
  /// **'Not available on this device'**
  String get settingsBiometricUnavailable;

  /// OS biometric-prompt reason string.
  ///
  /// In en, this message translates to:
  /// **'Verify to enable biometric login'**
  String get settingsBiometricReason;

  /// Toast after enabling biometric login.
  ///
  /// In en, this message translates to:
  /// **'Biometric login enabled'**
  String get settingsBiometricEnabled;

  /// Toast when enabling biometric login fails.
  ///
  /// In en, this message translates to:
  /// **'Could not enable biometric login'**
  String get settingsBiometricEnableFailed;

  /// Toast after disabling biometric login.
  ///
  /// In en, this message translates to:
  /// **'Biometric login disabled'**
  String get settingsBiometricDisabled;

  /// Row opening the learning-style screen.
  ///
  /// In en, this message translates to:
  /// **'Learning style'**
  String get settingsLearningStyle;

  /// About row. Keep 'Apalchi'.
  ///
  /// In en, this message translates to:
  /// **'Why Apalchi is different'**
  String get settingsWhyDifferent;

  /// About row showing the app version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// About row link. Keep 'Apalchi'.
  ///
  /// In en, this message translates to:
  /// **'About Apalchi'**
  String get settingsAboutApalchi;

  /// About row link.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsPrivacyPolicy;

  /// About row link.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get settingsTermsOfService;

  /// About row link.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get settingsHelpSupport;

  /// About row opening the mail client.
  ///
  /// In en, this message translates to:
  /// **'Email us'**
  String get settingsEmailUs;

  /// Account row / confirm button to sign out.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get settingsSignOut;

  /// Account row opening the delete-account flow.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get settingsDeleteAccount;

  /// Sign-out confirmation dialog title.
  ///
  /// In en, this message translates to:
  /// **'Sign Out?'**
  String get settingsSignOutTitle;

  /// Sign-out confirmation dialog body.
  ///
  /// In en, this message translates to:
  /// **'You\'ll need to sign in again'**
  String get settingsSignOutBody;

  /// Subscription tile subtitle when the entitlement fails to load.
  ///
  /// In en, this message translates to:
  /// **'Could not load — tap to retry'**
  String get settingsSubLoadError;

  /// Premium-trial countdown. Keep the star and 'Premium Trial'.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{⭐ Premium Trial · 1 day left} other{⭐ Premium Trial · {days} days left}}'**
  String settingsPremiumTrialLeft(int days);

  /// Trial end date line.
  ///
  /// In en, this message translates to:
  /// **'Ends {date}'**
  String settingsEndsLabel(String date);

  /// COMPLIANCE (App Store 3.1.1): price variant shown ONLY where allowPriceDisplay(ref) is true. The translation must stay faithful and must NOT imply payment outside the app. Do not reword to add purchase steering. Keep 'Premium' and 'US$9.99/mo' as-is.
  ///
  /// In en, this message translates to:
  /// **'Keep Premium from US\$9.99/mo'**
  String get settingsKeepPremiumPrice;

  /// COMPLIANCE-adjacent: no-price variant shown where price display is gated off (iOS w/o entitlement). Keep 'Premium'; do not add a price or purchase steering.
  ///
  /// In en, this message translates to:
  /// **'Keep Premium'**
  String get settingsKeepPremium;

  /// Plan label for a parent-managed subscription.
  ///
  /// In en, this message translates to:
  /// **'Family plan — managed by parent'**
  String get settingsFamilyPlan;

  /// Plan label for a free user.
  ///
  /// In en, this message translates to:
  /// **'Free plan'**
  String get settingsFreePlan;

  /// Subtitle for a premium user. 'Manage' matches settingsManage.
  ///
  /// In en, this message translates to:
  /// **'Tap Manage to update billing or cancel.'**
  String get settingsPremiumManage;

  /// Subtitle for a free user. Keep 'Mochis'. Do NOT add a price (iOS anti-steering).
  ///
  /// In en, this message translates to:
  /// **'Unlock unlimited {mascot}s, chat, and family sharing.'**
  String settingsFreePlanSubtitle(String mascot);

  /// Button to manage an existing subscription.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get settingsManage;

  /// Button to upgrade from free. Do NOT append a price (iOS anti-steering).
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get settingsUpgrade;

  /// Toast when a child taps Manage on a parent-managed plan.
  ///
  /// In en, this message translates to:
  /// **'Your subscription is managed by the parent account.'**
  String get settingsManagedByParent;

  /// Referral row title.
  ///
  /// In en, this message translates to:
  /// **'Invite friends'**
  String get settingsInviteFriends;

  /// Referral row subtitle.
  ///
  /// In en, this message translates to:
  /// **'See your code, share it, track who joined.'**
  String get settingsInviteFriendsSubtitle;

  /// Redeem row title.
  ///
  /// In en, this message translates to:
  /// **'Have a referral code?'**
  String get settingsHaveReferralCode;

  /// Redeem row subtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter it to reward you and the friend who sent it.'**
  String get settingsHaveReferralCodeSubtitle;

  /// Redeem sheet title.
  ///
  /// In en, this message translates to:
  /// **'Enter referral code'**
  String get settingsEnterReferralCode;

  /// Redeem sheet body.
  ///
  /// In en, this message translates to:
  /// **'Share the reward with the friend who invited you.'**
  String get settingsShareReward;

  /// Validation error for a referral code of the wrong length.
  ///
  /// In en, this message translates to:
  /// **'Codes are 6 characters'**
  String get settingsCodes6Chars;

  /// Success toast after redeeming a referral code.
  ///
  /// In en, this message translates to:
  /// **'Code applied! Take a quiz to activate the reward.'**
  String get settingsCodeApplied;

  /// Redeem sheet submit button.
  ///
  /// In en, this message translates to:
  /// **'Apply code'**
  String get settingsApplyCode;

  /// Interstitial shown when a signed-in user starts sign-up.
  ///
  /// In en, this message translates to:
  /// **'You\'re signed in as {name}. Log out to create a new account?'**
  String signupSignedInAs(String name);

  /// Interstitial when signed in without a known name.
  ///
  /// In en, this message translates to:
  /// **'You\'re already signed in. Log out to create a new account?'**
  String get signupAlreadySignedIn;

  /// Interstitial heading.
  ///
  /// In en, this message translates to:
  /// **'Create a new account?'**
  String get signupCreateNewAccount;

  /// Interstitial confirm button.
  ///
  /// In en, this message translates to:
  /// **'Log out & continue'**
  String get signupLogOutContinue;

  /// Sign-up progress indicator (3-step flow).
  ///
  /// In en, this message translates to:
  /// **'Step {step} of 3'**
  String signupStepOf(int step);

  /// Validation snackbar when no age group is chosen.
  ///
  /// In en, this message translates to:
  /// **'Please select your age group to continue.'**
  String get signupSelectAgeGroup;

  /// Step 1 heading.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get signupCreateYourAccount;

  /// Step 1 subtitle. Keep 'Mochi'.
  ///
  /// In en, this message translates to:
  /// **'{mascot} will become your personal study buddy.'**
  String signupStudyBuddy(String mascot);

  /// Name field label.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get signupFieldName;

  /// Name field placeholder.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get signupHintYourName;

  /// Name validation error.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters'**
  String get signupValidatorName;

  /// Email field label.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get signupFieldEmail;

  /// Empty-email validation error.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get signupValidatorEmailEmpty;

  /// Invalid-email validation error. Keep the example address.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email (e.g. you@example.com)'**
  String get signupValidatorEmailInvalid;

  /// Password field label.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get signupFieldPassword;

  /// Password field placeholder.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get signupHintPassword;

  /// Password validation error.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get signupValidatorPassword;

  /// Age-group section label.
  ///
  /// In en, this message translates to:
  /// **'Age group'**
  String get signupAgeGroup;

  /// Age-group option.
  ///
  /// In en, this message translates to:
  /// **'I am 13 or older'**
  String get signupAge13OrOlder;

  /// Age-group option (triggers parental-consent flow).
  ///
  /// In en, this message translates to:
  /// **'I am under 13'**
  String get signupAgeUnder13;

  /// Parent email field label (under-13).
  ///
  /// In en, this message translates to:
  /// **'Parent\'s email address'**
  String get signupFieldParentEmail;

  /// Empty parent-email validation error.
  ///
  /// In en, this message translates to:
  /// **'Please enter your parent\'s email'**
  String get signupValidatorParentEmailEmpty;

  /// Invalid parent-email validation error. Keep the example.
  ///
  /// In en, this message translates to:
  /// **'Please enter your parent\'s valid email (e.g. parent@example.com)'**
  String get signupValidatorParentEmailInvalid;

  /// Under-13 parental-consent explanation.
  ///
  /// In en, this message translates to:
  /// **'We\'ll email your parent to approve your account before you can use AI features.'**
  String get signupParentApproval;

  /// Step 1 advance button.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get signupNext;

  /// Link to the sign-in screen.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get signupAlreadyHaveAccount;

  /// Step 2 heading.
  ///
  /// In en, this message translates to:
  /// **'What are you studying?'**
  String get signupWhatStudying;

  /// Step 2 subtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick one subject to start with. You can add more later.'**
  String get signupPickSubject;

  /// Subject picker label.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get signupSubject;

  /// Education-stage picker label.
  ///
  /// In en, this message translates to:
  /// **'Education stage'**
  String get signupEducationStage;

  /// Step 2 submit button (creates the account).
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get signupCreateAccount;

  /// Heading for the segmented-upload chapter picker.
  ///
  /// In en, this message translates to:
  /// **'Your book is split into chapters'**
  String get signupBookSplitChapters;

  /// Chapter-picker subtitle. Keep 'Mochi'.
  ///
  /// In en, this message translates to:
  /// **'Pick the chapters you want {mascot} to study first.'**
  String signupPickChapters(String mascot);

  /// Button opening the chapter picker.
  ///
  /// In en, this message translates to:
  /// **'Choose chapters'**
  String get signupChooseChapters;

  /// Step 3 upload heading.
  ///
  /// In en, this message translates to:
  /// **'Add your first notes'**
  String get signupAddFirstNotes;

  /// Step 3 upload subtitle. Keep 'Mochi'.
  ///
  /// In en, this message translates to:
  /// **'Type or paste your notes below. {mascot} will read them and build a study module for you.'**
  String signupNotesInstructions(String mascot);

  /// Notes text-field placeholder. Keep the ellipsis.
  ///
  /// In en, this message translates to:
  /// **'Paste or type your notes here...'**
  String get signupNotesHint;

  /// Character count under the notes field.
  ///
  /// In en, this message translates to:
  /// **'{count} chars'**
  String signupCharCount(int count);

  /// Character count when below the 50-char minimum.
  ///
  /// In en, this message translates to:
  /// **'{count} chars (min 50)'**
  String signupCharCountMin(int count);

  /// Submit typed notes. Keep 'Mochi'.
  ///
  /// In en, this message translates to:
  /// **'Add to {mascot}'**
  String signupAddToMochi(String mascot);

  /// Divider between typed notes and photo/file upload.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get signupOr;

  /// Secondary upload option (camera).
  ///
  /// In en, this message translates to:
  /// **'Or snap a photo'**
  String get signupSnapPhoto;

  /// Tertiary upload option (file picker).
  ///
  /// In en, this message translates to:
  /// **'Or choose a file'**
  String get signupChooseFile;

  /// Inline error when an upload fails.
  ///
  /// In en, this message translates to:
  /// **'Upload failed. Please try again.'**
  String get signupUploadFailed;

  /// Join-code capture on the upload step. Keep the emoji + spacing.
  ///
  /// In en, this message translates to:
  /// **'🎟️  Have a class or group code? Enter or scan it'**
  String get signupHaveCode;

  /// Skip the upload step.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get signupSkipForNow;

  /// Processing state: uploading. Keep the ellipsis.
  ///
  /// In en, this message translates to:
  /// **'Uploading your notes...'**
  String get signupUploading;

  /// Processing state: compiling. Keep 'Mochi' + ellipsis.
  ///
  /// In en, this message translates to:
  /// **'{mascot} is reading your notes...'**
  String signupReadingNotes(String mascot);

  /// Processing state: generating. Keep the ellipsis.
  ///
  /// In en, this message translates to:
  /// **'Creating your first study module...'**
  String get signupCreatingModule;

  /// Generic processing fallback. Keep the ellipsis.
  ///
  /// In en, this message translates to:
  /// **'Working on it...'**
  String get signupWorkingOnIt;

  /// Processing reassurance line.
  ///
  /// In en, this message translates to:
  /// **'This may take a minute.'**
  String get signupTakeMinute;

  /// Fallback for {subject} in the irrelevant-upload copy when no subject is set.
  ///
  /// In en, this message translates to:
  /// **'this subject'**
  String get signupThisSubject;

  /// Irrelevant-upload heading.
  ///
  /// In en, this message translates to:
  /// **'This doesn\'t look like {subject} material'**
  String signupNotLikeMaterial(String subject);

  /// Irrelevant-upload body (fallback when the server gave no reason).
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t match it to {subject}. Use it anyway, or pick a different file.'**
  String signupCouldntMatch(String subject);

  /// Accept an upload the server flagged as irrelevant.
  ///
  /// In en, this message translates to:
  /// **'Use it anyway'**
  String get signupUseAnyway;

  /// Reject the flagged upload and pick another.
  ///
  /// In en, this message translates to:
  /// **'Choose a different file'**
  String get signupChooseDifferentFile;

  /// Success heading naming the generated module. Title may be student material — keep it verbatim.
  ///
  /// In en, this message translates to:
  /// **'Your \"{title}\" module is ready!'**
  String signupModuleReady(String title);

  /// Fallback for {title} in signupModuleReady when the module has no title ('Your "first" module').
  ///
  /// In en, this message translates to:
  /// **'first'**
  String get signupFirstModuleWord;

  /// Success heading when no module title is available. Keep 'Mochi'.
  ///
  /// In en, this message translates to:
  /// **'Your {mascot} is set up!'**
  String signupMochiSetUp(String mascot);

  /// Success subtitle. Keep 'Mochi'.
  ///
  /// In en, this message translates to:
  /// **'{mascot} has read your notes and built a study module for you.'**
  String signupModuleBuilt(String mascot);

  /// Primary success CTA into the first module.
  ///
  /// In en, this message translates to:
  /// **'Start learning'**
  String get signupStartLearning;

  /// Success CTA to the home screen.
  ///
  /// In en, this message translates to:
  /// **'Go to home'**
  String get signupGoToHome;

  /// Explainer-sheet heading. Keep 'Apalchi' + emoji.
  ///
  /// In en, this message translates to:
  /// **'What makes Apalchi different 🧠'**
  String get howDiffTitle;

  /// Explainer-sheet subtitle.
  ///
  /// In en, this message translates to:
  /// **'Here\'s what you just got — and why it matters.'**
  String get howDiffSubtitle;

  /// Differentiator card 1 title.
  ///
  /// In en, this message translates to:
  /// **'Built from your notes'**
  String get howDiffCard1Title;

  /// Differentiator card 1 body. Keep 'Mochi'.
  ///
  /// In en, this message translates to:
  /// **'Your {mascot} learns your material — your textbook, your class notes, your syllabus. So every answer matches what your teacher actually taught, not a generic textbook.'**
  String howDiffCard1Body(String mascot);

  /// Differentiator card 2 title.
  ///
  /// In en, this message translates to:
  /// **'Remembers how you learn'**
  String get howDiffCard2Title;

  /// Differentiator card 2 body.
  ///
  /// In en, this message translates to:
  /// **'It tracks which topics trip you up and brings them back until they stick. Easy things get spaced out. No time wasted on what you already know.'**
  String get howDiffCard2Body;

  /// Differentiator card 3 title.
  ///
  /// In en, this message translates to:
  /// **'Made for real studying'**
  String get howDiffCard3Title;

  /// Differentiator card 3 body. Keep 'Mochis'.
  ///
  /// In en, this message translates to:
  /// **'{mascot}s for every subject — flashcards, daily quizzes, mastery tracking, curriculum-aligned — depth designed for serious learners.'**
  String howDiffCard3Body(String mascot);

  /// Pull-quote near the bottom of the sheet. Keep 'Mochi' and the quotation marks.
  ///
  /// In en, this message translates to:
  /// **'\"Not a generic tutor. A {mascot} that knows yours.\"'**
  String howDiffQuote(String mascot);

  /// Dismiss button on the explainer sheet.
  ///
  /// In en, this message translates to:
  /// **'Got it — let\'s study!'**
  String get howDiffGotIt;

  /// Subject name. Localized ONLY for the known enum subjects; a teacher's free-text subject passes through untranslated.
  ///
  /// In en, this message translates to:
  /// **'Maths'**
  String get subjectMaths;

  /// Subject name.
  ///
  /// In en, this message translates to:
  /// **'Science'**
  String get subjectScience;

  /// Subject name (English as a school subject).
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get subjectEnglish;

  /// Subject name.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get subjectHistory;

  /// Subject name.
  ///
  /// In en, this message translates to:
  /// **'Coding'**
  String get subjectCoding;

  /// Subject name.
  ///
  /// In en, this message translates to:
  /// **'Art'**
  String get subjectArt;

  /// Subject name.
  ///
  /// In en, this message translates to:
  /// **'Geography'**
  String get subjectGeography;

  /// Subject name (languages in general).
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get subjectLanguages;

  /// Subject name.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get subjectMusic;

  /// Subject name (PE).
  ///
  /// In en, this message translates to:
  /// **'Physical Education'**
  String get subjectPhysicalEducation;

  /// Subject name.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get subjectHealth;

  /// Subject name.
  ///
  /// In en, this message translates to:
  /// **'Literature'**
  String get subjectLiterature;

  /// Subject name (catch-all / no specific subject).
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get subjectGeneral;

  /// Education stage.
  ///
  /// In en, this message translates to:
  /// **'Primary School'**
  String get levelPrimary;

  /// Education stage.
  ///
  /// In en, this message translates to:
  /// **'Secondary School'**
  String get levelSecondary;

  /// Education stage.
  ///
  /// In en, this message translates to:
  /// **'High School'**
  String get levelHighSchool;

  /// Education stage (tertiary / adult learners).
  ///
  /// In en, this message translates to:
  /// **'University / Adult'**
  String get levelUniversity;

  /// Age-range hint under the Primary stage.
  ///
  /// In en, this message translates to:
  /// **'Ages ~6–11'**
  String get levelPrimarySubtitle;

  /// Age-range hint under the Secondary stage.
  ///
  /// In en, this message translates to:
  /// **'Ages ~11–16'**
  String get levelSecondarySubtitle;

  /// Age-range hint under the High School stage.
  ///
  /// In en, this message translates to:
  /// **'Ages ~16–18'**
  String get levelHighSchoolSubtitle;

  /// Age-range hint under the University stage.
  ///
  /// In en, this message translates to:
  /// **'Ages 18+'**
  String get levelUniversitySubtitle;

  /// Plan tier label (default when the plan is unknown).
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get tierPremium;

  /// Plan tier label (brand tier name — usually kept as-is).
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get tierMax;

  /// Plan tier label (brand tier name — usually kept as-is).
  ///
  /// In en, this message translates to:
  /// **'Pro'**
  String get tierPro;

  /// Plan tier label.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get tierFree;

  /// Plan tier label.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get tierFamily;

  /// Plan tier label.
  ///
  /// In en, this message translates to:
  /// **'Trial'**
  String get tierTrial;

  /// Plan tier label (tuition centre).
  ///
  /// In en, this message translates to:
  /// **'Centre'**
  String get tierCentre;

  /// PR-C progress/achievements/goals.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievementsTitle;

  /// PR-C progress/achievements/goals.
  ///
  /// In en, this message translates to:
  /// **'Recently earned'**
  String get achievementsRecentlyEarned;

  /// PR-C progress/achievements/goals.
  ///
  /// In en, this message translates to:
  /// **'{earned} / {total} earned'**
  String achievementsEarnedCount(int earned, int total);

  /// PR-C progress/achievements/goals.
  ///
  /// In en, this message translates to:
  /// **'{pct}% of all achievements'**
  String achievementsPercentOfAll(int pct);

  /// PR-C progress/achievements/goals.
  ///
  /// In en, this message translates to:
  /// **'Complete actions to earn your first achievement.'**
  String get progressFirstAchievement;

  /// PR-C progress/achievements/goals.
  ///
  /// In en, this message translates to:
  /// **'Today\'s goal'**
  String get dailyGoalToday;

  /// PR-C progress/achievements/goals.
  ///
  /// In en, this message translates to:
  /// **'Pick your daily goal'**
  String get dailyGoalPick;

  /// PR-C progress/achievements/goals.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get dailyGoalMinutes;

  /// PR-C progress/achievements/goals.
  ///
  /// In en, this message translates to:
  /// **'Quizzes'**
  String get dailyGoalQuizzes;

  /// PR-C progress/achievements/goals.
  ///
  /// In en, this message translates to:
  /// **'Set my goal'**
  String get dailyGoalSet;

  /// PR-C progress/achievements/goals.
  ///
  /// In en, this message translates to:
  /// **'Commit to my goal'**
  String get dailyGoalCommit;

  /// PR-C progress/achievements/goals.
  ///
  /// In en, this message translates to:
  /// **'Close this ring every day to keep your streak safe.'**
  String get dailyGoalRingHint;

  /// PR-C progress/achievements/goals.
  ///
  /// In en, this message translates to:
  /// **'Could not save goal. Try again.'**
  String get dailyGoalSaveFailed;

  /// PR-C progress/achievements/goals.
  ///
  /// In en, this message translates to:
  /// **'Level rewards'**
  String get levelRoadmapTitle;

  /// PR-C progress/achievements/goals.
  ///
  /// In en, this message translates to:
  /// **'Level {current} of {max}'**
  String levelRoadmapCurrentOf(int current, int max);

  /// PR-C progress/achievements/goals.
  ///
  /// In en, this message translates to:
  /// **'{earned} of {total} rewards unlocked'**
  String levelRoadmapRewardsUnlocked(int earned, int total);

  /// PR-C progress/achievements/goals.
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String levelN(int level);

  /// PR-C progress/achievements/goals.
  ///
  /// In en, this message translates to:
  /// **'LEVEL UP!'**
  String get levelUpTitle;

  /// PR-C progress/achievements/goals.
  ///
  /// In en, this message translates to:
  /// **'Reached Level {level} — keep going!'**
  String levelUpReached(int level);

  /// PR-C progress/achievements/goals.
  ///
  /// In en, this message translates to:
  /// **'Keep going!'**
  String get levelUpKeepGoing;

  /// PR-C progress/achievements/goals.
  ///
  /// In en, this message translates to:
  /// **'You\'re getting smarter! 🎓'**
  String get levelUpSmarter;

  /// PR-C progress/achievements/goals.
  ///
  /// In en, this message translates to:
  /// **'My Progress'**
  String get progressTitle;

  /// PR-C progress/achievements/goals.
  ///
  /// In en, this message translates to:
  /// **'Total XP'**
  String get progressTotalXp;

  /// PR-C progress/achievements/goals.
  ///
  /// In en, this message translates to:
  /// **'Badges'**
  String get progressBadges;

  /// PR-C progress/achievements/goals.
  ///
  /// In en, this message translates to:
  /// **'Character Shop'**
  String get progressCharacterShop;

  /// PR-C progress/achievements/goals.
  ///
  /// In en, this message translates to:
  /// **'Needs Work'**
  String get progressNeedsWork;

  /// PR-C progress/achievements/goals.
  ///
  /// In en, this message translates to:
  /// **'Practice Weak Topics'**
  String get progressPracticeWeak;

  /// PR-C progress/achievements/goals.
  ///
  /// In en, this message translates to:
  /// **'{count} topics'**
  String progressTopicsCount(int count);

  /// PR-C progress/achievements/goals.
  ///
  /// In en, this message translates to:
  /// **'{xp} XP to Level {level}'**
  String progressXpToLevel(int xp, int level);

  /// PR-C progress/achievements/goals.
  ///
  /// In en, this message translates to:
  /// **'{min} min studied this week'**
  String progressMinThisWeek(int min);

  /// PR-C progress/achievements/goals.
  ///
  /// In en, this message translates to:
  /// **'Which {mascot} to quiz?'**
  String progressWhichMochi(String mascot);

  /// PR-C progress/achievements/goals.
  ///
  /// In en, this message translates to:
  /// **'Go Premium'**
  String get progressGoPremium;

  /// PR-C progress/achievements/goals.
  ///
  /// In en, this message translates to:
  /// **'Unlimited {mascot}s, chat & family sharing — 7-day free trial'**
  String progressPremiumPitch(String mascot);

  /// PR-C progress/achievements/goals.
  ///
  /// In en, this message translates to:
  /// **'Enter or scan a code someone gave you'**
  String get progressEnterCode;

  /// PR-C progress/achievements/goals.
  ///
  /// In en, this message translates to:
  /// **'Join a class or group'**
  String get progressJoinClass;

  /// PR-C progress/achievements/goals.
  ///
  /// In en, this message translates to:
  /// **'Earn bonus stars when they take their first quiz'**
  String get progressReferralBonus;

  /// PR-C progress/achievements/goals.
  ///
  /// In en, this message translates to:
  /// **'Streak ladder'**
  String get streakLadder;

  /// PR-C progress/achievements/goals.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String streakDays(int days);

  /// PR-C progress/achievements/goals.
  ///
  /// In en, this message translates to:
  /// **'Best: {days} days'**
  String streakBest(int days);

  /// PR-C progress/achievements/goals.
  ///
  /// In en, this message translates to:
  /// **'{days}-day streak'**
  String streakMilestoneDay(int days);

  /// PR-C progress/achievements/goals.
  ///
  /// In en, this message translates to:
  /// **'1-week badge'**
  String get streakBadge1Week;

  /// PR-C progress/achievements/goals.
  ///
  /// In en, this message translates to:
  /// **'2-week badge'**
  String get streakBadge2Week;

  /// PR-C progress/achievements/goals.
  ///
  /// In en, this message translates to:
  /// **'30-day badge'**
  String get streakBadge30Day;

  /// PR-C progress/achievements/goals.
  ///
  /// In en, this message translates to:
  /// **'100 days'**
  String get streak100Days;

  /// PR-C progress/achievements/goals.
  ///
  /// In en, this message translates to:
  /// **'a full year'**
  String get streakFullYear;

  /// PR-C progress/achievements/goals.
  ///
  /// In en, this message translates to:
  /// **'{days}-DAY STREAK!'**
  String streakMilestoneOverlayTitle(int days);

  /// PR-C progress/achievements/goals.
  ///
  /// In en, this message translates to:
  /// **'Keep it lit!'**
  String get streakKeepLit;

  /// PR-C streak.
  ///
  /// In en, this message translates to:
  /// **'Milestone reached — keep stacking!'**
  String get streakMilestoneReached;

  /// PR-C streak.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{1 day to {milestone}} other{{days} days to {milestone}}}'**
  String streakDaysToNext(int days, String milestone);

  /// PR-C streak.
  ///
  /// In en, this message translates to:
  /// **'Freezes save your streak when you miss a day. Hit each new 7-day milestone to earn one back (up to 3).'**
  String get streakFreezeHint;

  /// PR-C progress (ternary/switch strings the scanner missed).
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get achievementsCategoryStreak;

  /// PR-C progress (ternary/switch strings the scanner missed).
  ///
  /// In en, this message translates to:
  /// **'Mastery'**
  String get achievementsCategoryMastery;

  /// PR-C progress (ternary/switch strings the scanner missed).
  ///
  /// In en, this message translates to:
  /// **'Curiosity'**
  String get achievementsCategoryCuriosity;

  /// PR-C progress (ternary/switch strings the scanner missed).
  ///
  /// In en, this message translates to:
  /// **'Milestones'**
  String get achievementsCategoryMilestones;

  /// PR-C progress (ternary/switch strings the scanner missed).
  ///
  /// In en, this message translates to:
  /// **'day'**
  String get streakUnitDay;

  /// PR-C progress (ternary/switch strings the scanner missed).
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get streakUnitDays;

  /// PR-C progress (ternary/switch strings the scanner missed).
  ///
  /// In en, this message translates to:
  /// **'A freeze saves your streak if you miss one day.'**
  String get streakFreezeActive;

  /// PR-C progress (ternary/switch strings the scanner missed).
  ///
  /// In en, this message translates to:
  /// **'Earn a freeze by hitting a new 7-day milestone.'**
  String get streakFreezeEarn;

  /// PR-C daily-goal unit.
  ///
  /// In en, this message translates to:
  /// **'XP'**
  String get unitXp;

  /// PR-C daily-goal unit.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get unitMin;

  /// PR-C daily-goal unit.
  ///
  /// In en, this message translates to:
  /// **'quiz'**
  String get unitQuiz;

  /// PR-C daily-goal unit.
  ///
  /// In en, this message translates to:
  /// **'quizzes'**
  String get unitQuizzes;

  /// PR-C daily-goal unit.
  ///
  /// In en, this message translates to:
  /// **'{count} {unit}'**
  String dailyGoalValueUnit(int count, String unit);

  /// PR-D groups/join/invite.
  ///
  /// In en, this message translates to:
  /// **'Study Group'**
  String get groupTitle;

  /// PR-D groups/join/invite.
  ///
  /// In en, this message translates to:
  /// **'Study Groups'**
  String get groupsTitle;

  /// PR-D groups/join/invite.
  ///
  /// In en, this message translates to:
  /// **'No groups yet'**
  String get groupsEmpty;

  /// PR-D groups/join/invite.
  ///
  /// In en, this message translates to:
  /// **'Create a group or join one with an invite code from a friend.'**
  String get groupsEmptyBody;

  /// PR-D groups/join/invite.
  ///
  /// In en, this message translates to:
  /// **'Have an invite code?'**
  String get groupsHaveCode;

  /// PR-D groups/join/invite.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get groupJoin;

  /// PR-D groups/join/invite.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t join — check the code'**
  String get groupJoinFailed;

  /// PR-D groups/join/invite.
  ///
  /// In en, this message translates to:
  /// **'New Group'**
  String get groupNewTitle;

  /// PR-D groups/join/invite.
  ///
  /// In en, this message translates to:
  /// **'Create group'**
  String get groupCreate;

  /// PR-D groups/join/invite.
  ///
  /// In en, this message translates to:
  /// **'Group name'**
  String get groupNameLabel;

  /// PR-D groups/join/invite.
  ///
  /// In en, this message translates to:
  /// **'Give your group a name'**
  String get groupNameHint;

  /// PR-D groups/join/invite.
  ///
  /// In en, this message translates to:
  /// **'Year 6 Science Buddies'**
  String get groupNameExample;

  /// PR-D groups/join/invite.
  ///
  /// In en, this message translates to:
  /// **'Subject (optional)'**
  String get groupSubjectOptional;

  /// PR-D groups/join/invite.
  ///
  /// In en, this message translates to:
  /// **'Group created!'**
  String get groupCreated;

  /// PR-D groups/join/invite.
  ///
  /// In en, this message translates to:
  /// **'Could not create group'**
  String get groupCreateFailed;

  /// PR-D groups/join/invite.
  ///
  /// In en, this message translates to:
  /// **'Leave group'**
  String get groupLeave;

  /// PR-D groups/join/invite.
  ///
  /// In en, this message translates to:
  /// **'Leave this group?'**
  String get groupLeaveConfirm;

  /// PR-D groups/join/invite.
  ///
  /// In en, this message translates to:
  /// **'You\'ll need a new invite code to re-join.'**
  String get groupLeaveBody;

  /// PR-D groups/join/invite.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get groupLeaveAction;

  /// PR-D groups/join/invite.
  ///
  /// In en, this message translates to:
  /// **'Answers released'**
  String get groupAnswersReleased;

  /// PR-D groups/join/invite.
  ///
  /// In en, this message translates to:
  /// **'New challenge'**
  String get groupNewChallenge;

  /// PR-D groups/join/invite.
  ///
  /// In en, this message translates to:
  /// **'Muddiest points'**
  String get groupMuddiest;

  /// PR-D groups/join/invite.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get groupUpdate;

  /// PR-D groups/join/invite.
  ///
  /// In en, this message translates to:
  /// **'Open this assignment from your class {mascot}.'**
  String groupOpenAssignment(String mascot);

  /// PR-D groups/join/invite.
  ///
  /// In en, this message translates to:
  /// **'Invite a friend'**
  String get groupInviteFriend;

  /// PR-D groups/join/invite.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get groupCopy;

  /// PR-D groups/join/invite.
  ///
  /// In en, this message translates to:
  /// **'Code copied!'**
  String get groupCodeCopied;

  /// PR-D groups/join/invite.
  ///
  /// In en, this message translates to:
  /// **'Share this code with a friend to invite them'**
  String get groupShareCode;

  /// PR-D groups/join/invite.
  ///
  /// In en, this message translates to:
  /// **'No notes shared yet'**
  String get groupNoNotes;

  /// PR-D groups/join/invite.
  ///
  /// In en, this message translates to:
  /// **'Open a wiki page from your Library and tap \"Share to group\" to add the first note!'**
  String get groupNoNotesHint;

  /// PR-D groups/join/invite.
  ///
  /// In en, this message translates to:
  /// **'Share another note from Library'**
  String get groupShareAnother;

  /// PR-D groups/join/invite.
  ///
  /// In en, this message translates to:
  /// **'Go to Library'**
  String get groupGoLibrary;

  /// PR-D groups/join/invite.
  ///
  /// In en, this message translates to:
  /// **'Off topic?'**
  String get groupOffTopic;

  /// PR-D groups/join/invite.
  ///
  /// In en, this message translates to:
  /// **'Joined {name}!'**
  String groupJoinedName(String name);

  /// PR-D groups/join/invite.
  ///
  /// In en, this message translates to:
  /// **'by {name} · {time}'**
  String groupNoteBy(String name, String time);

  /// PR-D groups/join/invite.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 member · code {code}} other{{count} members · code {code}}}'**
  String groupMemberCodeLine(int count, String code);

  /// PR-D groups/join/invite.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get timeJustNow;

  /// PR-D groups/join/invite.
  ///
  /// In en, this message translates to:
  /// **'{n}m ago'**
  String timeMinAgo(int n);

  /// PR-D groups/join/invite.
  ///
  /// In en, this message translates to:
  /// **'{n}h ago'**
  String timeHourAgo(int n);

  /// PR-D groups/join/invite.
  ///
  /// In en, this message translates to:
  /// **'{n}d ago'**
  String timeDayAgo(int n);

  /// PR-D groups/join/invite.
  ///
  /// In en, this message translates to:
  /// **'Daily Challenge'**
  String get challengeTitle;

  /// PR-D groups/join/invite.
  ///
  /// In en, this message translates to:
  /// **'Reveal pending'**
  String get challengeRevealPending;

  /// PR-D groups/join/invite.
  ///
  /// In en, this message translates to:
  /// **'Correct: '**
  String get challengeCorrectPrefix;

  /// PR-D groups/join/invite.
  ///
  /// In en, this message translates to:
  /// **'(you)'**
  String get challengeYou;

  /// PR-D groups/join/invite.
  ///
  /// In en, this message translates to:
  /// **'Type your answer…'**
  String get challengeAnswerHint;

  /// PR-D groups/join/invite.
  ///
  /// In en, this message translates to:
  /// **'Answered — reveals in {time}'**
  String challengeAnsweredReveals(String time);

  /// PR-D groups/join/invite.
  ///
  /// In en, this message translates to:
  /// **'Reveals {day}/{month}'**
  String challengeRevealsOn(String day, String month);

  /// PR-D groups/join/invite.
  ///
  /// In en, this message translates to:
  /// **'Invite & connect'**
  String get inviteTitle;

  /// PR-D groups/join/invite.
  ///
  /// In en, this message translates to:
  /// **'Friends can scan this to grab your code'**
  String get inviteScanHint;

  /// PR-D groups/join/invite.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get inviteShare;

  /// PR-D groups/join/invite.
  ///
  /// In en, this message translates to:
  /// **'You both get bonus stars when they take their first quiz.'**
  String get inviteBonus;

  /// PR-D groups/join/invite.
  ///
  /// In en, this message translates to:
  /// **'Code copied'**
  String get inviteCopied;

  /// PR-D groups/join/invite.
  ///
  /// In en, this message translates to:
  /// **'Could not load your code — tap to retry'**
  String get inviteLoadFailed;

  /// PR-D groups/join/invite.
  ///
  /// In en, this message translates to:
  /// **'Invite'**
  String get inviteAction;

  /// PR-D groups/join/invite.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get inviteDismiss;

  /// PR-D groups/join/invite.
  ///
  /// In en, this message translates to:
  /// **'Invite a friend — you both get bonus stars.'**
  String get inviteNudgeBody;

  /// PR-D groups/join/invite.
  ///
  /// In en, this message translates to:
  /// **'{days}-day streak — nice!'**
  String milestoneStreakNice(int days);

  /// PR-D groups/join/invite.
  ///
  /// In en, this message translates to:
  /// **'Enter or scan a code'**
  String get joinTitle;

  /// PR-D groups/join/invite.
  ///
  /// In en, this message translates to:
  /// **'Got a class or study-group code? Type it in, or scan its QR.'**
  String get joinBody;

  /// PR-D groups/join/invite.
  ///
  /// In en, this message translates to:
  /// **'Enter code manually'**
  String get joinEnterManually;

  /// PR-D groups/join/invite.
  ///
  /// In en, this message translates to:
  /// **'Scan QR'**
  String get joinScanQr;

  /// PR-D groups/join/invite.
  ///
  /// In en, this message translates to:
  /// **'Point at a class or group QR'**
  String get joinPointQr;

  /// PR-D groups/join/invite.
  ///
  /// In en, this message translates to:
  /// **'Enter a code first'**
  String get joinEnterFirst;

  /// PR-D groups/join/invite.
  ///
  /// In en, this message translates to:
  /// **'That doesn\'t look like a valid code'**
  String get joinInvalidCode;

  /// PR-D groups/join/invite.
  ///
  /// In en, this message translates to:
  /// **'Parent links are no longer supported'**
  String get joinParentUnsupported;

  /// PR-D groups/join/invite.
  ///
  /// In en, this message translates to:
  /// **'Joined {name} 🎉'**
  String joinedSuccess(String name);

  /// PR-D groups/join/invite.
  ///
  /// In en, this message translates to:
  /// **'successfully'**
  String get joinedFallback;

  /// PR-E shop/flashcards.
  ///
  /// In en, this message translates to:
  /// **'Earn Stars'**
  String get shopEarnStars;

  /// PR-E shop/flashcards.
  ///
  /// In en, this message translates to:
  /// **'My Collection'**
  String get shopMyCollection;

  /// PR-E shop/flashcards.
  ///
  /// In en, this message translates to:
  /// **'Mystery Box'**
  String get shopMysteryBox;

  /// PR-E shop/flashcards.
  ///
  /// In en, this message translates to:
  /// **'Open to unlock a random character!'**
  String get shopMysteryBoxHint;

  /// PR-E shop/flashcards.
  ///
  /// In en, this message translates to:
  /// **'Power-ups'**
  String get shopPowerUps;

  /// PR-E shop/flashcards.
  ///
  /// In en, this message translates to:
  /// **'Quiz Power-ups'**
  String get shopQuizPowerUps;

  /// PR-E shop/flashcards.
  ///
  /// In en, this message translates to:
  /// **'Spend stars to study smarter.'**
  String get shopQuizPowerUpsHint;

  /// PR-E shop/flashcards.
  ///
  /// In en, this message translates to:
  /// **'Hint token'**
  String get shopHintToken;

  /// PR-E shop/flashcards.
  ///
  /// In en, this message translates to:
  /// **'Double-XP boost'**
  String get shopDoubleXp;

  /// PR-E shop/flashcards.
  ///
  /// In en, this message translates to:
  /// **'Bonus practice quiz'**
  String get shopBonusQuiz;

  /// PR-E shop/flashcards.
  ///
  /// In en, this message translates to:
  /// **'Streak Freeze'**
  String get shopStreakFreeze;

  /// PR-E shop/flashcards.
  ///
  /// In en, this message translates to:
  /// **'Save your streak if you miss a day.'**
  String get shopStreakFreezeHint;

  /// PR-E shop/flashcards.
  ///
  /// In en, this message translates to:
  /// **'Spend stars to protect your streak.'**
  String get shopStreakFreezeSpend;

  /// PR-E shop/flashcards.
  ///
  /// In en, this message translates to:
  /// **'Already Unlocked'**
  String get shopAlreadyUnlocked;

  /// PR-E shop/flashcards.
  ///
  /// In en, this message translates to:
  /// **'Awesome!'**
  String get shopAwesome;

  /// PR-E shop/flashcards.
  ///
  /// In en, this message translates to:
  /// **'New Character Unlocked!'**
  String get shopNewCharacter;

  /// PR-E shop/flashcards.
  ///
  /// In en, this message translates to:
  /// **'You can now use this {mascot} for studying!'**
  String shopCanUseMochi(String mascot);

  /// PR-E shop/flashcards.
  ///
  /// In en, this message translates to:
  /// **'Loading odds…'**
  String get shopLoadingOdds;

  /// PR-E shop/flashcards.
  ///
  /// In en, this message translates to:
  /// **'💡 FYI — Probability:'**
  String get shopProbability;

  /// PR-E shop/flashcards.
  ///
  /// In en, this message translates to:
  /// **'I will learn harder and try again!'**
  String get shopLearnHarder;

  /// PR-E shop/flashcards.
  ///
  /// In en, this message translates to:
  /// **'❄️ Freeze added — you now have {current}/{cap}'**
  String shopFreezeAdded(int current, int cap);

  /// PR-E shop/flashcards.
  ///
  /// In en, this message translates to:
  /// **'Bought {label} — you now have {count}'**
  String shopBought(String label, int count);

  /// PR-E shop/flashcards.
  ///
  /// In en, this message translates to:
  /// **'✨ {label}'**
  String shopRarityBadge(String label);

  /// PR-E shop/flashcards.
  ///
  /// In en, this message translates to:
  /// **'a hint token'**
  String get shopLabelHintToken;

  /// PR-E shop/flashcards.
  ///
  /// In en, this message translates to:
  /// **'a double-XP boost'**
  String get shopLabelDoubleXp;

  /// PR-E shop/flashcards.
  ///
  /// In en, this message translates to:
  /// **'a bonus quiz'**
  String get shopLabelBonusQuiz;

  /// PR-E shop/flashcards.
  ///
  /// In en, this message translates to:
  /// **'a powerup'**
  String get shopLabelPowerup;

  /// PR-E shop/flashcards.
  ///
  /// In en, this message translates to:
  /// **'Flashcards'**
  String get flashcardsTitle;

  /// PR-E shop/flashcards.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get flashcardQuestion;

  /// PR-E shop/flashcards.
  ///
  /// In en, this message translates to:
  /// **'Tap to flip'**
  String get flashcardTapFlip;

  /// PR-E shop/flashcards.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get flashcardEasy;

  /// PR-E shop/flashcards.
  ///
  /// In en, this message translates to:
  /// **'Okay'**
  String get flashcardOkay;

  /// PR-E shop/flashcards.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get flashcardHard;

  /// PR-E shop/flashcards.
  ///
  /// In en, this message translates to:
  /// **'No flashcards yet'**
  String get flashcardEmpty;

  /// PR-E shop/flashcards.
  ///
  /// In en, this message translates to:
  /// **'Ready to make cards'**
  String get flashcardReadyMake;

  /// PR-E shop/flashcards.
  ///
  /// In en, this message translates to:
  /// **'Ready to make your cards'**
  String get flashcardReadyMakeYours;

  /// PR-E shop/flashcards.
  ///
  /// In en, this message translates to:
  /// **'Generate flashcards'**
  String get flashcardGenerate;

  /// PR-E shop/flashcards.
  ///
  /// In en, this message translates to:
  /// **'Regenerate cards'**
  String get flashcardRegenerate;

  /// PR-E shop/flashcards.
  ///
  /// In en, this message translates to:
  /// **'Your {mascot} has notes but no cards yet.\nTap the button below to generate them.'**
  String flashcardHasNotesNoCards(String mascot);

  /// PR-E shop/flashcards.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{That\'s about 1 page of notes. It takes a moment — tap when you\'re ready.} other{That\'s about {count} pages of notes. It takes a moment — tap when you\'re ready.}}'**
  String flashcardAboutPages(int count);

  /// PR-E shop/flashcards.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Generate cards (~1 page)} other{Generate cards (~{count} pages)}}'**
  String flashcardGenerateN(int count);

  /// PR-E shop/flashcard (const-list strings the scanner missed).
  ///
  /// In en, this message translates to:
  /// **'Reveal one wrong option in a quiz.'**
  String get shopHintTokenSub;

  /// PR-E shop/flashcard (const-list strings the scanner missed).
  ///
  /// In en, this message translates to:
  /// **'Doubles XP on your next quiz (within the daily cap).'**
  String get shopDoubleXpSub;

  /// PR-E shop/flashcard (const-list strings the scanner missed).
  ///
  /// In en, this message translates to:
  /// **'Unlock an extra full-XP quiz today.'**
  String get shopBonusQuizSub;

  /// PR-E shop/flashcard (const-list strings the scanner missed).
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get flashcardFilterAll;

  /// PR-E shop/flashcard (const-list strings the scanner missed).
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get flashcardFilterDue;

  /// PR-E shop/flashcard (const-list strings the scanner missed).
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get flashcardFilterWeak;

  /// PR-E shop/flashcard (const-list strings the scanner missed).
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get flashcardFilterDone;

  /// PR-G photo_question.
  ///
  /// In en, this message translates to:
  /// **'Better photo = better answers from {mascot}'**
  String photoBetterPhoto(String mascot);

  /// PR-G photo_question.
  ///
  /// In en, this message translates to:
  /// **'Bright light'**
  String get photoBrightLight;

  /// PR-G photo_question.
  ///
  /// In en, this message translates to:
  /// **'Charts ✕'**
  String get photoChartsX;

  /// PR-G photo_question.
  ///
  /// In en, this message translates to:
  /// **'Clear numbers ✓'**
  String get photoClearNumbers;

  /// PR-G photo_question.
  ///
  /// In en, this message translates to:
  /// **'Diagrams ⚠️'**
  String get photoDiagramsWarn;

  /// PR-G photo_question.
  ///
  /// In en, this message translates to:
  /// **'Fill the frame'**
  String get photoFillFrame;

  /// PR-G photo_question.
  ///
  /// In en, this message translates to:
  /// **'Got it, close tips'**
  String get photoCloseTips;

  /// PR-G photo_question.
  ///
  /// In en, this message translates to:
  /// **'Graphs, charts & shapes don\'t scan well. Type those values yourself.'**
  String get photoGraphsWarn;

  /// PR-G photo_question.
  ///
  /// In en, this message translates to:
  /// **'Hold still'**
  String get photoHoldStill;

  /// PR-G photo_question.
  ///
  /// In en, this message translates to:
  /// **'Keep it straight'**
  String get photoKeepStraight;

  /// PR-G photo_question.
  ///
  /// In en, this message translates to:
  /// **'Neat handwriting ✓'**
  String get photoNeatHandwriting;

  /// PR-G photo_question.
  ///
  /// In en, this message translates to:
  /// **'Printed text ✓'**
  String get photoPrintedText;

  /// PR-G photo_question.
  ///
  /// In en, this message translates to:
  /// **'Symbols ⚠️'**
  String get photoSymbolsWarn;

  /// PR-G photo_question.
  ///
  /// In en, this message translates to:
  /// **'Type instead'**
  String get photoTypeInstead;

  /// PR-G photo_question.
  ///
  /// In en, this message translates to:
  /// **'What {mascot} reads:'**
  String photoWhatReads(String mascot);

  /// PR-G photo_question.
  ///
  /// In en, this message translates to:
  /// **'What can I read? ›'**
  String get photoWhatCanRead;

  /// PR-G photo_question.
  ///
  /// In en, this message translates to:
  /// **'📚 Point at your homework question'**
  String get photoPointHomework;

  /// PR-G photo_question.
  ///
  /// In en, this message translates to:
  /// **'📷 Tips for best results'**
  String get photoTipsBest;

  /// PR-G photo_question.
  ///
  /// In en, this message translates to:
  /// **'Homework Results'**
  String get photoHomeworkResults;

  /// PR-G photo_question.
  ///
  /// In en, this message translates to:
  /// **'Nothing to share yet.'**
  String get photoNothingShare;

  /// PR-G photo_question.
  ///
  /// In en, this message translates to:
  /// **'Share results'**
  String get photoShareResults;

  /// PR-G photo_question.
  ///
  /// In en, this message translates to:
  /// **'What next?'**
  String get photoWhatNext;

  /// PR-G photo_question.
  ///
  /// In en, this message translates to:
  /// **'🎯 Quiz me on this'**
  String get photoQuizMe;

  /// PR-G photo_question.
  ///
  /// In en, this message translates to:
  /// **'💡 Another example'**
  String get photoAnotherExample;

  /// PR-G photo_question.
  ///
  /// In en, this message translates to:
  /// **'📝 Show full working'**
  String get photoShowWorking;

  /// PR-G photo_question.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 question} other{{count} questions}}'**
  String photoQuestionCount(int count);

  /// PR-G photo_question.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{🔍 I found 1 question! Here are the solutions:} other{🔍 I found {count} questions! Here are the solutions:}}'**
  String photoIFound(int count);

  /// PR-G photo_question.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 question found} other{{count} questions found}}'**
  String photoQuestionsFound(int count);

  /// PR-G photo_question.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Send 1 question to {mascot} ✨} other{Send {count} questions to {mascot} ✨}}'**
  String photoSendQuestions(int count, String mascot);

  /// PR-G photo_question.
  ///
  /// In en, this message translates to:
  /// **'Could not read photo'**
  String get photoCouldNotRead;

  /// PR-G photo_question.
  ///
  /// In en, this message translates to:
  /// **'Detecting questions… 🔍'**
  String get photoDetecting;

  /// PR-G photo_question.
  ///
  /// In en, this message translates to:
  /// **'Edit questions'**
  String get photoEditQuestions;

  /// PR-G photo_question.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get photoRetake;

  /// PR-G photo_question.
  ///
  /// In en, this message translates to:
  /// **'Done — use these questions ✓'**
  String get photoDoneUse;

  /// PR-G photo_question.
  ///
  /// In en, this message translates to:
  /// **'Fix any text {mascot} misread'**
  String photoFixMisread(String mascot);

  /// PR-G photo_question.
  ///
  /// In en, this message translates to:
  /// **'✏️  Edit Questions'**
  String get photoEditQuestionsTitle;

  /// PR-G photo_question.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get photoChooseGallery;

  /// PR-G photo_question.
  ///
  /// In en, this message translates to:
  /// **'Keep Photo'**
  String get photoKeepPhoto;

  /// PR-G photo_question.
  ///
  /// In en, this message translates to:
  /// **'Retake photo?'**
  String get photoRetakeConfirm;

  /// PR-G photo_question.
  ///
  /// In en, this message translates to:
  /// **'You\'ll lose the current scan. Choose what to do:'**
  String get photoRetakeBody;

  /// PR-G photo_question.
  ///
  /// In en, this message translates to:
  /// **'Great! ✓'**
  String get photoGreat;

  /// PR-G photo_question.
  ///
  /// In en, this message translates to:
  /// **'Here\'s what {mascot} found in your photo:'**
  String photoFoundInPhoto(String mascot);

  /// PR-G photo_question.
  ///
  /// In en, this message translates to:
  /// **'High (>85%)'**
  String get photoConfHigh;

  /// PR-G photo_question.
  ///
  /// In en, this message translates to:
  /// **'{mascot}\'s Reading Report'**
  String photoReadingReport(String mascot);

  /// PR-G photo_question.
  ///
  /// In en, this message translates to:
  /// **'OK-ish'**
  String get photoConfOkish;

  /// PR-G photo_question.
  ///
  /// In en, this message translates to:
  /// **'Per question:'**
  String get photoPerQuestion;

  /// PR-G photo_question.
  ///
  /// In en, this message translates to:
  /// **'Risky (<50%)'**
  String get photoConfRisky;

  /// PR-G photo_question.
  ///
  /// In en, this message translates to:
  /// **'Send anyway ({mascot} will do its best)'**
  String photoSendAnyway(String mascot);

  /// PR-G photo_question.
  ///
  /// In en, this message translates to:
  /// **'Tricky (50–85%)'**
  String get photoConfTricky;

  /// PR-G photo_question.
  ///
  /// In en, this message translates to:
  /// **'Tricky ⚠️'**
  String get photoTrickyWarn;

  /// PR-G photo_question.
  ///
  /// In en, this message translates to:
  /// **'✏️  Fix text manually'**
  String get photoFixManually;

  /// PR-G photo_question.
  ///
  /// In en, this message translates to:
  /// **'💡 Better quality photos = more accurate answers'**
  String get photoBetterQuality;

  /// PR-G photo_question.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get photoChooseGalleryLower;

  /// PR-G photo_question.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get photoDone;

  /// PR-G photo_question.
  ///
  /// In en, this message translates to:
  /// **'Edit question text…'**
  String get photoEditText;

  /// PR-G photo_question.
  ///
  /// In en, this message translates to:
  /// **'Keep this photo'**
  String get photoKeepThisPhoto;

  /// PR-G photo_question.
  ///
  /// In en, this message translates to:
  /// **'Retake photo'**
  String get photoRetakePhoto;

  /// PR-G photo_question.
  ///
  /// In en, this message translates to:
  /// **'What would you like to do?'**
  String get photoWhatToDo;

  /// PR-G2 ocr_awareness.
  ///
  /// In en, this message translates to:
  /// **'Fix text manually'**
  String get ocrFixManually;

  /// PR-G2 ocr_awareness.
  ///
  /// In en, this message translates to:
  /// **'How well {mascot} can read each question'**
  String ocrHowWellReads(String mascot);

  /// PR-G2 ocr_awareness.
  ///
  /// In en, this message translates to:
  /// **'Q{n}: {text}'**
  String ocrQuestionLine(int n, String text);

  /// PR-G2 ocr_awareness.
  ///
  /// In en, this message translates to:
  /// **'Reading confidence'**
  String get ocrReadingConfidence;

  /// PR-G2 ocr_awareness.
  ///
  /// In en, this message translates to:
  /// **'Send anyway'**
  String get ocrSendAnyway;

  /// PR-G2 ocr_awareness.
  ///
  /// In en, this message translates to:
  /// **'Issues detected'**
  String get ocrIssuesDetected;

  /// PR-G2 ocr_awareness.
  ///
  /// In en, this message translates to:
  /// **'Photo quality is low'**
  String get ocrQualityLow;

  /// PR-G2 ocr_awareness.
  ///
  /// In en, this message translates to:
  /// **'Quality score'**
  String get ocrQualityScore;

  /// PR-G2 ocr_awareness.
  ///
  /// In en, this message translates to:
  /// **'Retake photo 📸'**
  String get ocrRetakePhoto;

  /// PR-G2 ocr_awareness.
  ///
  /// In en, this message translates to:
  /// **'Your tutor may misread some questions'**
  String get ocrMayMisread;

  /// PR-G2 ocr_awareness.
  ///
  /// In en, this message translates to:
  /// **'Get the best results from your camera'**
  String get ocrBestResults;

  /// PR-G2 ocr_awareness.
  ///
  /// In en, this message translates to:
  /// **'Got it — take photo'**
  String get ocrGotItTakePhoto;

  /// PR-G2 ocr_awareness.
  ///
  /// In en, this message translates to:
  /// **'Might need manual fix'**
  String get ocrMightNeedFix;

  /// PR-G2 ocr_awareness.
  ///
  /// In en, this message translates to:
  /// **'Photo tips for better reading'**
  String get ocrPhotoTips;

  /// PR-G2 ocr_awareness.
  ///
  /// In en, this message translates to:
  /// **'What reads well'**
  String get ocrWhatReadsWell;

  /// PR-G2 ocr_awareness.
  ///
  /// In en, this message translates to:
  /// **'Best tip: snap the words & numbers, then type any graph values yourself.'**
  String get ocrBestTip;

  /// PR-G2 ocr_awareness.
  ///
  /// In en, this message translates to:
  /// **'But it can\'t truly \"see\" pictures like graphs or shapes — it only reads the text around them.'**
  String get ocrCantSee;

  /// PR-G2 ocr_awareness.
  ///
  /// In en, this message translates to:
  /// **'{mascot} reads text & numbers really well'**
  String ocrReadsWell(String mascot);

  /// PR-G2 ocr_awareness.
  ///
  /// In en, this message translates to:
  /// **'What can Apalchi read?'**
  String get ocrWhatCanRead;

  /// PR-G2 ocr_awareness.
  ///
  /// In en, this message translates to:
  /// **'This image contains a diagram or chart. Text reading may miss visual elements.'**
  String get ocrWarnDiagram;

  /// PR-G2 ocr_awareness.
  ///
  /// In en, this message translates to:
  /// **'Maths symbols and equations may not be read perfectly by OCR.'**
  String get ocrWarnMaths;

  /// PR-G2 ocr_awareness.
  ///
  /// In en, this message translates to:
  /// **'Some content in this image may not be read accurately.'**
  String get ocrWarnGeneric;

  /// PR-G2 ocr_awareness.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Fix text manually\" to describe what the diagram shows.'**
  String get ocrFixDiagram;

  /// PR-G2 ocr_awareness.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Fix text manually\" to correct any misread symbols.'**
  String get ocrFixSymbols;

  /// PR-G2 ocr_awareness.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Fix text manually\" to review and correct the text.'**
  String get ocrFixGeneric;

  /// PR-G2 ocr_awareness.
  ///
  /// In en, this message translates to:
  /// **'Diagram detected'**
  String get ocrDiagramDetected;

  /// PR-G2 ocr_awareness.
  ///
  /// In en, this message translates to:
  /// **'Maths symbols detected'**
  String get ocrMathsDetected;

  /// PR-G3 upload typed errors/warnings/estimates.
  ///
  /// In en, this message translates to:
  /// **'Could not read \"{fileName}\" — try selecting it again.'**
  String uploadErrCouldNotRead(String fileName);

  /// PR-G3 upload typed errors/warnings/estimates.
  ///
  /// In en, this message translates to:
  /// **'\"{fileName}\" appears to be empty.'**
  String uploadErrEmpty(String fileName);

  /// PR-G3 upload typed errors/warnings/estimates.
  ///
  /// In en, this message translates to:
  /// **'\"{fileName}\" is {size}MB — max is 25MB. Try splitting it into smaller sections.'**
  String uploadErrTooLarge(String fileName, String size);

  /// PR-G3 upload typed errors/warnings/estimates.
  ///
  /// In en, this message translates to:
  /// **'\"{fileName}\" is a .{ext} file — only PDFs, images, and text files are supported.'**
  String uploadErrUnsupported(String fileName, String ext);

  /// PR-G3 upload typed errors/warnings/estimates.
  ///
  /// In en, this message translates to:
  /// **'\"{fileName}\" couldn\'t be read — it may be empty or corrupted.'**
  String uploadErrCorrupted(String fileName);

  /// PR-G3 upload typed errors/warnings/estimates.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please sign in again.'**
  String get uploadErrSession;

  /// PR-G3 upload typed errors/warnings/estimates.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached a plan limit.'**
  String get uploadErrPlanLimit;

  /// PR-G3 upload typed errors/warnings/estimates.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission to upload here.'**
  String get uploadErrNoPermission;

  /// PR-G3 upload typed errors/warnings/estimates.
  ///
  /// In en, this message translates to:
  /// **'\"{fileName}\" is identical to \"{existing}\" already in your {mascot}\'s brain. No need to upload it again!'**
  String uploadErrDuplicate(String fileName, String existing, String mascot);

  /// PR-G3 upload typed errors/warnings/estimates.
  ///
  /// In en, this message translates to:
  /// **'\"{fileName}\" is very similar to \"{existing}\" already in your {mascot}\'s brain. Uploading it again won\'t teach {mascot} anything new.'**
  String uploadErrSimilar(String fileName, String existing, String mascot);

  /// PR-G3 upload typed errors/warnings/estimates.
  ///
  /// In en, this message translates to:
  /// **'\"{fileName}\" is too large (max 25MB). Try splitting it into smaller sections.'**
  String uploadErrTooLarge413(String fileName);

  /// PR-G3 upload typed errors/warnings/estimates.
  ///
  /// In en, this message translates to:
  /// **'\"{fileName}\" isn\'t a supported file type. Use a PDF, image, or text file.'**
  String uploadErrUnsupported415(String fileName);

  /// PR-G3 upload typed errors/warnings/estimates.
  ///
  /// In en, this message translates to:
  /// **'Too many uploads at once. Wait a moment and try again.'**
  String get uploadErrTooMany;

  /// PR-G3 upload typed errors/warnings/estimates.
  ///
  /// In en, this message translates to:
  /// **'\"{fileName}\" couldn\'t be processed — it may be password-protected or corrupted. Try a different version.'**
  String uploadErrProcessing(String fileName);

  /// PR-G3 upload typed errors/warnings/estimates.
  ///
  /// In en, this message translates to:
  /// **'The server is busy right now. Wait a moment and try uploading \"{fileName}\" again.'**
  String uploadErrServerBusy(String fileName);

  /// PR-G3 upload typed errors/warnings/estimates.
  ///
  /// In en, this message translates to:
  /// **'{mascot} is busy right now — try again in a moment.'**
  String uploadErrMochiBusy(String mascot);

  /// PR-G3 upload typed errors/warnings/estimates.
  ///
  /// In en, this message translates to:
  /// **'{mascot} is still working on your notes in the background — check back in a few minutes.'**
  String uploadErrStillWorking(String mascot);

  /// PR-G3 upload typed errors/warnings/estimates.
  ///
  /// In en, this message translates to:
  /// **'Upload of \"{fileName}\" timed out. Check your connection and try again.'**
  String uploadErrTimeout(String fileName);

  /// PR-G3 upload typed errors/warnings/estimates.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Check your WiFi and try again.'**
  String get uploadErrNoInternet;

  /// PR-G3 upload typed errors/warnings/estimates.
  ///
  /// In en, this message translates to:
  /// **'Upload of \"{fileName}\" failed. Please try again.'**
  String uploadErrFailed(String fileName);

  /// PR-G3 upload typed errors/warnings/estimates.
  ///
  /// In en, this message translates to:
  /// **'Something unexpected went wrong uploading \"{fileName}\". Try again.'**
  String uploadErrUnexpected(String fileName);

  /// PR-G3 upload typed errors/warnings/estimates.
  ///
  /// In en, this message translates to:
  /// **'an existing file'**
  String get uploadExistingFileFallback;

  /// PR-G3 upload typed errors/warnings/estimates.
  ///
  /// In en, this message translates to:
  /// **'existing notes'**
  String get uploadExistingNotesFallback;

  /// PR-G3 upload typed errors/warnings/estimates.
  ///
  /// In en, this message translates to:
  /// **'I used my backup reader for this one — double-check it looks right.'**
  String get uploadWarnBackup;

  /// PR-G3 upload typed errors/warnings/estimates.
  ///
  /// In en, this message translates to:
  /// **'I couldn\'t read much text from this — re-upload a clearer copy or type it. It won\'t train me well as-is.'**
  String get uploadWarnLowText;

  /// PR-G3 upload typed errors/warnings/estimates.
  ///
  /// In en, this message translates to:
  /// **'30–60 sec'**
  String get uploadEstShort;

  /// PR-G3 upload typed errors/warnings/estimates.
  ///
  /// In en, this message translates to:
  /// **'1–2 min'**
  String get uploadEstMedium;

  /// PR-G3 upload typed errors/warnings/estimates.
  ///
  /// In en, this message translates to:
  /// **'3–5 min'**
  String get uploadEstLong;

  /// PR-G3 upload chrome.
  ///
  /// In en, this message translates to:
  /// **'Add Knowledge'**
  String get uploadAddKnowledge;

  /// PR-G3 upload chrome.
  ///
  /// In en, this message translates to:
  /// **'Brain updated!'**
  String get uploadBrainUpdated;

  /// PR-G3 upload chrome.
  ///
  /// In en, this message translates to:
  /// **'Build my brain'**
  String get uploadBuildBrain;

  /// PR-G3 upload chrome.
  ///
  /// In en, this message translates to:
  /// **'Choose a PDF from your device'**
  String get uploadChoosePdf;

  /// PR-G3 upload chrome.
  ///
  /// In en, this message translates to:
  /// **'Extracted text...'**
  String get uploadExtractedTextHint;

  /// PR-G3 upload chrome.
  ///
  /// In en, this message translates to:
  /// **'Large file — this takes a few minutes'**
  String get uploadLargeFile;

  /// PR-G3 upload chrome.
  ///
  /// In en, this message translates to:
  /// **'Looks good'**
  String get uploadLooksGood;

  /// PR-G3 upload chrome.
  ///
  /// In en, this message translates to:
  /// **'Paste from clipboard'**
  String get uploadPasteClipboard;

  /// PR-G3 upload chrome.
  ///
  /// In en, this message translates to:
  /// **'Re-upload'**
  String get uploadReupload;

  /// PR-G3 upload chrome.
  ///
  /// In en, this message translates to:
  /// **'Review extracted text'**
  String get uploadReviewExtracted;

  /// PR-G3 upload chrome.
  ///
  /// In en, this message translates to:
  /// **'Save edits'**
  String get uploadSaveEdits;

  /// PR-G3 upload chrome.
  ///
  /// In en, this message translates to:
  /// **'Snap your notes or textbook'**
  String get uploadSnapNotes;

  /// PR-G3 upload chrome.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get uploadSource;

  /// PR-G3 upload chrome.
  ///
  /// In en, this message translates to:
  /// **'Tag this upload (optional)'**
  String get uploadTagOptional;

  /// PR-G3 upload chrome.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get uploadTakePhoto;

  /// PR-G3 upload chrome.
  ///
  /// In en, this message translates to:
  /// **'Topic (e.g. Algebra)'**
  String get uploadTopicHint;

  /// PR-G3 upload chrome.
  ///
  /// In en, this message translates to:
  /// **'Upload PDF'**
  String get uploadUploadPdf;

  /// PR-G3 upload chrome.
  ///
  /// In en, this message translates to:
  /// **'Your notes become my brain.'**
  String get uploadNotesBecomeBrain;

  /// PR-G3 upload chrome.
  ///
  /// In en, this message translates to:
  /// **'Adding notes to {subject}'**
  String uploadAddingNotesTo(String subject);

  /// PR-G3 upload chrome.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 file uploaded} other{{count} files uploaded}}'**
  String uploadFilesUploaded(int count);

  /// PR-G3 upload chrome.
  ///
  /// In en, this message translates to:
  /// **'This is a large file ({mb}MB). Building your brain from it can take about {estimate}. You can leave this screen — {mascot} keeps building in the background and updates automatically when it\'s ready.'**
  String uploadLargeFileNotice(String mb, String estimate, String mascot);

  /// PR-G3 upload chrome.
  ///
  /// In en, this message translates to:
  /// **'{mascot} has read your notes and added them to the brain. You can now chat, quiz, and review your notes.'**
  String uploadSuccessBody(String mascot);

  /// PR-G3 upload chrome.
  ///
  /// In en, this message translates to:
  /// **'Start chatting'**
  String get uploadStartChatting;

  /// PR-G3 upload chrome.
  ///
  /// In en, this message translates to:
  /// **'Add more notes'**
  String get uploadAddMore;

  /// PR-G3 upload chrome.
  ///
  /// In en, this message translates to:
  /// **'Still building your brain'**
  String get uploadStillBuilding;

  /// PR-G3 upload chrome.
  ///
  /// In en, this message translates to:
  /// **'Taking longer than expected...'**
  String get uploadTakingLonger;

  /// PR-G3 upload chrome.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get uploadSomethingWrong;

  /// PR-G3 upload chrome.
  ///
  /// In en, this message translates to:
  /// **'Large files take a few minutes to compile. {mascot} is still working on it in the background and will update your brain automatically when it\'s ready — no need to re-upload.'**
  String uploadLargeTimeoutBody(String mascot);

  /// PR-G3 upload chrome.
  ///
  /// In en, this message translates to:
  /// **'{mascot} is still working on your notes in the background. Check back in a few minutes — the brain will update automatically.'**
  String uploadTimeoutBody(String mascot);

  /// PR-G3 upload chrome.
  ///
  /// In en, this message translates to:
  /// **'{mascot} couldn\'t process your notes. Try uploading again with a smaller file or different format.'**
  String uploadFailedBody(String mascot);

  /// PR-G3 upload chrome.
  ///
  /// In en, this message translates to:
  /// **'Return to home'**
  String get uploadReturnHome;

  /// PR-G3 upload chrome.
  ///
  /// In en, this message translates to:
  /// **'Large document — splitting into sections (~{estimate})'**
  String uploadSplittingSections(String estimate);

  /// PR-G3 upload chrome.
  ///
  /// In en, this message translates to:
  /// **'Building brain in sections...'**
  String get uploadBuildingSections;

  /// PR-G3 upload chrome.
  ///
  /// In en, this message translates to:
  /// **'Your document is large — {mascot} splits it into sections for better accuracy. Expected: {estimate}. You can close this screen; the brain updates automatically.'**
  String uploadDocLargeExpected(String mascot, String estimate);

  /// PR-G3 upload chrome.
  ///
  /// In en, this message translates to:
  /// **'New pages will appear in your library shortly. Expected: {estimate}.'**
  String uploadPagesShortly(String estimate);

  /// PR-G3 upload chrome.
  ///
  /// In en, this message translates to:
  /// **'Tip: clear, typed or printed pages read best.'**
  String get uploadTipBanner;

  /// Upload source-type dropdown (value stays English; label localized).
  ///
  /// In en, this message translates to:
  /// **'Textbook'**
  String get uploadSourceTextbook;

  /// Upload source-type dropdown (value stays English; label localized).
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get uploadSourceNotes;

  /// Upload source-type dropdown (value stays English; label localized).
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get uploadSourceWebsite;

  /// Upload source-type dropdown (value stays English; label localized).
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get uploadSourceOther;

  /// PR-H wiki/chapters.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 chapter not compiled yet} other{{count} chapters not compiled yet}}'**
  String wikiChaptersNotCompiled(int count);

  /// PR-H wiki/chapters.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{mascot} hasn\'t read this chapter yet — pick which to compile.} other{{mascot} hasn\'t read these chapters yet — pick which to compile.}}'**
  String wikiHasntReadChapters(int count, String mascot);

  /// PR-H wiki/chapters.
  ///
  /// In en, this message translates to:
  /// **'Choose'**
  String get wikiChoose;

  /// PR-H wiki/chapters.
  ///
  /// In en, this message translates to:
  /// **'Choose chapters to compile'**
  String get wikiChooseChaptersCompile;

  /// PR-H wiki/chapters.
  ///
  /// In en, this message translates to:
  /// **'Compile all ({count})'**
  String wikiCompileAll(int count);

  /// PR-H wiki/chapters.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load chapters. Please close and try again.'**
  String get wikiCouldntLoadChapters;

  /// PR-H wiki/chapters.
  ///
  /// In en, this message translates to:
  /// **'{mascot} is reading your chapters!'**
  String wikiReadingChapters(String mascot);

  /// PR-H wiki/chapters.
  ///
  /// In en, this message translates to:
  /// **'{mascot} only reads the chapters you pick — start with what you\'re studying now.'**
  String wikiOnlyReadsPicked(String mascot);

  /// PR-H wiki/chapters.
  ///
  /// In en, this message translates to:
  /// **'No chapters to compile.'**
  String get wikiNoChaptersCompile;

  /// PR-H wiki/chapters.
  ///
  /// In en, this message translates to:
  /// **'Pages {from}–{to} · {count, plural, =1{1 page} other{{count} pages}}'**
  String wikiPagesRange(int from, int to, int count);

  /// PR-H wiki/chapters.
  ///
  /// In en, this message translates to:
  /// **'This takes a few minutes. You can follow along in Library — {mascot} will show which chapter it is reading, and your lessons unlock when it is done.'**
  String wikiTakesFewMinutes(String mascot);

  /// PR-H wiki/chapters.
  ///
  /// In en, this message translates to:
  /// **'Ask {mascot} Now'**
  String wikiAskMochiNow(String mascot);

  /// PR-H wiki/chapters.
  ///
  /// In en, this message translates to:
  /// **'Brain Quality Score'**
  String get wikiBrainQuality;

  /// PR-H wiki/chapters.
  ///
  /// In en, this message translates to:
  /// **'Quick Quiz'**
  String get wikiQuickQuiz;

  /// PR-H wiki/chapters.
  ///
  /// In en, this message translates to:
  /// **'View Brain'**
  String get wikiViewBrain;

  /// PR-H wiki/chapters.
  ///
  /// In en, this message translates to:
  /// **'Add or re-upload content for this page'**
  String get wikiAddReupload;

  /// PR-H wiki/chapters.
  ///
  /// In en, this message translates to:
  /// **'Ask a grown-up to confirm \"{title}\" is accurate.'**
  String wikiAskConfirm(String title);

  /// PR-H wiki/chapters.
  ///
  /// In en, this message translates to:
  /// **'Fix my notes'**
  String get wikiFixNotes;

  /// PR-H wiki/chapters.
  ///
  /// In en, this message translates to:
  /// **'Get it checked'**
  String get wikiGetChecked;

  /// PR-H wiki/chapters.
  ///
  /// In en, this message translates to:
  /// **'Revoke'**
  String get wikiRevoke;

  /// PR-H wiki/chapters.
  ///
  /// In en, this message translates to:
  /// **'Send a link to anyone to check it'**
  String get wikiSendLink;

  /// PR-H wiki/chapters.
  ///
  /// In en, this message translates to:
  /// **'Share review link'**
  String get wikiShareReviewLink;

  /// PR-H wiki/chapters.
  ///
  /// In en, this message translates to:
  /// **'Checked by {name} ✓'**
  String wikiCheckedBy(String name);

  /// PR-H wiki/chapters.
  ///
  /// In en, this message translates to:
  /// **'{name} flagged something:'**
  String wikiReviewerFlagged(String name);

  /// PR-H wiki/chapters.
  ///
  /// In en, this message translates to:
  /// **'This was made from limited notes — double-check key facts.'**
  String get wikiLimitedNotes;

  /// PR-H wiki/chapters.
  ///
  /// In en, this message translates to:
  /// **'Unverified'**
  String get wikiUnverified;

  /// PR-H wiki/chapters.
  ///
  /// In en, this message translates to:
  /// **'a reviewer'**
  String get wikiReviewerFallback;

  /// PR-H wiki/chapters.
  ///
  /// In en, this message translates to:
  /// **'A reviewer'**
  String get wikiReviewerFallbackCap;

  /// PR-H wiki/chapters.
  ///
  /// In en, this message translates to:
  /// **'\"{fileName}\" will be removed and {mascot}\'s brain will update automatically.'**
  String wikiRemoveDoc(String fileName, String mascot);

  /// PR-H wiki/chapters.
  ///
  /// In en, this message translates to:
  /// **'{n} min ago'**
  String wikiMinAgo(int n);

  /// PR-H wiki/chapters.
  ///
  /// In en, this message translates to:
  /// **'Brain is empty'**
  String get wikiBrainEmpty;

  /// PR-H wiki/chapters.
  ///
  /// In en, this message translates to:
  /// **'Checked by {by} ✓{more}'**
  String wikiCheckedByShort(String by, String more);

  /// PR-H wiki/chapters.
  ///
  /// In en, this message translates to:
  /// **'Conflict'**
  String get wikiConflict;

  /// PR-H wiki/chapters.
  ///
  /// In en, this message translates to:
  /// **'Conflicting Info'**
  String get wikiConflictingInfo;

  /// PR-H wiki/chapters.
  ///
  /// In en, this message translates to:
  /// **'Could not save — try again.'**
  String get wikiCouldNotSave;

  /// PR-H wiki/chapters.
  ///
  /// In en, this message translates to:
  /// **'Edit page content'**
  String get wikiEditPageContent;

  /// PR-H wiki/chapters.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get wikiFailed;

  /// PR-H wiki/chapters.
  ///
  /// In en, this message translates to:
  /// **'Fix Now'**
  String get wikiFixNow;

  /// PR-H wiki/chapters.
  ///
  /// In en, this message translates to:
  /// **'Go to Groups'**
  String get wikiGoToGroups;

  /// PR-H wiki/chapters.
  ///
  /// In en, this message translates to:
  /// **'How should {mascot} teach you?'**
  String wikiHowTeach(String mascot);

  /// PR-H wiki/chapters.
  ///
  /// In en, this message translates to:
  /// **'Join a group first'**
  String get wikiJoinGroupFirst;

  /// PR-H wiki/chapters.
  ///
  /// In en, this message translates to:
  /// **'Manage {mascot}s'**
  String wikiManageMochis(String mascot);

  /// PR-H wiki/chapters.
  ///
  /// In en, this message translates to:
  /// **'{mascot} is reading your notes — new pages will appear here automatically.'**
  String wikiReadingNotes(String mascot);

  /// PR-H wiki/chapters.
  ///
  /// In en, this message translates to:
  /// **'Off-topic'**
  String get wikiOffTopic;

  /// PR-H wiki/chapters.
  ///
  /// In en, this message translates to:
  /// **'RECENT PAGES'**
  String get wikiRecentPages;

  /// PR-H wiki/chapters.
  ///
  /// In en, this message translates to:
  /// **'Reading…'**
  String get wikiReading;

  /// PR-H wiki/chapters.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get wikiRemove;

  /// PR-H wiki/chapters.
  ///
  /// In en, this message translates to:
  /// **'Remove document'**
  String get wikiRemoveDocument;

  /// PR-H wiki/chapters.
  ///
  /// In en, this message translates to:
  /// **'Remove document?'**
  String get wikiRemoveDocumentConfirm;

  /// PR-H wiki/chapters.
  ///
  /// In en, this message translates to:
  /// **'Search pages…'**
  String get wikiSearchPages;

  /// PR-H wiki/chapters.
  ///
  /// In en, this message translates to:
  /// **'Share to which group?'**
  String get wikiShareToGroup;

  /// PR-H wiki/chapters.
  ///
  /// In en, this message translates to:
  /// **'Source documents ({count})'**
  String wikiSourceDocuments(int count);

  /// PR-H wiki/chapters.
  ///
  /// In en, this message translates to:
  /// **'Tap a style or write your own — e.g. \"Use the bar model for fractions\" or \"Always show full working.\" {mascot} follows this in every lesson and chat.'**
  String wikiStylePrompt(String mascot);

  /// PR-H wiki/chapters.
  ///
  /// In en, this message translates to:
  /// **'Teacher notes'**
  String get wikiTeacherNotes;

  /// PR-H wiki/chapters.
  ///
  /// In en, this message translates to:
  /// **'This page contains information from multiple sources that may disagree with each other.\n\nYou can fix the content manually to resolve the conflict.'**
  String get wikiConflictBody;

  /// PR-H wiki/chapters.
  ///
  /// In en, this message translates to:
  /// **'You\'re not in any study groups yet. Join or create one, then you can share notes!'**
  String get wikiNoGroups;

  /// PR-H wiki/chapters.
  ///
  /// In en, this message translates to:
  /// **'Your centre keeps this class\'s materials up to date.'**
  String get wikiCentreKeepsUpdated;

  /// PR-H wiki/chapters.
  ///
  /// In en, this message translates to:
  /// **'Your centre sets how this class {mascot} teaches.'**
  String wikiCentreSetsTeaching(String mascot);

  /// PR-H wiki/chapters.
  ///
  /// In en, this message translates to:
  /// **'e.g. Use model method for fractions. Show all steps.'**
  String get wikiStyleExample;

  /// PR-H wiki/chapters.
  ///
  /// In en, this message translates to:
  /// **'from: {sources}'**
  String wikiFrom(String sources);

  /// PR-H wiki/chapters.
  ///
  /// In en, this message translates to:
  /// **'↗ Share'**
  String get wikiShareArrow;

  /// No description provided for @wikiChaptersOverLimit.
  ///
  /// In en, this message translates to:
  /// **'Only {remaining} left this month — deselect {excess}.'**
  String wikiChaptersOverLimit(int remaining, int excess);

  /// No description provided for @wikiChaptersSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String wikiChaptersSelectedCount(int count);

  /// No description provided for @wikiSelectChapters.
  ///
  /// In en, this message translates to:
  /// **'Select one or more chapters'**
  String get wikiSelectChapters;
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
