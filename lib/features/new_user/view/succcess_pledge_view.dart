import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:las_app/core/theme/app_colors.dart';
import 'package:las_app/core/theme/app_spacing.dart';
import 'package:las_app/core/theme/app_typography.dart';
import 'package:las_app/common_widgets/c_text.dart';

class LoanSuccessScreen extends StatefulWidget {
  const LoanSuccessScreen({super.key});

  @override
  State<LoanSuccessScreen> createState() => _LoanSuccessScreenState();
}

class _LoanSuccessScreenState extends State<LoanSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _tickController;
  late AnimationController _confettiController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _tickController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _tickController,
      curve: Curves.easeOutBack,
    );

    _tickController.forward();
    _confettiController.repeat();
  }

  @override
  void dispose() {
    _tickController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              /// ✅ Success Image
              ScaleTransition(
                scale: _scaleAnimation,
                child: Image.asset(
                  'assets/images/successPledge.png',
                  width: 140,
                  height: 140,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: Gaps.xl),

              /// ✅ Title
              CText(
                "congratulations".tr,
                style: AppTypography.h2.copyWith(color: AppColors.white),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: Gaps.sm),

              /// ✅ Subtitle
              CText(
                "loanSuccessMessage".tr,
                style: AppTypography.bodySecondary.copyWith(
                  color: const Color(0xFFB0B0B0),
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              /// ✅ Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    // TODO: Navigate to dashboard
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CText(
                        'goToDashboard'.tr,
                        style: AppTypography.buttonPrimary,
                      ),
                      const SizedBox(width: Gaps.xs),
                      const Icon(
                        Icons.arrow_right_alt,
                        color: AppColors.black,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: Gaps.md),

              /// ✅ Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CText(
                    "Powered by ",
                    style: AppTypography.caption.copyWith(
                      color: const Color(0xFF888888),
                    ),
                  ),
                  Image.asset(
                    'assets/images/value_enable_logo.png',
                    height: 18,
                    fit: BoxFit.contain,
                  ),
                ],
              ),

              const SizedBox(height: Gaps.lg),
            ],
          ),
        ),
      ),
    );
  }
}
