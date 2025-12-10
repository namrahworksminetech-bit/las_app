import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:las_app/common_widgets/c_snackbar.dart';
import 'package:las_app/core/theme/app_colors.dart';
import 'package:las_app/core/theme/app_spacing.dart';
import 'package:las_app/core/theme/app_typography.dart';
import 'package:las_app/common_widgets/c_text.dart';
import 'package:las_app/features/new_user/bloc/eligibility_bloc.dart';
import 'package:las_app/models/funds/mf_details_response_model.dart';
import 'package:las_app/models/funds/pledgeable_model.dart';

class PortfolioBreakdownView extends StatelessWidget {
  final MfDetailsResponse mfDetailsResponse;
  final Function(String) onCategoryTapped;
  final VoidCallback onRefresh;

  const PortfolioBreakdownView({
    super.key,
    required this.onCategoryTapped,
    required this.onRefresh,
    required this.mfDetailsResponse,
  });

  @override
  Widget build(BuildContext context) {
    final formatCurrencyInt = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹ ',
      decimalDigits: 0,
    );
    final formatCurrency = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹ ',
      decimalDigits: 2,
    );

    final isRefreshing =
        context.watch<EligibilityBloc>().state.isPortfolioRefreshing;

    // Extract data
    final List<PledgeableFund> pledgeableFunds =
        mfDetailsResponse.pledgeableFunds;

    final double totalPledgeable = pledgeableFunds.fold<double>(
      0,
      (sum, fund) => sum + (fund.availableAmount ?? 0),
    );

    final double nonPledgeable = mfDetailsResponse.nonPledgeableAmount ?? 0;
    final double demat = mfDetailsResponse.dematAmount ?? 0;
    final double unapprovedFunds = 0.0;

    return SingleChildScrollView(
      key: const ValueKey('breakdown_view'),
      padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 200.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Refresh Button
        

        

          // Breakdown Rows
          _buildBreakdownRow(
              context: context,
            title: 'pledgeableFunds'.tr,
            value: formatCurrencyInt.format(totalPledgeable),
            amount: totalPledgeable,
            onTap: () => onCategoryTapped('pledgeable'),
          ),
          _buildBreakdownRow(
              context: context,
            title: 'nonPledgeableFunds'.tr,
            value: formatCurrencyInt.format(nonPledgeable),
            amount: nonPledgeable,
            onTap: () => onCategoryTapped('non_pledgeable'),
          ),
          _buildBreakdownRow(
              context: context,
            title: 'dematFunds'.tr,
            value: formatCurrencyInt.format(demat),
            amount: demat,
            onTap: () => onCategoryTapped('demat'),
          ),
          _buildBreakdownRow(
              context: context,
            title: 'unapprovedFunds'.tr,
            value: formatCurrency.format(unapprovedFunds),
            amount: unapprovedFunds,
            onTap: () => onCategoryTapped('unapproved'),
           
          ),
        ],
      ),
    );
  }
Widget _buildBreakdownRow({
  required BuildContext context,
  required String title,
  required String value,
  required double amount,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: () {
      if (amount <= 0) {
        CSnackBar.show(
          context,
          "No funds available under $title",
          isError: true,
        );
        return;
      }
      onTap();
    },
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppColors.bSecondaryColor.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CText(
            title,
            style: AppTypography.bodyWhite.copyWith(fontSize: 14),
          ),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CText(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodyWhite.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Gaps.wSm,
              const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.bSecondaryColor,
                size: 14,
              ),
            ],
          ),
        ],
      ),
    ),
  );
}


}
