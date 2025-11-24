// lib/features/new_user/view/pledge_funds_otp_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:las_app/app.dart';

import 'package:las_app/common_widgets/c_button.dart';
import 'package:las_app/common_widgets/c_input.dart';
import 'package:las_app/common_widgets/c_text.dart';
import 'package:las_app/core/app_state_provider.dart';
import 'package:las_app/core/theme/app_colors.dart';
import 'package:las_app/core/theme/app_spacing.dart';
import 'package:las_app/core/theme/app_typography.dart';
import 'package:las_app/features/new_user/bloc/eligibility_bloc.dart';
import 'package:las_app/features/new_user/repository/pledge_status_repo.dart';
import 'package:las_app/features/new_user/repository/rta_repo.dart';
import 'package:las_app/features/new_user/view/succcess_pledge_view.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';



class PledgeFundsOtpScreen extends StatefulWidget {
  final String? mobileNumber;

  const PledgeFundsOtpScreen({super.key, this.mobileNumber});

  @override
  State<PledgeFundsOtpScreen> createState() => _PledgeFundsOtpScreenState();
}

class _PledgeFundsOtpScreenState extends State<PledgeFundsOtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isSubmitting = false;

  final RtaRepository _rtaRepo = RtaRepository();
final PledgeStatusRepository _pledgeStatusRepository = PledgeStatusRepository();
  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _submitOtp() async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty || otp.length < 4) {
      Get.snackbar('Error', 'Please enter a valid OTP');
      return;
    }

    final appState = GetIt.instance<AppStateProvider>();
    var phone = widget.mobileNumber ?? appState.mobileNumber ?? '';
    if (phone.isEmpty) {
      Get.snackbar('Error', 'Phone number not available');
      return;
    }

    // ensure +91 prefix
   if (!phone.startsWith('+')) {
  phone = phone.startsWith('91') ? '+$phone' : '+91$phone';
}

    // token and reqId are validated in RtaRepository, but we precheck here for helpful messages
    if (appState.token == null || appState.token!.isEmpty) {
      Get.snackbar('Error', 'Authorization token missing');
      return;
    }
    if (appState.reqId == null || appState.reqId!.isEmpty) {
      Get.snackbar('Error', 'reqId missing');
      return;
    }

    setState(() => _isSubmitting = true);
    Get.snackbar('Please wait', 'Verifying OTP...');

    try {
      final returnedReqId = await _rtaRepo.verifyRtaOtp(
        phone: phone,
        otp: otp,
        // rta: 'MFCENTRAL', // default already
        // refNo: '', // default already
      );

      // Expectation: API returns {status: "success", data: { req_id: "..." }, message: "..."}
      Get.snackbar('Success', 'OTP verified successfully');

   
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoanSuccessScreen()),
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionTimeout) {
        Get.snackbar('Error', 'Server down, please try again later');
      } else {
        final errMsg =
            e.response?.data?['message'] ?? e.message ?? 'Network error';
        Get.snackbar('Error', errMsg);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

@override
void initState() {
  super.initState();
_callPledgeStatusApi(); 
  _otpController.addListener(() {
    if (mounted) setState(() {}); 
  });
}
Future<void> _callPledgeStatusApi() async {
  final appState = getIt<AppStateProvider>();

  final reqId = appState.reqId;           
  final token = appState.token;         
  final result = await _pledgeStatusRepository.checkPledgeMfStatus(
    reqId: reqId!,
    type: "pledge",
   authToken: token!,
  );

  result.when(
    success: (data) {
      print("Pledge Status Success: $data");
    
    },
    failure: (error) {
      print("Error: $error");

    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Gaps.hXs,

              // Progress Header
              Gaps.hXl,
              Row(
                children: [
                  CircularPercentIndicator(
                    radius: 35.0,
                    lineWidth: 8.0,
                    percent: 1.0,
                    center: CText(
                      "4/4",
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
                        'pledgeFunds'.tr,
                        style: AppTypography.h2,
                      ),
                      Gaps.hXxs,
                      CText(
                        'nextApplicationSubmission'.tr,
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

              // Back Navigation
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Row(
                  children: [
                    const Icon(
                      Icons.arrow_back,
                      color: AppColors.white,
                      size: 20,
                    ),
                    Gaps.wXs,
                    CText(
                      'goBack'.tr,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),

              Gaps.hXs,

              // OTP Message
              CText(
                'otpSentMessage'.tr,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.white,
                  height: 1.4,
                ),
              ),

              Gaps.hXs,

              // OTP Input (sync with bloc state if available)
              BlocBuilder<EligibilityBloc, EligibilityState>(
                builder: (context, state) {
                  // keep controller in sync if bloc updates OTP
                  _otpController.text = state.otp;
                  _otpController.selection = TextSelection.fromPosition(
                    TextPosition(offset: _otpController.text.length),
                  );

                  return CInput(
                    labelText: "EnterOTP".tr,
                    hintText: '******',
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(6),
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onChanged: (value) =>
                        context.read<EligibilityBloc>().add(OtpChanged(value)),
                    errorText: state.rtaOtpError != null &&
                            state.rtaOtpError!.isNotEmpty
                        ? state.rtaOtpError
                        : null,
                  );
                },
              ),

              const Spacer(),

              // Submit + Resend Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CButton(
                    text: "submitComplete".tr,
                    type: ButtonType.primaryWhite,
                    isLoading: _isSubmitting,
                    suffixIcon: _isSubmitting
                        ? null
                        : const Icon(
                            Icons.arrow_forward,
                            color: AppColors.black,
                            size: 18,
                          ),
                    onPressed:
                        (_isSubmitting || _otpController.text.trim().isEmpty)
                            ? null
                            : () {
                                _submitOtp();
                              },
                  ),
                  Gaps.hXs,
                  GestureDetector(
                    onTap: _isSubmitting
                        ? null
                        : () {
                            final bloc = context.read<EligibilityBloc>();
                            if (!bloc.isClosed) {
                              bloc.add(const ResendOtp());
                            }
                          },
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "NoCode?".tr,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.bSecondaryColor,
                            ),
                          ),
                          TextSpan(
                            text: "ResendOTP".tr,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.bPrimaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Gaps.hXs,
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
