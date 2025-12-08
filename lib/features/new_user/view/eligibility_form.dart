import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:las_app/common_widgets/c_button.dart';
import 'package:las_app/common_widgets/c_text.dart';
import 'package:las_app/core/network/api_client.dart';
import 'package:las_app/core/theme/app_colors.dart';
import 'package:las_app/core/theme/app_spacing.dart';
import 'package:las_app/core/theme/app_typography.dart';
import 'package:las_app/features/new_user/repository/lenders_data_repo.dart';
import 'package:las_app/features/new_user/repository/pan_veirfy_repo.dart';
import 'package:las_app/features/new_user/view/widgets/one_check_eligibility/insurance_step_one.dart';
import 'package:las_app/features/new_user/view/widgets/one_check_eligibility/insurance_step_two.dart';
import 'package:las_app/features/new_user/view/widgets/one_check_eligibility/shares_step.dart';
import 'package:las_app/features/new_user/view/widgets/one_check_eligibility/step_fund_type.dart';
import 'package:las_app/features/new_user/view/widgets/one_check_eligibility/step_pan.dart';
import 'package:las_app/helper_widgets/fetched_overlay.dart';
import 'package:las_app/helper_widgets/fetching_overlay.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../bloc/eligibility_bloc.dart';

class EligibilityScreen extends StatefulWidget {
  
  final bool startWithMfFetch;

  const EligibilityScreen({super.key, this.startWithMfFetch = false});

  @override
  State<EligibilityScreen> createState() => _EligibilityScreenState();
}


class _EligibilityScreenState extends State<EligibilityScreen> {
  final PageController _pageController = PageController();
  PersistentBottomSheetController? _bottomSheetController;
  bool _isOverlayOpen = false;


  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showOverlay(BuildContext context, EligibilityOverlayType type) {
    if (_isOverlayOpen) return; // prevent multiple opens

    _isOverlayOpen = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final scaffoldState = Scaffold.maybeOf(context);
      if (scaffoldState == null || !scaffoldState.mounted) {
        debugPrint("⚠️ Scaffold not ready, skipping overlay");
        _isOverlayOpen = false;
        return;
      }

      Widget content;
      if (type == EligibilityOverlayType.fetchingPortfolio) {
        content = PortfolioFetchingOverlay();
      } else if (type == EligibilityOverlayType.eligibilityResult) {
        content = const EligibilityResultOverlay();
      } else {
        _isOverlayOpen = false;
        return;
      }

      _bottomSheetController = scaffoldState.showBottomSheet(
        (_) => content,
        backgroundColor: Colors.transparent,
      );

      _bottomSheetController?.closed.whenComplete(() {
        if (mounted) {
          setState(() {
            _isOverlayOpen = false;
          });
        } else {
          _isOverlayOpen = false;
        }
      });
    });
  }

   @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = EligibilityBloc(
          repository: PanRepository(ApiClient()),
          lenderRepository: LenderRepository(ApiClient()),
          apiClient: ApiClient(),
        );

        if (widget.startWithMfFetch) {
          // schedule immediately after creation so the bloc is ready
          Future.microtask(() {
            try {
              bloc.add(const StartFetchingFromLogin());
            } catch (e) {
              print('Failed to dispatch StartFetchingFromLogin: $e');
            }
          });
        }

        return bloc;
      },
      child: Scaffold(
        backgroundColor: AppColors.black,
        body: BlocConsumer<EligibilityBloc, EligibilityState>(
          listener: (context, state) {
            // animate page when bloc pageIndex changes
            if (state.pageIndex != (_pageController.page?.round() ?? 0)) {
              _pageController.animateToPage(
                state.pageIndex,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }

            // overlay handling
            if (state.currentOverlay != EligibilityOverlayType.none) {
              _showOverlay(context, state.currentOverlay);
            } else {
              if (_isOverlayOpen) {
                _bottomSheetController?.close();
                _bottomSheetController = null;
                setState(() => _isOverlayOpen = false);
              }
            }
          },
         builder: (context, state) {
  Widget step1Page;
  Widget step2Page;

  if (state.formData.investmentType == InvestmentType.insurancePolicy) {
    // Insurance flow
    step1Page = const StepInsuranceDetailsPage();   // index 1
    step2Page = const StepInsuranceUploadPage();    // index 2
  } else if (state.formData.investmentType == InvestmentType.shares) {
    // Shares flow
    step1Page = const StepSharesDetailsPage();      // index 1
    step2Page = Center(child: CText("Step 2.1"));   // TODO: replace with actual next step for shares
  } else {
    // Mutual fund (default) flow
    step1Page = const Step1PanPage();               // index 1
    step2Page = Center(child: CText("Step 2.1"));   // existing MF flow step
  }

  final List<Widget> allStepPages = [
    const Step1InvestmentPage(), // index 0

    step1Page,                   // index 1: depends on type
    step2Page,                   // index 2: depends on type

    Center(child: CText("Step 2.2")),  // index 3
    Center(child: CText("Step 3.1")),  // index 4
    Center(child: CText("Step 4.1")),  // index 5
  ];

  // 🔹 decide when to show the global CTA + footer
  final bool isInsuranceFlow =
      state.formData.investmentType == InvestmentType.insurancePolicy;

  // hide on insurance pages 1 & 2
  final bool hideGlobalCtaOnThisPage =
      isInsuranceFlow && (state.pageIndex == 1 || state.pageIndex == 2);

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
                            : (state.majorStep == 4 ? 'Submit'.tr : 'Confirm&Continue'.tr),
                  onPressed: state.isLoading || state.isSubmittingInsurance
    ? null
    : () {
        final inInsuranceFlow =
            state.formData.investmentType == InvestmentType.insurancePolicy;

        if (inInsuranceFlow && state.pageIndex == 2) {
          print("🔥 SUBMIT INSURANCE CALLED");
          context.read<EligibilityBloc>().add(SubmitInsuranceDetails());
          return; // ⛔ stops page skip
        }

        context.read<EligibilityBloc>().add(NextStepPressed());
      },

                        type: ButtonType.primaryWhite,
                        suffixIcon: state.isLoading
                            ? null
                            : const Icon(
                                Icons.arrow_forward,
                                color: AppColors.black,
                                size: 18,
                              ),
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
