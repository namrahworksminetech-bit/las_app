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
  debugPrint("🔥 PortfolioFetchingOverlay INIT CALLED");

  final bloc = context.read<EligibilityBloc>();
  if (bloc.state.isStep2Loading) {
    debugPrint('🔁 Fetch already in progress, skipping add(FetchStep2Data)');
  } else if (bloc.state.mfDetailsResponse != null) {
    debugPrint('🔁 mfDetailsResponse already present, skipping fetch');
  } else {
    bloc.add(FetchStep2Data());
  }
}
  @override
  Widget build(BuildContext context) {
    return BlocListener<EligibilityBloc, EligibilityState>(
  listenWhen: (prev, curr) =>
      prev.isStep2Loading == true && curr.isStep2Loading == false,
  listener: (context, state) {
    debugPrint("🎯 BlocListener triggered — isStep2Loading changed");
    debugPrint('   isLoading=${state.isLoading} isStep2Loading=${state.isStep2Loading}');

    // If API returned an error, show it and close the overlay
    if (state.generalErrorMessage != null && state.generalErrorMessage!.isNotEmpty) {
      Get.snackbar("Error", state.generalErrorMessage!);
      try {
        if (Navigator.of(context).canPop()) Navigator.of(context).pop();
      } catch (e) {
        debugPrint('⚠️ Navigator.pop() failed: $e');
      }
      return;
    }

    // Close fetching overlay if open
    try {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        debugPrint('⚠️ No route to pop when closing fetching overlay');
      }
    } catch (e) {
      debugPrint('⚠️ Exception when trying to pop fetching overlay: $e');
    }

    // Open result bottom sheet with the same bloc instance
    Get.bottomSheet(
      BlocProvider.value(
        value: context.read<EligibilityBloc>(),
        child: EligibilityResultOverlay(),
      ),
      isScrollControlled: true,
    );
  },
  child: _buildUI(),
)
;
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
