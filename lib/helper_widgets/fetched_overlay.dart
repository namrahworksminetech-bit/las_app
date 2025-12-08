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
    final formatCurrency = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹ ',
      decimalDigits: 0,
    );

    final state = context.watch<EligibilityBloc>().state;
    final mfDetailsResponse = state.mfDetailsResponse;

    final totalPledgeable =
        mfDetailsResponse?.pledgeableFunds.fold<double>(
              0,
              (sum, f) => sum + (f.availableAmount ?? 0),
            ) ??
            0.0;

    return Stack(
      children: [
        /// DARK BACKGROUND + DISABLE OUTSIDE TOUCH
        ModalBarrier(
          color: Colors.black.withOpacity(0.4),
          dismissible: false,
        ),

        /// FIXED BOTTOM OVERLAY (not scrollable, not dismissible)
        Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            // 👉 Block swipe-down gestures
            onVerticalDragStart: (_) {},
            onVerticalDragUpdate: (_) {},
            onVerticalDragEnd: (_) {},
            behavior: HitTestBehavior.opaque,

            child: IgnorePointer(
              ignoring: false,
              child: _buildUI(context, formatCurrency, totalPledgeable),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUI(
      BuildContext context, NumberFormat formatCurrency, double totalAmount) {
    return Container(
      padding: const EdgeInsets.all(Gaps.xl),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),

      /// Prevent any scrolling inside overlay
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
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

            RichText(
              text: TextSpan(
                style: AppTypography.h0.copyWith(color: AppColors.success),
                children: [
                  TextSpan(text: formatCurrency.format(totalAmount)),
                ],
              ),
            ),

            Gaps.hXs,

            CText(
              'fromInvestments'.tr,
              style: AppTypography.bodySmall.copyWith(color: AppColors.black),
            ),

            Gaps.hXxl,

            _buildContinueButton(context),

            Gaps.hMd,
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    return CButton(
      text: 'seeLoanOffers'.tr,
      type: ButtonType.secondaryBlack,
      suffixIcon: const Icon(Icons.arrow_forward, color: AppColors.black),
      onPressed: () {
        try {
          final eligibilityBloc = context.read<EligibilityBloc>();
          final innerStatus =
              eligibilityBloc.state.pledgeMfResponse?.extractInnerStatus();

          final raw = eligibilityBloc.state.pledgeMfResponse?.data;
          final List<String> rawStatusList = [];

          if (raw is Map && raw?['status'] != null) {
            if (raw?['status'] is String) {
              rawStatusList.add(raw?['status']);
            } else if (raw?['status'] is List) {
              for (var s in raw?['status']) {
                if (s is String) rawStatusList.add(s);
              }
            }
          }

          const redirectToKyc = {
            'kyc_done',
            'kfs_agreement_done',
            'penny_drop_done',
            'mandate_flow_fail',
          };

          const redirectToFunds = {
            'mf_fetched',
          };

          final bool goKyc =
              (innerStatus != null && redirectToKyc.contains(innerStatus)) ||
                  rawStatusList.any((s) => redirectToKyc.contains(s));

          final bool goFunds =
              (innerStatus != null && redirectToFunds.contains(innerStatus)) ||
                  rawStatusList.any((s) => redirectToFunds.contains(s));

          if (Navigator.of(context).canPop()) Navigator.of(context).pop();

          if (goKyc) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (_) => EligibilityBloc(
                    repository: PanRepository(ApiClient()),
                    lenderRepository: LenderRepository(ApiClient()),
                    apiClient: ApiClient(),
                  ),
                  child: KycVerificationScreen(),
                ),
              ),
            );
          } else {
            final nextScreen =
                goFunds ? const FundSelectionView() : const LenderSelectionScreen();

            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: eligibilityBloc,
                  child: nextScreen,
                ),
              ),
            );
          }
        } catch (_) {}
      },
    );
  }
}
