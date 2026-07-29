// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get language => 'Language';

  @override
  String get languagePickerSubtitle =>
      'Choose the language for the app\'s buttons and menus. This does not change the language your Mochi teaches in.';

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
  String get onboardingPage2Body =>
      'Make a separate Mochi for each subject or module. Each one only knows its stuff, so the answers stay sharp — whether it\'s Sec 3 Chemistry or a uni economics module.';

  @override
  String get onboardingFocusOkTitle => 'One subject per Mochi';

  @override
  String get onboardingFocusOkSub => 'Deep, accurate answers for that course';

  @override
  String get onboardingFocusBadTitle => 'Everything in one Mochi';

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
  String get onboardingThesis =>
      '“Not a generic AI — a Mochi that knows your notes.”';

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
  String libraryLeaveClassBody(String name) {
    return 'You\'ll lose access to $name\'s materials and class Mochi. Your personal Mochis stay. You can rejoin with the class code.';
  }

  @override
  String libraryLeftClass(String name) {
    return 'Left $name';
  }

  @override
  String get libraryStatusCompiling => '📖 Mochi is reading your chapters…';

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
  String get libraryEmptyTitle => 'No Mochis yet';

  @override
  String get libraryEmptySubtitle =>
      'Create a Mochi from the Home tab to see it here.';
}
