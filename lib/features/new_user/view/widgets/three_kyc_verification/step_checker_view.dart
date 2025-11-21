import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:las_app/common_widgets/c_button.dart';
import 'package:las_app/common_widgets/c_text.dart';
import 'package:las_app/common_widgets/webview_screen.dart';
import 'package:las_app/core/theme/app_colors.dart';
import 'package:las_app/core/theme/app_typography.dart';
import 'package:las_app/core/theme/app_spacing.dart';
import 'package:las_app/features/new_user/bloc/eligibility_bloc.dart';

import 'package:las_app/features/new_user/view/succcess_pledge_view.dart';
import 'package:las_app/features/new_user/view/widgets/four_pledge_funds/pledge_funds_otp_screen.dart';
import 'package:las_app/features/new_user/view/widgets/two_lender_selection/lender_selection.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../../../core/app_state_provider.dart';
import '../../../kyc_service.dart';
import '../../../../../core/network/api_client.dart';
import '../../../repository/pledge_status_repo.dart';
import '../../../repository/digio_repo.dart';
import '../../../digio_service.dart';

class KycVerificationScreen extends StatefulWidget {
  const KycVerificationScreen({super.key});

  @override
  State<KycVerificationScreen> createState() => _KycVerificationScreenState();
}

class _KycVerificationScreenState extends State<KycVerificationScreen> {
  Timer? _statusTimer;
  late final PledgeStatusRepository _pledgeRepo;
  late final DigioRepository _digioRepo;
  String? _lastStatus;
  bool _hasStartedKyc = false;
  int _apiCallCount = 0;
  int? _loadingStepIndex;
  bool _isPolling = false;

  @override
  void initState() {
    super.initState();
    _pledgeRepo = PledgeStatusRepository(GetIt.instance<ApiClient>());
    _digioRepo = DigioRepository(GetIt.instance<ApiClient>());
    // Call pledge-mf API once to update status
    _checkFirstPledgeStatus();
  }

