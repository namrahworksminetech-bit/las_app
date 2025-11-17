import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:las_app/common_widgets/c_button.dart';
import 'package:las_app/common_widgets/c_text.dart';
import 'package:las_app/core/theme/app_colors.dart';
import 'package:las_app/core/theme/app_typography.dart';
import 'package:las_app/core/theme/app_spacing.dart';
import 'package:las_app/features/new_user/bloc/eligibility_bloc.dart';

import 'package:las_app/features/new_user/view/succcess_pledge_view.dart';
import 'package:las_app/features/new_user/view/widgets/four_pledge_funds/pledge_funds_otp_screen.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../../../core/app_state_provider.dart';
import '../../../kyc_service.dart';
import '../../../../../core/network/api_client.dart';
import '../../../repository/pledge_status_repo.dart';

class KycVerificationScreen extends StatefulWidget {
  const KycVerificationScreen({super.key});

  @override
  State<KycVerificationScreen> createState() => _KycVerificationScreenState();
}

class _KycVerificationScreenState extends State<KycVerificationScreen> {
  Timer? _statusTimer;
  late final PledgeStatusRepository _pledgeRepo;
  String? _lastStatus;
  bool _hasStartedKyc = false;
  int _apiCallCount = 0;
  int? _loadingStepIndex;

  @override
  void initState() {
    super.initState();
    _pledgeRepo = PledgeStatusRepository(GetIt.instance<ApiClient>());
    // Don't start polling immediately - wait for user to click a step
  }

