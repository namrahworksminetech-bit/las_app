import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:las_app/common_widgets/c_text.dart';
import 'package:las_app/core/theme/app_colors.dart';
import 'package:las_app/core/theme/app_spacing.dart';
import 'package:las_app/core/theme/app_typography.dart';
import 'package:las_app/features/new_user/bloc/eligibility_bloc.dart';
import 'package:las_app/helper_widgets/fetched_overlay.dart';

class PortfolioFetchingOverlay extends StatefulWidget {
  const PortfolioFetchingOverlay({super.key});

  @override
  State<PortfolioFetchingOverlay> createState() =>
      _PortfolioFetchingOverlayState();
}

class _PortfolioFetchingOverlayState extends State<PortfolioFetchingOverlay> {
  @override
  void initState() {
    super.initState();

    print("🔥 PortfolioFetchingOverlay INIT CALLED");

    // Trigger API call immediately
    context.read<EligibilityBloc>().add(FetchStep2Data());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EligibilityBloc, EligibilityState>(
      listenWhen: (prev, curr) =>
          prev.isLoading == true && curr.isLoading == false,
      listener: (context, state) {
        print("🎯 BlocListener triggered — isLoading changed");

        // ❌ API ERROR
        if (state.generalErrorMessage != null) {
          Get.snackbar("Error", state.generalErrorMessage!);

          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          return;
        }

        // ✅ Close fetching overlay
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }

        // 👉 Open Result Overlay correctly (with BlocProvider.value)
        Get.bottomSheet(
          BlocProvider.value(
            value: context.read<EligibilityBloc>(),
            child: EligibilityResultOverlay(),
          ),
          isScrollControlled: true,
        );
      },
      child: _buildUI(),
    );
  }

  Widget _buildUI() {
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
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.black),
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
              'assets/images/fundFetchingAnimation.png',
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
