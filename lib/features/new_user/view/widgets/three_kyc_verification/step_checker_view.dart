import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:las_app/common_widgets/c_button.dart';
import 'package:las_app/common_widgets/c_text.dart';
import 'package:las_app/core/app_state_provider.dart';
import 'package:las_app/core/theme/app_colors.dart';
import 'package:las_app/core/theme/app_typography.dart';
import 'package:las_app/core/theme/app_spacing.dart';
import 'package:las_app/features/new_user/bloc/eligibility_bloc.dart';
import 'package:las_app/common_widgets/webview_screen.dart';
import 'package:las_app/features/new_user/view/widgets/four_pledge_funds/pledge_funds_otp_screen.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class KycVerificationScreen extends StatefulWidget {
  const KycVerificationScreen({super.key});

  @override
  State<KycVerificationScreen> createState() => _KycVerificationScreenState();
}

class _KycVerificationScreenState extends State<KycVerificationScreen> {
  @override
  void initState() {
    super.initState();

    /// Check pledge status on screen load
    context.read<EligibilityBloc>().add(const CheckPledgeStatus());
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // 🔔 Listener 1: Navigation to OTP screen
        BlocListener<EligibilityBloc, EligibilityState>(
          listenWhen: (previous, current) =>
              current.shouldNavigateToOtp && !previous.shouldNavigateToOtp,
          listener: (context, state) {
            debugPrint('✅ All KYC steps completed, navigating to OTP screen');
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PledgeFundsOtpScreen()),
            );
          },
        ),
        
        // 🔔 Listener 2: Auto-trigger Digio SDK when kyc_done status detected
        BlocListener<EligibilityBloc, EligibilityState>(
          listenWhen: (previous, current) {
            final step0Done =
                current.kycStepChecks.length > 0 && current.kycStepChecks[0];
            final step1Done =
                current.kycStepChecks.length > 1 && current.kycStepChecks[1];
            final isKycDone = current.currentKycStatus == 'kyc_done';
            final notTriggered = !current.hasTriggeredDigio;

            debugPrint('🔍 Digio Listener Check:');
            debugPrint('  step0Done: $step0Done, step1Done: $step1Done');
            debugPrint('  isKycDone: $isKycDone, notTriggered: $notTriggered');

            return step0Done && step1Done && isKycDone && notTriggered;
          },
          listener: (context, state) async {
            debugPrint('🔔 kyc_done detected - triggering Digio SDK');

            await Future.delayed(const Duration(milliseconds: 500));

            final reqId = GetIt.instance<AppStateProvider>().reqId;
            if (reqId != null) {
              context.read<EligibilityBloc>().add(
                StartDigioKyc(reqId: reqId, context: context),
              );
            }
          },
        ),

        /// 🌐 Listener 2: WebView controller - Opens/Closes WebView based on kycUrl changes
        BlocListener<EligibilityBloc, EligibilityState>(
          listenWhen: (previous, current) => previous.kycUrl != current.kycUrl,
          listener: (context, state) async {
            if (state.kycUrl != null && state.kycUrl!.isNotEmpty) {
              // 🌐 Open WebView with URL
              debugPrint('🌐 Opening WebView with URL: ${state.kycUrl}');
              debugPrint('🏷️ Step name: ${state.currentStepName}');
              final bloc = context.read<EligibilityBloc>();
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WebViewScreen(
                    url: state.kycUrl!,
                    title: state.currentStepName,
                    bloc: bloc,
                  ),
                ),
              );
              debugPrint('🚪 WebView closed by user');
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.black,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Gaps.hXl,

                Row(
                  children: [
                    CircularPercentIndicator(
                      radius: 35.0,
                      lineWidth: 8.0,
                      percent: 3 / 4.0,
                      center: CText(
                        "3/4",
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
                        CText('kycVerification'.tr, style: AppTypography.h2),
                        Gaps.hXxs,
                        CText(
                          'nextPledgeFunds'.tr,
                          style: AppTypography.bodySecondary,
                        ),
                      ],
                    ),
                  ],
                ),

                Gaps.hXl,
                const Divider(thickness: 1.5, color: AppColors.bSecondaryColor),
                Gaps.hMd,

                GestureDetector(
                  // onTap: () {
                  //   context.read<EligibilityBloc>().add(
                  //     ExitKycScreen(context: context),
                  //   );
                  // },
                  child: Row(
                    children: [
                      const Icon(
                        Icons.arrow_back,
                        color: AppColors.white,
                        size: 20,
                      ),
                      Gaps.wSm,
                      CText('goBack'.tr, style: AppTypography.bodyWhite),
                    ],
                  ),
                ),
                Gaps.hXl,

                CText(
                  'verifyDetails'.tr,
                  style: AppTypography.bodyWhite.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Gaps.hXxs,
                CText('safeSecure'.tr, style: AppTypography.caption),

                Gaps.hXl,

                Expanded(
                  child: BlocBuilder<EligibilityBloc, EligibilityState>(
                    builder: (context, state) {
                      // Show loader when initial loading or KYC API calling
                      if (state.isLoading || state.kycLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.bPrimaryColor,
                          ),
                        );
                      }

                      final checks = state.kycStepChecks ?? [];
                      final steps = state.kycSteps;

                      if (steps.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      return ListView.separated(
                        itemCount: steps.length,
                        separatorBuilder: (_, __) => Gaps.hSm,
                        itemBuilder: (context, index) {
                          final isChecked = checks.length > index
                              ? checks[index]
                              : false;
                          final isVisible =
                              index == 0 ||
                              (index > 0 &&
                                  checks.length > index - 1 &&
                                  checks[index - 1]);

                          // Only allow tap on next unchecked step (previous step must be checked)
                          final canTap = isVisible && !isChecked;

                          return GestureDetector(
                            onTap: canTap
                                ? () {
                                    debugPrint('🔔 Step $index tapped');
                                    context.read<EligibilityBloc>().add(
                                      KycStepTapped(
                                        stepIndex: index,
                                        context: context,
                                      ),
                                    );
                                  }
                                : null,
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: isVisible
                                    ? const Color(0xFF1C1C1C)
                                    : const Color(0xFF0F0F0F),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isVisible
                                      ? AppColors.bSecondaryColor.withOpacity(
                                          0.3,
                                        )
                                      : AppColors.bSecondaryColor.withOpacity(
                                          0.1,
                                        ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Container(
                                          height: 22,
                                          width: 22,
                                          decoration: BoxDecoration(
                                            color: isChecked
                                                ? AppColors.bPrimaryColor
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(
                                              2,
                                            ),
                                            border: Border.all(
                                              color: isVisible
                                                  ? AppColors.bPrimaryColor
                                                  : AppColors.bSecondaryColor
                                                        .withOpacity(0.3),
                                              width: 1.8,
                                            ),
                                          ),
                                          child: isChecked
                                              ? const Icon(
                                                  Icons.check,
                                                  size: 16,
                                                  color: Colors.black,
                                                )
                                              : null,
                                        ),
                                        Gaps.wMd,

                                        /// 👇 MOST IMPORTANT
                                        Expanded(
                                          child: CText(
                                            steps[index],
                                            style: AppTypography.bodyWhite
                                                .copyWith(
                                                  fontWeight: FontWeight.w500,
                                                  color: isVisible
                                                      ? AppColors.white
                                                      : AppColors
                                                            .bSecondaryColor
                                                            .withOpacity(0.5),
                                                ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: isVisible
                                        ? AppColors.bSecondaryColor
                                        : AppColors.bSecondaryColor.withOpacity(
                                            0.3,
                                          ),
                                    size: 14,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      BlocBuilder<EligibilityBloc, EligibilityState>(
                        builder: (context, state) {
                          // require at least 5 checks and all true for proceed
                          final checks = state.kycStepChecks;
                          final allStepsCompleted =
                              checks.length >= 5 &&
                              checks.take(5).every((s) => s);

                          return CButton(
                            text: 'proceedToFinalStep'.tr,
                            onPressed: allStepsCompleted
                                ? () {
                                    context.read<EligibilityBloc>().add(
                                      const NavigateToNextScreen(),
                                    );
                                  }
                                : null,
                            type: allStepsCompleted
                                ? ButtonType.primaryWhite
                                : ButtonType.secondaryGrey,
                            suffixIcon: allStepsCompleted
                                ? const Icon(
                                    Icons.arrow_forward,
                                    color: AppColors.black,
                                    size: 18,
                                  )
                                : null,
                          );
                        },
                      ),
                      Gaps.hSm,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CText('Powered by', style: AppTypography.caption),
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
            ),
          ),
        ),
      ),
    );
  }
}
