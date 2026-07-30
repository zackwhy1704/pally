// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get mascotName => 'Mochi';

  @override
  String get language => 'Language';

  @override
  String languagePickerSubtitle(String mascot) {
    return 'Choose the language for the app\'s buttons and menus. This does not change the language your $mascot teaches in.';
  }

  @override
  String get signInWelcomeBack => 'Welcome back! 👋';

  @override
  String get signInEmailLabel => 'Email';

  @override
  String get signInEmailHint => 'your@email.com';

  @override
  String get signInPasswordLabel => 'Password';

  @override
  String get signInForgotPassword => 'Forgot password?';

  @override
  String get signInButton => 'Sign In';

  @override
  String get signInOr => 'or';

  @override
  String get signInUseBiometrics => 'Use Biometrics';

  @override
  String get signInFaceTouchId => 'Face ID / Touch ID';

  @override
  String get signInEnableBiometricHint =>
      'Sign in once to enable biometric login';

  @override
  String get signInNoAccount => 'Don\'t have an account?';

  @override
  String get signInCreateAccount => 'Create Account ✨';

  @override
  String get signInBiometricReason => 'Sign in to Apalchi';

  @override
  String get signInErrorEmptyCredentials =>
      'Please enter your email and password';

  @override
  String get signInErrorBiometricsUnavailable =>
      'Biometrics not available on this device';

  @override
  String get signInErrorBiometricsNotRegistered =>
      'Sign in with your password first — biometrics will be enabled in Settings';

  @override
  String get signInErrorPasswordFirst => 'Sign in with your password first';

  @override
  String get biometricScanning => 'Scanning...';

  @override
  String get biometricVerified => 'Verified! ✨';

  @override
  String get biometricCouldntVerify => 'Couldn\'t verify';

  @override
  String get biometricScanningHint =>
      'Place your finger or look at your camera';

  @override
  String get biometricSigningIn => 'Signing you in...';

  @override
  String get biometricNotRecognised => 'Face or fingerprint not recognised';

  @override
  String get biometricUsePassword => 'Use password instead';

  @override
  String get commonTryAgain => 'Try Again';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get forgotPasswordTitle => 'Reset Password';

  @override
  String get forgotPasswordSend => 'Send Reset Link';

  @override
  String get forgotPasswordSent => 'Check your email for a reset link';

  @override
  String onboardingPageProgress(int current, int total) {
    return '$current of $total';
  }

  @override
  String get onboardingNext => 'Next →';

  @override
  String get onboardingLetsGo => 'Let\'s go →';

  @override
  String get onboardingPage1Title =>
      'I learn from your material — not the whole internet.';

  @override
  String get onboardingPage1Body =>
      'Upload your notes, slides, or lecture decks and I build a brain around exactly what you\'re studying — for a quiz, a final, a module, or just to get it.';

  @override
  String get onboardingContrastOk1Title => 'Your notes & slides';

  @override
  String get onboardingContrastOk1Sub =>
      'I learn exactly what you\'re covering';

  @override
  String get onboardingContrastOk2Title => 'Your lecture decks & readings';

  @override
  String get onboardingContrastOk2Sub =>
      'Same source material, sharper answers';

  @override
  String get onboardingContrastBadTitle => 'Random internet articles';

  @override
  String get onboardingContrastBadSub =>
      'Generic info that might not match your course';

  @override
  String get onboardingPage2Title =>
      'Give me one subject at a time — I go deep.';

  @override
  String onboardingPage2Body(String mascot) {
    return 'Make a separate $mascot for each subject or module. Each one only knows its stuff, so the answers stay sharp — whether it\'s Sec 3 Chemistry or a uni economics module.';
  }

  @override
  String onboardingFocusOkTitle(String mascot) {
    return 'One subject per $mascot';
  }

  @override
  String get onboardingFocusOkSub => 'Deep, accurate answers for that course';

  @override
  String onboardingFocusBadTitle(String mascot) {
    return 'Everything in one $mascot';
  }

  @override
  String get onboardingFocusBadSub => 'Mixed knowledge = muddled answers';

  @override
  String get onboardingPage3Title => 'I remember how you learn.';

  @override
  String get onboardingPage3Body =>
      'When you get something wrong, I notice — and I bring it back until it clicks. The more we study, the better I fit you.';

  @override
  String get onboardingBeat1 => 'Tricky topics come back until they stick';

  @override
  String get onboardingBeat2 => 'Easy things get spaced out — no time wasted';

  @override
  String get onboardingBeat3 => 'The more you study, the better it fits you';

  @override
  String onboardingThesis(String mascot) {
    return '“Not a generic AI — a $mascot that knows your notes.”';
  }

  @override
  String get libraryTitle => 'Library';

  @override
  String get libraryMyClasses => 'My classes';

  @override
  String get libraryLeave => 'Leave';

  @override
  String get libraryDelete => 'Delete';

  @override
  String libraryAvatarDeleted(String name) {
    return '$name deleted';
  }

  @override
  String get libraryDeleteFailed => 'Delete failed. Try again.';

  @override
  String get libraryLeaveClassTitle => 'Leave this class?';

  @override
  String libraryLeaveClassBody(String name, String mascot) {
    return 'You\'ll lose access to $name\'s materials and class $mascot. Your personal ${mascot}s stay. You can rejoin with the class code.';
  }

  @override
  String libraryLeftClass(String name) {
    return 'Left $name';
  }

  @override
  String libraryStatusCompiling(String mascot) {
    return '📖 $mascot is reading your chapters…';
  }

  @override
  String libraryStatusBrainPages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '🧠 $count brain pages',
      one: '🧠 $count brain page',
    );
    return '$_temp0';
  }

  @override
  String libraryStatusBuilding(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '⏳ Building brain from $count files…',
      one: '⏳ Building brain from $count file…',
    );
    return '$_temp0';
  }

  @override
  String get libraryStatusNoNotes =>
      '📂 No notes yet — teach me your material!';

  @override
  String libraryEmptyTitle(String mascot) {
    return 'No ${mascot}s yet';
  }

  @override
  String libraryEmptySubtitle(String mascot) {
    return 'Create a $mascot from the Home tab to see it here.';
  }

  @override
  String get hubLearn => 'Learn';

  @override
  String hubModulesSubtitle(int count, int mastery) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count modules · $mastery% mastery',
      one: '$count module · $mastery% mastery',
    );
    return '$_temp0';
  }

  @override
  String get hubStartFirstModule => 'Start your first module';

  @override
  String get hubSectionPractice => 'Practice';

  @override
  String get hubSectionProveIt => 'Prove it';

  @override
  String get hubSectionTools => 'Tools';

  @override
  String get hubCards => 'Cards';

  @override
  String get hubCardsSubtitle => 'Quick recall practice';

  @override
  String get hubTeach => 'Teach';

  @override
  String hubTeachSubtitle(String mascot) {
    return 'Explain it back to $mascot';
  }

  @override
  String get hubChat => 'Chat';

  @override
  String hubChatSubtitle(String mascot) {
    return 'Ask $mascot anything';
  }

  @override
  String get hubNotes => 'Notes';

  @override
  String get hubNotesSubtitle => 'Review your material';

  @override
  String get hubUpload => 'Upload';

  @override
  String get hubUploadSubtitle => 'Add more material';

  @override
  String get hubClassBadge => 'Class';

  @override
  String get hubUploadNotesCta =>
      'Upload your notes to unlock quizzes, cards and teaching.';

  @override
  String get hubQuiz => 'Quiz';

  @override
  String get hubQuizSubtitleDefault => 'Test yourself with MCQs';

  @override
  String get hubQuizSubtitleDoneToday => 'Done today · free play anytime';

  @override
  String hubQuizSubtitleMastered(int mastered, int total) {
    return 'Test yourself · $mastered/$total mastered';
  }

  @override
  String get commonLoading => 'Loading…';

  @override
  String get commonSomethingWrong => 'Something went wrong.';

  @override
  String chatCouldNotLoadMochis(String mascot) {
    return 'Could not load ${mascot}s.';
  }

  @override
  String chatCreateMochiFirst(String mascot) {
    return 'Create a $mascot from the Home tab first.';
  }

  @override
  String get chatCentreCuratedOnly => 'Centre-curated answers only';

  @override
  String chatMenuTeach(String mascot) {
    return 'Teach $mascot';
  }

  @override
  String get chatMenuAddKnowledge => 'Add knowledge';

  @override
  String chatMenuDelete(String mascot) {
    return 'Delete $mascot';
  }

  @override
  String get chatLostTrain => 'Hmm, I lost my train of thought. Ask me again!';

  @override
  String get chatNotSynced => 'Not synced — tap to retry';

  @override
  String get chatSending => 'Sending…';

  @override
  String get chatDailyDone =>
      'Daily chats done — come back tomorrow or go Premium.';

  @override
  String chatMessagesLeftToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count messages left today',
      one: '1 message left today',
    );
    return '$_temp0';
  }

  @override
  String get chatInputHint => 'Ask anything…';

  @override
  String get chatInputHintWait => 'Please wait…';

  @override
  String get chatSnap => 'Snap';

  @override
  String get chatEmptyTitle => 'Start the conversation!';

  @override
  String chatEmptySubtitle(String mascot) {
    return 'Ask your $mascot anything, or tap 📷 to snap a homework question!';
  }

  @override
  String chatDisclaimer(String mascot) {
    return '$mascot can make mistakes — always double-check your work!';
  }

  @override
  String get chatDoubleCheckNumbers =>
      'Double-check the numbers against your worksheet';

  @override
  String get chatCheckedWithCalculator => 'checked with calculator';

  @override
  String get commonCheckConnection => 'Check your connection and try again.';

  @override
  String get moduleHomeworkTooltip => 'Homework';

  @override
  String get moduleCouldNotLoad => 'Could not load modules.';

  @override
  String get moduleNoNotesToBuild => 'No notes to build lessons from yet.';

  @override
  String get moduleBuildFailed =>
      'Could not build lessons. Check your connection and try again.';

  @override
  String get moduleNoLessonsYet => 'No lessons yet';

  @override
  String get moduleGenerateFromMaterials =>
      'Generate lessons from your class materials.';

  @override
  String get moduleNotesInBuildFirst =>
      'Your notes are in — let\'s build your first lesson.';

  @override
  String get moduleGenerateLessons => 'Generate lessons';

  @override
  String get moduleBuildFirstLesson => 'Build my first lesson';

  @override
  String get moduleAddNotesCta =>
      'Add your notes and I\'ll build your first lesson from them.';

  @override
  String get moduleStageLearn => 'LEARN';

  @override
  String get moduleStageTest => 'TEST';

  @override
  String get moduleStageProve => 'PROVE';

  @override
  String get moduleStageComplete => 'COMPLETE';

  @override
  String get moduleCtaReview => 'Review';

  @override
  String get moduleCtaStartLearning => 'Start learning';

  @override
  String get moduleCtaContinue => 'Continue';

  @override
  String get moduleTeacherReviewed => 'Teacher-reviewed';

  @override
  String moduleRefreshing(String mascot) {
    return '$mascot is refreshing this lesson — check back soon.';
  }

  @override
  String get moduleGoToLibrary => 'Go to Library';

  @override
  String get moduleUnknownStage => 'Unknown stage';

  @override
  String get quizConfidence => 'Confidence';

  @override
  String get quizErrorRetry => 'Something went wrong — try again.';

  @override
  String get quizFinish => 'Finish Quiz';

  @override
  String get quizNextQuestion => 'Next Question';

  @override
  String quizReviewingWeakSpot(String concept) {
    return 'Reviewing your weak spot: $concept.';
  }

  @override
  String get quizAnswerLocked =>
      'Answer locked in — you\'ll see your results at the end.';

  @override
  String get quizCorrect => 'Correct!';

  @override
  String get quizNotQuite => 'Not quite';

  @override
  String quizScoreResult(int score, int total) {
    return 'You got $score out of $total correct.';
  }

  @override
  String get quizComplete => 'Quiz Complete!';

  @override
  String quizBackToMochi(String mascot) {
    return 'Back to $mascot';
  }

  @override
  String quizAnswerLabel(String answer) {
    return 'Answer: $answer';
  }

  @override
  String get quizHowSure => 'How sure are you?';

  @override
  String get quizConfNotSure => 'Not sure';

  @override
  String get quizConfKinda => 'Kinda';

  @override
  String get quizConfVerySure => 'Very sure';

  @override
  String get quizResultMastered => 'Mastered';

  @override
  String get quizResultMisconception => 'Misconception';

  @override
  String get quizResultLuckyGuess => 'Lucky guess';

  @override
  String get quizResultKnownGap => 'Known gap';

  @override
  String quizFocusNext(String topic) {
    return 'Focus next: $topic';
  }

  @override
  String quizTrickyOne(String display) {
    return 'I noticed $display is tricky for you — I\'ll bring it back soon.';
  }

  @override
  String get quizTrickySome =>
      'I noticed some topics were tricky — I\'ll bring them back soon.';

  @override
  String get quizBuilding => 'Building your quiz…';

  @override
  String get quizNoQuizToday => 'No quiz today';

  @override
  String quizUploadNotesCta(String mascot) {
    return 'Upload some notes so $mascot can build your first quiz!';
  }

  @override
  String get navHome => 'Home';

  @override
  String get navLibrary => 'Library';

  @override
  String get navGroups => 'Groups';

  @override
  String get navMe => 'Me';

  @override
  String get homeWelcomeBack => 'Welcome back! 👋';

  @override
  String get homeReadyToLearn => 'Ready to keep learning?';

  @override
  String homeNewMochi(String mascot) {
    return 'New $mascot';
  }

  @override
  String get homeSectionMyClasses => 'MY CLASSES';

  @override
  String get homeSectionYourMochis => 'YOUR MOCHIS';

  @override
  String homeLevelBadge(int level) {
    return '⭐ Level $level';
  }

  @override
  String get homeMaxLevel => 'MAX LEVEL ⭐';

  @override
  String homeXpProgress(int xpInto, int xpSpan) {
    return '$xpInto / $xpSpan XP';
  }

  @override
  String homeCouldNotLoadMochis(String mascot) {
    return 'Could not load ${mascot}s. Pull down to retry.';
  }

  @override
  String homeCouldNotLoadYourMochis(String mascot) {
    return 'Could not load your ${mascot}s.';
  }

  @override
  String get homeCheckConnectionPull =>
      'Check your connection and pull down to retry.';

  @override
  String homeConsentApprove(String mascot) {
    return 'Ask a grown-up to approve your account to make a $mascot.';
  }

  @override
  String get homeResendEmail => 'Resend email';

  @override
  String get homeConsentCollapsedChip =>
      'Awaiting parental approval — tap for options';

  @override
  String get homeConsentWaitingTitle => 'Waiting for parental approval';

  @override
  String homeConsentEmailSent(String email) {
    return 'A consent email was sent to $email. AI features unlock once your parent approves.';
  }

  @override
  String get homeConsentSignOut => 'Sign out';

  @override
  String get homeManageKnowledge => 'Manage knowledge';

  @override
  String get homeCouldNotActivate => 'Could not activate — try again.';

  @override
  String homeMochiLocked(String name) {
    return '$name is locked';
  }

  @override
  String homeActivateError(String mascot) {
    return 'Something went wrong — this $mascot should be active. Pull to refresh.';
  }

  @override
  String homeActivateCapMessage(int cap, String mascot) {
    String _temp0 = intl.Intl.pluralLogic(
      cap,
      locale: localeName,
      other:
          'You have $cap active ${mascot}s on your free plan. Deactivate another $mascot first, then activate this one.\n\nYou can swap once every 24 hours.',
      one:
          'You have 1 active $mascot on your free plan. Deactivate another $mascot first, then activate this one.\n\nYou can swap once every 24 hours.',
    );
    return '$_temp0';
  }

  @override
  String get homeActivating => 'Activating…';

  @override
  String homeActivateAvatar(String name) {
    return 'Activate $name';
  }

  @override
  String get homeClose => 'Close';

  @override
  String get homeNudgeFlashcards => 'You have flashcards due today!';

  @override
  String get homeNudgeStreak => 'Keep your streak going!';

  @override
  String homeReteachMessage(String concept) {
    return 'Can we review $concept? I keep getting it wrong';
  }

  @override
  String get homeReteachThis => 'this';

  @override
  String get homeContinueLearning => 'CONTINUE LEARNING';

  @override
  String homeFlashcardsDue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count flashcards due',
      one: '1 flashcard due',
    );
    return '$_temp0';
  }

  @override
  String homeStartReview(String name) {
    return 'Start with $name — 2-min review';
  }

  @override
  String get homeAssignments => 'ASSIGNMENTS';

  @override
  String get homeAssignmentOverdue => 'Overdue';

  @override
  String homeAssignmentDue(String date) {
    return 'Due: $date';
  }

  @override
  String get homeAssignmentPreClass => 'Pre-class';

  @override
  String get homeAssignmentPostClass => 'Post-class';

  @override
  String get homeAssignmentRevision => 'Revision';

  @override
  String get homeAssignmentCustom => 'Custom';

  @override
  String homeEmptyHi(String name) {
    return 'Hi $name! 👋';
  }

  @override
  String homeEmptySetupFirst(String mascot) {
    return 'Let\'s set up your first $mascot';
  }

  @override
  String homeEmptyNoMochis(String mascot) {
    return 'No ${mascot}s yet!';
  }

  @override
  String homeEmptyCreate(String mascot) {
    return 'Create your first $mascot and start learning something amazing 🚀';
  }

  @override
  String get homeEmptyPickBuddy =>
      'Pick a buddy, teach it your notes, ask it anything!';

  @override
  String homeEmptyCreateButton(String mascot) {
    return '+ Create My First $mascot ✨';
  }

  @override
  String get homeEmptyHaveCode => '🎟️  Have a code? Enter or scan it';

  @override
  String get homeEmptyChipLearn => '🧠 Learn from your notes';

  @override
  String get homeEmptyChipAsk => '💬 Ask any question';

  @override
  String get homeEmptyChipEarn => '⭐ Earn XP & rewards';

  @override
  String get moduleNext => 'Next';

  @override
  String get moduleReadyToTest => 'Ready to test yourself';

  @override
  String get moduleTimeToProve => 'Time to prove you understand';

  @override
  String moduleCardOf(int cardNumber, int total) {
    return 'Card $cardNumber of $total';
  }

  @override
  String moduleCardFallback(int n) {
    return 'Card $n';
  }

  @override
  String get moduleKeyTerms => 'Key terms';

  @override
  String get moduleComplete => 'Module complete!';

  @override
  String moduleXpEarned(int xp) {
    return '+$xp XP';
  }

  @override
  String get moduleYourMastery => 'Your mastery';

  @override
  String get moduleFocusArea => 'Focus area';

  @override
  String moduleReviewToImprove(String concept) {
    return 'Review \"$concept\" to improve your mastery.';
  }

  @override
  String get moduleBackToModules => 'Back to modules';

  @override
  String get moduleRevisionMode =>
      'Revision mode — fresh questions to check your progress.';

  @override
  String get moduleWhichHardest => 'Which part was hardest?';

  @override
  String get moduleMuddiestHint =>
      'Tap the one that felt the muddiest. This helps your tutor know what to review next.';

  @override
  String get moduleSkip => 'Skip';

  @override
  String moduleFromYourNotes(String title) {
    return 'From your notes: $title';
  }

  @override
  String moduleComeback(String concept) {
    return 'That\'s a comeback — $concept got you last time.';
  }

  @override
  String get moduleSubmitAllAnswers => 'Submit all answers';

  @override
  String moduleFocusingOn(String concept) {
    return 'Focusing on $concept — this tripped you up in the Test.';
  }

  @override
  String moduleQuestionNumber(int number) {
    return 'Question $number';
  }

  @override
  String get moduleAnswerHint => 'Write your answer (1-3 sentences)...';

  @override
  String moduleCompareReference(String mascot) {
    return 'Compare what you wrote to the reference. Be honest — this just helps $mascot learn what to revisit.';
  }

  @override
  String get moduleMarkOwnAnswers => 'Mark your own answers';

  @override
  String get modulePartly => 'Partly';

  @override
  String get moduleNo => 'No';

  @override
  String get moduleYourAnswer => 'Your answer';

  @override
  String get moduleReference => 'Reference';

  @override
  String get moduleDidYouGetIt => 'Did you get it?';

  @override
  String get moduleNoItems => 'No items';

  @override
  String get moduleTrueOrFalse => 'True or False?';

  @override
  String get moduleAgree => 'Agree';

  @override
  String get moduleDisagree => 'Disagree';

  @override
  String get moduleCheckingAnswer => 'Checking your answer…';

  @override
  String get moduleFeedbackUnavailable =>
      'Answer recorded — couldn\'t load feedback right now.';

  @override
  String get moduleSpotTheMistake => 'Spot the mistake';

  @override
  String get moduleSpotHint => 'What\'s wrong here? Type what you spotted...';

  @override
  String get moduleRevealError => 'Reveal the error';

  @override
  String get moduleTheError => 'The error:';

  @override
  String get moduleCorrectSolution => 'Correct solution:';

  @override
  String get moduleWereYouRight => 'Were you right?';

  @override
  String get moduleYes => 'Yes';

  @override
  String get moduleChallenge => 'Challenge';

  @override
  String get moduleTypeYourAnswer => 'Type your answer...';

  @override
  String get moduleSubmit => 'Submit';

  @override
  String get moduleYourAnswerColon => 'Your answer:';

  @override
  String get moduleExplanation => 'Explanation:';

  @override
  String get moduleAnswer => 'Answer';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSectionSubscription => 'Subscription';

  @override
  String get settingsSectionReferral => 'Referral';

  @override
  String get settingsSectionProfile => 'Profile';

  @override
  String get settingsSectionNotifications => 'Notifications';

  @override
  String get settingsSectionSecurity => 'Security';

  @override
  String get settingsSectionLearning => 'Learning';

  @override
  String get settingsSectionAbout => 'About';

  @override
  String get settingsSectionAccount => 'Account';

  @override
  String get settingsDisplayName => 'Display Name';

  @override
  String get settingsSave => 'Save';

  @override
  String get settingsNameUpdated => 'Name updated!';

  @override
  String get settingsNameSaveFailed =>
      'Could not save name — check your connection';

  @override
  String get settingsDailyReminder => 'Daily quiz reminder';

  @override
  String get settingsReminderTime => 'Reminder time';

  @override
  String get settingsBiometricLogin => 'Biometric Login';

  @override
  String get settingsBiometricUnavailable => 'Not available on this device';

  @override
  String get settingsBiometricReason => 'Verify to enable biometric login';

  @override
  String get settingsBiometricEnabled => 'Biometric login enabled';

  @override
  String get settingsBiometricEnableFailed =>
      'Could not enable biometric login';

  @override
  String get settingsBiometricDisabled => 'Biometric login disabled';

  @override
  String get settingsLearningStyle => 'Learning style';

  @override
  String get settingsWhyDifferent => 'Why Apalchi is different';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsAboutApalchi => 'About Apalchi';

  @override
  String get settingsPrivacyPolicy => 'Privacy Policy';

  @override
  String get settingsTermsOfService => 'Terms of Service';

  @override
  String get settingsHelpSupport => 'Help & Support';

  @override
  String get settingsEmailUs => 'Email us';

  @override
  String get settingsSignOut => 'Sign Out';

  @override
  String get settingsDeleteAccount => 'Delete Account';

  @override
  String get settingsSignOutTitle => 'Sign Out?';

  @override
  String get settingsSignOutBody => 'You\'ll need to sign in again';

  @override
  String get settingsSubLoadError => 'Could not load — tap to retry';

  @override
  String settingsPremiumTrialLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '⭐ Premium Trial · $days days left',
      one: '⭐ Premium Trial · 1 day left',
    );
    return '$_temp0';
  }

  @override
  String settingsEndsLabel(String date) {
    return 'Ends $date';
  }

  @override
  String get settingsKeepPremiumPrice => 'Keep Premium from US\$9.99/mo';

  @override
  String get settingsKeepPremium => 'Keep Premium';

  @override
  String get settingsFamilyPlan => 'Family plan — managed by parent';

  @override
  String get settingsFreePlan => 'Free plan';

  @override
  String get settingsPremiumManage => 'Tap Manage to update billing or cancel.';

  @override
  String settingsFreePlanSubtitle(String mascot) {
    return 'Unlock unlimited ${mascot}s, chat, and family sharing.';
  }

  @override
  String get settingsManage => 'Manage';

  @override
  String get settingsUpgrade => 'Upgrade';

  @override
  String get settingsManagedByParent =>
      'Your subscription is managed by the parent account.';

  @override
  String get settingsInviteFriends => 'Invite friends';

  @override
  String get settingsInviteFriendsSubtitle =>
      'See your code, share it, track who joined.';

  @override
  String get settingsHaveReferralCode => 'Have a referral code?';

  @override
  String get settingsHaveReferralCodeSubtitle =>
      'Enter it to reward you and the friend who sent it.';

  @override
  String get settingsEnterReferralCode => 'Enter referral code';

  @override
  String get settingsShareReward =>
      'Share the reward with the friend who invited you.';

  @override
  String get settingsCodes6Chars => 'Codes are 6 characters';

  @override
  String get settingsCodeApplied =>
      'Code applied! Take a quiz to activate the reward.';

  @override
  String get settingsApplyCode => 'Apply code';

  @override
  String signupSignedInAs(String name) {
    return 'You\'re signed in as $name. Log out to create a new account?';
  }

  @override
  String get signupAlreadySignedIn =>
      'You\'re already signed in. Log out to create a new account?';

  @override
  String get signupCreateNewAccount => 'Create a new account?';

  @override
  String get signupLogOutContinue => 'Log out & continue';

  @override
  String signupStepOf(int step) {
    return 'Step $step of 3';
  }

  @override
  String get signupSelectAgeGroup =>
      'Please select your age group to continue.';

  @override
  String get signupCreateYourAccount => 'Create your account';

  @override
  String signupStudyBuddy(String mascot) {
    return '$mascot will become your personal study buddy.';
  }

  @override
  String get signupFieldName => 'Name';

  @override
  String get signupHintYourName => 'Your name';

  @override
  String get signupValidatorName => 'Name must be at least 2 characters';

  @override
  String get signupFieldEmail => 'Email';

  @override
  String get signupValidatorEmailEmpty => 'Please enter your email';

  @override
  String get signupValidatorEmailInvalid =>
      'Please enter a valid email (e.g. you@example.com)';

  @override
  String get signupFieldPassword => 'Password';

  @override
  String get signupHintPassword => 'At least 8 characters';

  @override
  String get signupValidatorPassword =>
      'Password must be at least 8 characters';

  @override
  String get signupAgeGroup => 'Age group';

  @override
  String get signupAge13OrOlder => 'I am 13 or older';

  @override
  String get signupAgeUnder13 => 'I am under 13';

  @override
  String get signupFieldParentEmail => 'Parent\'s email address';

  @override
  String get signupValidatorParentEmailEmpty =>
      'Please enter your parent\'s email';

  @override
  String get signupValidatorParentEmailInvalid =>
      'Please enter your parent\'s valid email (e.g. parent@example.com)';

  @override
  String get signupParentApproval =>
      'We\'ll email your parent to approve your account before you can use AI features.';

  @override
  String get signupNext => 'Next';

  @override
  String get signupAlreadyHaveAccount => 'Already have an account? Sign in';

  @override
  String get signupWhatStudying => 'What are you studying?';

  @override
  String get signupPickSubject =>
      'Pick one subject to start with. You can add more later.';

  @override
  String get signupSubject => 'Subject';

  @override
  String get signupEducationStage => 'Education stage';

  @override
  String get signupCreateAccount => 'Create account';

  @override
  String get signupBookSplitChapters => 'Your book is split into chapters';

  @override
  String signupPickChapters(String mascot) {
    return 'Pick the chapters you want $mascot to study first.';
  }

  @override
  String get signupChooseChapters => 'Choose chapters';

  @override
  String get signupAddFirstNotes => 'Add your first notes';

  @override
  String signupNotesInstructions(String mascot) {
    return 'Type or paste your notes below. $mascot will read them and build a study module for you.';
  }

  @override
  String get signupNotesHint => 'Paste or type your notes here...';

  @override
  String signupCharCount(int count) {
    return '$count chars';
  }

  @override
  String signupCharCountMin(int count) {
    return '$count chars (min 50)';
  }

  @override
  String signupAddToMochi(String mascot) {
    return 'Add to $mascot';
  }

  @override
  String get signupOr => 'or';

  @override
  String get signupSnapPhoto => 'Or snap a photo';

  @override
  String get signupChooseFile => 'Or choose a file';

  @override
  String get signupUploadFailed => 'Upload failed. Please try again.';

  @override
  String get signupHaveCode =>
      '🎟️  Have a class or group code? Enter or scan it';

  @override
  String get signupSkipForNow => 'Skip for now';

  @override
  String get signupUploading => 'Uploading your notes...';

  @override
  String signupReadingNotes(String mascot) {
    return '$mascot is reading your notes...';
  }

  @override
  String get signupCreatingModule => 'Creating your first study module...';

  @override
  String get signupWorkingOnIt => 'Working on it...';

  @override
  String get signupTakeMinute => 'This may take a minute.';

  @override
  String get signupThisSubject => 'this subject';

  @override
  String signupNotLikeMaterial(String subject) {
    return 'This doesn\'t look like $subject material';
  }

  @override
  String signupCouldntMatch(String subject) {
    return 'We couldn\'t match it to $subject. Use it anyway, or pick a different file.';
  }

  @override
  String get signupUseAnyway => 'Use it anyway';

  @override
  String get signupChooseDifferentFile => 'Choose a different file';

  @override
  String signupModuleReady(String title) {
    return 'Your \"$title\" module is ready!';
  }

  @override
  String get signupFirstModuleWord => 'first';

  @override
  String signupMochiSetUp(String mascot) {
    return 'Your $mascot is set up!';
  }

  @override
  String signupModuleBuilt(String mascot) {
    return '$mascot has read your notes and built a study module for you.';
  }

  @override
  String get signupStartLearning => 'Start learning';

  @override
  String get signupGoToHome => 'Go to home';

  @override
  String get howDiffTitle => 'What makes Apalchi different 🧠';

  @override
  String get howDiffSubtitle =>
      'Here\'s what you just got — and why it matters.';

  @override
  String get howDiffCard1Title => 'Built from your notes';

  @override
  String howDiffCard1Body(String mascot) {
    return 'Your $mascot learns your material — your textbook, your class notes, your syllabus. So every answer matches what your teacher actually taught, not a generic textbook.';
  }

  @override
  String get howDiffCard2Title => 'Remembers how you learn';

  @override
  String get howDiffCard2Body =>
      'It tracks which topics trip you up and brings them back until they stick. Easy things get spaced out. No time wasted on what you already know.';

  @override
  String get howDiffCard3Title => 'Made for real studying';

  @override
  String howDiffCard3Body(String mascot) {
    return '${mascot}s for every subject — flashcards, daily quizzes, mastery tracking, curriculum-aligned — depth designed for serious learners.';
  }

  @override
  String howDiffQuote(String mascot) {
    return '\"Not a generic tutor. A $mascot that knows yours.\"';
  }

  @override
  String get howDiffGotIt => 'Got it — let\'s study!';

  @override
  String get subjectMaths => 'Maths';

  @override
  String get subjectScience => 'Science';

  @override
  String get subjectEnglish => 'English';

  @override
  String get subjectHistory => 'History';

  @override
  String get subjectCoding => 'Coding';

  @override
  String get subjectArt => 'Art';

  @override
  String get subjectGeography => 'Geography';

  @override
  String get subjectLanguages => 'Languages';

  @override
  String get subjectMusic => 'Music';

  @override
  String get subjectPhysicalEducation => 'Physical Education';

  @override
  String get subjectHealth => 'Health';

  @override
  String get subjectLiterature => 'Literature';

  @override
  String get subjectGeneral => 'General';

  @override
  String get levelPrimary => 'Primary School';

  @override
  String get levelSecondary => 'Secondary School';

  @override
  String get levelHighSchool => 'High School';

  @override
  String get levelUniversity => 'University / Adult';

  @override
  String get levelPrimarySubtitle => 'Ages ~6–11';

  @override
  String get levelSecondarySubtitle => 'Ages ~11–16';

  @override
  String get levelHighSchoolSubtitle => 'Ages ~16–18';

  @override
  String get levelUniversitySubtitle => 'Ages 18+';

  @override
  String get tierPremium => 'Premium';

  @override
  String get tierMax => 'Max';

  @override
  String get tierPro => 'Pro';

  @override
  String get tierFree => 'Free';

  @override
  String get tierFamily => 'Family';

  @override
  String get tierTrial => 'Trial';

  @override
  String get tierCentre => 'Centre';

  @override
  String get achievementsTitle => 'Achievements';

  @override
  String get achievementsRecentlyEarned => 'Recently earned';

  @override
  String achievementsEarnedCount(int earned, int total) {
    return '$earned / $total earned';
  }

  @override
  String achievementsPercentOfAll(int pct) {
    return '$pct% of all achievements';
  }

  @override
  String get progressFirstAchievement =>
      'Complete actions to earn your first achievement.';

  @override
  String get dailyGoalToday => 'Today\'s goal';

  @override
  String get dailyGoalPick => 'Pick your daily goal';

  @override
  String get dailyGoalMinutes => 'Minutes';

  @override
  String get dailyGoalQuizzes => 'Quizzes';

  @override
  String get dailyGoalSet => 'Set my goal';

  @override
  String get dailyGoalCommit => 'Commit to my goal';

  @override
  String get dailyGoalRingHint =>
      'Close this ring every day to keep your streak safe.';

  @override
  String get dailyGoalSaveFailed => 'Could not save goal. Try again.';

  @override
  String get levelRoadmapTitle => 'Level rewards';

  @override
  String levelRoadmapCurrentOf(int current, int max) {
    return 'Level $current of $max';
  }

  @override
  String levelRoadmapRewardsUnlocked(int earned, int total) {
    return '$earned of $total rewards unlocked';
  }

  @override
  String levelN(int level) {
    return 'Level $level';
  }

  @override
  String get levelUpTitle => 'LEVEL UP!';

  @override
  String levelUpReached(int level) {
    return 'Reached Level $level — keep going!';
  }

  @override
  String get levelUpKeepGoing => 'Keep going!';

  @override
  String get levelUpSmarter => 'You\'re getting smarter! 🎓';

  @override
  String get progressTitle => 'My Progress';

  @override
  String get progressTotalXp => 'Total XP';

  @override
  String get progressBadges => 'Badges';

  @override
  String get progressCharacterShop => 'Character Shop';

  @override
  String get progressNeedsWork => 'Needs Work';

  @override
  String get progressPracticeWeak => 'Practice Weak Topics';

  @override
  String progressTopicsCount(int count) {
    return '$count topics';
  }

  @override
  String progressXpToLevel(int xp, int level) {
    return '$xp XP to Level $level';
  }

  @override
  String progressMinThisWeek(int min) {
    return '$min min studied this week';
  }

  @override
  String progressWhichMochi(String mascot) {
    return 'Which $mascot to quiz?';
  }

  @override
  String get progressGoPremium => 'Go Premium';

  @override
  String progressPremiumPitch(String mascot) {
    return 'Unlimited ${mascot}s, chat & family sharing — 7-day free trial';
  }

  @override
  String get progressEnterCode => 'Enter or scan a code someone gave you';

  @override
  String get progressJoinClass => 'Join a class or group';

  @override
  String get progressReferralBonus =>
      'Earn bonus stars when they take their first quiz';

  @override
  String get streakLadder => 'Streak ladder';

  @override
  String streakDays(int days) {
    return '$days days';
  }

  @override
  String streakBest(int days) {
    return 'Best: $days days';
  }

  @override
  String streakMilestoneDay(int days) {
    return '$days-day streak';
  }

  @override
  String get streakBadge1Week => '1-week badge';

  @override
  String get streakBadge2Week => '2-week badge';

  @override
  String get streakBadge30Day => '30-day badge';

  @override
  String get streak100Days => '100 days';

  @override
  String get streakFullYear => 'a full year';

  @override
  String streakMilestoneOverlayTitle(int days) {
    return '$days-DAY STREAK!';
  }

  @override
  String get streakKeepLit => 'Keep it lit!';

  @override
  String get streakMilestoneReached => 'Milestone reached — keep stacking!';

  @override
  String streakDaysToNext(int days, String milestone) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days to $milestone',
      one: '1 day to $milestone',
    );
    return '$_temp0';
  }

  @override
  String get streakFreezeHint =>
      'Freezes save your streak when you miss a day. Hit each new 7-day milestone to earn one back (up to 3).';

  @override
  String get achievementsCategoryStreak => 'Streak';

  @override
  String get achievementsCategoryMastery => 'Mastery';

  @override
  String get achievementsCategoryCuriosity => 'Curiosity';

  @override
  String get achievementsCategoryMilestones => 'Milestones';

  @override
  String get streakUnitDay => 'day';

  @override
  String get streakUnitDays => 'days';

  @override
  String get streakFreezeActive =>
      'A freeze saves your streak if you miss one day.';

  @override
  String get streakFreezeEarn =>
      'Earn a freeze by hitting a new 7-day milestone.';

  @override
  String get unitXp => 'XP';

  @override
  String get unitMin => 'min';

  @override
  String get unitQuiz => 'quiz';

  @override
  String get unitQuizzes => 'quizzes';

  @override
  String dailyGoalValueUnit(int count, String unit) {
    return '$count $unit';
  }

  @override
  String get groupTitle => 'Study Group';

  @override
  String get groupsTitle => 'Study Groups';

  @override
  String get groupsEmpty => 'No groups yet';

  @override
  String get groupsEmptyBody =>
      'Create a group or join one with an invite code from a friend.';

  @override
  String get groupsHaveCode => 'Have an invite code?';

  @override
  String get groupJoin => 'Join';

  @override
  String get groupJoinFailed => 'Couldn\'t join — check the code';

  @override
  String get groupNewTitle => 'New Group';

  @override
  String get groupCreate => 'Create group';

  @override
  String get groupNameLabel => 'Group name';

  @override
  String get groupNameHint => 'Give your group a name';

  @override
  String get groupNameExample => 'Year 6 Science Buddies';

  @override
  String get groupSubjectOptional => 'Subject (optional)';

  @override
  String get groupCreated => 'Group created!';

  @override
  String get groupCreateFailed => 'Could not create group';

  @override
  String get groupLeave => 'Leave group';

  @override
  String get groupLeaveConfirm => 'Leave this group?';

  @override
  String get groupLeaveBody => 'You\'ll need a new invite code to re-join.';

  @override
  String get groupLeaveAction => 'Leave';

  @override
  String get groupAnswersReleased => 'Answers released';

  @override
  String get groupNewChallenge => 'New challenge';

  @override
  String get groupMuddiest => 'Muddiest points';

  @override
  String get groupUpdate => 'Update';

  @override
  String groupOpenAssignment(String mascot) {
    return 'Open this assignment from your class $mascot.';
  }

  @override
  String get groupInviteFriend => 'Invite a friend';

  @override
  String get groupCopy => 'Copy';

  @override
  String get groupCodeCopied => 'Code copied!';

  @override
  String get groupShareCode => 'Share this code with a friend to invite them';

  @override
  String get groupNoNotes => 'No notes shared yet';

  @override
  String get groupNoNotesHint =>
      'Open a wiki page from your Library and tap \"Share to group\" to add the first note!';

  @override
  String get groupShareAnother => 'Share another note from Library';

  @override
  String get groupGoLibrary => 'Go to Library';

  @override
  String get groupOffTopic => 'Off topic?';

  @override
  String groupJoinedName(String name) {
    return 'Joined $name!';
  }

  @override
  String groupNoteBy(String name, String time) {
    return 'by $name · $time';
  }

  @override
  String groupMemberCodeLine(int count, String code) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count members · code $code',
      one: '1 member · code $code',
    );
    return '$_temp0';
  }

  @override
  String get timeJustNow => 'just now';

  @override
  String timeMinAgo(int n) {
    return '${n}m ago';
  }

  @override
  String timeHourAgo(int n) {
    return '${n}h ago';
  }

  @override
  String timeDayAgo(int n) {
    return '${n}d ago';
  }

  @override
  String get challengeTitle => 'Daily Challenge';

  @override
  String get challengeRevealPending => 'Reveal pending';

  @override
  String get challengeCorrectPrefix => 'Correct: ';

  @override
  String get challengeYou => '(you)';

  @override
  String get challengeAnswerHint => 'Type your answer…';

  @override
  String challengeAnsweredReveals(String time) {
    return 'Answered — reveals in $time';
  }

  @override
  String challengeRevealsOn(String day, String month) {
    return 'Reveals $day/$month';
  }

  @override
  String get inviteTitle => 'Invite & connect';

  @override
  String get inviteScanHint => 'Friends can scan this to grab your code';

  @override
  String get inviteShare => 'Share';

  @override
  String get inviteBonus =>
      'You both get bonus stars when they take their first quiz.';

  @override
  String get inviteCopied => 'Code copied';

  @override
  String get inviteLoadFailed => 'Could not load your code — tap to retry';

  @override
  String get inviteAction => 'Invite';

  @override
  String get inviteDismiss => 'Dismiss';

  @override
  String get inviteNudgeBody => 'Invite a friend — you both get bonus stars.';

  @override
  String milestoneStreakNice(int days) {
    return '$days-day streak — nice!';
  }

  @override
  String get joinTitle => 'Enter or scan a code';

  @override
  String get joinBody =>
      'Got a class or study-group code? Type it in, or scan its QR.';

  @override
  String get joinEnterManually => 'Enter code manually';

  @override
  String get joinScanQr => 'Scan QR';

  @override
  String get joinPointQr => 'Point at a class or group QR';

  @override
  String get joinEnterFirst => 'Enter a code first';

  @override
  String get joinInvalidCode => 'That doesn\'t look like a valid code';

  @override
  String get joinParentUnsupported => 'Parent links are no longer supported';

  @override
  String joinedSuccess(String name) {
    return 'Joined $name 🎉';
  }

  @override
  String get joinedFallback => 'successfully';

  @override
  String get shopEarnStars => 'Earn Stars';

  @override
  String get shopMyCollection => 'My Collection';

  @override
  String get shopMysteryBox => 'Mystery Box';

  @override
  String get shopMysteryBoxHint => 'Open to unlock a random character!';

  @override
  String get shopPowerUps => 'Power-ups';

  @override
  String get shopQuizPowerUps => 'Quiz Power-ups';

  @override
  String get shopQuizPowerUpsHint => 'Spend stars to study smarter.';

  @override
  String get shopHintToken => 'Hint token';

  @override
  String get shopDoubleXp => 'Double-XP boost';

  @override
  String get shopBonusQuiz => 'Bonus practice quiz';

  @override
  String get shopStreakFreeze => 'Streak Freeze';

  @override
  String get shopStreakFreezeHint => 'Save your streak if you miss a day.';

  @override
  String get shopStreakFreezeSpend => 'Spend stars to protect your streak.';

  @override
  String get shopAlreadyUnlocked => 'Already Unlocked';

  @override
  String get shopAwesome => 'Awesome!';

  @override
  String get shopNewCharacter => 'New Character Unlocked!';

  @override
  String shopCanUseMochi(String mascot) {
    return 'You can now use this $mascot for studying!';
  }

  @override
  String get shopLoadingOdds => 'Loading odds…';

  @override
  String get shopProbability => '💡 FYI — Probability:';

  @override
  String get shopLearnHarder => 'I will learn harder and try again!';

  @override
  String shopFreezeAdded(int current, int cap) {
    return '❄️ Freeze added — you now have $current/$cap';
  }

  @override
  String shopBought(String label, int count) {
    return 'Bought $label — you now have $count';
  }

  @override
  String shopRarityBadge(String label) {
    return '✨ $label';
  }

  @override
  String get shopLabelHintToken => 'a hint token';

  @override
  String get shopLabelDoubleXp => 'a double-XP boost';

  @override
  String get shopLabelBonusQuiz => 'a bonus quiz';

  @override
  String get shopLabelPowerup => 'a powerup';

  @override
  String get flashcardsTitle => 'Flashcards';

  @override
  String get flashcardQuestion => 'Question';

  @override
  String get flashcardTapFlip => 'Tap to flip';

  @override
  String get flashcardEasy => 'Easy';

  @override
  String get flashcardOkay => 'Okay';

  @override
  String get flashcardHard => 'Hard';

  @override
  String get flashcardEmpty => 'No flashcards yet';

  @override
  String get flashcardReadyMake => 'Ready to make cards';

  @override
  String get flashcardReadyMakeYours => 'Ready to make your cards';

  @override
  String get flashcardGenerate => 'Generate flashcards';

  @override
  String get flashcardRegenerate => 'Regenerate cards';

  @override
  String flashcardHasNotesNoCards(String mascot) {
    return 'Your $mascot has notes but no cards yet.\nTap the button below to generate them.';
  }

  @override
  String flashcardAboutPages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'That\'s about $count pages of notes. It takes a moment — tap when you\'re ready.',
      one:
          'That\'s about 1 page of notes. It takes a moment — tap when you\'re ready.',
    );
    return '$_temp0';
  }

  @override
  String flashcardGenerateN(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Generate cards (~$count pages)',
      one: 'Generate cards (~1 page)',
    );
    return '$_temp0';
  }

  @override
  String get shopHintTokenSub => 'Reveal one wrong option in a quiz.';

  @override
  String get shopDoubleXpSub =>
      'Doubles XP on your next quiz (within the daily cap).';

  @override
  String get shopBonusQuizSub => 'Unlock an extra full-XP quiz today.';

  @override
  String get flashcardFilterAll => 'All';

  @override
  String get flashcardFilterDue => 'Due';

  @override
  String get flashcardFilterWeak => 'Weak';

  @override
  String get flashcardFilterDone => 'Done';

  @override
  String photoBetterPhoto(String mascot) {
    return 'Better photo = better answers from $mascot';
  }

  @override
  String get photoBrightLight => 'Bright light';

  @override
  String get photoChartsX => 'Charts ✕';

  @override
  String get photoClearNumbers => 'Clear numbers ✓';

  @override
  String get photoDiagramsWarn => 'Diagrams ⚠️';

  @override
  String get photoFillFrame => 'Fill the frame';

  @override
  String get photoCloseTips => 'Got it, close tips';

  @override
  String get photoGraphsWarn =>
      'Graphs, charts & shapes don\'t scan well. Type those values yourself.';

  @override
  String get photoHoldStill => 'Hold still';

  @override
  String get photoKeepStraight => 'Keep it straight';

  @override
  String get photoNeatHandwriting => 'Neat handwriting ✓';

  @override
  String get photoPrintedText => 'Printed text ✓';

  @override
  String get photoSymbolsWarn => 'Symbols ⚠️';

  @override
  String get photoTypeInstead => 'Type instead';

  @override
  String photoWhatReads(String mascot) {
    return 'What $mascot reads:';
  }

  @override
  String get photoWhatCanRead => 'What can I read? ›';

  @override
  String get photoPointHomework => '📚 Point at your homework question';

  @override
  String get photoTipsBest => '📷 Tips for best results';

  @override
  String get photoHomeworkResults => 'Homework Results';

  @override
  String get photoNothingShare => 'Nothing to share yet.';

  @override
  String get photoShareResults => 'Share results';

  @override
  String get photoWhatNext => 'What next?';

  @override
  String get photoQuizMe => '🎯 Quiz me on this';

  @override
  String get photoAnotherExample => '💡 Another example';

  @override
  String get photoShowWorking => '📝 Show full working';

  @override
  String photoQuestionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count questions',
      one: '1 question',
    );
    return '$_temp0';
  }

  @override
  String photoIFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '🔍 I found $count questions! Here are the solutions:',
      one: '🔍 I found 1 question! Here are the solutions:',
    );
    return '$_temp0';
  }

  @override
  String photoQuestionsFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count questions found',
      one: '1 question found',
    );
    return '$_temp0';
  }

  @override
  String photoSendQuestions(int count, String mascot) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Send $count questions to $mascot ✨',
      one: 'Send 1 question to $mascot ✨',
    );
    return '$_temp0';
  }

  @override
  String get photoCouldNotRead => 'Could not read photo';

  @override
  String get photoDetecting => 'Detecting questions… 🔍';

  @override
  String get photoEditQuestions => 'Edit questions';

  @override
  String get photoRetake => 'Retake';

  @override
  String get photoDoneUse => 'Done — use these questions ✓';

  @override
  String photoFixMisread(String mascot) {
    return 'Fix any text $mascot misread';
  }

  @override
  String get photoEditQuestionsTitle => '✏️  Edit Questions';

  @override
  String get photoChooseGallery => 'Choose from Gallery';

  @override
  String get photoKeepPhoto => 'Keep Photo';

  @override
  String get photoRetakeConfirm => 'Retake photo?';

  @override
  String get photoRetakeBody =>
      'You\'ll lose the current scan. Choose what to do:';

  @override
  String get photoGreat => 'Great! ✓';

  @override
  String photoFoundInPhoto(String mascot) {
    return 'Here\'s what $mascot found in your photo:';
  }

  @override
  String get photoConfHigh => 'High (>85%)';

  @override
  String photoReadingReport(String mascot) {
    return '$mascot\'s Reading Report';
  }

  @override
  String get photoConfOkish => 'OK-ish';

  @override
  String get photoPerQuestion => 'Per question:';

  @override
  String get photoConfRisky => 'Risky (<50%)';

  @override
  String photoSendAnyway(String mascot) {
    return 'Send anyway ($mascot will do its best)';
  }

  @override
  String get photoConfTricky => 'Tricky (50–85%)';

  @override
  String get photoTrickyWarn => 'Tricky ⚠️';

  @override
  String get photoFixManually => '✏️  Fix text manually';

  @override
  String get photoBetterQuality =>
      '💡 Better quality photos = more accurate answers';

  @override
  String get photoChooseGalleryLower => 'Choose from gallery';

  @override
  String get photoDone => 'Done';

  @override
  String get photoEditText => 'Edit question text…';

  @override
  String get photoKeepThisPhoto => 'Keep this photo';

  @override
  String get photoRetakePhoto => 'Retake photo';

  @override
  String get photoWhatToDo => 'What would you like to do?';

  @override
  String get ocrFixManually => 'Fix text manually';

  @override
  String ocrHowWellReads(String mascot) {
    return 'How well $mascot can read each question';
  }

  @override
  String ocrQuestionLine(int n, String text) {
    return 'Q$n: $text';
  }

  @override
  String get ocrReadingConfidence => 'Reading confidence';

  @override
  String get ocrSendAnyway => 'Send anyway';

  @override
  String get ocrIssuesDetected => 'Issues detected';

  @override
  String get ocrQualityLow => 'Photo quality is low';

  @override
  String get ocrQualityScore => 'Quality score';

  @override
  String get ocrRetakePhoto => 'Retake photo 📸';

  @override
  String get ocrMayMisread => 'Your tutor may misread some questions';

  @override
  String get ocrBestResults => 'Get the best results from your camera';

  @override
  String get ocrGotItTakePhoto => 'Got it — take photo';

  @override
  String get ocrMightNeedFix => 'Might need manual fix';

  @override
  String get ocrPhotoTips => 'Photo tips for better reading';

  @override
  String get ocrWhatReadsWell => 'What reads well';

  @override
  String get ocrBestTip =>
      'Best tip: snap the words & numbers, then type any graph values yourself.';

  @override
  String get ocrCantSee =>
      'But it can\'t truly \"see\" pictures like graphs or shapes — it only reads the text around them.';

  @override
  String ocrReadsWell(String mascot) {
    return '$mascot reads text & numbers really well';
  }

  @override
  String get ocrWhatCanRead => 'What can Apalchi read?';

  @override
  String get ocrWarnDiagram =>
      'This image contains a diagram or chart. Text reading may miss visual elements.';

  @override
  String get ocrWarnMaths =>
      'Maths symbols and equations may not be read perfectly by OCR.';

  @override
  String get ocrWarnGeneric =>
      'Some content in this image may not be read accurately.';

  @override
  String get ocrFixDiagram =>
      'Tap \"Fix text manually\" to describe what the diagram shows.';

  @override
  String get ocrFixSymbols =>
      'Tap \"Fix text manually\" to correct any misread symbols.';

  @override
  String get ocrFixGeneric =>
      'Tap \"Fix text manually\" to review and correct the text.';

  @override
  String get ocrDiagramDetected => 'Diagram detected';

  @override
  String get ocrMathsDetected => 'Maths symbols detected';
}
