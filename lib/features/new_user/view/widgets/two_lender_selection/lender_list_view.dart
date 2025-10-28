import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:las_app/common_widgets/c_text.dart';
import 'package:las_app/helper_widgets/lender_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:las_app/core/theme/app_colors.dart';
import 'package:las_app/features/new_user/bloc/eligibility_bloc.dart';

class LenderListView extends StatelessWidget {
  const LenderListView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EligibilityBloc>().state;

    if (state.lenders.isEmpty && state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.bPrimaryColor),
      );
    }
    if (state.lenders.isEmpty && !state.isLoading) {
      return Center(
        child: CText(
          'Nolendersavailable'.tr,
          style: TextStyle(color: AppColors.bSecondaryColor),
        ),
      );
    }

    return ListView.builder(
      key: const ValueKey('lender_list'),
      padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 24.0),
      itemCount: state.lenders.length,
      itemBuilder: (context, index) {
        final lender = state.lenders[index];
        final displayAmount =
            state.editedLoanAmounts[lender.id] ?? lender.loanAmount;
        final displayLender = lender.copyWith(loanAmount: displayAmount);

        return LenderCard(
          lender: displayLender,
          isSelected: state.selectedLenderId == lender.id,
          onTap: () =>
              context.read<EligibilityBloc>().add(LenderSelected(lender.id)),
          onAmountSaved: (newAmount) {
            context.read<EligibilityBloc>().add(
              SaveEditedLoanAmount(lender.id, newAmount),
            );
          },

          onContinue: () => context.read<EligibilityBloc>().add(
            LenderContinuePressed(lender.id),
          ),
        );
      },
    );
  }
}
