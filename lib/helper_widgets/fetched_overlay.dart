import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:las_app/common_widgets/c_button.dart';
import 'package:las_app/common_widgets/c_text.dart';
import 'package:las_app/core/network/api_client.dart';
import 'package:las_app/core/theme/app_colors.dart';
import 'package:las_app/core/theme/app_spacing.dart';
import 'package:las_app/core/theme/app_typography.dart';
import 'package:las_app/features/new_user/bloc/eligibility_bloc.dart';
import 'package:las_app/features/new_user/repository/lenders_data_repo.dart';
import 'package:las_app/features/new_user/repository/pan_veirfy_repo.dart';

import 'package:las_app/features/new_user/view/widgets/three_kyc_verification/step_checker_view.dart';
import 'package:las_app/features/new_user/view/widgets/two_lender_selection/fund_selection_view.dart';
import 'package:las_app/features/new_user/view/widgets/two_lender_selection/lender_selection.dart';
import 'package:las_app/models/funds/pledge_mf_response.dart';

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
<<<<<<< HEAD
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

 
    final innerStatus =
        eligibilityBloc.state.pledgeMfResponse?.extractInnerStatus();

    // Also check raw status list (in case helper didn't pick the desired value)
    final rawStatus = eligibilityBloc.state.pledgeMfResponse?.data;
    final List<String> statusListFromMap = [];
    if (rawStatus is Map && rawStatus?['status'] != null) {
      final s = rawStatus?['status'];
      if (s is String) {
        statusListFromMap.add(s);
      } else if (s is List) {
        for (final item in s) {
          if (item is String) statusListFromMap.add(item);
        }
      }
    }

    // statuses that should redirect to KYC verification
    const redirectToKyc = {
      'kyc_done',
      'kfs_agreement_done',
      'penny_drop_done',
      'mandate_flow_fail',
    };

    // statuses that should redirect to Funds (kept from prior logic)
    const redirectToFunds = {
      'mf_fetched',
   
   
    };

    final bool hasKycStatus = (innerStatus != null && redirectToKyc.contains(innerStatus)) ||
        statusListFromMap.any((s) => redirectToKyc.contains(s));

    final bool shouldGoToFunds = (innerStatus != null && redirectToFunds.contains(innerStatus)) ||
        statusListFromMap.any((s) => redirectToFunds.contains(s));

    debugPrint('Eligibility navigation decision: innerStatus=$innerStatus, '
        'statusList=$statusListFromMap, hasKycStatus=$hasKycStatus, shouldGoToFunds=$shouldGoToFunds');

    // Close the overlay (bottom sheet)
    if (Navigator.of(context).canPop()) Navigator.of(context).pop();

    // NAVIGATION DECISION:
    if (hasKycStatus) {
      // Navigate to KYC verification screen with a NEW EligibilityBloc instance
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (routeCtx) => BlocProvider(
            create: (_) => EligibilityBloc(
             repository: PanRepository(ApiClient()),
                          lenderRepository: LenderRepository(ApiClient()),
                          apiClient: ApiClient(),
            ),
            child: KycVerificationScreen(
            
            ),
          ),
        ),
      );
    } else {
      // For funds/lender flow — reuse same bloc instance as before
      final Widget nextScreen =
          shouldGoToFunds ? const FundSelectionView() : const LenderSelectionScreen();

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (routeCtx) => BlocProvider.value(
            value: eligibilityBloc,
            child: nextScreen,
          ),
        ),
      );
    }
  } catch (e, st) {
    debugPrint("Navigation error: $e");
    debugPrintStack(stackTrace: st);
  }
},
          ),
=======
  text: 'seeLoanOffers'.tr,
  onPressed: () {
    final eligibilityBloc = context.read<EligibilityBloc>();
>>>>>>> 9c76ba7 (changes committed)

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
