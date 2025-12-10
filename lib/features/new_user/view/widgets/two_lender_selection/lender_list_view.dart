import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:las_app/common_widgets/c_text.dart';
import 'package:las_app/helper_widgets/lender_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:las_app/core/theme/app_colors.dart';
import 'package:las_app/features/new_user/bloc/eligibility_bloc.dart';
class LenderListView extends StatelessWidget {
  const LenderListView({super.key});
Future<void> _showEditLoanDialog(
  BuildContext context,
  Lender lender,
  double currentAmount,
) async {
  final TextEditingController controller = TextEditingController(
    text: currentAmount.toStringAsFixed(0),
  );

  final newAmount = await showDialog<double>(
    context: context,
    builder: (_) {
      return AlertDialog(
        backgroundColor: const Color(0xFF1F2937),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          "Edit Loan Amount",
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            prefixText: "₹ ",
            prefixStyle: TextStyle(color: Colors.white),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white54),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blueAccent),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(
                context,
                double.tryParse(controller.text),
              );
            },
            child: const Text("Save", style: TextStyle(color: Colors.blue)),
          ),
        ],
      );
    },
  );

  if (newAmount != null) {
    context.read<EligibilityBloc>().add(
          SaveEditedLoanAmount(lender.id, newAmount),
        );
  }
}

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EligibilityBloc>().state;

    if (state.lenders.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.bPrimaryColor),
      );
    }

    final Map<String, double> editedLoanAmounts = state.editedLoanAmounts ?? {};

    return Stack(
  children: [
    ListView.builder(
      key: const ValueKey('lender_list'),
      padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 24.0),
      itemCount: state.lenders.length,
      itemBuilder: (context, index) {
        final lender = state.lenders[index];
        final displayAmount = (state.editedLoanAmounts ?? {}).containsKey(lender.id)
            ? state.editedLoanAmounts![lender.id]!
            : (lender.loanAmount ?? 0.0);

        return LenderCard(
  lender: lender.copyWith(loanAmount: displayAmount),
  snackbarMessage: state.snackbarMessage,
  isSelected: state.selectedLenderId == lender.id,
  isSavingLoan: state.isSavingLoan,
  lastSavedLenderId: state.lastSavedLenderId,
  lastSaveMessage: state.lastSaveMessage,

  onTap: () => context.read<EligibilityBloc>().add(
        LenderSelected(lender.id),
      ),

  // ⭐ NEW CALLBACK → Opens Edit Loan Amount popup dialog
  onEditDialog: () {
    _showEditLoanDialog(
      context,
      lender,
      displayAmount,
    );
  },

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
    ),

    // Overlay only when save is in progress
    if (state.isSavingLoan)
      const Positioned.fill(
        child: ColoredBox(
          color: Color.fromRGBO(0, 0, 0, 0.45),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
  ],
);
}
}