import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:las_app/features/new_user/bloc/eligibility_bloc.dart';
import 'package:las_app/core/theme/app_colors.dart';
import 'package:las_app/core/theme/app_typography.dart';
import 'package:las_app/core/theme/app_spacing.dart';
import 'package:las_app/common_widgets/c_text.dart';
import 'package:las_app/features/new_user/view/widgets/two_lender_selection/fund_selection_view.dart';
import 'package:las_app/features/new_user/view/widgets/two_lender_selection/lender_list_view.dart';
import 'package:las_app/features/new_user/view/widgets/two_lender_selection/pledgable_funds_details_view.dart';
import 'package:las_app/features/new_user/view/widgets/two_lender_selection/portfolio_breakdown.dart';

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
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: BlocBuilder<EligibilityBloc, EligibilityState>(
          builder: (context, state) {
            final bool showFullHeader =
                state.lenderSelectionView == LenderSelectionView.lenderList ||
                state.lenderSelectionView ==
                    LenderSelectionView.portfolioBreakdown ||
                state.lenderSelectionView ==
                    LenderSelectionView.pledgeableDetail;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Gaps.hXl,
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Row(
                          children: [
                            CircularPercentIndicator(
                              radius: 35.0,
                              lineWidth: 8.0,
                              percent: 0.5,
                              center: CText(
                                "2/4",
                                style: AppTypography.bodyWhite.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              progressColor: AppColors.bPrimaryColor,
                              backgroundColor: AppColors.bSecondaryColor,
                              circularStrokeCap: CircularStrokeCap.round,
                            ),
                            Gaps.wMd,
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CText(
                                  'lenderSelectionTitle'.tr,
                                  style: AppTypography.h2,
                                ),
                                Gaps.hXs,
                                CText(
                                  'nextKycVerification'.tr,
                                  style: AppTypography.bodySecondary,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Gaps.hXl,
                      const Divider(
                        thickness: 1.5,
                        color: AppColors.bSecondaryColor,
                      ),
                      Gaps.hMd,
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 16.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () => Navigator.of(context).pop(),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.arrow_back,
                                        color: AppColors.white,
                                        size: 20,
                                      ),
                                      Gaps.wXs,
                                      CText(
                                        'Go Back',
                                        style: AppTypography.bodyWhite.copyWith(
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text:
                                            (state.lenderSelectionView ==
                                                    LenderSelectionView
                                                        .portfolioBreakdown ||
                                                state.lenderSelectionView ==
                                                    LenderSelectionView
                                                        .pledgeableDetail)
                                            ? 'viewLenders'.tr
                                            : 'viewYourMfDetails'.tr,
                                        style: AppTypography.bodyWhite.copyWith(
                                          decoration: TextDecoration.underline,
                                          decorationColor: AppColors.white,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () => context
                                              .read<EligibilityBloc>()
                                              .add(ViewDetailsToggled()),
                                      ),
                                      const WidgetSpan(child: Gaps.wXs),
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
                              Gaps.hXl,
                              CText(
                                'eligibleCreditLimit'.tr,
                                style: AppTypography.bodyWhite,
                              ),
                              Gaps.hSm,

  // ✅ Use pledgeable funds total instead of maxEligibleLimit
  Builder(
    builder: (_) {
     final totalPledgeable = state.mfDetailsResponse?.pledgeableFunds
        .fold<double>(0, (sum, fund) => sum + (fund.availableAmount ?? 0)) ??
    0.0;

return CText(
  formatCurrency.format(totalPledgeable ?? 0),
  style: AppTypography.h1.copyWith(color: AppColors.bPrimaryColor),
);

    },
  ),
                              Gaps.hXxs,
                              CText(
                                'totalPortfolioValue'.trParams({
                                  'value': formatCurrency.format(
                                      state.mfDetailsResponse?.eligiblePortfolio ?? 0),
                                }),
                                style: AppTypography.caption,
                              ),
                              Gaps.hXl,
                            ],
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder: (child, animation) =>
                                  FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                              child: () {
                                final currentView = state.lenderSelectionView;
                                if (currentView ==
                                    LenderSelectionView.lenderList) {
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
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.badge_outlined,
                                          color: AppColors.bPrimaryColor,
                                          size: 24,
                                        ),
                                        Gaps.wSm,
                                        Expanded(
                                          child: CText(
                                            'selectLenderInfo'.tr,
                                            style: AppTypography.bodyWhite,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                if (currentView ==
                                        LenderSelectionView
                                            .portfolioBreakdown ||
                                    currentView ==
                                        LenderSelectionView.pledgeableDetail) {
                                  return Align(
                                    key: const ValueKey('breakdown_title'),
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        top: 24.0,
                                        bottom: 8.0,
                                      ),
                                      child: CText(
                                        currentView ==
                                                LenderSelectionView
                                                    .portfolioBreakdown
                                            ? 'portfolioBreakdown'.tr
                                            : 'portfolioBreakdownPledgeableFunds'
                                                  .tr,
                                        style: AppTypography.caption,
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink(
                                  key: ValueKey('empty'),
                                );
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
                      final offsetAnimation =
                          Tween<Offset>(
                            begin: const Offset(0.0, 0.1),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeInOut,
                            ),
                          );
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
}

Widget _buildCurrentView(BuildContext context, EligibilityState state) {
  Widget _noDataView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "No details available. Please try again later.",
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              context.read<EligibilityBloc>().add(RefreshPortfolioPressed());
            },
            icon: const Icon(Icons.refresh, color: Colors.white, size: 18),
            label: const Text("Retry", style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.bPrimaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  switch (state.lenderSelectionView) {
    case LenderSelectionView.lenderList:
      return const LenderListView(key: ValueKey('lender_list'));

    case LenderSelectionView.portfolioBreakdown:
      if (state.mfDetailsResponse == null ||
          state.mfDetailsResponse?.pledgeableFunds.isEmpty == true) {
        return _noDataView();
      }
      return PortfolioBreakdownView(
        key: const ValueKey('breakdown_view'),
        mfDetailsResponse: state.mfDetailsResponse!,
        onCategoryTapped: (categoryId) {
          context
              .read<EligibilityBloc>()
              .add(BreakdownCategoryTapped(categoryId));
        },
        onRefresh: () =>
            context.read<EligibilityBloc>().add(RefreshPortfolioPressed()),
      );

    case LenderSelectionView.pledgeableDetail:
      if (state.mfDetailsResponse == null ||
          state.mfDetailsResponse?.pledgeableFunds.isEmpty == true) {
        return _noDataView();
      }
      return PledgeableFundsDetailView(
        key: const ValueKey('detail_view'),
        onRefresh: () =>
            context.read<EligibilityBloc>().add(RefreshPortfolioPressed()),
      );

    case LenderSelectionView.fundSelection:
      return const FundSelectionView(key: ValueKey('fund_selection_view'));

    default:
      return const LenderListView(key: ValueKey('lender_list'));
  }
}
}