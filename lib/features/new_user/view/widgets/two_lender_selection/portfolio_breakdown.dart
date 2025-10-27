import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:las_app/core/theme/app_colors.dart'; 
import 'package:las_app/features/new_user/bloc/eligibility_bloc.dart'; 

class PortfolioBreakdownView extends StatelessWidget {
  final PortfolioData portfolioData;
  final Function(String) onCategoryTapped;
  final VoidCallback onRefresh;

  const PortfolioBreakdownView({
    super.key,
    required this.portfolioData,
    required this.onCategoryTapped,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(
        locale: 'en_IN', symbol: '₹ ', decimalDigits: 2);
    final formatCurrencyInt = NumberFormat.currency(
        locale: 'en_IN', symbol: '₹ ', decimalDigits: 0);

    final double nonPledgeableFunds = 320000;
    final double dematFunds = 275000;
    final double unapprovedFunds = 285922.36;

    return SingleChildScrollView(
      key: const ValueKey('breakdown_view'),
           padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 200.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onRefresh, 
              icon: context.watch<EligibilityBloc>().state.isPortfolioRefreshing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.bSecondaryColor))
                  : const Icon(Icons.refresh, color: AppColors.bSecondaryColor, size: 20),
              label: const Text('Refresh Portfolio',
                  style: TextStyle(color: AppColors.bSecondaryColor, fontSize: 14)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.bSecondaryColor),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 24), 
          
          
          
          
          
          
          
          
          
          
          

          
          _buildBreakdownRow(
            context: context,
            title: 'Pledgeable Funds',
            value: formatCurrencyInt.format(portfolioData.pledgeableFunds),
            onTap: () => onCategoryTapped('pledgeable'),
          ),
          _buildBreakdownRow(
            context: context,
            title: 'Non Pledgeable Funds',
            value: formatCurrencyInt.format(nonPledgeableFunds),
            onTap: () => onCategoryTapped('non_pledgeable'),
          ),
          _buildBreakdownRow(
            context: context,
            title: 'Demat Funds',
            value: formatCurrencyInt.format(dematFunds),
            onTap: () => onCategoryTapped('demat'),
          ),
          _buildBreakdownRow(
            context: context,
            title: 'Unapproved Funds',
            value: formatCurrency.format(unapprovedFunds),
            onTap: () => onCategoryTapped('unapproved'),
            showBorder: false,
          ),
        ],
      ),
    );
  }

  
  Widget _buildBreakdownRow({
    required BuildContext context,
    required String title,
    required String value,
    required VoidCallback onTap,
    bool showBorder = true,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        decoration: BoxDecoration(
          border: showBorder
              ? const Border(
                  bottom: BorderSide(color: AppColors.bSecondaryColor, width: 0.5),
                )
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(color: AppColors.white, fontSize: 14)),
            Row(
              children: [
                Text(value,
                    style: const TextStyle(
                        color: AppColors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios, color: AppColors.bSecondaryColor, size: 14),
              ],
            ),
          ],
        ),
      ),
    );
  }
}