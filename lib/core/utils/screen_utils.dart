import 'package:flutter/widgets.dart';

class ScreenUtils {
  ScreenUtils._();

  static late MediaQueryData _mq;

  static void init(BuildContext context) {
    _mq = MediaQuery.of(context);
  }

  static double get screenWidth => _mq.size.width;
  static double get screenHeight => _mq.size.height;
  static double get topPadding => _mq.padding.top;
  static double get bottomPadding => _mq.padding.bottom;
  static double get keyboardHeight => _mq.viewInsets.bottom;

  static double get usableHeight =>
      screenHeight - topPadding - bottomPadding - keyboardHeight;

  // Fractional helpers — prefer these over hardcoded pixels
  static double hp(double fraction) => screenHeight * fraction;
  static double wp(double fraction) => screenWidth * fraction;
}
