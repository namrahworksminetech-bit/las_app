import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:las_app/common_widgets/c_snackbar.dart';
import 'package:las_app/common_widgets/c_text.dart';
import 'package:las_app/core/theme/app_colors.dart';
import 'package:las_app/core/theme/app_typography.dart';
import 'package:las_app/features/new_user/bloc/eligibility_bloc.dart';

Future<void> showEditLoanDialog(
  BuildContext context,
  Lender lender,
  double currentAmount,
) async {
  final eligibilityBloc = context.read<EligibilityBloc>();

  final controller = TextEditingController(
    text: currentAmount.toStringAsFixed(0),
  );

  final eligibleLimit = lender.maxEligibleLimit ?? 0;

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogCtx) {
      return AlertDialog(
        backgroundColor: const Color(0xFF1F2937),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: CText("Edit Loan Amount",
            style: AppTypography.h3.copyWith(color: AppColors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: AppTypography.bodyWhite.copyWith(fontSize: 24),
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                prefixText: "₹ ",
                prefixStyle: TextStyle(color: AppColors.white, fontSize: 24),
              ),
            ),
            const SizedBox(height: 8),
            CText(
              "Eligible limit: ₹${eligibleLimit.toStringAsFixed(0)}",
              style: AppTypography.bodySecondary.copyWith(
                color: AppColors.bSecondaryColor,
                fontSize: 12,
              ),
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: CText("Cancel", style: AppTypography.bodySecondary),
          ),
          TextButton(
            onPressed: () {
              final newAmt = double.tryParse(controller.text);
              if (newAmt == null) {
                CSnackBar.show(context, "Invalid amount", isError: true);
                return;
              }

              eligibilityBloc.add(
                SaveEditedLoanAmount(lender.id, newAmt),
              );

              Navigator.pop(dialogCtx);
            },
            child: CText(
              "Confirm",
              style: AppTypography.bodyWhite.copyWith(
                color: AppColors.bPrimaryColor,
              ),
            ),
          ),
        ],
      );
    },
  );
}
