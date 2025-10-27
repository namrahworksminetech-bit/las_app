import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:las_app/core/theme/app_colors.dart';
import 'package:las_app/features/new_user/bloc/eligibility_bloc.dart';
import 'package:las_app/features/new_user/view/widgets/two_lender_selection/fund_selection_view.dart';
import 'package:las_app/features/new_user/view/widgets/two_lender_selection/lender_list_view.dart';
import 'package:las_app/features/new_user/view/widgets/two_lender_selection/pledgable_funds_details_view.dart';
import 'package:las_app/features/new_user/view/widgets/two_lender_selection/portfolio_breakdown.dart';

import 'package:percent_indicator/percent_indicator.dart';

class LenderSelectionScreen extends StatefulWidget {
  const LenderSelectionScreen({super.key});

  @override
  State<LenderSelectionScreen> createState() => _LenderSelectionScreenState();
}

class _LenderSelectionScreenState extends State<LenderSelectionScreen> {
@override
Widget build(BuildContext context) {
  final formatCurrency = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹ ',
    decimalDigits: 0,
  );

  return Scaffold(
    backgroundColor: Colors.black,
    body: SafeArea(
      child: BlocBuilder<EligibilityBloc, EligibilityState>(
        builder: (context, state) {
          final bool showFullHeader =
              state.lenderSelectionView == LenderSelectionView.lenderList ||
                  state.lenderSelectionView == LenderSelectionView.portfolioBreakdown ||
                  state.lenderSelectionView == LenderSelectionView.pledgeableDetail;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Row(
                        children: [
                          CircularPercentIndicator(
                            radius: 35.0,
                            lineWidth: 8.0,
                            percent: 2 / 4.0,
                            center: const Text(
                              "2/4",
                              style: TextStyle(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            progressColor: AppColors.bPrimaryColor,
                            backgroundColor: AppColors.bSecondaryColor,
                            circularStrokeCap: CircularStrokeCap.round,
                          ),
                          const SizedBox(width: 16),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Lender Selection',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Next: KYC Verification',
                                style: TextStyle(
                                  color: AppColors.bSecondaryColor,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Divider(thickness: 1.5, color: AppColors.bSecondaryColor),
                    const SizedBox(height: 16),

                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                         Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    
    Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.read<EligibilityBloc>().add(PreviousStepPressed()),
        borderRadius: BorderRadius.circular(6),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.arrow_back, color: AppColors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Go Back',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    ),

    
  RichText(
  text: TextSpan(
    children: [
      TextSpan(
        text: (state.lenderSelectionView == LenderSelectionView.portfolioBreakdown ||
               state.lenderSelectionView == LenderSelectionView.pledgeableDetail)
            ? 'View Lenders'
            : 'View Your MF Details',
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 14,
          decoration: TextDecoration.underline,
          decorationColor: AppColors.white,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () => context
              .read<EligibilityBloc>()
              .add(ViewDetailsToggled()),
      ),
      const WidgetSpan(child: SizedBox(width: 4)),
      const WidgetSpan(
        child: Icon(
          Icons.arrow_forward_ios,
          color: AppColors.white,
          size: 12,
        ),
        alignment: PlaceholderAlignment.middle,
      ),
    ],
  ),
),

  ],
),

                          if (showFullHeader) ...[
                            const SizedBox(height: 24),
                            const Text(
                              'Your Eligible Credit Limit',
                              style: TextStyle(color: AppColors.white, fontSize: 14),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              formatCurrency.format(state.portfolioData.eligibleCreditLimit),
                              style: const TextStyle(
                                color: AppColors.bPrimaryColor,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Your Total Portfolio Value is ${formatCurrency.format(state.portfolioData.totalValue)}',
                              style: const TextStyle(
                                color: AppColors.bSecondaryColor,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (child, animation) =>
                                FadeTransition(opacity: animation, child: child),
                            child: () {
                              final currentView = state.lenderSelectionView;

                              if (currentView == LenderSelectionView.lenderList) {
                                return Container(
                                  key: const ValueKey('info_box'),
                                  margin: const EdgeInsets.only(top: 24.0),
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 18.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1F2937),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.badge_outlined,
                                          color: AppColors.bPrimaryColor, size: 24),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'Select a lender to proceed with your loan application.',
                                          style: TextStyle(
                                            color: AppColors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              if (currentView == LenderSelectionView.portfolioBreakdown ||
                                  currentView == LenderSelectionView.pledgeableDetail) {
                                return Align(
                                  key: const ValueKey('breakdown_title'),
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
                                    child: Text(
                                      currentView == LenderSelectionView.portfolioBreakdown
                                          ? 'Portfolio Breakdown'
                                          : 'Portfolio Breakdown > Pledgeable Funds',
                                      style: const TextStyle(
                                        color: AppColors.bSecondaryColor,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                );
                              }

                              return const SizedBox.shrink(key: ValueKey('empty'));
                            }(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    final offsetAnimation = Tween<Offset>(
                      begin: const Offset(0.0, 0.1),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeInOut,
                    ));
                    return SlideTransition(
                      position: offsetAnimation,
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  child: _buildCurrentView(context, state),
                ),
              ),
             
            ],
          );
        },
      ),
    ),
  );
}

  Widget _buildCurrentView(BuildContext context, EligibilityState state) {
    switch (state.lenderSelectionView) {
      case LenderSelectionView.lenderList:
        
        return const LenderListView(
          key: ValueKey('lender_list'),
        );
        
      case LenderSelectionView.portfolioBreakdown:
        return PortfolioBreakdownView(
          key: const ValueKey('breakdown_view'),
          portfolioData: state.portfolioData,
          onCategoryTapped: (categoryId) {
            context.read<EligibilityBloc>().add(BreakdownCategoryTapped(categoryId));
          },
          onRefresh: () =>
              context.read<EligibilityBloc>().add(RefreshPortfolioPressed()),
        );
        
      case LenderSelectionView.pledgeableDetail:
        return PledgeableFundsDetailView(
          key: const ValueKey('detail_view'),
          onRefresh: () =>
              context.read<EligibilityBloc>().add(RefreshPortfolioPressed()),
        );
        
      case LenderSelectionView.fundSelection:
        
        return const FundSelectionView(
          key: ValueKey('fund_selection_view'),
        );
        
      default:
        
        return const LenderListView(
          key: ValueKey('lender_list'),
        );
    }
  }}