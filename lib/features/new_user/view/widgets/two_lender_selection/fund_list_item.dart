import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:las_app/common_widgets/c_text.dart';
import 'package:las_app/core/theme/app_colors.dart';
import 'package:las_app/core/theme/app_spacing.dart';
import 'package:las_app/core/theme/app_typography.dart';
import 'package:las_app/features/new_user/bloc/eligibility_bloc.dart';

class FundListItem extends StatefulWidget {
  final PledgeableFund fund;
  final bool isSelected;
  final VoidCallback onToggle;

  const FundListItem({
    super.key,
    required this.fund,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  State<FundListItem> createState() => _FundListItemState();
}

class _FundListItemState extends State<FundListItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final formatCurrencyInt =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹ ', decimalDigits: 0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Row(
              children: [
                Checkbox(
                  value: widget.isSelected,
                  onChanged: (val) => widget.onToggle(),
                  activeColor: AppColors.borderPrimaryColor,
                  checkColor: AppColors.white,
                  side: const BorderSide(
                      color: AppColors.bSecondaryColor, width: 1.5),
                ),
                Expanded(
                  child: CText(
                    widget.fund.name,
                    style: AppTypography.bodyWhite,
                  ),
                ),
                const SizedBox(width: Gaps.md),
                CText(
                  formatCurrencyInt.format(widget.fund.value),
                  style: AppTypography.bodyWhite.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _isExpanded
                ? Padding(
                    padding: const EdgeInsets.only(
                        left: 48.0, right: 16.0, top: 8.0, bottom: 8.0),
                    child: Column(
                      children: [
                        _buildDetailRow(
                          'totalUnits'.tr,
                          '${widget.fund.units}',
                        ),
                        const SizedBox(height: Gaps.xs),
                        _buildDetailRow(
                          'totalFundValue'.trParams(
                              {'perUnit': '${widget.fund.perUnitValue}'}),
                          formatCurrencyInt.format(widget.fund.value),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          const Divider(
              color: AppColors.bSecondaryColor, height: 1, thickness: 0.5),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CText(title, style: AppTypography.bodySecondary),
        Row(
          children: [
            CText(
              value,
              style: AppTypography.bodyWhite.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: Gaps.xxs),
            const Icon(Icons.edit_outlined,
                color: AppColors.bSecondaryColor, size: 14),
          ],
        ),
      ],
    );
  }
}
