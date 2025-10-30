import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:las_app/common_widgets/c_button.dart';
import 'package:las_app/common_widgets/c_text.dart';
import 'package:las_app/core/theme/app_colors.dart';
import 'package:las_app/core/theme/app_spacing.dart';
import 'package:las_app/core/theme/app_typography.dart';
import 'package:las_app/features/new_user/bloc/eligibility_bloc.dart';
import 'package:las_app/features/new_user/view/widgets/three_kyc_verification/step_checker_view.dart';
import 'package:las_app/features/new_user/view/widgets/two_lender_selection/fund_list_item.dart';

class FundSelectionView extends StatelessWidget {
  const FundSelectionView({super.key});

  Future<void> _showEditLoanDialog(
    BuildContext blocContext,
    Lender lender,
    double currentAmount,
  ) async {
    final TextEditingController amountController = TextEditingController(
      text: currentAmount.toStringAsFixed(0),
    );

    final portfolioData = blocContext.read<EligibilityBloc>().state.portfolioData;

    final newAmount = await showDialog<double>(
      context: blocContext,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1F2937),
          contentPadding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
          content: TextField(
            controller: amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: false),
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
          actionsPadding: const EdgeInsets.symmetric(horizontal: 8.0),
          actions: <Widget>[
            TextButton(
              child: CText('cancel'.tr, style: AppTypography.bodySecondary),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: CText(
                'confirm'.tr,
                style: AppTypography.bodyWhite.copyWith(color: AppColors.bPrimaryColor),
              ),
              onPressed: () {
                final enteredAmount = double.tryParse(amountController.text);
                if (enteredAmount != null && enteredAmount > 0) {
                  if (enteredAmount <= portfolioData.eligibleCreditLimit) {
                    Navigator.of(dialogContext).pop(enteredAmount);
                  } else {
                    ScaffoldMessenger.of(blocContext).showSnackBar(
                      SnackBar(
                        content: CText('amountExceedLimit'.tr),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(blocContext).showSnackBar(
                    SnackBar(
                      content: CText('invalidAmount'.tr),
                      backgroundColor: Colors.red,
                    ),
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
    final state = context.watch<EligibilityBloc>().state;

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

    final displayAmount = state.editedLoanAmounts[selectedLender.id] ?? selectedLender.loanAmount;
    final displayLender = selectedLender.copyWith(loanAmount: displayAmount);

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
                                border: Border.all(color: AppColors.borderPrimaryColor, width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.borderPrimaryColor.withOpacity(0.4),
                                    blurRadius: 8.0,
                                    spreadRadius: 1.0,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: displayLender.logoAsset.isNotEmpty
                                            ? Image.network(
                                                displayLender.logoAsset,
                                                errorBuilder: (_, __, ___) => const Icon(Icons.business, color: Colors.grey),
                                              )
                                            : const Icon(Icons.business, color: Colors.grey),
                                      ),
                                      Gaps.wSm,
                                      Expanded(
                                        child: CText(
                                          displayLender.name,
                                          style: AppTypography.bodyWhite.copyWith(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.bPrimaryColor,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: CText(
                                          'yourSelection'.tr,
                                          style: AppTypography.bodyWhite.copyWith(
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
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildDetailColumn('interestRate'.tr, '${displayLender.interestRate}%'),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          CText('loanAmount'.tr, style: AppTypography.bodySecondary.copyWith(fontSize: 12)),
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
                                                  NumberFormat.currency(
                                                    locale: 'en_IN',
                                                    symbol: '₹ ',
                                                    decimalDigits: 0,
                                                  ).format(displayLender.loanAmount),
                                                  style: AppTypography.bodyWhite.copyWith(fontSize: 14, fontWeight: FontWeight.w500),
                                                ),
                                                Gaps.wXs,
                                                const Icon(
                                                  Icons.edit_outlined,
                                                  color: AppColors.bSecondaryColor,
                                                  size: 14,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      _buildDetailColumn('pledgeableMFs'.tr, '${displayLender.pledgeableMFs}'),
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
                                  style: AppTypography.bodySecondary.copyWith(fontSize: 12),
                                ),
                                const Icon(Icons.info_outline, color: AppColors.bSecondaryColor, size: 16),
                              ],
                            ),
                          ],
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: state.pledgeableFunds.length,
                        itemBuilder: (context, index) {
                          final fund = state.pledgeableFunds[index];
                          final bool isSelected = state.selectedFundIds.contains(fund.id);
                          return FundListItem(
                            fund: fund,
                            isSelected: isSelected,
                            onToggle: () => context.read<EligibilityBloc>().add(ToggleFundSelection(fund.id)),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Builder(
                    builder: (blocContext) => CButton(
                      text: 'continueWith'.trParams({'lenderName': selectedLender.name}),
                      onPressed: () {
                        Navigator.push(
                          blocContext,
                          MaterialPageRoute(
                            builder: (context) => BlocProvider.value(
                              value: blocContext.read<EligibilityBloc>(),
                              child: const KycVerificationScreen(),
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
                  ),
                  Gaps.hSm,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CText(
                        'Powered by',
                        style: AppTypography.bodySecondary.copyWith(fontSize: 12),
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
          style: AppTypography.bodyWhite.copyWith(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
