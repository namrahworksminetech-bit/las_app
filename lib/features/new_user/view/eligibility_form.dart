import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:las_app/helper_widgets/fetched_overlay.dart';
import 'package:las_app/helper_widgets/fetching_overlay.dart';
import 'package:las_app/core/theme/app_colors.dart';
import 'package:las_app/features/new_user/view/widgets/one_check_eligibility/step_fund_type.dart';
import 'package:las_app/features/new_user/view/widgets/one_check_eligibility/step_pan.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../common_widgets/c_button.dart';
import '../../../common_widgets/c_snackbar.dart';
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
      builder: (BuildContext bc) {
        return content;
      },
    );
  }
  

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EligibilityBloc(),
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
              const Center(
                  child:
                      Text('Step 2.1', style: TextStyle(color: Colors.white))),
              const Center(
                  child:
                      Text('Step 2.2', style: TextStyle(color: Colors.white))),
              const Center(
                  child:
                      Text('Step 3.1', style: TextStyle(color: Colors.white))),
              const Center(
                  child:
                      Text('Step 4.1', style: TextStyle(color: Colors.white))),
            ];

            return SafeArea(
              child: Column(
                children: [
                  
                  if (state.majorStep == 1) ...[
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Image.asset('assets/images/sliQ.png', height: 50),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(
                        thickness: 1.5, color: AppColors.bSecondaryColor),
                  ],

                  
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      children: [
                        CircularPercentIndicator(
                          radius: 35.0,
                          lineWidth: 8.0,
                          percent: state.majorStep / 4.0,
                          center: Text(
                            "${state.majorStep}/4",
                            style: const TextStyle(
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
                              'Check Eligibility',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Next: Lender Selection',
                              style: TextStyle(
                                color: AppColors.bSecondaryColor,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        )
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
                            ? 'Submitting...'
                            : (state.majorStep == 4
                                ? 'Submit'
                                : 'Confirm & Continue'),
                        onPressed: state.isLoading
                            ? () {}
                            : () => context
                                .read<EligibilityBloc>()
                                .add(NextStepPressed()),
                        type: ButtonType.primaryWhite,
                        suffixIcon: state.isLoading
                            ? null
                            : const Icon(Icons.arrow_forward,
                                color: AppColors.black, size: 18),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Powered by',
                              style: TextStyle(
                                  color: AppColors.bSecondaryColor,
                                  fontSize: 12),
                            ),
                            const SizedBox(width: 8),
                            Image.asset(
                              'assets/images/value_enable_logo.png',
                              height: 20,
                            ),
                          ],
                        ),
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