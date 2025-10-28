import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:las_app/common_widgets/c_button.dart';
import 'package:las_app/common_widgets/c_input.dart';
import 'package:las_app/common_widgets/c_text.dart';
import 'package:las_app/core/theme/app_colors.dart';
import 'package:las_app/core/theme/app_spacing.dart';
import 'package:las_app/core/theme/app_typography.dart';
import 'package:las_app/features/new_user/bloc/eligibility_bloc.dart';
import 'package:las_app/features/new_user/view/succcess_pledge_view.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class PledgeFundsOtpScreen extends StatelessWidget {
  const PledgeFundsOtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final otpController = TextEditingController();

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
              Row(
                children: [
                  CircularPercentIndicator(
                    radius: 35.0,
                    lineWidth: 8.0,
                    percent: 1.0,
                    center: CText(
                      "4/4",
                      style: AppTypography.bodyMedium
                          .copyWith(color: AppColors.white),
                    ),
                    progressColor: AppColors.bPrimaryColor,
                    backgroundColor: AppColors.bSecondaryColor,
                    circularStrokeCap: CircularStrokeCap.round,
                  ),
                  Gaps.wXs,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CText(
                        'pledgeFunds'.tr,
                        style: AppTypography.h4
                            .copyWith(color: AppColors.white),
                      ),
                      Gaps.hXs,
                      CText(
                        'nextApplicationSubmission'.tr,
                        style: AppTypography.caption
                            .copyWith(color: AppColors.bSecondaryColor),
                      ),
                    ],
                  ),
                ],
              ),

              Gaps.hXl,
              const Divider(thickness: 1.5, color: AppColors.bSecondaryColor),
              Gaps.hXs,

              // Back Navigation
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_back,
                        color: AppColors.white, size: 20),
                    Gaps.wXs,
                    CText('goBack'.tr,
                        style: AppTypography.bodySmall
                            .copyWith(color: AppColors.white)),
                  ],
                ),
              ),

              Gaps.hXs,

              // OTP Message
              CText(
                'otpSentMessage'.tr,
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.white, height: 1.4),
              ),

              Gaps.hXs,

              // OTP Input
              BlocBuilder<EligibilityBloc, EligibilityState>(
                builder: (context, state) {
                  otpController.text = state.otp;
                  otpController.selection = TextSelection.fromPosition(
                    TextPosition(offset: otpController.text.length),
                  );

                  return CInput(
                    labelText: "EnterOTP".tr,
                    hintText: '******',
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    onChanged: (value) =>
                        context.read<EligibilityBloc>().add(OtpChanged(value)),
                    errorText: state.otpError ? "InvalidOtp".tr : null,
                  );
                },
              ),

              const Spacer(),

              // Submit + Resend Section
              BlocBuilder<EligibilityBloc, EligibilityState>(
                builder: (context, state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CButton(
                        text: "submitComplete".tr,
                        type: ButtonType.primaryWhite,
                        suffixIcon: const Icon(
                          Icons.arrow_forward,
                          color: AppColors.black,
                          size: 18,
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoanSuccessScreen(),
                            ),
                          );
                        },
                      ),
                      Gaps.hXs,
                      GestureDetector(
                        onTap: state.isSubmitting
                            ? null
                            : () => context
                                .read<EligibilityBloc>()
                                .add(const ResendOtp()),
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
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
