import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:las_app/common_widgets/c_text.dart';
import 'package:las_app/core/theme/app_colors.dart';
import 'package:las_app/core/theme/app_spacing.dart';
import 'package:las_app/core/theme/app_typography.dart';

class PortfolioFetchingOverlay extends StatefulWidget {
  const PortfolioFetchingOverlay({super.key});

  @override
  State<PortfolioFetchingOverlay> createState() =>
      _PortfolioFetchingOverlayState();
}

class _PortfolioFetchingOverlayState extends State<PortfolioFetchingOverlay>
    {
  

  @override
  void initState() {
    super.initState();
  
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: Gaps.xl),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Gaps.xl),
            child: Column(
              children: [
                CText(
                  'almostThere'.tr,
                  style: AppTypography.h2.copyWith(color: AppColors.black),
                  textAlign: TextAlign.center,
                ),
                Gaps.hXs,
                CText(
                  'fetchingMutualFunds'.tr,
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.black),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          Gaps.hXxl,

        SizedBox(
  width: 240,
  height: 240,
  child: Image.asset(
    'assets/images/fundFetchingAnimation.png', // Ensure your asset path matches your actual file name & location
    width: 540,
    height: 540,
    fit: BoxFit.contain,
  ),
),
          Gaps.hXxl,

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Gaps.xl),
            child: CText(
              'cibilNote'.tr,
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall
                  .copyWith(color: AppColors.kIndicatorInactiveColor),
            ),
          ),
        ],
      ),
    );
  }
}

