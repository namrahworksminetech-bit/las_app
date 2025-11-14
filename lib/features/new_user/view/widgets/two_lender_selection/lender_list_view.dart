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

    // Show the spinner while loading (existing behavior)
    if (state.lenders.isEmpty && state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.bPrimaryColor),
      );
    }

    // If there are no lenders yet, show a loader instead of "No lenders available"
    // (useful when API is very slow and you want the user to see a spinner)
    if (state.lenders.isEmpty && !state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.bPrimaryColor),
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

        final isSavingForThisLender =
            state.isLoading && state.selectedLenderId == lender.id;

        return LenderCard(
          lender: displayLender,
          snackbarMessage: state.snackbarMessage,
          isSelected: state.selectedLenderId == lender.id,
          isSaving: isSavingForThisLender,
          lastSavedLenderId: state.lastSavedLenderId, // NEW
          lastSaveMessage: state.lastSaveMessage, // NEW
          onTap: () => context.read<EligibilityBloc>().add(LenderSelected(lender.id)),
          onAmountSaved: (newAmount) {
            context.read<EligibilityBloc>().add(SaveEditedLoanAmount(lender.id, newAmount));
          },
          onContinue: () => context.read<EligibilityBloc>().add(LenderContinuePressed(lender.id)),
        );
      },
    );
  }
}
