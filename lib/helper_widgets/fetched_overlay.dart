import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:las_app/common_widgets/c_button.dart';
import 'package:las_app/common_widgets/c_text.dart';
import 'package:las_app/core/theme/app_colors.dart';
import 'package:las_app/core/theme/app_spacing.dart';
import 'package:las_app/core/theme/app_typography.dart';
import 'package:las_app/features/new_user/bloc/eligibility_bloc.dart';
import 'package:las_app/features/new_user/view/widgets/two_lender_selection/lender_selection.dart';

class EligibilityResultOverlay extends StatelessWidget {
  const EligibilityResultOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Gaps.xl),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CText(
            'eligibleUnlock'.tr,
            style: AppTypography.bodyWhite.copyWith(color: AppColors.black),
            textAlign: TextAlign.center,
          ),
          Gaps.hXxl,

        SizedBox(
  width: 150, // or 120 for even bigger
  height: 150, // or 120 for even bigger
  child: ClipOval(
    child: Image.asset(
      'assets/images/fetchedFunds.png', // Update with your asset path
      fit: BoxFit.cover, // Ensures the image fills the container
    ),
  ),
),


          Gaps.hXl,

          RichText(
            text: TextSpan(
              style: AppTypography.h0.copyWith(
                color: AppColors.success,
              ),
              children: [
                TextSpan(text: '₹ '.tr),
                TextSpan(text: '4,85,800'.tr),
              ],
            ),
          ),

          Gaps.hXs,

          CText(
            'fromInvestments'.tr,
            style: AppTypography.bodySmall.copyWith(color: AppColors.black),
          ),

          Gaps.hXxl,

          CButton(
  text: 'seeLoanOffers'.tr,
  onPressed: () {
    final eligibilityBloc = context.read<EligibilityBloc>();

    // 🔹 Correct: Fetch lender list + portfolio data here
    eligibilityBloc.add(FetchStep2Data());

    // 🔹 Navigate to lender selection screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: eligibilityBloc,
          child: const LenderSelectionScreen(),
        ),
      ),
    );
  },
  type: ButtonType.secondaryBlack,
  suffixIcon: const Icon(
    Icons.arrow_forward,
    color: AppColors.black,
    size: 18,
  ),
),
          Gaps.hMd,
        ],
      ),
    );
  }
}
