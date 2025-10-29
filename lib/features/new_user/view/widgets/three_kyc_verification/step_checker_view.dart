import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:las_app/common_widgets/c_button.dart';
import 'package:las_app/common_widgets/c_text.dart';
import 'package:las_app/core/theme/app_colors.dart';
import 'package:las_app/core/theme/app_typography.dart';
import 'package:las_app/core/theme/app_spacing.dart';
import 'package:las_app/features/new_user/bloc/eligibility_bloc.dart';
import 'package:las_app/features/new_user/view/succcess_pledge_view.dart';
import 'package:las_app/features/new_user/view/widgets/four_pledge/pledge_otp_view.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class KycVerificationScreen extends StatelessWidget {
  const KycVerificationScreen({super.key});

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
              const Divider(thickness: 1.5, color: AppColors.bSecondaryColor),
              Gaps.hMd,

              // ===== Back Button =====
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_back,
                        color: AppColors.white, size: 20),
                    Gaps.wSm,
                    CText(
                      'goBack'.tr,
                      style: AppTypography.bodyWhite,
                    ),
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
              CText(
                'safeSecure'.tr,
                style: AppTypography.caption,
              ),

              Gaps.hXl,

              // ===== Step List =====
              Expanded(
                child: BlocBuilder<EligibilityBloc, EligibilityState>(
                  builder: (context, state) {
                    final checks = state.kycStepChecks;

                    return ListView.separated(
                      itemCount: steps.length,
                      separatorBuilder: (_, __) => Gaps.hSm,
                      itemBuilder: (context, index) {
                        final isChecked = checks[index];

                        return GestureDetector(
                          onTap: () => context
                              .read<EligibilityBloc>()
                              .add(ToggleKycStep(index)),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1C1C1C),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: AppColors.bSecondaryColor.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
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
                                          ? const Icon(Icons.check,
                                              size: 16, color: Colors.black)
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
                    CButton(
                      text: 'proceedToFinalStep'.tr,
                      onPressed: () {
                        final bloc = context.read<EligibilityBloc>();
                       Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (context) => const LoanSuccessScreen()),
);

                      },
                      type: ButtonType.primaryWhite,
                      suffixIcon: const Icon(
                        Icons.arrow_forward,
                        color: AppColors.black,
                        size: 18,
                      ),
                    ),
                    Gaps.hSm,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CText(
                          'Powered by',
                          style: AppTypography.caption,
                        ),
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
