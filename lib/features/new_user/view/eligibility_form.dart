import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:las_app/common_widgets/c_button.dart';
import 'package:las_app/common_widgets/c_snackbar.dart';
import 'package:las_app/common_widgets/c_text.dart';
import 'package:las_app/core/network/api_client.dart';
import 'package:las_app/core/theme/app_colors.dart';
import 'package:las_app/core/theme/app_spacing.dart';
import 'package:las_app/core/theme/app_typography.dart';
import 'package:las_app/features/new_user/repository/lenders_data_repo.dart';
import 'package:las_app/features/new_user/repository/pan_veirfy_repo.dart';
import 'package:las_app/features/new_user/view/widgets/one_check_eligibility/step_fund_type.dart';
import 'package:las_app/features/new_user/view/widgets/one_check_eligibility/step_pan.dart';
import 'package:las_app/helper_widgets/fetched_overlay.dart';
import 'package:las_app/helper_widgets/fetching_overlay.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../bloc/eligibility_bloc.dart';

class EligibilityScreen extends StatefulWidget {
  const EligibilityScreen({super.key});

  @override
  State<EligibilityScreen> createState() => _EligibilityScreenState();
}

class _EligibilityScreenState extends State<EligibilityScreen> {
  final PageController _pageController = PageController();
  PersistentBottomSheetController? _bottomSheetController;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showOverlay(BuildContext context, EligibilityOverlayType type) {
    _bottomSheetController?.close();

    Widget content;
    if (type == EligibilityOverlayType.fetchingPortfolio) {
      content = const PortfolioFetchingOverlay();
    } else if (type == EligibilityOverlayType.eligibilityResult) {
      content = const EligibilityResultOverlay();
    } else {
      return;
    }

    _bottomSheetController = showBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bc) => content,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EligibilityBloc(repository: PanRepository(ApiClient()),lenderRepository: LenderRepository(ApiClient())),
      child: Scaffold(
        backgroundColor: AppColors.black,
        body: BlocConsumer<EligibilityBloc, EligibilityState>(
          listener: (context, state) {
            if (state.generalErrorMessage != null) {
              CSnackBar.show(context, state.generalErrorMessage!, isError: true);
              context.read<EligibilityBloc>().add(ErrorMessageCleared());
            }

            if (state.pageIndex != (_pageController.page?.round() ?? 0)) {
              _pageController.animateToPage(
                state.pageIndex,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }

            if (state.currentOverlay != EligibilityOverlayType.none) {
              _showOverlay(context, state.currentOverlay);
            } else {
              _bottomSheetController?.close();
              _bottomSheetController = null;
            }
          },
          builder: (context, state) {
            final List<Widget> allStepPages = [
              const Step1InvestmentPage(),
              const Step1PanPage(),
            Center(child: CText('Step 2.1', style: AppTypography.bodyWhite)),
              Center(child: CText('Step 2.2', style: AppTypography.bodyWhite)),
              Center(child: CText('Step 3.1', style: AppTypography.bodyWhite)),
              Center(child: CText('Step 4.1', style: AppTypography.bodyWhite)),
            ];

            return SafeArea(
              child: Column(
                children: [
                  if (state.majorStep == 1) ...[
                    Gaps.hXl, 
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Image.asset('assets/images/sliQ.png', height: 50),
                        ],
                      ),
                    ),
                    Gaps.hXl,
                    const Divider(
                      thickness: 1.5,
                      color: AppColors.bSecondaryColor,
                    ),
                  ],

                  Gaps.hXl, 
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      children: [
                        CircularPercentIndicator(
                          radius: 35.0,
                          lineWidth: 8.0,
                          percent: state.majorStep / 4.0,
                          center: CText(
                            "${state.majorStep}/4",
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
                              'CheckEligibility'.tr,
                              style: AppTypography.h2.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Gaps.hXs, 
                            CText(
                              'NextLenderSelection'.tr,
                              style: AppTypography.body.copyWith(
                                color: AppColors.bSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: allStepPages,
                    ),
                  ),

                  if (state.pageIndex != 1) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0),
                      child: CButton(
                        text: state.isLoading
                            ? 'Submitting'.tr
                            : (state.majorStep == 4
                                ? 'Submit'.tr
                                : 'Confirm&Continue'.tr),
                        onPressed: state.isLoading
                            ? () {}
                            : () => context.read<EligibilityBloc>().add(NextStepPressed()),
                        type: ButtonType.primaryWhite,
                        suffixIcon: state.isLoading
                            ? null
                            : const Icon(Icons.arrow_forward, color: AppColors.black, size: 18),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CText(
                            'Powered by',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.bSecondaryColor,
                            ),
                          ),
                          Gaps.wXs, 
                          Image.asset(
                            'assets/images/value_enable_logo.png',
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
