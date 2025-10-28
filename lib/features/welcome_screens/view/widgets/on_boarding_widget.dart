import 'package:flutter/material.dart';
import 'package:las_app/common_widgets/c_text.dart';
import 'package:las_app/core/theme/app_colors.dart';
import 'package:las_app/core/theme/app_spacing.dart';
import 'package:las_app/core/theme/app_typography.dart';


class OnboardingPageContent extends StatelessWidget {
  final String imagePath;
  final String iconAssetPath;
  final String subtitle;
  final String title;

  const OnboardingPageContent({
    super.key,
    required this.imagePath,
    required this.iconAssetPath,
    required this.subtitle,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    const Color kPrimaryColor = AppColors.bPrimaryColor;
    const Color kSubtitleTextColor = Color(0x80E5E7EB);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [

        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 3.0),
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
            ),
          ),
        ),

        Gaps.hMd, 

  
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset(
                    iconAssetPath,
                    color: kPrimaryColor,
                    width: 20,
                    height: 20,
                  ),
                  Gaps.wXs, 
                  CText(
                    subtitle,
                    style: AppTypography.body.copyWith(
                      color: kSubtitleTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              Gaps.hMd, 

              CText(
                title,
                style: AppTypography.h1.copyWith(
                  color: AppColors.white,
                  fontSize: 30, // same as before
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
