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

  @override
  String onboardingPageProgress(int current, int total) {
    return '$current / $total';
  }

  @override
  String get onboardingNext => '下一步 →';

  @override
  String get onboardingLetsGo => '开始吧 →';

  @override
  String get onboardingPage1Title => '我学习你的材料——而不是整个互联网。';

  @override
  String get onboardingPage1Body =>
      '上传你的笔记、幻灯片或课堂讲义，我就会围绕你正在学的内容打造一个专属大脑——无论是为了小测、期末考、某个单元，还是单纯想把它弄懂。';

  @override
  String get onboardingContrastOk1Title => '你的笔记和幻灯片';

  @override
  String get onboardingContrastOk1Sub => '我学的正是你在学的内容';

  @override
  String get onboardingContrastOk2Title => '你的课堂讲义和阅读材料';

  @override
  String get onboardingContrastOk2Sub => '同样的材料，更精准的解答';

  @override
  String get onboardingContrastBadTitle => '网上随便找的文章';

  @override
  String get onboardingContrastBadSub => '泛泛的信息，未必符合你的课程';

  @override
  String get onboardingPage2Title => '一次给我一个科目——我会学得很深入。';

  @override
  String get onboardingPage2Body =>
      '为每个科目或单元建立一个单独的 Mochi。每个 Mochi 只懂它自己的内容，所以解答始终精准——无论是中三化学还是大学的经济学单元。';

  @override
  String get onboardingFocusOkTitle => '每个 Mochi 专注一个科目';

  @override
  String get onboardingFocusOkSub => '为那门课提供深入、准确的解答';

  @override
  String get onboardingFocusBadTitle => '所有内容都塞进一个 Mochi';

  @override
  String get onboardingFocusBadSub => '知识混在一起 = 解答含糊不清';

  @override
  String get onboardingPage3Title => '我记得你是怎么学习的。';

  @override
  String get onboardingPage3Body =>
      '当你做错时，我会留意到——并且会不断把它带回来，直到你真正掌握。我们学得越多，我就越适合你。';

  @override
  String get onboardingBeat1 => '难懂的知识点会不断回来，直到你记牢';

  @override
  String get onboardingBeat2 => '简单的内容会拉开复习间隔——不浪费时间';

  @override
  String get onboardingBeat3 => '你学得越多，它就越适合你';

  @override
  String get onboardingThesis => '“不是一个普通的 AI——而是一个懂你笔记的 Mochi。”';
}
