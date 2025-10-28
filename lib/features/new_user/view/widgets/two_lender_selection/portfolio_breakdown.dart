import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:las_app/core/theme/app_colors.dart';
import 'package:las_app/core/theme/app_typography.dart';
import 'package:las_app/core/theme/app_spacing.dart';
import 'package:las_app/common_widgets/c_text.dart';
import 'package:las_app/features/new_user/bloc/eligibility_bloc.dart';

class PortfolioBreakdownView extends StatelessWidget {
  final PortfolioData portfolioData;
  final Function(String) onCategoryTapped;
  final VoidCallback onRefresh;

  const PortfolioBreakdownView({
    super.key,
    required this.portfolioData,
    required this.onCategoryTapped,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final formatCurrency =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹ ', decimalDigits: 2);
    final formatCurrencyInt =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹ ', decimalDigits: 0);

    final double nonPledgeableFunds = 320000;
    final double dematFunds = 275000;
    final double unapprovedFunds = 285922.36;

    final isRefreshing =
        context.watch<EligibilityBloc>().state.isPortfolioRefreshing;

    return SingleChildScrollView(
      key: const ValueKey('breakdown_view'),
      padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 200.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onRefresh,
              icon: isRefreshing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.bSecondaryColor,
                      ),
                    )
                  : const Icon(
                      Icons.refresh,
                      color: AppColors.bSecondaryColor,
                      size: 20,
                    ),
              label: CText(
                'refreshPortfolio'.tr,
                style: AppTypography.bodySecondary,
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.bSecondaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          Gaps.hXl,

          _buildBreakdownRow(
            title: 'pledgeableFunds'.tr,
            value: formatCurrencyInt.format(portfolioData.pledgeableFunds),
            onTap: () => onCategoryTapped('pledgeable'),
          ),
          _buildBreakdownRow(
            title: 'nonPledgeableFunds'.tr,
            value: formatCurrencyInt.format(nonPledgeableFunds),
            onTap: () => onCategoryTapped('non_pledgeable'),
          ),
          _buildBreakdownRow(
            title: 'dematFunds'.tr,
            value: formatCurrencyInt.format(dematFunds),
            onTap: () => onCategoryTapped('demat'),
          ),
          _buildBreakdownRow(
            title: 'unapprovedFunds'.tr,
            value: formatCurrency.format(unapprovedFunds),
            onTap: () => onCategoryTapped('unapproved'),
            showBorder: false,
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow({
    required String title,
    required String value,
    required VoidCallback onTap,
    bool showBorder = true,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        decoration: BoxDecoration(
          border: showBorder
              ? const Border(
                  bottom:
                      BorderSide(color: AppColors.bSecondaryColor, width: 0.5),
                )
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CText(
              title,
              style: AppTypography.bodyWhite,
            ),
            Row(
              children: [
                CText(
                  value,
                  style: AppTypography.bodyWhite.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Gaps.wXs,
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
