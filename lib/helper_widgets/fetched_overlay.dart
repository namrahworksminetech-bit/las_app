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
    // Format ₹ amounts
    final formatCurrency = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹ ',
      decimalDigits: 0,
    );

    // Watch eligibility state
    final state = context.watch<EligibilityBloc>().state;

    final mfDetailsResponse = state.mfDetailsResponse;

    // Calculate total pledgeable
    final totalPledgeable = mfDetailsResponse?.pledgeableFunds.fold<double>(
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

          // Image
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

          // Amount
          RichText(
            text: TextSpan(
              style: AppTypography.h0.copyWith(color: AppColors.success),
              children: [
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

          // Continue button
          CButton(
            text: 'seeLoanOffers'.tr,
            type: ButtonType.secondaryBlack,
            suffixIcon: const Icon(
              Icons.arrow_forward,
              color: AppColors.black,
              size: 18,
            ),
            onPressed: () {
              try {
                final eligibilityBloc = context.read<EligibilityBloc>();

                // Close bottom sheet safely
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }

                // Navigate to lender selection with same bloc instance
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (routeCtx) => BlocProvider.value(
                      value: eligibilityBloc,
                      child: const LenderSelectionScreen(),
                    ),
                  ),
                );
              } catch (e, st) {
                debugPrint("Navigation error: $e");
                debugPrintStack(stackTrace: st);
              }
            },
          ),

          Gaps.hMd,
        ],
      ),
    );
  }
}
