import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
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
    // ✅ Currency formatter
    final formatCurrency = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹ ',
      decimalDigits: 0,
    );

    // ✅ Access the BLoC state
    final mfDetailsResponse = context
        .watch<EligibilityBloc>()
        .state
        .mfDetailsResponse;

    // ✅ Calculate total pledgeable funds dynamically
    final totalPledgeable =
        mfDetailsResponse?.pledgeableFunds.fold<double>(
          0,
          (sum, fund) => sum + (fund.availableAmount ?? 0),
        ) ??
        0.0;

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

          // ✅ Center Image
          SizedBox(
            width: 150,
            height: 150,
            child: ClipOval(
              child: Image.asset(
                'assets/images/fetchedFunds.png',
                fit: BoxFit.cover,
              ),
            ),
          ),

          Gaps.hXl,

          // ✅ Dynamic total pledgeable value
          RichText(
            text: TextSpan(
              style: AppTypography.h0.copyWith(color: AppColors.success),
              children: [
                // TextSpan(text: /*'₹ '*/.tr),
                TextSpan(text: formatCurrency.format(totalPledgeable)),
              ],
            ),
          ),

          Gaps.hXs,

          CText(
            'fromInvestments'.tr,
            style: AppTypography.bodySmall.copyWith(color: AppColors.black),
          ),

          Gaps.hXxl,

          // ✅ Button to proceed
          CButton(
            text: 'seeLoanOffers'.tr,
            onPressed: () {
              final eligibilityBloc = context.read<EligibilityBloc>();

              // 🔹 Trigger data fetch for lender list + portfolio
              eligibilityBloc.add(FetchStep2Data());
              Navigator.pop(context);
              // 🔹 Navigate to LenderSelectionScreen
              Navigator.pushReplacement(
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
