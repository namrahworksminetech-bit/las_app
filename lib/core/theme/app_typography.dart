import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTypography {
  static const _base = TextStyle(fontFamily: 'Roboto', color: AppColors.white);
   static TextStyle get h0 =>
      _base.copyWith(fontSize: 34, fontWeight: FontWeight.w700);

  static TextStyle get h1 =>
      _base.copyWith(fontSize: 28, fontWeight: FontWeight.w700);
  static TextStyle get h2 =>
      _base.copyWith(fontSize: 22, fontWeight: FontWeight.w600);
  static TextStyle get h3 =>
      _base.copyWith(fontSize: 18, fontWeight: FontWeight.w600);
        static TextStyle get h4 =>
      _base.copyWith(fontSize: 19, fontWeight: FontWeight.w700);
  static TextStyle get body =>
      _base.copyWith(fontSize: 14, fontWeight: FontWeight.w400, height: 1.4);
       static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Colors.white70, // or AppColors.bSecondaryColor if you have it
  );

  static TextStyle get bodyMedium =>
      _base.copyWith(fontSize: 16, fontWeight: FontWeight.w500, height: 1.4);

    static TextStyle get bodyWhite => _base.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.white,
        height: 1.4,
      );

  static TextStyle get bodySecondary => _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.bSecondaryColor,
    height: 1.4,
  );

  // ===== Captions / Labels =====
  static TextStyle get caption => _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.bSecondaryColor,
    height: 1.3,
  );

  static TextStyle get overline => _base.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: AppColors.bSecondaryColor,
    letterSpacing: 0.5,
  );

  // ===== Buttons =====
  static TextStyle get buttonPrimary => _base.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.black,
  );

  static TextStyle get buttonSecondary => _base.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );

  // ===== Subtitle Variant =====
  static TextStyle get subtitle => _base.copyWith(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.bSecondaryColor,
  );
}
