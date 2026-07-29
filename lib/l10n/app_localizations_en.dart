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
}
