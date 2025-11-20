import 'package:flutter/material.dart';
import 'package:las_app/common_widgets/c_text.dart';
import 'package:las_app/core/theme/app_colors.dart';
import 'package:las_app/core/theme/app_typography.dart';

class AppWidgetUtil {
  static void showErrorDialog(BuildContext context, {required String error}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2937),
        title: CText(
          'Error',
          style: AppTypography.h2.copyWith(color: AppColors.white),
        ),
        content: CText(
          error,
          style: AppTypography.body.copyWith(color: AppColors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: CText(
              'OK',
              style: AppTypography.body.copyWith(color: AppColors.bPrimaryColor),
            ),
          ),
        ],
      ),
    );
  }

  static void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.bPrimaryColor,
      ),
    );
  }
}