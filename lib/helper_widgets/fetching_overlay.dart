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
      debugPrint('🔁 Already loading… skipping fetch');
    } else if (bloc.state.mfDetailsResponse != null) {
      debugPrint('🔁 Data already present… skipping fetch');
    } else {
      bloc.add(FetchStep2Data());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        /// DARK OVERLAY — BLOCK ALL OUTSIDE TOUCHES
        ModalBarrier(
          color: Colors.black.withOpacity(0.5),
          dismissible: false,
        ),

        /// FIXED BOTTOM OVERLAY — NOT DISMISSIBLE / NOT SCROLLABLE
        Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            // BLOCK SWIPE DOWN
            onVerticalDragStart: (_) {},
            onVerticalDragUpdate: (_) {},
            onVerticalDragEnd: (_) {},
            behavior: HitTestBehavior.opaque,

            child: IgnorePointer(
              ignoring: false,
              child: BlocListener<EligibilityBloc, EligibilityState>(
                listenWhen: (prev, curr) =>
                    prev.isStep2Loading == true &&
                    curr.isStep2Loading == false,
                listener: _listener,
                child: _buildUI(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _listener(BuildContext context, EligibilityState state) {
    debugPrint("🎯 Step2 loading finished, navigating…");

    // ERROR CASE — Close overlay & show message
    if (state.generalErrorMessage != null &&
        state.generalErrorMessage!.isNotEmpty) {
      Get.snackbar("Error", state.generalErrorMessage!);

      try {
        if (Navigator.of(context).canPop()) Navigator.of(context).pop();
      } catch (e) {
        debugPrint('⚠️ Failed to pop overlay: $e');
      }
      return;
    }

    // CLOSE THIS OVERLAY
    try {
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();
    } catch (e) {
      debugPrint('⚠️ Error closing overlay: $e');
    }

    // OPEN RESULT SHEET
    Get.bottomSheet(
      BlocProvider.value(
        value: context.read<EligibilityBloc>(),
        child: EligibilityResultOverlay(),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildUI() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: Gaps.xl),
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),

      /// PREVENT INTERNAL SCROLLING
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
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
      ),
    );
  }
}
