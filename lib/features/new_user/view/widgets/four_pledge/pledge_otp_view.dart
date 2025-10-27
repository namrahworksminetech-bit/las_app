import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:las_app/common_widgets/c_button.dart';
import 'package:las_app/common_widgets/c_input.dart';
import 'package:las_app/core/theme/app_colors.dart';
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
              const SizedBox(height: 24),

              Row(
                children: [
                  CircularPercentIndicator(
                    radius: 35.0,
                    lineWidth: 8.0,
                    percent: 1.0,
                    center: const Text(
                      "4/4",
                      style: TextStyle(
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
                        'Pledge Funds',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Next: Application Submission',
                        style: TextStyle(
                          color: AppColors.bSecondaryColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),
              const Divider(thickness: 1.5, color: AppColors.bSecondaryColor),
              const SizedBox(height: 16),

              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Row(
                  children: [
                    Icon(Icons.arrow_back, color: AppColors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Go Back',
                      style: TextStyle(color: AppColors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'OTP sent from MFCentral to your registered mobile number ending with XX45',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 20),

              BlocBuilder<EligibilityBloc, EligibilityState>(
                builder: (context, state) {
                  otpController.text = state.otp;
                  otpController.selection = TextSelection.fromPosition(
                    TextPosition(offset: otpController.text.length),
                  );

                  return CInput(
                    labelText: "Enter 6-digit OTP",
                    hintText: '******',
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    onChanged: (value) =>
                        context.read<EligibilityBloc>().add(OtpChanged(value)),
                    errorText: state.otpError
                        ? "Invalid OTP. Try again."
                        : null,
                  );
                },
              ),

              const Spacer(),

              BlocBuilder<EligibilityBloc, EligibilityState>(
                builder: (context, state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CButton(
                        text: "Submit & Complete Application",
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
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: state.isSubmitting
                            ? null
                            : () => context.read<EligibilityBloc>().add(
                                const ResendOtp(),
                              ),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Didn't receive the code? ",
                                style: const TextStyle(
                                  color: AppColors.bSecondaryColor,
                                  fontSize: 14,
                                ),
                              ),
                              TextSpan(
                                text: "Resend OTP",
                                style: const TextStyle(
                                  color: AppColors.bPrimaryColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
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
