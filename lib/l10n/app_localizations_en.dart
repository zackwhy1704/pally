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
  String get hubBossBattleSubtitle => 'Answer questions, defeat the boss';

  @override
  String get hubJoinBattle => 'Join a Live Battle';

  @override
  String get hubJoinBattleSubtitle => 'Enter a class code from your teacher';

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
  String get bossBattleTitle => 'Boss Battle';

  @override
  String bossBattleHpRemaining(int remaining, int max) {
    return '$remaining / $max hits left';
  }

  @override
  String get bossBattleAttack => 'Attack!';

  @override
  String get bossBattleDefeatedTitle => 'Boss defeated!';

  @override
  String bossBattleRewardMessage(String mascot) {
    return 'Your $mascot companion is thrilled with you!';
  }

  @override
  String get bossBattleNoBossTitle => 'No boss to fight right now';

  @override
  String get bossBattleNoBossBody =>
      'Keep practicing — a boss shows up once we spot a topic you\'re finding tricky.';

  @override
  String get classroomJoinTitle => 'Join Classroom Battle';

  @override
  String get classroomJoinCodeLabel => 'Class code';

  @override
  String get classroomNicknameLabel => 'Your nickname (just for this game)';

  @override
  String get classroomJoinCta => 'Join Battle';

  @override
  String get classroomBattleTitle => 'Classroom Battle';

  @override
  String get classroomNotJoinedYet =>
      'Join a classroom battle first to see this.';

  @override
  String get classroomSessionEnded => 'The teacher ended this session.';

  @override
  String get classroomBossDefeated => 'The class defeated the boss!';

  @override
  String classroomParticipantCount(int count) {
    return '$count in this battle';
  }

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
  String get signupTermsCheckboxLabel =>
      'I agree to the Terms of Use — including zero tolerance for objectionable content or abusive behavior.';

  @override
  String get signupViewFullTerms => 'Read the full Terms of Use';

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

  @override
  String uploadErrCouldNotRead(String fileName) {
    return 'Could not read \"$fileName\" — try selecting it again.';
  }

  @override
  String uploadErrEmpty(String fileName) {
    return '\"$fileName\" appears to be empty.';
  }

  @override
  String uploadErrTooLarge(String fileName, String size) {
    return '\"$fileName\" is ${size}MB — max is 25MB. Try splitting it into smaller sections.';
  }

  @override
  String uploadErrUnsupported(String fileName, String ext) {
    return '\"$fileName\" is a .$ext file — only PDFs, images, and text files are supported.';
  }

  @override
  String uploadErrCorrupted(String fileName) {
    return '\"$fileName\" couldn\'t be read — it may be empty or corrupted.';
  }

  @override
  String get uploadErrSession => 'Session expired. Please sign in again.';

  @override
  String get uploadErrPlanLimit => 'You\'ve reached a plan limit.';

  @override
  String get uploadErrNoPermission =>
      'You don\'t have permission to upload here.';

  @override
  String uploadErrDuplicate(String fileName, String existing, String mascot) {
    return '\"$fileName\" is identical to \"$existing\" already in your $mascot\'s brain. No need to upload it again!';
  }

  @override
  String uploadErrSimilar(String fileName, String existing, String mascot) {
    return '\"$fileName\" is very similar to \"$existing\" already in your $mascot\'s brain. Uploading it again won\'t teach $mascot anything new.';
  }

  @override
  String uploadErrTooLarge413(String fileName) {
    return '\"$fileName\" is too large (max 25MB). Try splitting it into smaller sections.';
  }

  @override
  String uploadErrUnsupported415(String fileName) {
    return '\"$fileName\" isn\'t a supported file type. Use a PDF, image, or text file.';
  }

  @override
  String get uploadErrTooMany =>
      'Too many uploads at once. Wait a moment and try again.';

  @override
  String uploadErrProcessing(String fileName) {
    return '\"$fileName\" couldn\'t be processed — it may be password-protected or corrupted. Try a different version.';
  }

  @override
  String uploadErrServerBusy(String fileName) {
    return 'The server is busy right now. Wait a moment and try uploading \"$fileName\" again.';
  }

  @override
  String uploadErrMochiBusy(String mascot) {
    return '$mascot is busy right now — try again in a moment.';
  }

  @override
  String uploadErrStillWorking(String mascot) {
    return '$mascot is still working on your notes in the background — check back in a few minutes.';
  }

  @override
  String uploadErrTimeout(String fileName) {
    return 'Upload of \"$fileName\" timed out. Check your connection and try again.';
  }

  @override
  String get uploadErrNoInternet =>
      'No internet connection. Check your WiFi and try again.';

  @override
  String uploadErrFailed(String fileName) {
    return 'Upload of \"$fileName\" failed. Please try again.';
  }

  @override
  String uploadErrUnexpected(String fileName) {
    return 'Something unexpected went wrong uploading \"$fileName\". Try again.';
  }

  @override
  String get uploadExistingFileFallback => 'an existing file';

  @override
  String get uploadExistingNotesFallback => 'existing notes';

  @override
  String get uploadWarnBackup =>
      'I used my backup reader for this one — double-check it looks right.';

  @override
  String get uploadWarnLowText =>
      'I couldn\'t read much text from this — re-upload a clearer copy or type it. It won\'t train me well as-is.';

  @override
  String get uploadEstShort => '30–60 sec';

  @override
  String get uploadEstMedium => '1–2 min';

  @override
  String get uploadEstLong => '3–5 min';

  @override
  String get uploadAddKnowledge => 'Add Knowledge';

  @override
  String get uploadBrainUpdated => 'Brain updated!';

  @override
  String get uploadBuildBrain => 'Build my brain';

  @override
  String get uploadChoosePdf => 'Choose a PDF from your device';

  @override
  String get uploadExtractedTextHint => 'Extracted text...';

  @override
  String get uploadLargeFile => 'Large file — this takes a few minutes';

  @override
  String get uploadLooksGood => 'Looks good';

  @override
  String get uploadPasteClipboard => 'Paste from clipboard';

  @override
  String get uploadReupload => 'Re-upload';

  @override
  String get uploadReviewExtracted => 'Review extracted text';

  @override
  String get uploadSaveEdits => 'Save edits';

  @override
  String get uploadSnapNotes => 'Snap your notes or textbook';

  @override
  String get uploadSource => 'Source';

  @override
  String get uploadTagOptional => 'Tag this upload (optional)';

  @override
  String get uploadTakePhoto => 'Take a photo';

  @override
  String get uploadTopicHint => 'Topic (e.g. Algebra)';

  @override
  String get uploadUploadPdf => 'Upload PDF';

  @override
  String get uploadNotesBecomeBrain => 'Your notes become my brain.';

  @override
  String uploadAddingNotesTo(String subject) {
    return 'Adding notes to $subject';
  }

  @override
  String uploadFilesUploaded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count files uploaded',
      one: '1 file uploaded',
    );
    return '$_temp0';
  }

  @override
  String uploadLargeFileNotice(String mb, String estimate, String mascot) {
    return 'This is a large file (${mb}MB). Building your brain from it can take about $estimate. You can leave this screen — $mascot keeps building in the background and updates automatically when it\'s ready.';
  }

  @override
  String uploadSuccessBody(String mascot) {
    return '$mascot has read your notes and added them to the brain. You can now chat, quiz, and review your notes.';
  }

  @override
  String get uploadStartChatting => 'Start chatting';

  @override
  String get uploadAddMore => 'Add more notes';

  @override
  String get uploadStillBuilding => 'Still building your brain';

  @override
  String get uploadTakingLonger => 'Taking longer than expected...';

  @override
  String get uploadSomethingWrong => 'Something went wrong';

  @override
  String uploadLargeTimeoutBody(String mascot) {
    return 'Large files take a few minutes to compile. $mascot is still working on it in the background and will update your brain automatically when it\'s ready — no need to re-upload.';
  }

  @override
  String uploadTimeoutBody(String mascot) {
    return '$mascot is still working on your notes in the background. Check back in a few minutes — the brain will update automatically.';
  }

  @override
  String uploadFailedBody(String mascot) {
    return '$mascot couldn\'t process your notes. Try uploading again with a smaller file or different format.';
  }

  @override
  String get uploadReturnHome => 'Return to home';

  @override
  String uploadSplittingSections(String estimate) {
    return 'Large document — splitting into sections (~$estimate)';
  }

  @override
  String get uploadBuildingSections => 'Building brain in sections...';

  @override
  String uploadDocLargeExpected(String mascot, String estimate) {
    return 'Your document is large — $mascot splits it into sections for better accuracy. Expected: $estimate. You can close this screen; the brain updates automatically.';
  }

  @override
  String uploadPagesShortly(String estimate) {
    return 'New pages will appear in your library shortly. Expected: $estimate.';
  }

  @override
  String get uploadTipBanner => 'Tip: clear, typed or printed pages read best.';

  @override
  String get uploadSourceTextbook => 'Textbook';

  @override
  String get uploadSourceNotes => 'Notes';

  @override
  String get uploadSourceWebsite => 'Website';

  @override
  String get uploadSourceOther => 'Other';

  @override
  String wikiChaptersNotCompiled(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count chapters not compiled yet',
      one: '1 chapter not compiled yet',
    );
    return '$_temp0';
  }

  @override
  String wikiHasntReadChapters(int count, String mascot) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$mascot hasn\'t read these chapters yet — pick which to compile.',
      one: '$mascot hasn\'t read this chapter yet — pick which to compile.',
    );
    return '$_temp0';
  }

  @override
  String get wikiChoose => 'Choose';

  @override
  String get wikiChooseChaptersCompile => 'Choose chapters to compile';

  @override
  String wikiCompileAll(int count) {
    return 'Compile all ($count)';
  }

  @override
  String get wikiCouldntLoadChapters =>
      'Couldn\'t load chapters. Please close and try again.';

  @override
  String wikiReadingChapters(String mascot) {
    return '$mascot is reading your chapters!';
  }

  @override
  String wikiOnlyReadsPicked(String mascot) {
    return '$mascot only reads the chapters you pick — start with what you\'re studying now.';
  }

  @override
  String get wikiNoChaptersCompile => 'No chapters to compile.';

  @override
  String wikiPagesRange(int from, int to, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pages',
      one: '1 page',
    );
    return 'Pages $from–$to · $_temp0';
  }

  @override
  String wikiTakesFewMinutes(String mascot) {
    return 'This takes a few minutes. You can follow along in Library — $mascot will show which chapter it is reading, and your lessons unlock when it is done.';
  }

  @override
  String wikiAskMochiNow(String mascot) {
    return 'Ask $mascot Now';
  }

  @override
  String get wikiBrainQuality => 'Brain Quality Score';

  @override
  String get wikiQuickQuiz => 'Quick Quiz';

  @override
  String get wikiViewBrain => 'View Brain';

  @override
  String get wikiAddReupload => 'Add or re-upload content for this page';

  @override
  String wikiAskConfirm(String title) {
    return 'Ask a grown-up to confirm \"$title\" is accurate.';
  }

  @override
  String get wikiFixNotes => 'Fix my notes';

  @override
  String get wikiGetChecked => 'Get it checked';

  @override
  String get wikiRevoke => 'Revoke';

  @override
  String get wikiSendLink => 'Send a link to anyone to check it';

  @override
  String get wikiShareReviewLink => 'Share review link';

  @override
  String wikiCheckedBy(String name) {
    return 'Checked by $name ✓';
  }

  @override
  String wikiReviewerFlagged(String name) {
    return '$name flagged something:';
  }

  @override
  String get wikiLimitedNotes =>
      'This was made from limited notes — double-check key facts.';

  @override
  String get wikiUnverified => 'Unverified';

  @override
  String get wikiReviewerFallback => 'a reviewer';

  @override
  String get wikiReviewerFallbackCap => 'A reviewer';

  @override
  String wikiRemoveDoc(String fileName, String mascot) {
    return '\"$fileName\" will be removed and $mascot\'s brain will update automatically.';
  }

  @override
  String wikiMinAgo(int n) {
    return '$n min ago';
  }

  @override
  String get wikiBrainEmpty => 'Brain is empty';

  @override
  String wikiCheckedByShort(String by, String more) {
    return 'Checked by $by ✓$more';
  }

  @override
  String get wikiConflict => 'Conflict';

  @override
  String get wikiConflictingInfo => 'Conflicting Info';

  @override
  String get wikiCouldNotSave => 'Could not save — try again.';

  @override
  String get wikiEditPageContent => 'Edit page content';

  @override
  String get wikiFailed => 'Failed';

  @override
  String get wikiFixNow => 'Fix Now';

  @override
  String get wikiGoToGroups => 'Go to Groups';

  @override
  String wikiHowTeach(String mascot) {
    return 'How should $mascot teach you?';
  }

  @override
  String get wikiJoinGroupFirst => 'Join a group first';

  @override
  String wikiManageMochis(String mascot) {
    return 'Manage ${mascot}s';
  }

  @override
  String wikiReadingNotes(String mascot) {
    return '$mascot is reading your notes — new pages will appear here automatically.';
  }

  @override
  String get wikiOffTopic => 'Off-topic';

  @override
  String get wikiRecentPages => 'RECENT PAGES';

  @override
  String get wikiReading => 'Reading…';

  @override
  String get wikiRemove => 'Remove';

  @override
  String get wikiRemoveDocument => 'Remove document';

  @override
  String get wikiRemoveDocumentConfirm => 'Remove document?';

  @override
  String get wikiSearchPages => 'Search pages…';

  @override
  String get wikiShareToGroup => 'Share to which group?';

  @override
  String wikiSourceDocuments(int count) {
    return 'Source documents ($count)';
  }

  @override
  String wikiStylePrompt(String mascot) {
    return 'Tap a style or write your own — e.g. \"Use the bar model for fractions\" or \"Always show full working.\" $mascot follows this in every lesson and chat.';
  }

  @override
  String get wikiTeacherNotes => 'Teacher notes';

  @override
  String get wikiConflictBody =>
      'This page contains information from multiple sources that may disagree with each other.\n\nYou can fix the content manually to resolve the conflict.';

  @override
  String get wikiNoGroups =>
      'You\'re not in any study groups yet. Join or create one, then you can share notes!';

  @override
  String get wikiCentreKeepsUpdated =>
      'Your centre keeps this class\'s materials up to date.';

  @override
  String wikiCentreSetsTeaching(String mascot) {
    return 'Your centre sets how this class $mascot teaches.';
  }

  @override
  String get wikiStyleExample =>
      'e.g. Use model method for fractions. Show all steps.';

  @override
  String wikiFrom(String sources) {
    return 'from: $sources';
  }

  @override
  String get wikiShareArrow => '↗ Share';

  @override
  String wikiChaptersOverLimit(int remaining, int excess) {
    return 'Only $remaining left this month — deselect $excess.';
  }

  @override
  String wikiChaptersSelectedCount(int count) {
    return '$count selected';
  }

  @override
  String get wikiSelectChapters => 'Select one or more chapters';

  @override
  String get createTutorSubjectTitle => 'What subject?';

  @override
  String createTutorSubjectPrompt(String name) {
    return 'What will $name help you with?';
  }

  @override
  String get createTutorSubjectHint => 'e.g. Maths, Science, Guitar…';

  @override
  String get createTutorQuickPicks => 'Quick picks';

  @override
  String get createTutorGradeTitle => 'Almost there! 🎓';

  @override
  String createTutorGradePrompt(String name) {
    return 'Help $name teach at the right level. (Optional)';
  }

  @override
  String get createTutorSelectAge => 'Select age (optional)';

  @override
  String get createTutorNotSet => '— Not set —';

  @override
  String createTutorCreateName(String name) {
    return 'Create $name! 🎉';
  }

  @override
  String createTutorNameTitle(String mascot) {
    return 'Give your $mascot a name';
  }

  @override
  String createTutorNamePrompt(String mascot) {
    return 'What would you like to call your $mascot?';
  }

  @override
  String get createTutorNameHint => 'e.g. Robo, Prof. Felix…';

  @override
  String createTutorChooseTitle(String mascot) {
    return 'Choose Your $mascot';
  }

  @override
  String createTutorChooseSubtitle(String mascot) {
    return 'Pick a $mascot that matches your vibe! 🎉';
  }

  @override
  String createTutorLoadFailed(String mascot) {
    return 'Could not load ${mascot}s — tap to retry.';
  }

  @override
  String get createTutorCharLocked => 'Character Locked';

  @override
  String createTutorUnlockPrompt(String name) {
    return 'Earn XP to open a mystery box and unlock $name!';
  }

  @override
  String get createTutorOpenMysteryBox => 'Open Mystery Box';

  @override
  String get createTutorStarsToUnlock => '600 ⭐ to unlock';

  @override
  String createTutorScreenTitle(String mascot) {
    return 'Create $mascot';
  }

  @override
  String createTutorErrFailed(String mascot) {
    return 'Could not create $mascot. Please try again.';
  }

  @override
  String get chatGeneralKnowledge =>
      '🌐 general knowledge — upload notes for tailored answers';

  @override
  String get chatFromYourNotes => '📖 from your notes';

  @override
  String get reportTitle => 'Report this message';

  @override
  String reportBlurb(String mascot) {
    return 'Help us keep $mascot safe and helpful. We\'ll look into it.';
  }

  @override
  String reportReasonUnsafe(String mascot) {
    return 'Something $mascot said was not safe or upsetting';
  }

  @override
  String reportReasonWrong(String mascot) {
    return '$mascot got it wrong or was confusing';
  }

  @override
  String get reportReasonOther => 'Something else';

  @override
  String get reportCommentLabel => 'Want to tell us more? (optional)';

  @override
  String get reportCommentHint => 'Type here…';

  @override
  String get reportSend => 'Send report';

  @override
  String reportFooter(String mascot) {
    return 'Your report helps keep $mascot safe.';
  }

  @override
  String get homeworkCouldNotSolve =>
      'Could not solve these questions. Please try again with a clearer photo.';

  @override
  String get homeworkViewFullResults => 'Tap to view full results →';

  @override
  String homeworkSolvedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Solved $count questions!',
      one: 'Solved 1 question!',
    );
    return '$_temp0';
  }

  @override
  String homeworkXpEarned(int xp) {
    return '+$xp XP earned';
  }

  @override
  String get homeworkShowWorking => '📝 Show full working';

  @override
  String get homeworkAnotherExample => '🔄 Another example';

  @override
  String get homeworkQuizMe => '⚡ Quiz me on this';

  @override
  String homeworkFromPage(String page) {
    return '📖 from $page.md';
  }

  @override
  String photoQuestionsDetected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count questions detected',
      one: '1 question detected',
    );
    return '📷 $_temp0';
  }

  @override
  String get photoHomeworkPhoto => '📷 Homework photo';

  @override
  String get photoReadingHomework => 'Hold on, I\'m reading your homework… 🔍';

  @override
  String get answerCardShow => 'Show →';

  @override
  String get aiDisclosureTitle => 'A quick note about AI';

  @override
  String get aiDisclosureBody =>
      'Apalchi uses AI helpers to turn your notes into lessons. Your notes are sent to two AI companies — Anthropic (Claude) and Google (Gemini) — whose computers are outside Singapore. They only use your notes to make your study material.';

  @override
  String get aiDisclosureGrownup =>
      'A grown-up looks after this choice for you.';

  @override
  String get aiDisclosureOkToContinue => 'OK to continue?';

  @override
  String get aiDisclosureAnthropic => 'Anthropic (Claude)';

  @override
  String get aiDisclosureAnthropicDesc =>
      'Makes your explanations, quizzes and chat replies.';

  @override
  String get aiDisclosureGoogle => 'Google (Gemini)';

  @override
  String get aiDisclosureGoogleDesc => 'Helps read and understand your notes.';

  @override
  String get aiDisclosureOutside =>
      'These companies are outside Singapore. We only send what we need to make your study material.';

  @override
  String get aiDisclosureReadMore => 'Read more';

  @override
  String get aiDisclosureOk => 'OK';

  @override
  String get aiDisclosureAgree => 'I agree';

  @override
  String get consentNotNow => 'Not now';

  @override
  String get consentApprovedTitle => 'Approved';

  @override
  String consentApprovedBody(String mascot) {
    return 'Your grown-up said yes — your account is ready. Let\'s start learning with $mascot!';
  }

  @override
  String get consentPendingSend => 'Send';

  @override
  String consentPendingResent(String email) {
    return 'Approval email re-sent to $email — check inbox and spam.';
  }

  @override
  String get consentPendingSending => 'Sending…';

  @override
  String consentPendingResendIn(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get consentPendingResendEmail => 'Resend email';

  @override
  String get consentPendingTitle => 'Almost there! 🎉';

  @override
  String get consentPendingSubtitle => 'We just need a grown-up to say yes.';

  @override
  String get consentPendingAskEmailBefore =>
      'Ask them to check their email at ';

  @override
  String get consentPendingAskEmailAfter => ' and tap the link.';

  @override
  String get consentPendingSpamNote =>
      'It can take a minute. If they don\'t see it, ask them to check their spam or junk folder and tap \'Not spam\' so the next one arrives properly.';

  @override
  String get consentPendingAutoUnlock =>
      'We\'ll unlock automatically the moment they do — you can close the app, it\'ll be ready when you\'re back.';

  @override
  String get consentPendingNotApproved =>
      'Not approved yet — ask your grown-up to tap the link, then try again.';

  @override
  String get consentPendingGotIt => 'Got it';

  @override
  String get deleteAccountAppBar => 'Delete account';

  @override
  String get deleteAccountTitle => 'Delete your account?';

  @override
  String get deleteAccountIntro =>
      'This permanently deletes your account. It cannot be undone after the restore window closes.';

  @override
  String get deleteAccountWhatDeleted => 'What gets deleted';

  @override
  String deleteAccountItem1(String mascot) {
    return 'Your ${mascot}s and everything they learned from your notes';
  }

  @override
  String get deleteAccountItem2 =>
      'Your uploaded notes, lessons, quizzes and flashcards';

  @override
  String get deleteAccountItem3 =>
      'Your progress, streaks, stars and chat history';

  @override
  String get deleteAccountGrace =>
      'You have 14 days to change your mind. Sign back in during that time to restore your account and all your data. After 14 days it is gone for good.';

  @override
  String get deleteAccountKeep => 'Keep my account';

  @override
  String get deleteAccountConfirmTitle => 'Confirm it\'s you';

  @override
  String get deleteAccountConfirmBody =>
      'For your security, confirm your identity before we schedule the deletion.';

  @override
  String get deleteAccountEmailCode => 'Email me a code instead';

  @override
  String get deleteAccountCodeSent =>
      'We emailed you a 6-digit code. Enter it below to confirm.';

  @override
  String get deleteAccountCodeLabel => '6-digit code';

  @override
  String get deleteAccountConfirmBtn => 'Delete my account';

  @override
  String get deleteAccountBack => 'Back';

  @override
  String get deleteAccountScheduledTitle =>
      'Your account is scheduled for deletion';

  @override
  String deleteAccountScheduledOn(String date) {
    return 'It will be permanently deleted on $date.';
  }

  @override
  String get deleteAccountScheduledGeneric =>
      'It will be permanently deleted after the 14-day restore window.';

  @override
  String get deleteAccountChangedMind =>
      'Changed your mind? Sign back in before then to restore your account and all your data.';

  @override
  String get deleteAccountManualCancel =>
      'If you subscribed through the App Store or Google Play, remember to cancel your subscription in your device\'s subscription settings — deleting your account here does not cancel it.';

  @override
  String get deleteAccountErrEnterCredential =>
      'Enter your password or the emailed code to confirm.';

  @override
  String get restoreScheduledTitle => 'This account is scheduled for deletion';

  @override
  String restoreScheduledOn(String date) {
    return 'It will be permanently deleted on $date. Restore it now to keep your account and all your data.';
  }

  @override
  String get restoreGeneric =>
      'Restore it now to keep your account and all your data.';

  @override
  String get restoreBtn => 'Restore my account';

  @override
  String get completeProfileTitle => 'One quick thing';

  @override
  String get completeProfileSubtitle =>
      'Tell us your age group so we can set up your account safely.';

  @override
  String get completeProfileAgeGroup => 'Age group';

  @override
  String get completeProfile13Plus => 'I am 13 or older';

  @override
  String get completeProfileUnder13 => 'I am under 13';

  @override
  String get completeProfileErrSelectAge =>
      'Please select your age group to continue.';

  @override
  String get completeProfileErrParentEmail =>
      'Please enter your parent\'s email address.';

  @override
  String get completeProfileErrGeneric =>
      'Something went wrong. Please try again.';

  @override
  String get monthJan => 'January';

  @override
  String get monthFeb => 'February';

  @override
  String get monthMar => 'March';

  @override
  String get monthApr => 'April';

  @override
  String get monthMay => 'May';

  @override
  String get monthJun => 'June';

  @override
  String get monthJul => 'July';

  @override
  String get monthAug => 'August';

  @override
  String get monthSep => 'September';

  @override
  String get monthOct => 'October';

  @override
  String get monthNov => 'November';

  @override
  String get monthDec => 'December';

  @override
  String dateFormatDMY(int day, String month, int year) {
    return '$day $month $year';
  }

  @override
  String get consentApprovedAllSet => 'You\'re all set! 🎉';

  @override
  String get consentApprovedLetsGo => 'Let\'s go!';

  @override
  String get consentPendingEmailLabel => 'Your grown-up\'s email';

  @override
  String get consentPendingHelperText =>
      'We\'ll send the approval link here instead.';

  @override
  String get consentPendingResendFailed =>
      'Couldn\'t resend just now — try again shortly.';

  @override
  String get consentPendingRefresh => 'I\'ve approved — refresh';

  @override
  String get consentPendingChangeEmail => 'Wrong grown-up\'s email? Change it';

  @override
  String get completeProfileParentEmailLabel => 'Parent\'s email address';

  @override
  String get completeProfileParentEmailRequired =>
      'Please enter your parent\'s email';

  @override
  String get completeProfileParentEmailInvalid =>
      'Please enter your parent\'s valid email (e.g. parent@example.com)';

  @override
  String get completeProfileParentEmailHelper =>
      'We\'ll email your parent to approve your account before you can use AI features.';

  @override
  String get commonTryAgainSentence => 'Try again';

  @override
  String teachTitle(String mascot) {
    return 'Teach $mascot';
  }

  @override
  String teachIntro(String mascot) {
    return 'Pick a topic and TEACH $mascot! Explaining is the fastest way to know you really understand.';
  }

  @override
  String teachAboutLabel(String mascot) {
    return 'Teach $mascot about';
  }

  @override
  String teachHint(String mascot) {
    return 'Pretend $mascot has never heard of this. Use your own words…';
  }

  @override
  String get teachSubmit => 'Done — show me how I did';

  @override
  String get teachPerfect => 'You taught it all!';

  @override
  String get teachGreat => 'Great teaching!';

  @override
  String commonXpPlus(int xp) {
    return '+$xp XP';
  }

  @override
  String get teachYouExplained => 'You explained';

  @override
  String get teachMissedConcepts => 'Missed concepts';

  @override
  String teachMochiAsks(String mascot, String question) {
    return '$mascot asks: $question';
  }

  @override
  String get teachPickAnother => 'Pick another';

  @override
  String get teachNoTopics => 'No topics to teach yet';

  @override
  String teachNoTopicsPersonalDesc(String mascot) {
    return 'Upload some notes first so $mascot has something to learn from!';
  }

  @override
  String teachCouldntCheck(String mascot) {
    return '$mascot couldn\'t check this one';
  }

  @override
  String get teachEvalFailedFallback =>
      'Something went wrong — give it another go.';

  @override
  String get hwTitle => 'Homework';

  @override
  String get hwSubmit => 'Submit homework';

  @override
  String get hwEmptyTitle => 'No homework yet';

  @override
  String get hwEmptyBody =>
      'Submit a photo or PDF of your work and your teacher will send back feedback here.';

  @override
  String get hwBadgeFeedbackReady => 'Feedback ready';

  @override
  String get hwBadgeRedo => 'Please redo';

  @override
  String get hwBadgeInReview => 'In review';

  @override
  String get hwHintReleasedBody =>
      'Your teacher has reviewed your work — read their feedback below.';

  @override
  String get hwHintReturnedTitle => 'Returned for another go';

  @override
  String get hwHintReturnedBody =>
      'Your teacher asked you to take another look and resubmit.';

  @override
  String get hwHintInReviewBody =>
      'Your teacher is reviewing your work. You\'ll see their feedback here once they share it.';

  @override
  String get hwTeacherFeedback => 'Teacher\'s feedback';

  @override
  String get hwWhatYouSubmitted => 'What you submitted';

  @override
  String get hwFieldTitle => 'Title';

  @override
  String get hwFieldTitleHint => 'e.g. Maths worksheet 3';

  @override
  String get hwFieldSubject => 'Subject (optional)';

  @override
  String get hwFieldSubjectHint => 'e.g. Mathematics';

  @override
  String get hwYourWork => 'Your work';

  @override
  String get hwSubmitting => 'Submitting…';

  @override
  String get hwSubmitToTeacher => 'Submit to teacher';

  @override
  String get hwReviewNote =>
      'Your teacher reviews every submission before sending feedback back to you.';

  @override
  String get hwChipScan => 'Scan';

  @override
  String get hwChipPhoto => 'Photo';

  @override
  String get examPrepTitle => 'Exam Prep';

  @override
  String get examPrepLoadError => 'Could not load exam prep data.';

  @override
  String get examPrepConceptMastery => 'CONCEPT MASTERY';

  @override
  String get examPrepEmptyTitle => 'No exam prep data yet';

  @override
  String get examPrepEmptyBody =>
      'Complete some modules first to see your concept mastery.';

  @override
  String get examPrepDaysUntilExam => 'days until exam';

  @override
  String examPrepDailyTarget(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Study $count modules/day to finish by exam',
      one: 'Study 1 module/day to finish by exam',
    );
    return '$_temp0';
  }

  @override
  String get examPrepSelfAssessed => 'Self-assessed';

  @override
  String get examPrepRedo => 'Re-do';

  @override
  String get examPrepStartRevisionError =>
      'Could not start revision. Try again.';

  @override
  String get commonCouldNotSaveConnection =>
      'Could not save — check your connection';

  @override
  String get referralTitle => 'Invite friends';

  @override
  String get referralFriendsInvited => 'Friends you invited';

  @override
  String get referralLoadInvitesError => 'Could not load your invites';

  @override
  String get referralYourCode => 'Your invite code';

  @override
  String get referralCodeCopied => 'Code copied';

  @override
  String referralShareMessage(String code) {
    return 'Try Apalchi — the AI study companion. Use my code $code at sign-up so we both earn bonus stars when you take your first quiz.';
  }

  @override
  String referralActivatedOfTarget(int activated, int target) {
    return '$activated of $target friends activated';
  }

  @override
  String referralNextTier(int count, int bonus) {
    return 'Refer $count more → +$bonus⭐ bonus';
  }

  @override
  String get referralActivatedNote =>
      'Friends count as \"activated\" after they complete their first quiz.';

  @override
  String get referralEmptyInvites =>
      'No invites yet — share your code above to get started!';

  @override
  String get referralStatusActivated => 'Activated';

  @override
  String get referralStatusPending => 'Pending';

  @override
  String get studyPlanTitle => 'Study Plan';

  @override
  String get studyPlanTodayTasks => 'Today\'s Tasks';

  @override
  String get studyPlanAllDone => 'Today\'s plan done! 🎉 Keep it up!';

  @override
  String get studyPlanComingUp => 'Coming Up';

  @override
  String get studyPlanBubbleTitle => 'Here\'s your plan for today! 📅';

  @override
  String get studyPlanBubbleBody =>
      'Complete all tasks to keep your streak going and earn bonus stars!';

  @override
  String get studyPlanMarkDone => 'Done';

  @override
  String get studyPlanStart => 'Start';

  @override
  String get studyPlanUpcoming => 'Upcoming';

  @override
  String get studyPlanTomorrow => 'Tomorrow';

  @override
  String get studyPlanIn2Days => 'In 2 days';

  @override
  String get studyPlanUpcomingTest => 'Upcoming Test';

  @override
  String studyPlanSubjectTest(String subject) {
    return '$subject Test';
  }

  @override
  String get studyPlanTestToday => 'Today';

  @override
  String studyPlanDaysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days left',
      one: '1 day left',
    );
    return '$_temp0';
  }

  @override
  String get studyPlanSetTestDate =>
      'Set a test date in Settings to see a countdown here.';

  @override
  String get brainHealthTitle => 'Brain Health 🧠';

  @override
  String get brainHealthWikiPages => 'Wiki Pages';

  @override
  String get brainHealthWeakTopics => 'Weak Topics';

  @override
  String get brainHealthScore => 'Brain Health Score';

  @override
  String get brainHealthPages => 'Pages';

  @override
  String get brainHealthVerified => 'Verified';

  @override
  String get brainHealthAvgQuality => 'Avg Quality';

  @override
  String brainHealthErrors(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count errors',
      one: '1 error',
    );
    return '$_temp0';
  }

  @override
  String get quizDailyTitle => 'Daily Quiz';

  @override
  String quizQuestionOf(int current, int total) {
    return 'Question $current of $total';
  }

  @override
  String quizXpEarnedLong(int xp) {
    return '+$xp XP earned';
  }

  @override
  String get quizMasteryBreakdown => 'Mastery breakdown';

  @override
  String quizMoreItems(int count) {
    return '+$count more';
  }

  @override
  String get centreJoinTitle => 'Join a class';

  @override
  String get centreJoinEnterFull => 'Enter the full class code';

  @override
  String get centreJoinHeading => 'Enter the class code';

  @override
  String get centreJoinBody =>
      'Ask your teacher or tuition centre for the class code on their dashboard, then type it in below.';

  @override
  String get centreJoinYourClassFallback => 'your class';

  @override
  String centreJoinSuccess(String className) {
    return 'Joined $className 🎉';
  }

  @override
  String get centreJoinFailed =>
      'Could not join — check the code and try again';

  @override
  String get centreJoinButton => 'Join class';

  @override
  String get assignTitle => 'Assignment';

  @override
  String get assignPickedForYou => 'Picked for you';

  @override
  String get assignNotReleasedTitle => 'Answers not released yet';

  @override
  String get assignNotReleasedBody =>
      'Your teacher hasn\'t shared the model answers. You\'ll be able to compare here once they do.';

  @override
  String get assignReleasedBody =>
      'Compare your answers with the model answers below.';

  @override
  String assignQuestionNumber(int n) {
    return 'Q$n';
  }

  @override
  String get assignYourAnswer => 'Your answer';

  @override
  String get assignNoAnswerRecorded => 'No answer recorded';

  @override
  String get assignModelAnswer => 'Model answer';

  @override
  String get assignEvaluation => 'Evaluation';

  @override
  String get assignEmptyReleased => 'No answers to compare yet';

  @override
  String get assignEmptyNotReleased => 'Come back after answers are released';

  @override
  String get learningStyleTitle => 'Learning style';

  @override
  String get learningStyleDefaultMode => 'Default answer mode';

  @override
  String get learningStyleBody =>
      'Guide Me builds understanding — you figure it out, you remember more. You can switch per question with the toggle in chat.';

  @override
  String get learningStyleSaved => 'Default saved!';

  @override
  String get learningStyleRecommended => 'RECOMMENDED';

  @override
  String learningStyleGuideDesc(String mascot) {
    return '$mascot guides you to the answer — builds real retention.';
  }

  @override
  String learningStyleAnswerDesc(String mascot) {
    return '$mascot gives the worked solution — great for checking your work.';
  }

  @override
  String get chatModeGuideMe => 'Guide Me';

  @override
  String get chatModeJustAnswer => 'Just answer';

  @override
  String get chatModeTwoWays => 'Two ways to learn 🎓';

  @override
  String get chatModeSwitchAnyTime =>
      'You can switch any time with the toggle above the chat.';

  @override
  String chatModeGuideDesc(String mascot) {
    return '$mascot asks you guiding questions — you figure it out yourself. What you discover, you remember.';
  }

  @override
  String chatModeAnswerDesc(String mascot) {
    return '$mascot gives you the worked solution directly. Great for checking your work — but you\'ll remember less.';
  }

  @override
  String get chatModeDefaultGuide => 'Default: Guide Me';

  @override
  String get chatModeGotIt => 'Got it — let\'s learn!';

  @override
  String chatCoachTapToggle(String mascot) {
    return 'Tap the toggle to switch how $mascot helps you.';
  }

  @override
  String get chatAnswerNudge =>
      'Full answer coming up — try Guide Me sometimes, you\'ll remember more.';

  @override
  String get chatEscapeGreatEffort => 'Great effort! Here\'s the answer';

  @override
  String chatEscapeAddedPractice(String topic) {
    return 'Added \"$topic\" to your practice list';
  }

  @override
  String get chatHints => 'Hints: ';

  @override
  String get chatAnswerReady => '— answer ready';

  @override
  String get chatReported => 'Reported';

  @override
  String get chatTabTitle => 'Chat';

  @override
  String get reportThanks => 'Thanks — we\'ll take a look';

  @override
  String get reportDoneButton => 'Done';

  @override
  String get commonRetry => 'Retry';

  @override
  String get centreBlockTitle => 'This is a Centre account';

  @override
  String get centreBlockBody =>
      'The Apalchi app is for students only. Centre teachers and owners manage their classes at apalchi.com.';

  @override
  String get centreBlockLoginWeb => 'Log in at apalchi.com';

  @override
  String get centreBlockBackToSignIn => 'Back to Sign In';

  @override
  String avatarPickerCreateError(String mascot, String message) {
    return 'Could not create $mascot — $message';
  }

  @override
  String avatarPickerTitle(String mascot) {
    return 'Choose Your $mascot ✨';
  }

  @override
  String get avatarPickerSubtitle =>
      'Each one is unique 🍡 Pick who you want to learn with!';

  @override
  String get collectionTitle => 'Collection';

  @override
  String collectionAlbumTitle(String mascot) {
    return '$mascot Album';
  }

  @override
  String createTutorWishHelp(String mascot) {
    return 'WHAT DO YOU WISH $mascot TO HELP YOU WITH?';
  }

  @override
  String get groupCodeHint => 'e.g. AB23CD';

  @override
  String get joinCodeHint => 'e.g. 5K7Q2X';

  @override
  String get moduleListTitle => 'Modules';

  @override
  String get uploadTypedNotesTip =>
      'Typed notes give the best results. Paste from Google Docs or type from your textbook.';

  @override
  String get uploadSplitLongNotesTip =>
      'Consider splitting long notes into separate uploads for better accuracy.';

  @override
  String voiceTalkTo(String mascot) {
    return 'Talk to $mascot';
  }

  @override
  String voiceExplainer(String mascot) {
    return '$mascot uses your phone\'s speech recognition to turn talking into text — your voice isn\'t saved.';
  }

  @override
  String get voiceMicNeeded => 'Microphone access needed';

  @override
  String voiceMicGuidance(String mascot) {
    return 'To talk to $mascot, turn on microphone access in Settings. You can still type your answer.';
  }

  @override
  String get voiceNotNow => 'Not now';

  @override
  String get voiceOpenSettings => 'Open Settings';

  @override
  String weaknessImproved(String topics) {
    return 'You improved on $topics! 📈';
  }

  @override
  String get weaknessFocusOn => 'Let\'s focus on';

  @override
  String weaknessHelpPractise(String mascot) {
    return '$mascot will help you practise these.';
  }

  @override
  String tourStep1Title(String mascot) {
    return 'Hi, I\'m $mascot!';
  }

  @override
  String get tourStep1Body =>
      'Let me show you 4 quick things that make Apalchi different from any other study app.';

  @override
  String tourStep2Title(String mascot) {
    return 'A $mascot for every subject';
  }

  @override
  String tourStep2Body(String mascot) {
    return 'Create one $mascot per subject — each one learns only YOUR notes, so every answer matches exactly what your teacher taught.';
  }

  @override
  String get tourStep3Title => 'Learn it. Test it. Prove it.';

  @override
  String get tourStep3Body =>
      'Every topic becomes a mini-mission: quick cards to learn, hot-takes to test yourself, and a challenge to prove it — what you get wrong, I bring back until it sticks.';

  @override
  String get tourStep4Title => 'I remember what you find hard';

  @override
  String get tourStep4Body =>
      'The Library tracks your mastery by topic. When you get something wrong, I bring it back — spaced and scheduled — until it sticks.';

  @override
  String tourStep5Title(String mascot) {
    return 'Not a generic AI — a $mascot that knows yours.';
  }

  @override
  String get tourStep5Body =>
      'Upload your notes and every answer, quiz, and challenge comes from what YOUR teacher taught.';

  @override
  String get tourStep5Cta => 'Start';

  @override
  String get tourBack => '← Back';

  @override
  String get tourDone => 'Done!';

  @override
  String get tourShowMe => 'Show me!';

  @override
  String get tourNext => 'Next →';

  @override
  String get tourSkip => 'Skip';

  @override
  String get moduleStageTitleLearn => 'Learn';

  @override
  String get moduleStageTitleTest => 'Test';

  @override
  String get moduleStageTitleProve => 'Prove';

  @override
  String get moduleStageTitleComplete => 'Complete';

  @override
  String get forceUpdateTitle => 'Time to update!';

  @override
  String get forceUpdateBody =>
      'A newer version of Apalchi is ready with important improvements. Please update to keep learning.';

  @override
  String get forceUpdateCta => 'Update now';

  @override
  String get uploadLargeFileSizeLabel => 'large file';

  @override
  String get consentGateAlmostThere => 'Almost there!';

  @override
  String consentGateBody(String feature) {
    return '$feature unlocks once a grown-up approves your account. We\'ve already sent them an email — or tap below to send a reminder.';
  }

  @override
  String get consentGateRemind => 'Remind my grown-up';

  @override
  String get consentGateFeatureUpload => 'Upload notes';

  @override
  String consentGateFeatureCreateTutor(String mascot) {
    return 'Create your own $mascot';
  }

  @override
  String get consentGateFeatureShareNote => 'Share notes';

  @override
  String get consentGateFeaturePersistChat => 'Save conversations';

  @override
  String get consentGateFeatureEarnXp => 'Earn rewards';

  @override
  String get consentGateFeatureGeneric => 'This feature';

  @override
  String get consentGateFinishSetup =>
      'Let\'s finish setting up your account so you can start learning';

  @override
  String serverErrorRetry(int status) {
    return 'Server error ($status) — please try again';
  }

  @override
  String get consentPendingYourGrownUp => 'your grown-up';

  @override
  String get notifQuizTitle => 'Quiz time!';

  @override
  String get notifQuizBody =>
      'Your daily quiz is waiting — earn XP and keep your streak!';

  @override
  String get notifQuizChannelName => 'Daily Quiz Reminder';

  @override
  String get notifQuizChannelDesc => 'Reminds you to take your daily quiz';

  @override
  String notifSrsTitle(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards due for $name',
      one: '1 card due for $name',
    );
    return '$_temp0';
  }

  @override
  String get notifSrsBodyOverdue =>
      'Quick 2-min review to lock it in your memory 📚';

  @override
  String get notifSrsBody =>
      'Spaced repetition works best when you keep the streak 💪';

  @override
  String get notifSrsChannelName => 'Flashcard reviews';

  @override
  String get notifSrsChannelDesc =>
      'Reminds you when spaced-repetition flashcards are due';

  @override
  String notifYourMascot(String mascot) {
    return 'your $mascot';
  }

  @override
  String deleteTutorTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String get deleteTutorBody =>
      'This permanently deletes this tutor and all their knowledge, chat history, and quiz progress. This cannot be undone.';

  @override
  String get deleteTutorKnowledgePages => 'Knowledge pages';

  @override
  String get deleteTutorChatMessages => 'Chat messages';

  @override
  String get deleteTutorQuizProgress => 'Quiz progress';

  @override
  String get deleteTutorAllDeleted => 'All will be deleted';

  @override
  String get deleteTutorAllLost => 'All will be lost';

  @override
  String get deleteTutorKeep => 'Keep Tutor';

  @override
  String get deleteTutorDelete => 'Delete';

  @override
  String get relevanceTitle => 'Hmm, this might not fit!';

  @override
  String relevanceBody(String subject) {
    return 'This file doesn\'t seem to match \"$subject\". Your tutor works best with notes from that subject.';
  }

  @override
  String get relevanceGoBack => 'Go Back';

  @override
  String get relevanceAddAnyway => 'Add Anyway';

  @override
  String get routerGoHome => 'Go home';

  @override
  String get appAsyncDefaultError =>
      'Something went wrong. Pull down to retry.';

  @override
  String moduleItemsLearn(int count) {
    return '$count learn';
  }

  @override
  String moduleItemsTest(int count) {
    return '$count test';
  }

  @override
  String moduleItemsProve(int count) {
    return '$count prove';
  }

  @override
  String get subReturnTitle => 'Subscription';

  @override
  String get subReturnSuccess => 'You are premium!';

  @override
  String subReturnSuccessBody(String mascot) {
    return 'Everything just unlocked — unlimited ${mascot}s, family sharing, parent dashboard, and more.';
  }

  @override
  String get subReturnStartExploring => 'Start exploring';

  @override
  String get subReturnStillConfirming => 'Still confirming…';

  @override
  String get subReturnTimeoutBody =>
      'Your payment may still be processing. You can check Settings → Subscription in a minute or two.';

  @override
  String get subReturnBackToApalchi => 'Back to Apalchi';

  @override
  String get subReturnConfirming => 'Confirming your subscription…';

  @override
  String get webCtaDefaultIntro =>
      'Subscriptions are managed on the Apalchi website. Sign in with the same account to upgrade — your app unlocks automatically.';

  @override
  String get webCtaContinueOnWeb => 'Continue on web';

  @override
  String get webCtaCouldntOpenBrowser =>
      'Couldn\'t open your browser. Tap “Copy link” above and paste it.';

  @override
  String get webCtaEmailFailNow =>
      'Couldn\'t send right now — copy the link above instead.';

  @override
  String get webCtaEmailBothSent =>
      'Sent! Check your email — we also pushed a notification with the link.';

  @override
  String get webCtaEmailSent => 'Sent! Check your email for the link.';

  @override
  String get webCtaPushSent => 'Sent you a notification with the link.';

  @override
  String get webCtaRateLimited =>
      'You\'ve requested this a few times — try again in a little while.';

  @override
  String get webCtaEmailError =>
      'Couldn\'t send the link. Check your connection and try again.';

  @override
  String get webCtaNotActiveYet =>
      'Not active yet. Finish checkout in your browser, then tap again.';

  @override
  String get webCtaCopied => 'Copied';

  @override
  String get webCtaCopyLink => 'Copy link';

  @override
  String get webCtaSending => 'Sending…';

  @override
  String get webCtaEmailLink => 'Email me the link';

  @override
  String get webCtaChecking => 'Checking…';

  @override
  String get webCtaUpgradedRefresh => 'I\'ve upgraded — refresh';

  @override
  String trialTimeHoursLeft(int hours) {
    return '${hours}h left';
  }

  @override
  String trialTimeDaysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days left',
      one: '1 day left',
    );
    return '$_temp0';
  }

  @override
  String trialBannerUrgent(String mascot, String time) {
    return 'Last day of Premium! ⏳ $time — keep your ${mascot}s.';
  }

  @override
  String trialBannerWarning(String mascot, String time) {
    return '$time of Premium — subscribe to keep all your ${mascot}s.';
  }

  @override
  String trialBannerCalm(String mascot, String time) {
    return '$time of Premium · Enjoying unlimited ${mascot}s? Keep them after.';
  }

  @override
  String get trialKeepPremium => 'Keep Premium';

  @override
  String get trialWhenEnds => 'When your trial ends:';

  @override
  String trialLockMochis(String mascot) {
    return '🔒 Extra ${mascot}s locked (you keep 1 free)';
  }

  @override
  String get trialLockChat => '💬 Chat capped at 80/day (was unlimited)';

  @override
  String get trialLockQuiz => '📊 Advanced quiz & study plan limited';

  @override
  String get trialWelcomeTitle => '🎁 Premium is on us\nfor 7 days!';

  @override
  String get trialWelcomeSubtitle =>
      'No card needed. We\'ll remind you before it ends.';

  @override
  String trialWelcomePerk1Title(String mascot) {
    return 'Unlimited ${mascot}s';
  }

  @override
  String trialWelcomePerk1Sub(String mascot) {
    return 'One $mascot for every subject you study';
  }

  @override
  String get trialWelcomePerk2Title => 'Unlimited chat';

  @override
  String get trialWelcomePerk2Sub => 'Ask anything, any time — no daily limit';

  @override
  String get trialWelcomePerk3Title => 'Full flashcards & quizzes';

  @override
  String get trialWelcomePerk3Sub => 'Every feature, zero restrictions';

  @override
  String get trialWelcomeStart => 'Start exploring! 🚀';

  @override
  String get trialWelcomeSubscribeNow => 'Subscribe now';

  @override
  String get trialExpiredTitle => 'Your free week is up! ⏰';

  @override
  String trialExpiredBody(String mascot) {
    return 'You still have all your ${mascot}s — nothing was deleted. Subscribe to keep them all, or pick one to stay free.';
  }

  @override
  String trialExpiredKeepAll(String mascot) {
    return '⭐ Keep all your ${mascot}s';
  }

  @override
  String trialExpiredPerks(String mascot) {
    return 'Unlimited ${mascot}s, unlimited chat, full flashcards & quizzes.';
  }

  @override
  String get trialExpiredUpTo4Kids => 'up to 4 kids';

  @override
  String trialExpiredOrContinue(String mascot) {
    return 'Or — continue free with 1 $mascot';
  }

  @override
  String trialExpiredPickBody(String mascot) {
    return 'Choose which $mascot stays active. The rest are locked (🔒) but not deleted — subscribing restores them instantly.';
  }

  @override
  String trialExpiredContinueWith(String name) {
    return 'Continue free with $name';
  }

  @override
  String trialKeeperFallback(String mascot) {
    return '1 $mascot';
  }

  @override
  String get subPlansChooseTitle => 'Choose your plan';

  @override
  String get subPlansLoadError =>
      'Could not load subscription info. Try again.';

  @override
  String get subPlansYourSubscription => 'Your subscription';

  @override
  String get subPlansUpgradeTitle => 'Upgrade Apalchi';

  @override
  String get subPlansProSubtitle => '1 student · all AI features';

  @override
  String get subPlansMaxSubtitle => '1 student · smarter AI for hard problems';

  @override
  String get subPlansFamilySubtitle => 'Up to 4 students';

  @override
  String get subPlansProFeat1 => '100 AI messages / day';

  @override
  String subPlansProFeat2(String mascot) {
    return 'Up to 5 ${mascot}s';
  }

  @override
  String get subPlansProFeat3 => 'Quiz & flashcards';

  @override
  String get subPlansProFeat4 => 'Homework photo scan';

  @override
  String get subPlansMaxFeat1 => 'Unlimited AI messages';

  @override
  String subPlansMaxFeat2(String mascot) {
    return 'Unlimited ${mascot}s';
  }

  @override
  String get subPlansMaxFeat3 => 'Sonnet model for complex questions';

  @override
  String get subPlansMaxFeat4 => 'All Pro features';

  @override
  String get subPlansFamilyFeat1 => 'Everything in Max';

  @override
  String get subPlansFamilyFeat2 => 'Up to 4 child accounts';

  @override
  String get subPlansFamilyFeat3 => 'Parent dashboard';

  @override
  String get subPlansFamilyFeat4 => 'Shared star rewards';

  @override
  String get subPlansBadgeExams => 'Best for exams';

  @override
  String get subPlansBadgePopular => 'Most popular';

  @override
  String get subPlansBestValue => 'Best value';

  @override
  String get subPlansCurrent => 'Current';

  @override
  String get subPlansMonthly => 'Monthly';

  @override
  String get subPlansAnnual => 'Annual  (save ~34%)';

  @override
  String subPlansFreeFeatures(String mascot) {
    return '20 messages/day · 1 $mascot · basic features';
  }

  @override
  String get subPlansCentreBanner => '⭐ Premium via your centre';

  @override
  String subPlansHeaderCentre(String mascot) {
    return 'Your Premium comes from your centre. Enjoy unlimited chat and ${mascot}s!';
  }

  @override
  String subPlansHeaderTrial(int days, String mascot) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return 'Your free trial ends in $_temp0. Subscribe to keep all your ${mascot}s.';
  }

  @override
  String subPlansHeaderPremium(String tier) {
    return 'You\'re on $tier. Manage or cancel anytime on the web.';
  }

  @override
  String get subPlansHeaderFree =>
      'Start with a 7-day free trial. Cancel anytime.';

  @override
  String get subPlansManageIntro =>
      'Manage your plan, update your card, or cancel anytime on the Apalchi website.';

  @override
  String get subPlansManageOnWeb => 'Manage on web';

  @override
  String paywallHeadCreateTutor(String mascot) {
    return 'Want more ${mascot}s?';
  }

  @override
  String get paywallHeadUpload => 'Need more uploads?';

  @override
  String get paywallHeadCompile => 'Compiled all your chapters';

  @override
  String get paywallHeadChat => 'Out of chats for today';

  @override
  String get paywallHeadParent => 'Parent dashboard is premium';

  @override
  String get paywallHeadCurriculum => 'Curriculum journey is premium';

  @override
  String get paywallHeadFreeze => 'Stack more streak freezes';

  @override
  String get paywallHeadGroups => 'Study groups are premium';

  @override
  String get paywallHeadAddStudent => 'Need more student accounts?';

  @override
  String get paywallHeadDefault => 'Unlock Apalchi Premium';

  @override
  String paywallSubCreateTutor(String mascot) {
    return 'Free users get 1 $mascot. Sign up for premium for unlimited ${mascot}s so each subject gets its own $mascot. Or, level up to level 5 to unlock your next $mascot slot!';
  }

  @override
  String paywallSubUpload(String mascot) {
    return 'Uploads are unlimited — free or premium. The gate is how many ${mascot}s you can have. Premium gives you one per subject.';
  }

  @override
  String paywallSubCompile(String mascot) {
    return 'Big documents split into chapters so you pick what $mascot reads. Free plans include a handful of chapter compiles a month; premium plans give you many more — reset on a rolling 30 days.';
  }

  @override
  String get paywallSubChat =>
      'Free users get 20 chats a day. Pro lifts the cap to 100; Max and above remove it entirely.';

  @override
  String get paywallSubParent =>
      'Parents track progress, set goals, and read weekly reports.';

  @override
  String get paywallSubCurriculum =>
      'Plan ahead with a syllabus-aware journey across every topic.';

  @override
  String get paywallSubFreeze =>
      'Premium lets you stack up to 3 streak freezes so a missed day never costs your streak.';

  @override
  String get paywallSubGroups =>
      'Collaborate with classmates in shared study groups. Available on Pro and above.';

  @override
  String get paywallSubAddStudent =>
      'Family plan supports up to 4 students. Centre plan supports up to 15 students.';

  @override
  String paywallSubDefault(String mascot) {
    return 'Get everything Apalchi has to offer — unlimited ${mascot}s, family sharing, premium analytics.';
  }

  @override
  String paywallPerk1(String mascot) {
    return 'Unlimited ${mascot}s + uploads';
  }

  @override
  String get paywallPerk2 => 'Unlimited daily chats';

  @override
  String get paywallPerk3 => 'Family sharing — up to 4 kids';

  @override
  String get paywallPerk4 => 'Parent dashboard + weekly reports';

  @override
  String get paywallPerk5 => '3 streak freezes (up from 1)';

  @override
  String get paywallSeePlans => 'See plans';

  @override
  String get paywallMaybeLater => 'Maybe later';

  @override
  String get createTutorLanguageLabel => 'TEACHING LANGUAGE';

  @override
  String createTutorLanguageHint(String name) {
    return '$name will teach and chat with you in this language.';
  }

  @override
  String get avatarLanguageMenuLabel => 'Teaching language';

  @override
  String get avatarLanguageTitle => 'Teaching language';

  @override
  String avatarLanguageBody(String mascot) {
    return '$mascot generates new lessons, quizzes and chat in this language. Existing material keeps the language it was created in — recompile to regenerate it.';
  }

  @override
  String get avatarLanguageSave => 'Save';

  @override
  String get avatarLanguageSaveError =>
      'Could not save the teaching language. Please try again.';

  @override
  String get avatarLanguageSaved => 'Teaching language updated';

  @override
  String get onboardErrWrongPassword =>
      'Wrong password. Already have an account? Tap \'Already have an account? Sign in\' below.';

  @override
  String get onboardErrAccountExists =>
      'An account with this email already exists. Try signing in instead.';

  @override
  String get onboardErrInvalidEmail => 'Please enter a valid email address.';

  @override
  String get onboardErrParentEmailInvalid =>
      'A valid parent email is required. Please go back and correct it.';

  @override
  String get onboardErrParentEmailMissing =>
      'Please enter your parent\'s email address.';

  @override
  String get onboardErrTermsNotAccepted =>
      'Please accept the Terms of Use to create your account.';

  @override
  String get onboardErrConsentPending =>
      'Your account is pending parental approval. Ask your parent to check their email.';

  @override
  String get onboardErrRateLimited =>
      'Too many requests. Wait a moment and try again.';

  @override
  String get onboardErrServerError =>
      'Account setup hit a temporary error. If you already have an account, please try signing in instead.';

  @override
  String get onboardErrServerMessageFallback =>
      'Please check your details and try again.';

  @override
  String get onboardErrConsentEmailFailed =>
      'Could not send the parental consent email. Please ask your parent to check their inbox for a confirmation link.';

  @override
  String get onboardErrSignUpRequired => 'Please complete sign-up first.';

  @override
  String get onboardErrFileReadFailed => 'Could not read the file. Try again.';

  @override
  String get onboardErrUploadFailed => 'Upload failed. Please try again.';

  @override
  String get onboardErrResendRateLimited =>
      'Please wait 60 seconds before resending.';

  @override
  String get onboardErrResendFailed => 'Could not resend. Try again shortly.';

  @override
  String get streakMilestone3 => 'Three days in a row — habit forming!';

  @override
  String get streakMilestone7 => 'A whole week! Week Warrior unlocked 🏅';

  @override
  String get streakMilestone14 => 'Two weeks. You\'re on fire.';

  @override
  String get streakMilestone30 => 'Thirty days. Legendary 👑';

  @override
  String get streakMilestone60 => 'Sixty days — that\'s elite focus.';

  @override
  String get streakMilestone100 => 'Triple digits. Unreal 🚀';

  @override
  String get streakMilestone365 => 'A whole year. Take a bow.';

  @override
  String get streakMilestoneDefault => 'Keep that streak burning!';

  @override
  String get dailyGoalUnitXp => 'XP';

  @override
  String get dailyGoalUnitMin => 'min';

  @override
  String dailyGoalUnitQuiz(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'quizzes',
      one: 'quiz',
    );
    return '$_temp0';
  }

  @override
  String get dailyGoalVerbXp => 'XP earned today';

  @override
  String get dailyGoalVerbMinutes => 'minutes today';

  @override
  String dailyGoalVerbQuiz(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'quizzes today',
      one: 'daily quiz',
    );
    return '$_temp0';
  }

  @override
  String get dailyGoalMet => 'Goal';

  @override
  String dailyGoalRemaining(int target, String unit) {
    return '/ $target $unit';
  }

  @override
  String get dailyGoalCompleteStreak => 'Goal complete! Streak safe 🔥';

  @override
  String dailyGoalProgressOf(int pct, String verb) {
    return '$pct% of your $verb';
  }

  @override
  String get createTutorAgeLabel => 'AGE';

  @override
  String get createTutorExamPrep => 'Examination Preparation';

  @override
  String get createTutorUniversity => 'University — Midterms / Finals';

  @override
  String get createTutorCodingInterview => 'Coding Interview Preparation';

  @override
  String get createTutorProfessional => 'Professional Examinations';

  @override
  String get createTutorOtherGoal => 'Others';

  @override
  String get uploadTipSectionBefore => 'Before you upload';

  @override
  String get uploadTipMaxSize => 'Files must be under 25 MB.';

  @override
  String get uploadTipBigFiles =>
      'Big files (a whole book) can be slow or time out — upload a chapter or topic at a time.';

  @override
  String get uploadTipPdfText =>
      'PDFs need selectable text. A scanned, image-only PDF can\'t be read — photograph the pages instead.';

  @override
  String uploadTipSectionReadsWell(String mascot) {
    return '$mascot reads these well';
  }

  @override
  String get uploadTipTypedText =>
      'Typed or printed text, clean PDFs, and screenshots.';

  @override
  String get uploadTipNeatHandwriting =>
      'Neat handwriting — clear, reasonably large, dark ink.';

  @override
  String get uploadTipSectionHardToRead => 'Type these instead — hard to read';

  @override
  String get uploadTipCursive => 'Cursive or messy handwriting.';

  @override
  String get uploadTipGlare =>
      'Glare, shadows, or a photo of a screen — shoot the page directly.';

  @override
  String get uploadTipTinyText =>
      'Tiny text (footnotes, shrunk photocopies) — zoom in.';

  @override
  String get uploadTipFaint =>
      'Faint pencil or low-contrast pages — go over it in pen.';

  @override
  String get uploadTipCropped =>
      'Cropped edges — capture the whole page, flat and filling the frame.';

  @override
  String get uploadTipCluttered =>
      'Cluttered multi-column layouts — one clean column per photo.';

  @override
  String get uploadTipSectionCheck => 'One quick check';

  @override
  String uploadTipGlanceCheck(String mascot) {
    return 'After a photo or handwriting, glance at what $mascot read — if something looks off, retake or type it.';
  }

  @override
  String get uploadTipHide => 'Hide';

  @override
  String get uploadTipWhatReadsBest => 'What reads best?';

  @override
  String get uploadStepReviewing => 'Step 1 of 3 — Reviewing content...';

  @override
  String get uploadStepCheckingRelevance =>
      'Step 1 of 3 — Checking relevance...';

  @override
  String get uploadStepSendingToServer => 'Step 2 of 3 — Sending to server...';

  @override
  String get uploadStepProcessingDoc => 'Step 2 of 3 — Processing document...';

  @override
  String get uploadStepExtractingText => 'Step 2 of 3 — Extracting text...';

  @override
  String get uploadStepAlmostThere => 'Step 2 of 3 — Almost there...';

  @override
  String get uploadStepReadingNotes => 'Step 3 of 3 — Reading your notes...';

  @override
  String get uploadStepFindingConcepts =>
      'Step 3 of 3 — Finding key concepts...';

  @override
  String get uploadStepBuildingPages => 'Step 3 of 3 — Building brain pages...';

  @override
  String get uploadStepProcessingSections =>
      'Step 3 of 3 — Processing sections...';

  @override
  String get uploadStepAlmostReady => 'Step 3 of 3 — Almost ready...';

  @override
  String get uploadStepSending => 'Step 2 of 3 — Sending...';

  @override
  String get uploadStepProcessing => 'Step 2 of 3 — Processing...';

  @override
  String get uploadTakes30to60s => 'This usually takes 30-60 seconds';

  @override
  String get uploadCheckingSubjectFit => 'Making sure this fits the subject...';

  @override
  String get uploadCheckingNotes => 'Checking your notes...';

  @override
  String get uploadUploadingLargeDoc => 'Uploading large document...';

  @override
  String get uploadUploading => 'Uploading...';

  @override
  String get uploadProcessing => 'Processing...';

  @override
  String uploadHeroSpeechSubject(String subject) {
    return 'Teach me your $subject material!';
  }

  @override
  String get uploadHeroSpeechGeneric => 'Teach me your material!';

  @override
  String get uploadTabType => 'Type';

  @override
  String get uploadTabPhoto => 'Photo';

  @override
  String get uploadTabFile => 'File';

  @override
  String get ocrTierGreat => '✅  Reads great';

  @override
  String get ocrTierOk => '⚠️  Usually OK — check it';

  @override
  String get ocrTierTypeIt => '🚫  Best to type it yourself';

  @override
  String get ocrItemPrintedText => 'Printed text';

  @override
  String get ocrNotePrintedText =>
      'Clear printed questions — reads almost perfectly';

  @override
  String get ocrItemNumbers => 'Numbers & basic maths';

  @override
  String get ocrNoteNumbers => 'Digits and operators (+, −, ×, ÷) read well';

  @override
  String get ocrItemMcqLabels => 'Multiple choice labels';

  @override
  String get ocrNoteMcqLabels => 'A. B. C. D. labels are reliably detected';

  @override
  String get ocrItemHandwriting => 'Neat handwriting';

  @override
  String get ocrNoteHandwriting =>
      'Clear block letters work; cursive may need fixing';

  @override
  String get ocrItemEquations => 'Maths equations';

  @override
  String get ocrNoteEquations =>
      'Simple equations OK; complex fractions may need editing';

  @override
  String get ocrItemFormulas => 'Chemical formulas';

  @override
  String get ocrNoteFormulas =>
      'Subscripts & superscripts often need manual correction';

  @override
  String get ocrItemGraphs => 'Graphs & charts';

  @override
  String ocrNoteGraphs(String mascot) {
    return '$mascot may read labels but cannot read bar heights, line values, or data points.';
  }

  @override
  String ocrActionGraphs(String mascot) {
    return 'Tell $mascot the numbers yourself';
  }

  @override
  String get ocrItemGeometry => 'Geometry figures';

  @override
  String ocrNoteGeometry(String mascot) {
    return '$mascot can\'t measure a drawing — it can\'t see angles or lengths from lines on paper.';
  }

  @override
  String get ocrActionGeometry => 'Type the sides & angles instead';

  @override
  String get ocrItemCursive => 'Cursive handwriting';

  @override
  String get ocrNoteCursive =>
      'Very variable — cursive letters often get mixed up.';

  @override
  String get ocrActionCursive => 'Type it out for accurate results';

  @override
  String get ocrTipDigitalTitle => 'Digital is best';

  @override
  String get ocrTipDigitalBody => 'A clear PDF or screenshot beats a photo';

  @override
  String get ocrTipLightingTitle => 'Good lighting';

  @override
  String get ocrTipLightingBody =>
      'Bright, even light — avoid shadows on the page';

  @override
  String get ocrTipFlatTitle => 'Flat and straight';

  @override
  String get ocrTipFlatBody =>
      'Hold your phone directly above, not at an angle';

  @override
  String get ocrTipFillFrameTitle => 'Fill the frame';

  @override
  String get ocrTipFillFrameBody =>
      'Get close enough so text is large and clear';

  @override
  String get ocrTipOneTopicTitle => 'One topic per upload';

  @override
  String get ocrTipOneTopicBody =>
      'Separate topics read better than a mixed dump';

  @override
  String get ocrTipMathTitle => 'Math? Type it';

  @override
  String get ocrTipMathBody =>
      'For equations, a typed copy or very clear photo reads best';

  @override
  String get ocrReadablePrinted => 'Printed text';

  @override
  String get ocrReadableTyped => 'Typed questions';

  @override
  String get ocrReadableNumbers => 'Numbers';

  @override
  String get ocrReadableMcq => 'Multiple choice';

  @override
  String get ocrReadableFillBlank => 'Fill in the blank';

  @override
  String get ocrReadableShortParagraphs => 'Short paragraphs';

  @override
  String get ocrTrickyHandwriting => 'Handwriting';

  @override
  String get ocrTrickyDiagrams => 'Diagrams';

  @override
  String get ocrTrickyGraphs => 'Graphs';

  @override
  String get ocrTrickyMathSymbols => 'Maths symbols';

  @override
  String get ocrTrickyChemFormulas => 'Chemical formulas';

  @override
  String get ocrTrickyTables => 'Tables';

  @override
  String chapterCompileCount(int count) {
    return 'Compile ($count)';
  }

  @override
  String get chapterCompile => 'Compile';

  @override
  String get chapterStateCompiled => '✓ Compiled';

  @override
  String get chapterStateCompiling => 'Compiling…';

  @override
  String get chapterStateNotCompiled => 'Not compiled';

  @override
  String get rarityCommon => 'Common';

  @override
  String get rarityRare => 'Rare';

  @override
  String get raritySecret => 'Secret';

  @override
  String shopOddsCommons(int count, int pct) {
    return '$count commons = $pct% each';
  }

  @override
  String shopOddsNamed(String rarity, String name, int pct) {
    return '$rarity ($name) = $pct%';
  }

  @override
  String mochiNamePencil(String mascot) {
    return 'Pencil $mascot';
  }

  @override
  String mochiNameScience(String mascot) {
    return 'Science $mascot';
  }

  @override
  String mochiNamePe(String mascot) {
    return 'PE $mascot';
  }

  @override
  String mochiNameArt(String mascot) {
    return 'Art $mascot';
  }

  @override
  String mochiNameLunchbox(String mascot) {
    return 'Lunch Box $mascot';
  }

  @override
  String mochiNameLibrary(String mascot) {
    return 'Library $mascot';
  }

  @override
  String mochiNameHeadmaster(String mascot) {
    return 'Headmaster $mascot';
  }

  @override
  String mochiNameGoldstar(String mascot) {
    return 'Gold Star $mascot';
  }

  @override
  String get inviteShowQr => 'Show QR';

  @override
  String get inviteHideQr => 'Hide QR';

  @override
  String get mochiTip1 =>
      'I only learn from what YOU give me — so my answers match your syllabus.';

  @override
  String get mochiTip2 => 'The more you study, the better I fit you.';

  @override
  String get mochiTip3 => 'Get one wrong? I bring it back till it clicks.';

  @override
  String mochiTip4(String mascot) {
    return 'One subject per $mascot keeps my answers sharp.';
  }

  @override
  String mochiTip5(String mascot) {
    return 'Your notes → your $mascot. Nothing generic here.';
  }

  @override
  String get mochiTip6 =>
      'Hard topics come back. Easy ones get spaced out. No wasted time.';

  @override
  String get mochiTip7 =>
      'I track what trips you up — so we can fix it together.';

  @override
  String get mochiTip8 => 'Every note you upload makes my answers more yours.';

  @override
  String get mochiTip9 => 'No random internet stuff. Just your material.';

  @override
  String get mochiTip10 => 'Upload once, study smarter forever.';

  @override
  String get splashHero1 => 'Learn it.';

  @override
  String get splashSub1 => 'Don\'t just look it up.';

  @override
  String get splashHero2 => 'Trained on your notes.';

  @override
  String get splashSub2 => 'Not the whole internet.';

  @override
  String get splashHero3 => 'A study buddy that did the reading.';

  @override
  String get splashSub3 => 'Knows your material. Not everyone else\'s.';

  @override
  String get splashHero4 => 'Not a know-it-all.';

  @override
  String get splashSub4 => 'A learn-it-with-you.';

  @override
  String get splashHero5 => 'Your notes, now with a brain.';

  @override
  String get splashSub5 => 'Feed me a little, and I\'ll quiz you a lot.';

  @override
  String get splashHero6 => 'Study with someone who gets your syllabus.';

  @override
  String splashSub6(String mascot) {
    return 'One $mascot, one subject — nothing gets fuzzy.';
  }

  @override
  String get splashHero7 => 'I remember how you learn.';

  @override
  String get splashSub7 =>
      'Get it wrong once, and I\'ll bring it back till it clicks.';

  @override
  String get splashHero8 => 'Looking it up is so last season.';

  @override
  String splashSub8(String mascot) {
    return '$mascot saw nothing. 🫣';
  }

  @override
  String noNotesCentreReminder(String mascot) {
    return 'This class doesn\'t have notes yet. Ask your teacher to add some so $mascot can help! 📚';
  }

  @override
  String flashcardUploadNotesCta(String mascot) {
    return 'Upload notes or a document for this $mascot and cards will be made automatically.';
  }

  @override
  String get mochiGeneratingDefaultStep => 'Working on it…';
}
