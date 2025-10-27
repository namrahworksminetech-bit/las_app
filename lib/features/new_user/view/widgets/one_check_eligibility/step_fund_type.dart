import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:las_app/common_widgets/c_selection_card.dart';
import 'package:las_app/core/theme/app_colors.dart';
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
          const SizedBox(height: 30),

          RichText(
            text: TextSpan(
              style: const TextStyle(
                color: AppColors.bSecondaryColor,
                fontSize: 13,
              ),
              children: [
                const TextSpan(text: 'Select The Investment You Want to '),
                const TextSpan(
                  text: 'Unlock Funds From',
                  style: TextStyle(color: AppColors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SelectionCard(
            title: 'Insurance Policy',
            subtitle: 'Get loan against your life insurance policies.',
            iconPath: 'assets/icons/umbrella.png',
            isSelected:
                state.formData.investmentType == InvestmentType.insurancePolicy,
            onTap: () => context.read<EligibilityBloc>().add(
              const InvestmentTypeUpdated(InvestmentType.insurancePolicy),
            ),
          ),
          SelectionCard(
            title: 'Mutual Fund',
            subtitle: 'Get instant funds while your MF stay invested.',
            iconPath: 'assets/icons/mutual_fund_bag.png',
            isSelected:
                state.formData.investmentType == InvestmentType.mutualFund,
            onTap: () => context.read<EligibilityBloc>().add(
              const InvestmentTypeUpdated(InvestmentType.mutualFund),
            ),
          ),
          SelectionCard(
            title: 'Shares',
            subtitle: 'Leverage your shares without selling them.',
            iconPath: 'assets/icons/shares_icon.png',
            isSelected: state.formData.investmentType == InvestmentType.shares,
            onTap: () => context.read<EligibilityBloc>().add(
              const InvestmentTypeUpdated(InvestmentType.shares),
            ),
          ),
        ],
      ),
    );
  }
}
