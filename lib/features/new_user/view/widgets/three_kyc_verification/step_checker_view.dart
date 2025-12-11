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
import 'package:las_app/features/home/view_home.dart';
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

    /// Check pledge status on screen load with context
    context.read<EligibilityBloc>().add(CheckPledgeStatus(context: context));
  }

  @override
  void dispose() {
    // Stop all ongoing processes when leaving the screen
    context.read<EligibilityBloc>().add(const StopAllKycProcesses());
    super.dispose();
  }

  Future<bool> _showExitConfirmDialog() async {
    final res = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Exit to Home?'),
          content: const Text(
            'Are you sure you want to leave this flow and go back to the home screen?',
          ),
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

  void _navigateHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const Home()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // 🔔 Listener 1: Navigation to OTP screen
        BlocListener<EligibilityBloc, EligibilityState>(
          listenWhen: (previous, current) {
            final checks = current.kycStepChecks;
            final allStepsCompleted =
                checks.length >= 5 && checks.take(5).every((s) => s);
            return current.shouldNavigateToOtp &&
                !previous.shouldNavigateToOtp &&
                allStepsCompleted;
          },
          listener: (context, state) {
            debugPrint('✅ All KYC steps completed, navigating to OTP screen');
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PledgeFundsOtpScreen()),
            );
          },
        ),

        // 🔔 Listener 2: Auto-handle Digio flow when kyc_done status detected
        BlocListener<EligibilityBloc, EligibilityState>(
          listenWhen: (previous, current) {
            final step0Done =
                current.kycStepChecks.length > 0 && current.kycStepChecks[0];
            final step1Done =
                current.kycStepChecks.length > 1 && current.kycStepChecks[1];
            final isKycDone = current.currentKycStatus == 'kyc_done';
            final notTriggered = !current.hasTriggeredDigio;
            final isPennyDropDone =
                current.currentKycStatus == 'penny_drop_done';
            final statusChanged =
                previous.currentKycStatus != current.currentKycStatus;

            debugPrint('🔍 Digio Listener Check:');
            debugPrint('  step0Done: $step0Done, step1Done: $step1Done');
            debugPrint('  isKycDone: $isKycDone, notTriggered: $notTriggered');
            debugPrint(
              '  isPennyDropDone: $isPennyDropDone, statusChanged: $statusChanged',
            );

            // Only trigger if kyc_done, not penny_drop_done, and status actually changed
            return step0Done &&
                step1Done &&
                isKycDone &&
                notTriggered &&
                !isPennyDropDone &&
                statusChanged;
          },
          listener: (context, state) async {
            debugPrint('🔔 kyc_done detected - starting Digio SDK');

            final reqId = GetIt.instance<AppStateProvider>().reqId;
            if (reqId != null) {
              // Directly start Digio SDK without calling CheckPledgeStatus again
              context.read<EligibilityBloc>().add(
                StartDigioKyc(reqId: reqId, context: context),
              );
            }
          },
        ),

        /// 🌐 Listener 3: WebView controller - Opens/Closes WebView based on kycUrl changes
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
      child: WillPopScope(
        onWillPop: () async {
          final confirm = await _showExitConfirmDialog();
          if (confirm) {
            context.read<EligibilityBloc>().add(const StopAllKycProcesses());
            _navigateHome();
          }
          return false; // Prevent automatic pop
        },
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
                  const Divider(
                    thickness: 1.5,
                    color: AppColors.bSecondaryColor,
                  ),
                  Gaps.hMd,

                  GestureDetector(
                    onTap: () async {
                      final confirm = await _showExitConfirmDialog();
                      if (confirm) {
                        context.read<EligibilityBloc>().add(
                          const StopAllKycProcesses(),
                        );
                        _navigateHome();
                      }
                    },

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
                        if (state.isLoading ||
                            state.kycLoading ||
                            state.isPennyDropPolling) {
                          print("isLoading${state.isLoading}");
                          print("kycLoading${state.kycLoading}");
                          print(
                            "isPennyDropPolling${state.isPennyDropPolling}",
                          );
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const CircularProgressIndicator(
                                  color: AppColors.bPrimaryColor,
                                ),
                                const SizedBox(height: 16),
                                CText(
                                  state.kycLoading &&
                                          state.currentKycStatus == 'kyc_done'
                                      ? 'Processing verification...\nPlease wait'
                                      : 'Loading...',
                                  style: AppTypography.bodyWhite.copyWith(
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        }

                        final checks = state.kycStepChecks ?? [];
                        final steps = state.kycSteps;

                        if (steps.isEmpty) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
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
                                              borderRadius:
                                                  BorderRadius.circular(2),
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
                                          : AppColors.bSecondaryColor
                                                .withOpacity(0.3),
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
                                checks.take(5).every((s) => s) &&
                                !state.kycLoading &&
                                !state.isPennyDropPolling;

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
      ),
    );
  }
}
