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
import 'package:las_app/core/network/api_client.dart';
import 'package:las_app/core/theme/app_colors.dart';
import 'package:las_app/core/theme/app_spacing.dart';
import 'package:las_app/core/theme/app_typography.dart';
import 'package:las_app/features/home/view_home.dart';
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

  // class-level AppStateProvider (do not shadow locally)
  final AppStateProvider appState = GetIt.instance<AppStateProvider>();

  final RtaRepository _rtaRepo = RtaRepository();
  final PledgeStatusRepository _pledgeStatusRepository = PledgeStatusRepository();

  // Prevent submitting before pledge check finished and phone saved
  bool _pledgeChecked = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _submitOtp() async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty || otp.length < 4) {
      if (!mounted) return;
      Get.snackbar('Error', 'Please enter a valid OTP');
      return;
    }

    // DEBUG: log values used for submission
    debugPrint(
        '🔎 _submitOtp: widget.mobileNumber=${widget.mobileNumber}, appState.mobileNumber=${appState.mobileNumber}, _pledgeChecked=$_pledgeChecked');

    // Ensure pledge check finished
    if (!_pledgeChecked) {
      if (!mounted) return;
      Get.snackbar('Please wait', 'Still fetching OTP destination — try again in a moment');
      debugPrint('Submit blocked: pledge check not completed');
      return;
    }

   var phone = (widget.mobileNumber != null && widget.mobileNumber!.isNotEmpty)
    ? widget.mobileNumber!
    : (appState.mobileNumber ?? '');
    if (phone.isEmpty) {
      if (!mounted) return;
      Get.snackbar('Error', 'Phone number not available');
      debugPrint('Submit failed: phone empty');
      return;
    }


    if (phone.contains('*')) {
      if (!mounted) return;
      Get.snackbar('Error', 'Phone number is masked. Use the original phone to verify OTP.');
      debugPrint('Attempt to submit OTP with masked phone: $phone');
      return;
    }


    phone = phone.replaceAll(RegExp(r'[\s\-]'), '');
    if (!phone.startsWith('+')) {
      phone = phone.startsWith('91') ? '+$phone' : '+91$phone';
    }

    debugPrint('Using phone for verify: $phone');

    if (appState.token == null || appState.token!.isEmpty) {
      if (!mounted) return;
      Get.snackbar('Error', 'Authorization token missing');
      return;
    }
    if (appState.reqId == null || appState.reqId!.isEmpty) {
      if (!mounted) return;
      Get.snackbar('Error', 'reqId missing');
      return;
    }

    setState(() => _isSubmitting = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Get.snackbar('Please wait', 'Verifying OTP...');
    });

    try {
      final returnedReqId = await _rtaRepo.verifyRtaOtp(
        phone: phone,
        otp: otp,
      );

      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar('Success', 'OTP verified successfully');
      });

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoanSuccessScreen()),
      );
    } on DioException catch (e) {
      if (!mounted) return;
      if (e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionTimeout) {
        Get.snackbar('Error', 'Server down, please try again later');
      } else {
        final errMsg = e.response?.data?['message'] ?? e.message ?? 'Network error';
        Get.snackbar('Error', errMsg);
      }
    } catch (e) {
      if (mounted) Get.snackbar('Error', e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void initState() {
    super.initState();


    _otpController.addListener(() {
      if (!mounted) return;
    
      setState(() {});
    });

    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _callPledgeStatusApi();
    });
  }

  Future<void> _callPledgeStatusApi() async {
    try {
      final reqId = appState.reqId;
      final token = appState.token;

      if (reqId == null || reqId.isEmpty) {
        debugPrint('[PledgeStatus] skipped: reqId is null/empty');
        return;
      }
      if (token == null || token.isEmpty) {
        debugPrint('[PledgeStatus] skipped: token is null/empty');
        return;
      }

      debugPrint('[PledgeStatus] calling API with reqId=$reqId');

      final result = await _pledgeStatusRepository.checkPledgeMfStatus(
        reqId: reqId,
        type: "pledge",
        authToken: token,
      );

      result.when(
        success: (data) {
          debugPrint("Pledge Status Success (raw): $data");

          try {
            // robust extraction: data['data'] might be Map or List or nested
            String? phoneFromResp;
            final inner = data['data'];

            if (inner is List && inner.isNotEmpty) {
              final first = inner[0];
              if (first is Map && first['phone'] != null) {
                phoneFromResp = first['phone'].toString();
              }
            } else if (inner is Map && inner['data'] is List && (inner['data'] as List).isNotEmpty) {
              final first = (inner['data'] as List)[0];
              if (first is Map && first['phone'] != null) phoneFromResp = first['phone'].toString();
            } else if (inner is Map && inner['phone'] != null) {
              phoneFromResp = inner['phone'].toString();
            }

            debugPrint('Parsed phoneFromResp: $phoneFromResp');

            if (phoneFromResp == null || phoneFromResp.isEmpty) {
              debugPrint('No phone found in pledge response; skipping save.');
              // mark that we've completed check even if no phone (so user isn't blocked forever)
              _pledgeChecked = true;
              setState(() {});
            } else if (phoneFromResp.contains('*')) {
              debugPrint('Phone is masked; not saving to AppState: $phoneFromResp');
              if (mounted) {
                Get.snackbar(
                  'Note',
                  'OTP sent to a masked number. If verification fails, use the original phone.',
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 4),
                );
              }
              // still mark pledge checked (we know check completed but phone masked)
              _pledgeChecked = true;
              setState(() {});
            } else {
              // normalize: remove spaces/hyphens, ensure +91 prefix
              var normalized = phoneFromResp.replaceAll(RegExp(r'[\s\-]'), '');
              if (!normalized.startsWith('+')) {
                normalized = normalized.startsWith('91') ? '+$normalized' : '+91$normalized';
              }

              // save into AppState
              appState.setMobileNumber(normalized);
              _pledgeChecked = true;
              setState(() {});
              debugPrint('✅ Saved phone into AppState.mobileNumber: $normalized');

              if (mounted) {
                Get.snackbar(
                  'Info',
                  'OTP sent to $normalized',
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 2),
                );
              }
            }
          } catch (e, st) {
            debugPrint('Error parsing/saving phone from pledge response: $e\n$st');
            // mark checked to avoid blocking user forever
            _pledgeChecked = true;
            setState(() {});
          }
        },
        failure: (error) {
          debugPrint("Pledge Status Failure: $error");
          // mark checked to avoid blocking submit forever
          _pledgeChecked = true;
          setState(() {});
        },
      );
    } catch (e, st) {
      debugPrint('PledgeStatus API error: $e\n$st');
      _pledgeChecked = true;
      if (mounted) setState(() {});
    }
  }