  void _startStatusPolling() {
    setState(() {
      _isPolling = true;
    });
    _checkPledgeStatus();
    _statusTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (mounted && _isPolling) {
        _checkPledgeStatus();
      }
    });
  }

  Future<void> _checkPledgeStatus() async {
    if (!mounted || !_isPolling) return;

    final appState = GetIt.instance<AppStateProvider>();
    final reqId = appState.reqId;
    final token = appState.token;

    if (reqId == null || token == null) return;

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

          if (status != null && status != _lastStatus) {
            print('📊 Status changed==============: $_lastStatus → $status');
            _lastStatus = status;
            _updateStepsBasedOnStatus(status);

            print("status---------------${status}");
            // Only call Digio API when KYC is actually completed
            if (status == 'kyc_done') {
              _statusTimer?.cancel();
              setState(() {
                _isPolling = false;
              });
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
              _callDigioAPI();
            }
          }
        }
      },
      failure: (error) {
        print('❌ Error checking pledge status: $error');
      },
    );
  }

  Future<void> _checkFirstPledgeStatus() async {
    final appState = GetIt.instance<AppStateProvider>();
    final reqId = appState.reqId;
    final token = appState.token;

    if (reqId == null || token == null) return;

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

  Future<void> _callDigioAPI() async {
    print('🔴 _callDigioAPI method called');
    final appState = GetIt.instance<AppStateProvider>();
    final reqId = appState.reqId;
    print('📝 ReqId from AppState: $reqId');

    if (reqId == null) {
      print('❌ Missing reqId for Digio API');
      return;
    }

    print('🚀 Calling get-digio-config API...');
    final result = await _digioRepo.getDigioConfig(
      reqId: reqId,
      context: context,
    );

    result.when(
      success: (data) {
        print('✅ Digio API called successfully: $data');
      },
      failure: (error) {
        print('❌ Digio API error: $error');
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
      // case 'kyc_done':
      //   steps[0] = true;
      //   break;
      case 'kyc_done':
        steps[0] = true;
        steps[1] = true;
        break;
      case 'mandate_done' || 'penny_drop_done':
        steps[0] = true;
        steps[1] = true;
        steps[2] = true;
        break;
      case 'kfs_agreement_done':
        steps[0] = true;
        steps[1] = true;
        steps[2] = true;
        steps[3] = true;
        break;
    }

    context.read<EligibilityBloc>().add(UpdateKycStepsAll(steps));

    // Stop polling only when all steps are completed
    if (steps.every((step) => step)) {
      _statusTimer?.cancel();
      setState(() {
        _isPolling = false;
      });
    }
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

    // For 4th step (index 3), just mark as completed
    // if (stepIndex == 3) {
    //   print('🚀 4th step clicked - marking as completed');
    //   context.read<EligibilityBloc>().add(UpdateKycStep(stepIndex, true));
    //   setState(() {
    //     _loadingStepIndex = null;
    //   });
    //   return;
    // }

    // For steps 2 and 3, if kyc_done status, skip start-kyc API

    final allowedStatuses = [
      'penny_drop_done',
      'kyc_done',
      'mandate_done',
      'kfs_agreement_done',
    ];

    if ((stepIndex == 2 || stepIndex == 3) &&
        allowedStatuses.contains(_lastStatus)) {
      print(
        '🎯 Step $stepIndex clicked with kyc_done status - calling Digio API',
      );
      await Future.delayed(const Duration(milliseconds: 500));
      _callDigioAPI();
      if (!_hasStartedKyc) {
        _hasStartedKyc = true;
        _startStatusPolling();
      }
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
      onKycComplete: () {
        print('🎯 KYC completed from WebView - calling Digio API');
        _callDigioAPI();
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
    _digioRepo.stopPolling();
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        _statusTimer?.cancel();
        _digioRepo.stopPolling();
        setState(() {
          _isPolling = false;
        });
        final bloc = context.read<EligibilityBloc>();
        try {
          bloc.add(
            const SetLenderSelectionView(LenderSelectionView.fundSelection),
          );
          bloc.add(const JumpToPage(2));
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => BlocProvider.value(
                value: bloc,
                child: const LenderSelectionScreen(),
              ),
            ),
          );
        } catch (e, st) {
          debugPrint('Failed to navigate back to fund selection: $e\n$st');
          if (Navigator.of(context).canPop()) Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.black,
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () async {
        //     var headers = {
        //       'accept': 'application/json',
        //       'Content-Type': 'application/json',
        //       'Authorization':
        //           'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJuYW1lIjoiQXNod2luIFBhbmRleSIsIm1vYmlsZSI6Iis5MTkxMDY2MjE5NTkiLCJ1c2VySWQiOjQ3NTMsImlhdCI6MTc2MzQ2NjM3NywiZXhwIjoxNzYzNDY4MTc3fQ.Ayz_EE5dcDjv-C1tDk5S9hOAPT7N2AloO9LgYZ8g584',
        //     };
        //     var data = json.encode({
        //       "req_id": "bb65d512-c463-11f0-a5b0-0afc8596d62f",
        //       "kyc_id": "KID251118171857981MIIVKF2L7ZTWZP",
        //       "kyc_status": "success",
        //     });
        //     var dio = Dio();
        //     var response = await dio.request(
        //       'https://api-dev.valuenable.in/lamf/customer/update-pennydrop-status',
        //       options: Options(method: 'POST', headers: headers),
        //       data: data,
        //     );
        //
        //     if (response.statusCode == 200) {
        //       print(json.encode(response.data));
        //     } else {
        //       print(response.statusMessage);
        //     }
        //   },
        // ),
        body: Stack(
          children: [
            SafeArea(
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
                            CText(
                              'kycVerification'.tr,
                              style: AppTypography.h2,
                            ),
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

                    // ===== Back Button =====
                    GestureDetector(
                      onTap: () {
                        _statusTimer?.cancel();
                        _digioRepo.stopPolling();
                        setState(() {
                          _isPolling = false;
                        });
                        final bloc = context.read<EligibilityBloc>();

                        try {
                          // 1) Set the lender selection subview to fundSelection
                          bloc.add(
                            const SetLenderSelectionView(
                              LenderSelectionView.fundSelection,
                            ),
                          );

                          // 2) Jump the main page controller to the lender-selection page (pageIndex = 2)
                          bloc.add(const JumpToPage(2));

                          // Navigator.of(context).pushReplacement(
                          //   MaterialPageRoute(
                          //     builder: (ctx) => BlocProvider.value(
                          //       value: bloc,
                          //       child: const LenderSelectionScreen(),
                          //     ),
                          //   ),
                          // );
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (ctx) => BlocProvider.value(
                                value: bloc,
                                child: const LenderSelectionScreen(),
                              ),
                            ),
                          );
                        } catch (e, st) {
                          debugPrint(
                            'Failed to navigate back to fund selection: $e\n$st',
                          );

                          if (Navigator.of(context).canPop())
                            Navigator.of(context).pop();
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
                      child: Stack(
                        children: [
                          BlocBuilder<EligibilityBloc, EligibilityState>(
                            builder: (context, state) {
                              final checks = state.kycStepChecks;
                              print('📝 Current KYC step checks: $checks');

                              return ListView.separated(
                                itemCount: steps.length,
                                separatorBuilder: (_, __) => Gaps.hSm,
                                itemBuilder: (context, index) {
                                  final isChecked = checks[index];
                                  final isClickable = _isStepClickable(
                                    index,
                                    checks,
                                  );
                                  final isVisible = _isStepVisible(
                                    index,
                                    checks,
                                  );
                                  final isLoading = _loadingStepIndex == index;
                                  final allStepsCompleted = checks.every(
                                    (step) => step,
                                  );
                                  return GestureDetector(
                                    onTap:
                                        (!allStepsCompleted &&
                                            (isClickable || index == 3))
                                        ? () => _handleStepClick(
                                            context,
                                            state,
                                            index,
                                          )
                                        : null,
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
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
                                              ? AppColors.bSecondaryColor
                                                    .withOpacity(0.3)
                                              : AppColors.bSecondaryColor
                                                    .withOpacity(0.1),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
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
                                                  borderRadius:
                                                      BorderRadius.circular(2),
                                                  border: Border.all(
                                                    color: isVisible
                                                        ? AppColors
                                                              .bPrimaryColor
                                                        : AppColors
                                                              .bSecondaryColor
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
                                                style: AppTypography.bodyWhite
                                                    .copyWith(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: isVisible
                                                          ? AppColors.white
                                                          : AppColors
                                                                .bSecondaryColor
                                                                .withOpacity(
                                                                  0.5,
                                                                ),
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
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                          Color
                                                        >(
                                                          AppColors
                                                              .bPrimaryColor,
                                                        ),
                                                  ),
                                                )
                                              : Icon(
                                                  Icons.arrow_forward_ios,
                                                  color: isVisible
                                                      ? AppColors
                                                            .bSecondaryColor
                                                      : AppColors
                                                            .bSecondaryColor
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
                          if (_isPolling)
                            Container(
                              color: Colors.black.withOpacity(0.5),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.bPrimaryColor,
                                ),
                              ),
                            ),
                        ],
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
                              final allStepsCompleted = state.kycStepChecks
                                  .every((step) => step);

                              return CButton(
                                text: 'proceedToFinalStep'.tr,
                                onPressed: allStepsCompleted
                                    ? () async {
                                        await Future.delayed(
                                          const Duration(milliseconds: 500),
                                        );
                                        _navigateToNextScreen();
                                        // Navigator.pushReplacement(
                                        //   context,
                                        //   MaterialPageRoute(
                                        //     builder: (context) =>
                                        //         const LoanSuccessScreen(),
                                        //   ),
                                        // );
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
          ],
        ),
      ),
    );
  }
}
