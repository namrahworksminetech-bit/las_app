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
    // Currency formatter
    final formatCurrency = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹ ',
      decimalDigits: 0,
    );

    // Access the BLoC state
    final mfDetailsResponse = context
        .watch<EligibilityBloc>()
        .state
        .mfDetailsResponse;

    // Calculate total pledgeable funds dynamically
    final totalPledgeable =
        mfDetailsResponse?.pledgeableFunds.fold<double>(
          0,
          (sum, fund) => sum + (fund.availableAmount ?? 0),
        ) ??
        0.0;

    // Helper to safely add events to BLoC (avoids crashes if bloc closed)
    void safeAdd(EligibilityBloc bloc, EligibilityEvent event) {
      try {
        bloc.add(event);
      } catch (e, st) {
        debugPrint('EligibilityBloc.add() failed: $e\n$st');
      }
    }

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

          // Center Image
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

          // Dynamic total pledgeable value
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

          // Button to proceed
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

                // Close the bottom sheet / overlay first (if this widget is inside one)
                try {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop(); // closes bottom sheet or route
                  }
                } catch (e) {
                  debugPrint('Failed to pop overlay before navigation: $e');
                }

                // Trigger data fetch for lender list + portfolio
                safeAdd(eligibilityBloc, FetchStep2Data());

                // Navigate to LenderSelectionScreen and reuse the same bloc instance.
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (navCtx) => BlocProvider.value(
                      value: eligibilityBloc,
                      child: const LenderSelectionScreen(),
                    ),
                  ),
                );
              } catch (e, st) {
                debugPrint('Error navigating to lender selection: $e');
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
