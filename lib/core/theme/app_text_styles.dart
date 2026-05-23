import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pally/core/theme/app_colors.dart';

abstract final class AppTextStyles {
  static TextStyle get heading1 => GoogleFonts.nunito(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.text1,
      );

  static TextStyle get title => GoogleFonts.nunito(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.text1,
      );

  static TextStyle get body => GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.text1,
      );

  static TextStyle get bodySmall => GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.text2,
      );

  static TextStyle get label => GoogleFonts.nunito(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.text2,
      );

  static TextStyle get caption => GoogleFonts.nunito(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        color: AppColors.text3,
      );
}
