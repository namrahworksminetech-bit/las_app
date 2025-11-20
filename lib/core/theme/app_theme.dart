import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);

    // Start from base, apply Poppins to the entire textTheme, then override specific styles
    final textThemeWithPoppins = base.textTheme
        .apply(fontFamily: 'Poppins')
        .copyWith(
          // Ensure the custom AppTypography styles also use Poppins
          headlineMedium: AppTypography.h2.copyWith(fontFamily: 'Poppins'),
          bodyMedium: AppTypography.body.copyWith(fontFamily: 'Poppins'),
        );

    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
      scaffoldBackgroundColor: AppColors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.black,
        elevation: 0,
      ),

      // apply the constructed text theme
      textTheme: textThemeWithPoppins,

      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);

    final textThemeWithPoppins = base.textTheme
        .apply(fontFamily: 'Poppins')
        .copyWith(
          // If you have dark-specific AppTypography styles, also ensure they have Poppins
          headlineMedium: AppTypography.h2.copyWith(fontFamily: 'Poppins'),
          bodyMedium: AppTypography.body.copyWith(fontFamily: 'Poppins'),
        );

    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryDark,
        brightness: Brightness.dark,
      ),
      textTheme: textThemeWithPoppins,
    );
  }
}
