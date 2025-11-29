import 'package:flutter/material.dart';
import 'package:las_app/common_widgets/c_text.dart';
import 'package:las_app/core/theme/app_colors.dart';
import 'package:las_app/core/theme/app_typography.dart';
import 'package:las_app/features/home/view_home.dart';

class InsuranceSuccessScreen extends StatelessWidget {
  const InsuranceSuccessScreen({super.key});

  void _goHome(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const Home()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,

      /// 🔥 Allow content to scroll
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [

              const SizedBox(height: 180),

              /// Success Icon
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: Image.asset(
                  'assets/images/successPledge.png',
                  width: 180,
                  height: 180,
                ),
              ),

              const SizedBox(height: 26),

              CText(
                "Thank You!",
                style: AppTypography.h2.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 10),

              CText(
                "Your documents are submitted successfully and will be reviewed shortly for loan application.",
                style: AppTypography.bodySecondary.copyWith(
                  color: Colors.white,
                  fontSize: 17,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 180),

              /// CTA Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => _goHome(context),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CText(
                        "Explore More",
                        style: AppTypography.buttonPrimary.copyWith(
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_right_alt, color: Colors.black),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              /// Powered By
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CText(
                    "Powered by ",
                    style: AppTypography.caption.copyWith(color: Colors.grey),
                  ),
                  Image.asset(
                    'assets/images/value_enable_logo.png',
                    height: 18,
                  ),
                ],
              ),

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
