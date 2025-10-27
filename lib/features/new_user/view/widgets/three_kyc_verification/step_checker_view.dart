import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:las_app/common_widgets/c_button.dart';
import 'package:las_app/core/theme/app_colors.dart';
import 'package:las_app/features/new_user/bloc/eligibility_bloc.dart';
import 'package:las_app/features/new_user/view/widgets/four_pledge/pledge_otp_view.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class KycVerificationScreen extends StatelessWidget {
  const KycVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> steps = [
      "Fill your basic info",
      "Aadhar and PAN verification",
      "Link account & set mandate",
      "Loan agreement signing",
    ];

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
                    percent: 3 / 4.0,
                    center: const Text(
                      "3/4",
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
                        'KYC Verification',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Next: Pledge Funds',
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
                'Verify details to proceed securely',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Safe & Secure • Your data is encrypted',
                style: TextStyle(
                  color: AppColors.bSecondaryColor,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 24),

              Expanded(
                child: BlocBuilder<EligibilityBloc, EligibilityState>(
                  builder: (context, state) {
                    final checks = state.kycStepChecks;

                    return ListView.separated(
                      itemCount: steps.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final isChecked = checks[index];

                        return GestureDetector(
                          onTap: () {
                            context.read<EligibilityBloc>().add(
                              ToggleKycStep(index),
                            );
                          },
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
                                    const SizedBox(width: 12),
                                    Text(
                                      steps[index],
                                      style: const TextStyle(
                                        color: AppColors.white,
                                        fontSize: 14,
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

              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CButton(
                      text: 'Proceed to Final Step',
                      onPressed: () {
                        final bloc = context.read<EligibilityBloc>();

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: bloc,
                              child: const PledgeFundsOtpScreen(),
                            ),
                          ),
                        );
                      },
                      type: ButtonType.primaryWhite,
                      suffixIcon: const Icon(
                        Icons.arrow_forward,
                        color: AppColors.black,
                        size: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Powered by',
                          style: TextStyle(
                            color: AppColors.bSecondaryColor,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
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
