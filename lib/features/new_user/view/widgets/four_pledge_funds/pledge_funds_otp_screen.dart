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

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }



  @override
  void initState() {
    super.initState();
    _otpController.addListener(() {
      if (!mounted) return;
      context.read<EligibilityBloc>().add(OtpChanged(_otpController.text));
    });
    context.read<EligibilityBloc>().add(const FetchPledgePhoneNumber());
  }

  void _submitOtp(BuildContext context, EligibilityState state) {
    final otp = _otpController.text.trim();
    if (otp.isEmpty || otp.length < 4) return;

    final phone = state.pledgePhoneNumber ?? widget.mobileNumber ?? '';
    if (phone.isEmpty || phone.contains('*')) return;

    context.read<EligibilityBloc>().add(SubmitPledgeOtp(otp: otp, phone: phone));
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
    return MultiBlocListener(
      listeners: [
        BlocListener<EligibilityBloc, EligibilityState>(
          listenWhen: (prev, curr) => 
              !prev.pledgeOtpSubmitting && curr.pledgeOtpSubmitting == false && prev.rtaOtpError != curr.rtaOtpError && curr.rtaOtpError == null,
          listener: (context, state) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoanSuccessScreen()),
            );
          },
        ),
        BlocListener<EligibilityBloc, EligibilityState>(
          listenWhen: (prev, curr) => prev.pledgePhoneNumber != curr.pledgePhoneNumber && curr.pledgePhoneNumber != null,
          listener: (context, state) {
            Get.snackbar(
              'OTP Sent',
              'OTP sent to ${state.pledgePhoneNumber}',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppColors.bPrimaryColor,
              colorText: Colors.white,
              duration: const Duration(seconds: 2),
            );
          },
        ),
      ],
      child: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return BlocBuilder<EligibilityBloc, EligibilityState>(
      builder: (context, state) {
        final canSubmit = state.otp.trim().isNotEmpty && 
            state.pledgeChecked && 
            (state.pledgePhoneNumber != null || widget.mobileNumber != null);

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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CText('pledgeFunds'.tr, style: AppTypography.h2),
                        Gaps.hXxs,
                        CText(
                          'nextApplicationSubmission'.tr,
                          style: AppTypography.bodySecondary,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
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
              CText(
                'otpSentMessage'.tr,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.white,
                  height: 1.4,
                ),
              ),
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
                    errorText:
                        state.rtaOtpError != null &&
                            state.rtaOtpError!.isNotEmpty
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
                    suffixIcon: state.pledgeOtpSubmitting
                        ? null
                        : const Icon(
                            Icons.arrow_forward,
                            color: AppColors.black,
                            size: 18,
                          ),
                    onPressed: canSubmit ? () => _submitOtp(context, state) : null,
                    isLoading: state.pledgeOtpSubmitting,
                  ),
                  Gaps.hXs,
                  GestureDetector(
                    onTap: state.pledgeOtpSubmitting
                        ? null
                        : () {
                            context.read<EligibilityBloc>().add(const FetchPledgePhoneNumber());
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
      },
    );
  }
}
