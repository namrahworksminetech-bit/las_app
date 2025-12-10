import 'dart:async';
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

    final eligibleLimit = lender.maxEligibleLimit ?? 0.0;
    final eligibilityBloc = blocContext.read<EligibilityBloc>();

    final newAmount = await showDialog<double>(
      context: blocContext,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            bool isSubmitting = false;

            Future<void> _onConfirm() async {
              final enteredAmount = double.tryParse(amountController.text);
              print(
                "💰 Entered: $enteredAmount | Eligible Limit: $eligibleLimit",
              );

              if (enteredAmount == null || enteredAmount <= 0) {
                CSnackBar.show(
                  blocContext,
                  'Invalid amount entered',
                  isError: true,
                );
                return;
              }

              if (enteredAmount > eligibleLimit) {
                CSnackBar.show(
                  blocContext,
                  'Amount exceeds eligible limit (₹${eligibleLimit.toStringAsFixed(0)})',
                  isError: true,
                );
                return;
              }

              // Show a local loader attached to the dialog's navigator
              showDialog<void>(
                context: dialogContext,
                barrierDismissible: false,
                useRootNavigator: false,
                builder: (_) => WillPopScope(
                  onWillPop: () async => false,
                  child: Container(
                    color: Colors.black54,
                    child: const Center(
                      child: SizedBox(
                        width: 56,
                        height: 56,
                        child: CircularProgressIndicator(strokeWidth: 3),
                      ),
                    ),
                  ),
                ),
              );

              // dispatch save event AFTER showing loader
              eligibilityBloc.add(
                SaveEditedLoanAmount(lender.id, enteredAmount),
              );

              try {
                // Wait for the bloc to emit a save result for this lender AND for the saving flag to clear
                final finalState = await eligibilityBloc.stream
                    .firstWhere(
                      (s) =>
                          s.lastSavedLenderId != null &&
                          s.lastSavedLenderId == lender.id &&
                          s.lastSaveMessage != null &&
                          s.lastSaveMessage!.trim().isNotEmpty &&
                          s.isSavingLoan == false,
                    ) // <-- use isSavingLoan here
                    .timeout(const Duration(seconds: 30));

                // Close the local loader (dialog's navigator)
                try {
                  if (Navigator.of(dialogContext).canPop()) {
                    Navigator.of(dialogContext).pop(); // closes the loader
                  }
                } catch (_) {}

                // Show the message returned by bloc
                CSnackBar.show(blocContext, finalState.lastSaveMessage!);

                // Close the edit dialog and return the entered amount
                if (Navigator.of(dialogContext).canPop()) {
                  Navigator.of(dialogContext).pop(enteredAmount);
                }
              } on TimeoutException {
                // Close local loader if still open
                try {
                  if (Navigator.of(dialogContext).canPop()) {
                    Navigator.of(dialogContext).pop();
                  }
                } catch (_) {}

                CSnackBar.show(
                  blocContext,
                  'Request timed out. Please try again.',
                  isError: true,
                );

                if (Navigator.of(dialogContext).canPop()) {
                  Navigator.of(dialogContext).pop();
                }
              } catch (e) {
                // Close local loader if still open
                try {
                  if (Navigator.of(dialogContext).canPop()) {
                    Navigator.of(dialogContext).pop();
                  }
                } catch (_) {}

                CSnackBar.show(
                  blocContext,
                  'Something went wrong',
                  isError: true,
                );

                if (Navigator.of(dialogContext).canPop()) {
                  Navigator.of(dialogContext).pop();
                }
              }
            }

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
                      prefixStyle: TextStyle(
                        color: AppColors.white,
                        fontSize: 24,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.bSecondaryColor,
                        ),
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
                  onPressed: () {
                    if (Navigator.of(dialogContext).canPop()) {
                      Navigator.of(dialogContext).pop();
                    }
                  },
                ),
                TextButton(
                  child: CText(
                    'confirm'.tr,
                    style: AppTypography.bodyWhite.copyWith(
                      color: AppColors.bPrimaryColor,
                    ),
                  ),
                  onPressed: _onConfirm,
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _goBackToLenderSelection(BuildContext context) {
    final bloc = context.read<EligibilityBloc>();

    // update bloc state (pageIndex = 2)
    bloc.add(const JumpToPage(2));

    // pop back to previous screen (Lender Selection)
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<EligibilityBloc>();
    final state = context.watch<EligibilityBloc>().state;
    final eligibilityBloc = context.read<EligibilityBloc>();

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
              maxEligibleLimit: 0,
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

    // Wrap the whole UI in a BlocListener so navigation is driven by state
    return BlocListener<EligibilityBloc, EligibilityState>(
      listenWhen: (previous, current) =>
          previous.shouldNavigateToKyc != current.shouldNavigateToKyc ||
          previous.isLoading != current.isLoading ||
          previous.isPortfolioRefreshing != current.isPortfolioRefreshing,
      listener: (context, state) {
        final canNavigate =
            state.shouldNavigateToKyc == true &&
            state.isLoading == false &&
            (state.isPortfolioRefreshing == false ||
                state.isPortfolioRefreshing == null);

        if (!canNavigate) return;

        // Close potential root overlays if any (safe attempt)
        try {
          Navigator.of(context, rootNavigator: true).pop();
        } catch (_) {}

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => BlocProvider.value(
              value: eligibilityBloc, // pass the existing instance
              child:
                  KycVerificationScreen(), // no `const` — ensures fresh instance/context
            ),
          ),
        );

        // Acknowledge navigation so bloc doesn't try again
        context.read<EligibilityBloc>().add(AcknowledgeKycNavigation());
      },
      child: LayoutBuilder(
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
                                            color: Colors.black,
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
                                        Flexible(
                                          child: _buildDetailColumn(
                                            'interestRate'.tr,
                                            '${displayLender.interestRate}%',
                                          ),
                                        ),
                                        Flexible(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              CText(
                                                'loanAmount'.tr,
                                                style: AppTypography
                                                    .bodySecondary
                                                    .copyWith(fontSize: 12),
                                              ),
                                              Gaps.hXs,
                                              GestureDetector(
                                                onTap: () =>
                                                    _showEditLoanDialog(
                                                      context,
                                                      selectedLender,
                                                      displayAmount,
                                                    ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Flexible(
                                                      child: CText(
                                                        formatCurrency.format(
                                                          displayLender
                                                              .loanAmount,
                                                        ),

                                                        style: AppTypography
                                                            .bodyWhite
                                                            .copyWith(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    Gaps.wXs,
                                                    const Icon(
                                                      Icons.edit_outlined,
                                                      color: AppColors
                                                          .bSecondaryColor,
                                                      size: 14,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Flexible(
                                          child: _buildDetailColumn(
                                            'pledgeableMFs'.tr,
                                            '${displayLender.pledgeableMFs}',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Gaps.hLg,
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: CText(
                                      'chooseFundsHint'.tr,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTypography.bodySecondary
                                          .copyWith(fontSize: 12),
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
                              previous.selectedFundIds !=
                              current.selectedFundIds ||
    previous.pledgeableFunds != current.pledgeableFunds,
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
                                  key: ValueKey(
                                    '${fund.fundCode}-${isSelected}',
                                  ),
                                  fund: fund,
                                  isSelected: isSelected,

                                  onToggle: () {
                                    context.read<EligibilityBloc>().add(
                                      ToggleFundSelection(fund.fundCode),
                                    );
                                  },

                                  onEditAmount: (newValue) {
                                    context.read<EligibilityBloc>().add(
                                      UpdateFundAmount(fund.fundCode, newValue),
                                    );
                                  },
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
                    /// 🔥 Show Save Changes button ONLY when there are unsaved changes
                    if (state.hasUnsavedFundChanges)
                      CButton(
                        text: "Save Changes",
                        type: ButtonType.primaryWhite,
                        onPressed: () {
                          context.read<EligibilityBloc>().add(
                            ConfirmFundSelection(),
                          );
                        },
                      ),

                    if (state.hasUnsavedFundChanges) Gaps.hMd,

                    /// 🚀 Continue Button (NO confirm fund selection here)
                    CButton(
                      text: 'continueWith'.trParams({
                        'lenderName': selectedLender.name,
                      }),
                      onPressed: () {
                        // DIRECT NAVIGATION TO KYC
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: eligibilityBloc,
                              child: KycVerificationScreen(),
                            ),
                          ),
                        );
                      },
                      type: ButtonType.primaryWhite,
                      suffixIcon: const Icon(
                        Icons.arrow_forward,
                        color: AppColors.black,
                        size: 18,
                      ),
                    ),

                    Gaps.hSm,

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: CText(
                            'Powered by',
                            style: AppTypography.bodySecondary.copyWith(
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Gaps.wSm,
                        Flexible(
                          child: Image.asset(
                            'assets/images/value_enable_logo.png',
                            height: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
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
