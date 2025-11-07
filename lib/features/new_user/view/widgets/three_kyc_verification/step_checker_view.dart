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
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../../../core/services/websocket_service.dart';
import '../../../../../core/app_state_provider.dart';
import '../../../kyc_service.dart';

class KycVerificationScreen extends StatefulWidget {
  const KycVerificationScreen({super.key});

  @override
  State<KycVerificationScreen> createState() => _KycVerificationScreenState();
}

class _KycVerificationScreenState extends State<KycVerificationScreen> {
  StreamSubscription? _webSocketSubscription;

  @override
  void initState() {
    super.initState();
    _initWebSocket();
  }

  void _initWebSocket() async {
    print('🔌 Initializing WebSocket connection...');
    await WebSocketService.instance.connect();

    if (WebSocketService.instance.stream == null) {
      print('❌ WebSocket stream is null!');
      return;
    }

    _webSocketSubscription = WebSocketService.instance.stream?.listen(
      (data) {
        print('📨 WebSocket message received: $data');
        _handleWebSocketMessage(data);
      },
      onError: (error) {
        print('❌ WebSocket stream error: $error');
      },
      onDone: () {
        print('🔚 WebSocket stream closed');
      },
    );
    print('✅ WebSocket subscription established');

    // Test WebSocket after 3 seconds
    // Timer(Duration(seconds: 3), _testWebSocketMessage);
  }

  void _handleWebSocketMessage(Map<String, dynamic> data) {
    print('🔍 Processing WebSocket message: $data');

    if (data['type'] == 'kyc_step_update') {
      final stepIndex = data['step_index'] as int?;
      final isCompleted = data['is_completed'] as bool?;

      print('📝 KYC Step Update - Index: $stepIndex, Completed: $isCompleted');

      if (stepIndex != null && isCompleted != null && mounted) {
        print('✅ Updating KYC step $stepIndex to $isCompleted');
        context.read<EligibilityBloc>().add(
          UpdateKycStep(stepIndex, isCompleted),
        );
      } else {
        print('❌ Invalid step data or widget not mounted');
      }
    } else {
      print('🔄 Non-KYC message type: ${data['type']}');
    }
  }

  void _handleFirstStepClick(
    BuildContext context,
    EligibilityState state,
  ) async {
    print('💆 First step clicked - Starting KYC process');

    final reqId = GetIt.instance<AppStateProvider>().reqId;
    if (reqId == null) {
      print('❌ Missing reqId for KYC process');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Missing request ID. Please restart the process.'),
        ),
      );
      return;
    }

    final selectedLender = state.lenders.firstWhere(
      (l) => l.id == state.selectedLenderId,
      orElse: () => state.lenders.first,
    );

    print(
      '🏦 Selected lender: ${selectedLender.name} (${selectedLender.lender_code})',
    );
    print('🎯 ReqId: $reqId');

    KycService.startKyc(
      context,
      lenderCode: selectedLender.lender_code,
      reqId: reqId,
      onSuccess: () {
        print(
          '✅ KYC URL opened successfully - WebSocket will handle step updates',
        );

        // Check WebSocket connection status
        if (WebSocketService.instance.isConnected) {
          print('✅ WebSocket is connected and ready to receive messages');
          print('🚀 Starting KYC monitoring - will check status every 5 seconds');
          WebSocketService.instance.startKycMonitoring();
        } else {
          print('❌ WebSocket is not connected!');
        }
      },
    );
  }

  // void _testWebSocketMessage() {
  //   print('🧪 Testing WebSocket with mock message...');
  //   final testMessage = {
  //     'type': 'kyc_step_update',
  //     'step_index': 0,
  //     'is_completed': true
  //   };
  //   _handleWebSocketMessage(testMessage);
  // }

  @override
  void dispose() {
    _webSocketSubscription?.cancel();
    WebSocketService.instance.stopKycMonitoring();
    WebSocketService.instance.disconnect();
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

              // ===== Step List =====
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

                        return GestureDetector(
                          onTap: index == 0
                              ? () => _handleFirstStepClick(context, state)
                              : null,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1C1C1C),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: AppColors.bSecondaryColor.withOpacity(
                                  0.3,
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
                                          color: AppColors.bPrimaryColor,
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
                                      ),
                                    ),
                                  ],
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  color: AppColors.bSecondaryColor,
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
            ],
          ),
        ),
      ),
    );
  }
}