Future<bool> _showExitConfirmDialog() async {
  final res = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: const Text("Exit Application?"),
        content: const Text(
          "Are you sure you want to exit this step and go back to the Dashboard?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Confirm"),
          ),
        ],
      );
    },
  );
  return res ?? false;
}

  @override
  Widget build(BuildContext context) {
    final bool canSubmit = !_isSubmitting &&
        _otpController.text.trim().isNotEmpty &&
        _pledgeChecked &&
        (widget.mobileNumber != null && widget.mobileNumber!.isNotEmpty || (appState.mobileNumber != null && appState.mobileNumber!.isNotEmpty));

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Gaps.hXs,
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
                      CText('pledgeFunds'.tr, style: AppTypography.h2),
                      Gaps.hXxs,
                      CText('nextApplicationSubmission'.tr,
                          style: AppTypography.bodySecondary),
                    ],
                  ),
                ],
              ),
              Gaps.hXl,
              const Divider(thickness: 1.5, color: AppColors.bSecondaryColor),
              Gaps.hMd,
             GestureDetector(
  onTap: () async {
    final shouldExit = await _showExitConfirmDialog();
    if (shouldExit) {
      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => Home()),
        (route) => false,
      );
    }
  },
  child: Row(
    children: [
      const Icon(Icons.arrow_back, color: AppColors.white, size: 20),
      Gaps.wXs,
      CText('goBack'.tr,
          style: AppTypography.bodySmall.copyWith(color: AppColors.white)),
    ],
  ),
),

              Gaps.hXs,
              CText('otpSentMessage'.tr,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.white,
                    height: 1.4,
                  )),
              Gaps.hXs,
              BlocBuilder<EligibilityBloc, EligibilityState>(
                builder: (context, state) {
                  // Only update controller if changed (prevents loops)
                  if (_otpController.text != state.otp) {
                    _otpController.text = state.otp;
                    _otpController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _otpController.text.length),
                    );
                  }
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
                    errorText: state.rtaOtpError != null && state.rtaOtpError!.isNotEmpty
                        ? state.rtaOtpError
                        : null,
                  );
                },
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CButton(
                    text: "submitComplete".tr,
                    type: ButtonType.primaryWhite,
                    isLoading: _isSubmitting,
                    suffixIcon: _isSubmitting
                        ? null
                        : const Icon(Icons.arrow_forward, color: AppColors.black, size: 18),
                    onPressed: canSubmit ? _submitOtp : null,
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
