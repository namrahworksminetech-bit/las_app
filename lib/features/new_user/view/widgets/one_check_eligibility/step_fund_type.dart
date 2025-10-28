import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:las_app/common_widgets/c_selection_card.dart';
import 'package:las_app/core/theme/app_colors.dart';
import 'package:las_app/core/theme/app_spacing.dart';
import 'package:las_app/core/theme/app_typography.dart';
import 'package:las_app/features/new_user/bloc/eligibility_bloc.dart';

class Step1InvestmentPage extends StatelessWidget {
  const Step1InvestmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EligibilityBloc>().state;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: Gaps.xxl),

          RichText(
            text: TextSpan(
              style: AppTypography.bodySecondary.copyWith(
                color: AppColors.bSecondaryColor,
                fontSize: 13,
              ),
              children: [
                TextSpan(text: 'selectInvestmentTitlePart1'.tr),
                TextSpan(
                  text: 'selectInvestmentTitlePart2'.tr,
                  style: AppTypography.bodyWhite.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: Gaps.md),

     
          SelectionCard(
            title: 'insurancePolicyTitle'.tr,
            subtitle: 'insurancePolicySubtitle'.tr,
            iconPath: 'assets/icons/umbrella.png',
            isSelected:
                state.formData.investmentType == InvestmentType.insurancePolicy,
            onTap: () => context.read<EligibilityBloc>().add(
                  const InvestmentTypeUpdated(InvestmentType.insurancePolicy),
                ),
          ),

          SelectionCard(
            title: 'mutualFundTitle'.tr,
            subtitle: 'mutualFundSubtitle'.tr,
            iconPath: 'assets/icons/mutual_fund_bag.png',
            isSelected:
                state.formData.investmentType == InvestmentType.mutualFund,
            onTap: () => context.read<EligibilityBloc>().add(
                  const InvestmentTypeUpdated(InvestmentType.mutualFund),
                ),
          ),

          SelectionCard(
            title: 'sharesTitle'.tr,
            subtitle: 'sharesSubtitle'.tr,
            iconPath: 'assets/icons/shares_icon.png',
            isSelected:
                state.formData.investmentType == InvestmentType.shares,
            onTap: () => context.read<EligibilityBloc>().add(
                  const InvestmentTypeUpdated(InvestmentType.shares),
                ),
          ),
        ],
      ),
    );
  }
}
