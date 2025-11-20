import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:las_app/core/theme/app_colors.dart';
import 'package:las_app/core/theme/app_typography.dart';
import 'package:las_app/core/theme/app_spacing.dart';
import 'package:las_app/common_widgets/c_text.dart';
import 'package:las_app/features/new_user/bloc/eligibility_bloc.dart';

class PledgeableFundsDetailView extends StatelessWidget {
  final VoidCallback onRefresh;

  const PledgeableFundsDetailView({
    super.key,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final eligibilityState = context.watch<EligibilityBloc>().state;
    final isRefreshing = eligibilityState.isPortfolioRefreshing;

    
    final funds = eligibilityState.mfDetailsResponse?.pledgeableFunds ?? [];

    final formatCurrencyInt = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹ ',
      decimalDigits: 0,
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 8.0),
          child: SizedBox(
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
        ),

        // ✅ Handle empty or data state
        if (funds.isEmpty)
          Expanded(
            child: Center(
              child: CText(
                "No pledgeable funds found",
                style: AppTypography.bodyWhite,
              ),
            ),
          )
        else
          Expanded(
            child: ListView.separated(
              key: const ValueKey('detail_view'),
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              itemCount: funds.length,
              separatorBuilder: (_, __) => const Divider(
                color: AppColors.bSecondaryColor,
                thickness: 0.5,
                height: 0.5,
              ),
              itemBuilder: (context, index) {
                final fund = funds[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: CText(
                          fund.fundName ?? '-',
                          style: AppTypography.bodyWhite,
                        ),
                      ),
                      Gaps.wMd,
                      CText(
                        formatCurrencyInt.format(fund.fundValue ?? 0.0),
                        style: AppTypography.bodyWhite.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
