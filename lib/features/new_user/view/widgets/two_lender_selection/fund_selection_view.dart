import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:las_app/common_widgets/c_button.dart';
import 'package:las_app/common_widgets/c_snackbar.dart';
import 'package:las_app/common_widgets/c_text.dart';
import 'package:las_app/core/theme/app_colors.dart';
import 'package:las_app/core/theme/app_spacing.dart';
import 'package:las_app/core/theme/app_typography.dart';
import 'package:las_app/features/new_user/bloc/eligibility_bloc.dart';
import 'package:las_app/features/new_user/view/widgets/three_kyc_verification/step_checker_view.dart';
import 'package:las_app/features/new_user/view/widgets/two_lender_selection/fund_list_item.dart';

class FundSelectionView extends StatelessWidget {
  const FundSelectionView({super.key});

  // 🧮 Loan edit dialog
  Future<void> _showEditLoanDialog(
    BuildContext blocContext,
    Lender lender,
    double currentAmount,
  ) async {
    final TextEditingController amountController = TextEditingController(
      text: currentAmount.toStringAsFixed(0),
    );

    final eligibleLimit = lender.loanAmount;

    final newAmount = await showDialog<double>(
      context: blocContext,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1F2937),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          title: CText(
            'Edit Loan Amount',
            style: AppTypography.h3.copyWith(color: AppColors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: false,
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: AppTypography.bodyWhite.copyWith(fontSize: 24),
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  prefixText: '₹ ',
                  prefixStyle: TextStyle(color: AppColors.white, fontSize: 24),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.bSecondaryColor),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.bPrimaryColor),
                  ),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 10),
              CText(
                'Eligible limit: ₹${eligibleLimit.toStringAsFixed(0)}',
                style: AppTypography.bodySecondary.copyWith(
                  color: AppColors.bSecondaryColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 8.0),
          actions: [
            TextButton(
              child: CText('cancel'.tr, style: AppTypography.bodySecondary),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: CText(
                'confirm'.tr,
                style: AppTypography.bodyWhite.copyWith(
                  color: AppColors.bPrimaryColor,
                ),
              ),
              onPressed: () {
                final enteredAmount = double.tryParse(amountController.text);
                print(
                  "💰 Entered: $enteredAmount | Eligible Limit: $eligibleLimit",
                );

                if (enteredAmount != null && enteredAmount > 0) {
                  if (enteredAmount <= eligibleLimit) {
                    Navigator.of(dialogContext).pop(enteredAmount);

                    // ✅ Show success snackbar using CSnackBar
                    CSnackBar.show(
                      blocContext,
                      'Loan amount updated to ₹${enteredAmount.toStringAsFixed(0)}',
                    );
                  } else {
                    // ⚠️ Show error snackbar for exceeding limit
                    CSnackBar.show(
                      blocContext,
                      'Amount exceeds eligible limit (₹${eligibleLimit.toStringAsFixed(0)})',
                      isError: true,
                    );
                  }
                } else {
                  // ❌ Show error snackbar for invalid input
                  CSnackBar.show(
                    blocContext,
                    'Invalid amount entered',
                    isError: true,
                  );
                }
              },
            ),
          ],
        );
      },
    );

    if (newAmount != null) {
      blocContext.read<EligibilityBloc>().add(
        SaveEditedLoanAmount(lender.id, newAmount),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<EligibilityBloc>();
    final state = context.watch<EligibilityBloc>().state;

    // 🧩 Auto-select all funds on UI load (once)
    if (state.selectedFundIds.isEmpty && state.pledgeableFunds.isNotEmpty) {
      final allFundIds = state.pledgeableFunds.map((f) => f.fundCode).toSet();
      context.read<EligibilityBloc>().add(AutoSelectAllFunds(allFundIds));
      print('🟢 Auto-selected all ${allFundIds.length} funds on UI load');
    }

    final selectedLender = state.lenders.firstWhere(
      (l) => l.id == state.selectedLenderId,
      orElse: () => state.lenders.isNotEmpty
          ? state.lenders.first
          : const Lender(
              id: '',
              name: 'Error',
              logoAsset: '',
              interestRate: 0,
              loanAmount: 0,
              pledgeableMFs: 0,
              tag: '',
            ),
    );

    final displayAmount =
        state.editedLoanAmounts[selectedLender.id] ?? selectedLender.loanAmount;
    final displayLender = selectedLender.copyWith(loanAmount: displayAmount);

    final formatCurrency = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹ ',
      decimalDigits: 0,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Selected Lender Card ---
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: AppColors.black,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.borderPrimaryColor,
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.borderPrimaryColor
                                        .withOpacity(0.4),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child:
                                            displayLender.logoAsset.isNotEmpty
                                            ? Image.network(
                                                displayLender.logoAsset,
                                                errorBuilder: (_, __, ___) =>
                                                    const Icon(
                                                      Icons.business,
                                                      color: Colors.grey,
                                                    ),
                                              )
                                            : const Icon(
                                                Icons.business,
                                                color: Colors.grey,
                                              ),
                                      ),
                                      Gaps.wSm,
                                      Expanded(
                                        child: CText(
                                          displayLender.name,
                                          style: AppTypography.bodyWhite
                                              .copyWith(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.bPrimaryColor,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: CText(
                                          'yourSelection'.tr,
                                          style: AppTypography.bodyWhite
                                              .copyWith(
                                                color: AppColors.black,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Gaps.hMd,
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildDetailColumn(
                                        'interestRate'.tr,
                                        '${displayLender.interestRate}%',
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CText(
                                            'loanAmount'.tr,
                                            style: AppTypography.bodySecondary
                                                .copyWith(fontSize: 12),
                                          ),
                                          Gaps.hXs,
                                          GestureDetector(
                                            onTap: () => _showEditLoanDialog(
                                              context,
                                              selectedLender,
                                              displayAmount,
                                            ),
                                            child: Row(
                                              children: [
                                                CText(
                                                  formatCurrency.format(
                                                    displayLender.loanAmount,
                                                  ),
                                                  style: AppTypography.bodyWhite
                                                      .copyWith(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                ),
                                                Gaps.wXs,
                                                const Icon(
                                                  Icons.edit_outlined,
                                                  color:
                                                      AppColors.bSecondaryColor,
                                                  size: 14,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      _buildDetailColumn(
                                        'pledgeableMFs'.tr,
                                        '${displayLender.pledgeableMFs}',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Gaps.hLg,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CText(
                                  'chooseFundsHint'.tr,
                                  style: AppTypography.bodySecondary.copyWith(
                                    fontSize: 12,
                                  ),
                                ),
                                const Icon(
                                  Icons.info_outline,
                                  color: AppColors.bSecondaryColor,
                                  size: 16,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // --- List of Funds ---
                      BlocBuilder<EligibilityBloc, EligibilityState>(
                        buildWhen: (previous, current) =>
                            previous.selectedFundIds != current.selectedFundIds,
                        builder: (context, state) {
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemCount: state.pledgeableFunds.length,
                            itemBuilder: (context, index) {
                              final fund = state.pledgeableFunds[index];
                              final bool isSelected = state.selectedFundIds
                                  .contains(fund.fundCode);
                              return FundListItem(
                                key: ValueKey('${fund.fundCode}-${isSelected}'),
                                fund: fund,
                                isSelected: isSelected,
                                onToggle: () => context
                                    .read<EligibilityBloc>()
                                    .add(ToggleFundSelection(fund.fundCode)),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // --- Continue Button ---
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Builder(
                    builder: (blocContext) => CButton(
                      text: 'continueWith'.trParams({
                        'lenderName': selectedLender.name,
                      }),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<EligibilityBloc>(),
                              child: const KycVerificationScreen(),
                            ),
                          ),
                        );

                        // blocContext.read<EligibilityBloc>().add(
                        //   ConfirmFundSelection(context),
                        // );
                      },
                      type: ButtonType.primaryWhite,
                      suffixIcon: const Icon(
                        Icons.arrow_forward,
                        color: AppColors.black,
                        size: 18,
                      ),
                    ),
                  ),
                  Gaps.hSm,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CText(
                        'Powered by',
                        style: AppTypography.bodySecondary.copyWith(
                          fontSize: 12,
                        ),
                      ),
                      Gaps.wSm,
                      Image.asset(
                        'assets/images/value_enable_logo.png',
                        height: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailColumn(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CText(title, style: AppTypography.bodySecondary.copyWith(fontSize: 12)),
        Gaps.hXs,
        CText(
          value,
          style: AppTypography.bodyWhite.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CText(title, style: AppTypography.bodySecondary),
          CText(
            value,
            style: AppTypography.bodyWhite.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
