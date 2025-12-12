import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:las_app/common_widgets/c_text.dart';
import 'package:las_app/core/theme/app_colors.dart';
import 'package:las_app/core/theme/app_spacing.dart';
import 'package:las_app/core/theme/app_typography.dart';

import 'package:las_app/models/funds/pledgeable_model.dart';

class FundListItem extends StatefulWidget {
  final PledgeableFund fund;
  final bool isSelected;
  final VoidCallback onToggle;
  final Function(double newValue) onEditAmount;

  const FundListItem({
    super.key,
    required this.fund,
    required this.isSelected,
    required this.onToggle,
    required this.onEditAmount,
  });

  @override
  State<FundListItem> createState() => _FundListItemState();
}

class _FundListItemState extends State<FundListItem> {
  bool _isExpanded = false;

  void _editFundValue() async {
    final controller = TextEditingController(
      text: (widget.fund.updatedFundAmount ?? widget.fund.availableAmount)
          .toString(),
    );

    final newValue = await showDialog<double>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Fund Value"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: "Enter new fund value"),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Navigator.pop(context, double.tryParse(controller.text));
            },
            child: const Text("Proceed"),
          ),
        ],
      ),
    );

    if (newValue != null) {
      widget.onEditAmount(newValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrencyInt =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹ ', decimalDigits: 0);

    // NEW LOGIC ADDED HERE
    final bool isZeroFund = widget.fund.availableAmount == 0;
    final bool isEnabled = widget.fund.enabled && !isZeroFund;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          InkWell(
            onTap: isEnabled
                ? () => setState(() => _isExpanded = !_isExpanded)
                : null,
            child: Row(
              children: [
                // Checkbox uses NEW isEnabled
                Checkbox(
                  value: isEnabled ? widget.isSelected : false,
                  onChanged: isEnabled ? (_) => widget.onToggle() : null,
                  activeColor: AppColors.borderPrimaryColor,
                  checkColor: AppColors.white,
                  side: const BorderSide(
                    color: AppColors.bSecondaryColor,
                    width: 1.5,
                  ),
                ),

                Expanded(
                  child: CText(
                    widget.fund.fundName ?? '-',
                    style: AppTypography.bodyWhite.copyWith(
                      color: isEnabled
                          ? AppColors.white
                          : AppColors.bSecondaryColor,
                    ),
                  ),
                ),

                const SizedBox(width: Gaps.md),

                CText(
                  formatCurrencyInt.format(
                    widget.fund.updatedFundAmount ??
                        widget.fund.availableAmount,
                  ),
                  style: AppTypography.bodyWhite.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isEnabled
                        ? AppColors.white
                        : AppColors.bSecondaryColor,
                  ),
                ),
              ],
            ),
          ),

          // Expanded Section
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: (_isExpanded && isEnabled)
                ? Padding(
                    padding: const EdgeInsets.only(
                      left: 40.0,
                      right: 8.0,
                      top: 8.0,
                      bottom: 8.0,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 3),
                        _buildDetailRow(
                          'totalUnits'.tr,
                          '${widget.fund.lienEligibleUnits ?? 0.0}',
                        ),
                        const SizedBox(height: Gaps.md),
                        _buildDetailRow(
                          'totalFundValue'.trParams({
                            'available':
                                widget.fund.availableAmount.toStringAsFixed(2),
                          }),
                          formatCurrencyInt.format(
                            widget.fund.updatedFundAmount ??
                                widget.fund.availableAmount,
                          ),
                          onEdit: isEnabled && widget.fund.active
                              ? _editFundValue
                              : null,
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          const Divider(
            color: AppColors.bSecondaryColor,
            height: 1,
            thickness: 0.5,
          ),
        ],
      ),
    );
  }

Widget _buildDetailRow(String title, String value, {VoidCallback? onEdit}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(child: CText(title, style: AppTypography.bodySecondary)),
      Row(
        children: [
          CText(
            value,
            style: AppTypography.bodyWhite.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 6),

          if (onEdit != null)
            GestureDetector(
              onTap: onEdit,   // SAME EDIT FUNCTION YOU ALREADY HAVE
              child: const Icon(
                Icons.edit_outlined,
                color: AppColors.bSecondaryColor,
                size: 16,
              ),
            ),
        ],
      ),
    ],
  );
}
}
