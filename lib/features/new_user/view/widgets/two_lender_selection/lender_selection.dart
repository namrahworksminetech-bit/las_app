import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:las_app/features/dashboard/view_dashboard.dart';
import 'package:las_app/features/home/view_home.dart';
import 'package:las_app/features/new_user/view/widgets/two_lender_selection/demat_funds_detail_view.dart';
import 'package:las_app/features/new_user/view/widgets/two_lender_selection/non_pledgeable_funds_details_view.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:las_app/features/new_user/bloc/eligibility_bloc.dart';
import 'package:las_app/core/theme/app_colors.dart';
import 'package:las_app/core/theme/app_typography.dart';
import 'package:las_app/core/theme/app_spacing.dart';
import 'package:las_app/common_widgets/c_text.dart';
import 'package:las_app/common_widgets/c_snackbar.dart';
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
  DateTime? lastBackPress;
  
  Future<bool> _showExitConfirmDialog() async {
    final res = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Exit to Home?'),
          content: const Text(
              'Are you sure you want to leave this flow and go back to the home screen?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
    return res ?? false;
  }

  /// Navigate to Dashboard clearing the stack
  void _navigateToDashboard() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const Home()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹ ',
      decimalDigits: 0,
    );

    void safeAdd(EligibilityEvent event) {
      try {
        context.read<EligibilityBloc>().add(event);
      } catch (e, st) {
        debugPrint('EligibilityBloc.add() failed: $e\n$st');
      }
    }

    return WillPopScope(
  onWillPop: () async {
  final bloc = context.read<EligibilityBloc>();
  final view = bloc.state.lenderSelectionView;

  // CASE 1: In Fund Selection → go back to Lender List
  if (view == LenderSelectionView.fundSelection) {
    bloc.add(const SetLenderSelectionView(LenderSelectionView.lenderList));
    return false;
  }

  // CASE 2: In Breakdown or Pledgeable → go back to Lender List

if (view == LenderSelectionView.portfolioBreakdown ||
    view == LenderSelectionView.pledgeableDetail ||
    view == LenderSelectionView.nonPledgeableDetail ||
    view == LenderSelectionView.dematDetail) {

  bloc.add(const SetLenderSelectionView(LenderSelectionView.lenderList));
  return false;
}


  // CASE 3: Already in lender list → show exit dialog
  final confirm = await _showExitConfirmDialog();
  if (confirm) {
    _navigateToDashboard();
  }

  return false;
},
      child: Scaffold(
        backgroundColor: AppColors.black,
        body: SafeArea(
          child: BlocConsumer<EligibilityBloc, EligibilityState>(
            listener: (context, state) {
              if (state.generalErrorMessage != null) {
                CSnackBar.show(
                  context,
                  state.generalErrorMessage!,
                  isError: true,
                );
                context.read<EligibilityBloc>().add(ErrorMessageCleared());
              }
            },
            builder: (context, state) {
            final bool showFullHeader =
      state.lenderSelectionView == LenderSelectionView.lenderList ||
      state.lenderSelectionView == LenderSelectionView.portfolioBreakdown ||
      state.lenderSelectionView == LenderSelectionView.pledgeableDetail ||
      state.lenderSelectionView == LenderSelectionView.nonPledgeableDetail ||
      state.lenderSelectionView == LenderSelectionView.dematDetail;


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
                            thickness: 1.5, color: AppColors.bSecondaryColor),
                        Gaps.hMd,
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24.0, vertical: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Robust Go Back:
                                  GestureDetector(
                                  onTap: () {
  final bloc = context.read<EligibilityBloc>();
  final view = bloc.state.lenderSelectionView;

  // CASE 1: In Fund Selection → back to lender list
  if (view == LenderSelectionView.fundSelection) {
    bloc.add(const SetLenderSelectionView(LenderSelectionView.lenderList));
    return;
  }

  // CASE 2: In Breakdown / Pledgeable → back to lender list
  if (view == LenderSelectionView.portfolioBreakdown ||
      view == LenderSelectionView.pledgeableDetail ||
      view == LenderSelectionView.nonPledgeableDetail || view == LenderSelectionView.dematDetail) {
    bloc.add(const SetLenderSelectionView(LenderSelectionView.lenderList));
    return;
  }

  // CASE 3: Already at Lender List → ask to exit
  _showExitConfirmDialog().then((confirm) {
    if (confirm) _navigateToDashboard();
  });
},

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
                                          style: AppTypography.bodyWhite
                                              .copyWith(
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: (state.lenderSelectionView ==
                                                      LenderSelectionView
                                                          .portfolioBreakdown ||
                                                  state.lenderSelectionView ==
                                                      LenderSelectionView
                                                          .pledgeableDetail)
                                              ? 'viewLenders'.tr
                                              : 'viewYourMfDetails'.tr,
                                          style:
                                              AppTypography.bodyWhite.copyWith(
                                            decoration:
                                                TextDecoration.underline,
                                            decorationColor: AppColors.white,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              // safe add of toggle event
                                              safeAdd(ViewDetailsToggled());
                                            },
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
                                CText('eligibleCreditLimit'.tr,
                                    style: AppTypography.bodyWhite),
                                Gaps.hSm,
                                Builder(
                                  builder: (_) {
                                    final totalPledgeable = state
                                            .mfDetailsResponse
                                            ?.pledgeableFunds
                                            .fold<double>(
                                                0,
                                                (sum, fund) =>
                                                    sum +
                                                    (fund.availableAmount ??
                                                        0)) ??
                                        0.0;

                                    return CText(
                                      formatCurrency.format(totalPledgeable),
                                      style: AppTypography.h1.copyWith(
                                          color: AppColors.bPrimaryColor),
                                    );
                                  },
                                ),
                                Gaps.hXxs,
                                CText(
                                  'totalPortfolioValue'.trParams({
                                    'value': formatCurrency.format(
                                        state.mfDetailsResponse
                                                ?.eligiblePortfolio ??
                                            0),
                                  }),
                                  style: AppTypography.caption,
                                ),
                                Gaps.hXl,
                              ],
                              AnimatedSwitcher(
                                duration:
                                    const Duration(milliseconds: 300),
                                transitionBuilder:
                                    (child, animation) =>
                                        FadeTransition(
                                            opacity: animation,
                                            child: child),
                                child: () {
                                  final currentView = state.lenderSelectionView;
                                  if (currentView ==
                                      LenderSelectionView.lenderList) {
                                    return Container(
                                      key: const ValueKey('info_box'),
                                      margin:
                                          const EdgeInsets.only(top: 24.0),
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0, vertical: 18.0),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1F2937),
                                        borderRadius:
                                            BorderRadius.circular(8),
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
                                              style:
                                                  AppTypography.bodyWhite,
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
                                          LenderSelectionView
                                              .pledgeableDetail) {
                                    return Align(
                                      key:
                                          const ValueKey('breakdown_title'),
                                      alignment: Alignment.centerLeft,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            top: 24.0, bottom: 8.0),
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
                                      key: ValueKey('empty'));
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
                          child:
                              FadeTransition(opacity: animation, child: child),
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
      ),
    );
  }

 Widget _buildCurrentView(BuildContext context, EligibilityState state) {
  Widget _noDataView({required bool isLoading}) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.bPrimaryColor),
        ),
      );
    }

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
      if (state.mfDetailsResponse == null) {
        return _noDataView(isLoading: state.isLoading);
      }
      return PortfolioBreakdownView(
        key: const ValueKey('breakdown_view'),
        mfDetailsResponse: state.mfDetailsResponse!,
        onCategoryTapped: (categoryId) {
          context.read<EligibilityBloc>().add(
            BreakdownCategoryTapped(categoryId)
          );
        },
        onRefresh: () =>
            context.read<EligibilityBloc>().add(RefreshPortfolioPressed()),
      );

    case LenderSelectionView.pledgeableDetail:
      if (state.mfDetailsResponse == null ||
          state.mfDetailsResponse?.pledgeableFunds.isEmpty == true) {
        return _noDataView(isLoading: state.isLoading);
      }
      return PledgeableFundsDetailView(
        key: const ValueKey('pledgeable_detail_view'),
        onRefresh: () =>
            context.read<EligibilityBloc>().add(RefreshPortfolioPressed()),
      );

    /// 🚀 NEW — NON-PLEDGEABLE FUNDS VIEW
    case LenderSelectionView.nonPledgeableDetail:
      if (state.mfDetailsResponse == null ||
          state.mfDetailsResponse!.nonPledgeableFunds.isEmpty) {
        return _noDataView(isLoading: state.isLoading);
      }
      return NonPledgeableFundsDetailView(
        key: const ValueKey('nonpledgeable_detail_view'),
        onRefresh: () =>
            context.read<EligibilityBloc>().add(RefreshPortfolioPressed()),
      );

    /// 🚀 NEW — DEMAT FUNDS VIEW
    case LenderSelectionView.dematDetail:
      if (state.mfDetailsResponse == null ||
          state.mfDetailsResponse!.dematFunds.isEmpty) {
        return _noDataView(isLoading: state.isLoading);
      }
      return DematFundsDetailView(
        key: const ValueKey('demat_detail_view'),
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