  void _startStatusPolling() {
    _checkPledgeStatus();
    _statusTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _checkPledgeStatus();
    });
  }

  Future<void> _checkPledgeStatus() async {
    final appState = GetIt.instance<AppStateProvider>();
    final reqId = appState.reqId;
    final token = appState.token;

    if (reqId == null || token == null) return;

    _apiCallCount++;
    print('📞 get-mf-details API call count: $_apiCallCount/10');
    
    // Close WebView after 10 API calls
    if (_apiCallCount >= 10) {
      print('✅ 10 API calls completed - closing WebView and returning to KYC screen');
      _statusTimer?.cancel();
      if (Navigator.canPop(context)) {
        Navigator.pop(context); // This will close the WebView
      }
      return;
    }

    final result = await _pledgeRepo.checkPledgeStatus(
      reqId: reqId,
      authToken: token,
    );

    result.when(
      success: (data) {
        if (mounted) {
          // Extract status from nested structure: data.data.status
          // Handle both String and List cases
          final statusData = data['data']?['status'];
          final String? status;

          if (statusData is String) {
            status = statusData;
          } else if (statusData is List && statusData.isNotEmpty) {
            status = statusData.first as String?;
          } else {
            status = null;
          }

          // Only update if status changed
          if (status != null && status != _lastStatus) {
            print('📊 Status changed: $_lastStatus → $status');
            _lastStatus = status;
            _updateStepsBasedOnStatus(status);
          }
        }
      },
      failure: (error) {
        print('❌ Error checking pledge status: $error');
      },
    );
  }

  void _updateStepsBasedOnStatus(String? status) {
    if (status == null) return;

    print('📊 Current status: $status');

    if (status == 'completed') {
      if (Navigator.canPop(context)) {
        Navigator.pop(context); // closes the WebView
      }
    }

    List<bool> steps = [false, false, false, false];

    switch (status) {
      case 'not_started' || 'pan_verified' || 'pending':
        // All steps remain false
        break;
      case 'verified':
        steps[0] = true;
        break;
      case 'kyc_done':
        steps[0] = true;
        steps[1] = true;
        break;
      case ('mandate_done' || 'kfs_agreement_done'):
        steps[0] = true;
        steps[1] = true;
        steps[2] = true;
        break;
    }

    context.read<EligibilityBloc>().add(UpdateKycStepsAll(steps));
  }

  void _navigateToNextScreen() {
    _statusTimer?.cancel();
    final bloc = context.read<EligibilityBloc>();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: bloc,
          child: const PledgeFundsOtpScreen(),
        ),
      ),
    );
  }

  bool _isStepClickable(int index, List<bool> checks) {
    // First step is always clickable if not completed
    if (index == 0) return !checks[0];

    // Other steps are clickable only if previous step is completed
    return index > 0 && checks[index - 1] && !checks[index];
  }

  bool _isStepVisible(int index, List<bool> checks) {
    // First step is always visible
    if (index == 0) return true;

    // Other steps are visible only if previous step is completed
    return index > 0 && checks[index - 1];
  }

  void _handleStepClick(
    BuildContext context,
    EligibilityState state,
    int stepIndex,
  ) async {
    print('💆 Step $stepIndex clicked');

    // Show loading for this step
    setState(() {
      _loadingStepIndex = stepIndex;
    });

    // For 4th step (index 3), directly navigate to next screen
    if (stepIndex == 3) {
      print('🚀 4th step clicked - Navigating to next screen');
      await Future.delayed(const Duration(milliseconds: 500)); // Show loader briefly
      _navigateToNextScreen();
      setState(() {
        _loadingStepIndex = null;
      });
      return;
    }

    // For other steps, open KYC URL
    final appState = GetIt.instance<AppStateProvider>();
    final reqId = appState.reqId;
    final lenderCode = "BFL";

    print('🏦 Lender code: $lenderCode');
    print('🎯 ReqId: $reqId');
    print('📋 Step Index: $stepIndex');

    final List<String> stepNames = [
      "fillBasicInfo".tr,
      "aadharPanVerification".tr,
      "linkAccountMandate".tr,
      "loanAgreementSigning".tr,
    ];

    if (reqId == null || lenderCode == null) {
      print('❌ Missing reqId or lenderCode');
      return;
    }

    KycRepository.startKyc(
      context,
      lenderCode: "BFL",
      reqId: reqId,
      stepName: stepNames[stepIndex],
      onSuccess: () {
        print('✅ KYC URL opened successfully - starting status polling');
        setState(() {
          _loadingStepIndex = null;
        });
        if (!_hasStartedKyc) {
          _hasStartedKyc = true;
          _startStatusPolling();
        }
      },
    );
    
    // Clear loading if there's an error
    setState(() {
      _loadingStepIndex = null;
    });
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> steps = [
      "fillBasicInfo".tr,
      "aadharPanVerification".tr,
      "linkAccountMandate".tr,
      "loanAgreementSigning".tr,
    ];

    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Gaps.hXl,

              // ===== Progress Indicator =====
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

              // ===== Back Button =====
              GestureDetector(
                onTap: () => Navigator.pop(context),
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

              // ===== Header Text =====
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
                    final checks = state.kycStepChecks;
                    print('📝 Current KYC step checks: $checks');

                    return ListView.separated(
                      itemCount: steps.length,
                      separatorBuilder: (_, __) => Gaps.hSm,
                      itemBuilder: (context, index) {
                        final isChecked = checks[index];
                        final isClickable = _isStepClickable(index, checks);
                        final isVisible = _isStepVisible(index, checks);
                        final isLoading = _loadingStepIndex == index;
                        print("${isChecked}");
                        return GestureDetector(
                          onTap: (isClickable || index == 3)
                              ? () => _handleStepClick(context, state, index)
                              : null,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
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
                                    ? AppColors.bSecondaryColor.withOpacity(0.3)
                                    : AppColors.bSecondaryColor.withOpacity(
                                        0.1,
                                      ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      height: 22,
                                      width: 22,
                                      decoration: BoxDecoration(
                                        color: isChecked
                                            ? AppColors.bPrimaryColor
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(2),
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
                                    CText(
                                      steps[index],
                                      style: AppTypography.bodyWhite.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: isVisible
                                            ? AppColors.white
                                            : AppColors.bSecondaryColor
                                                  .withOpacity(0.5),
                                      ),
                                    ),
                                  ],
                                ),
                                isLoading
                                    ? const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            AppColors.bPrimaryColor,
                                          ),
                                        ),
                                      )
                                    : Icon(
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

              // ===== Bottom Section =====
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    BlocBuilder<EligibilityBloc, EligibilityState>(
                      builder: (context, state) {
                        final allStepsCompleted = state.kycStepChecks.every(
                          (step) => step,
                        );

                        return CButton(
                          text: 'proceedToFinalStep'.tr,
                          onPressed: allStepsCompleted
                              ? () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const LoanSuccessScreen(),
                                    ),
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
              // CButton(
              //   text: 'proceedToFinalStep'.tr,
              //   onPressed: () {
              //     _navigateToNextScreen();
              //   },
              //   type: ButtonType.secondaryGrey,
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
