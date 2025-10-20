import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTypography {
  static const _base = TextStyle(
    fontFamily: 'Roboto', // replace if you have custom font
    color: AppColors.black,
  );

  static TextStyle get h1 => _base.copyWith(fontSize: 28, fontWeight: FontWeight.w700);
  static TextStyle get h2 => _base.copyWith(fontSize: 22, fontWeight: FontWeight.w600);
  static TextStyle get h3 => _base.copyWith(fontSize: 18, fontWeight: FontWeight.w600);
  static TextStyle get body => _base.copyWith(fontSize: 14, fontWeight: FontWeight.w400);
  static TextStyle get caption => _base.copyWith(fontSize: 12, color: AppColors.grey700);
}
