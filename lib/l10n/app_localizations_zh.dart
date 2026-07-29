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
}
