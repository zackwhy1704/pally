// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get language => '语言';

  @override
  String get languagePickerSubtitle =>
      '选择应用界面（按钮和菜单）显示的语言。这不会改变 Mochi 教学内容使用的语言。';

  @override
  String get signInWelcomeBack => '欢迎回来！👋';

  @override
  String get signInEmailLabel => '电子邮件';

  @override
  String get signInEmailHint => 'your@email.com';

  @override
  String get signInPasswordLabel => '密码';

  @override
  String get signInForgotPassword => '忘记密码？';

  @override
  String get signInButton => '登录';

  @override
  String get signInOr => '或';

  @override
  String get signInUseBiometrics => '使用生物识别';

  @override
  String get signInFaceTouchId => 'Face ID / Touch ID';

  @override
  String get signInEnableBiometricHint => '先登录一次即可启用生物识别登录';

  @override
  String get signInNoAccount => '还没有账户？';

  @override
  String get signInCreateAccount => '创建账户 ✨';

  @override
  String get signInBiometricReason => '登录 Apalchi';

  @override
  String get signInErrorEmptyCredentials => '请输入电子邮件和密码';

  @override
  String get signInErrorBiometricsUnavailable => '此设备不支持生物识别';

  @override
  String get signInErrorBiometricsNotRegistered => '请先使用密码登录 —— 生物识别可在“设置”中启用';

  @override
  String get signInErrorPasswordFirst => '请先使用密码登录';

  @override
  String get biometricScanning => '扫描中……';

  @override
  String get biometricVerified => '验证成功！✨';

  @override
  String get biometricCouldntVerify => '无法验证';

  @override
  String get biometricScanningHint => '请放上手指或注视摄像头';

  @override
  String get biometricSigningIn => '正在为你登录……';

  @override
  String get biometricNotRecognised => '无法识别面容或指纹';

  @override
  String get biometricUsePassword => '改用密码';

  @override
  String get commonTryAgain => '重试';

  @override
  String get commonCancel => '取消';

  @override
  String get forgotPasswordTitle => '重置密码';

  @override
  String get forgotPasswordSend => '发送重置链接';

  @override
  String get forgotPasswordSent => '请查收邮件中的重置链接';
}
