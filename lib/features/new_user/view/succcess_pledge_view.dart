// loan_success_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/services.dart';

import 'package:las_app/core/theme/app_colors.dart';
import 'package:las_app/core/theme/app_spacing.dart';
import 'package:las_app/core/theme/app_typography.dart';
import 'package:las_app/common_widgets/c_text.dart';
import 'package:las_app/common_widgets/webview_screen.dart'; 


import 'package:las_app/core/app_state_provider.dart';
import 'package:las_app/features/home/view_home.dart';
import 'package:las_app/features/new_user/repository/video_kyc_repo.dart';
import 'package:url_launcher/url_launcher.dart';

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

  bool _isLoading = false;

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

Future<void> _startVideoKyc() async {
  if (_isLoading) return;

  final appState = GetIt.instance<AppStateProvider>();
  final reqId = appState.reqId;
  if (reqId == null || reqId.isEmpty) {
    Get.snackbar('Error', 'reqId not available');
    return;
  }

  setState(() => _isLoading = true);
  Get.snackbar('Please wait', 'Starting Video KYC...');

  try {
    final repo = VideoKycRepository();
    final urlString = await repo.startVcipApplication(reqId: reqId);

    if (urlString.isEmpty) {
      Get.snackbar('KYC Failed', 'No URL returned from server');
      return;
    }

    final uri = Uri.tryParse(urlString);
    if (uri == null) {
      Get.snackbar('KYC Failed', 'Invalid URL returned');
      return;
    }

    // Try to open externally (default: external application / browser)
   final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication, // <-- FIXED HERE
    );
    if (!launched) {
      // Fallback: try in-app webview (optional) or show error
      Get.snackbar('KYC Failed', 'Could not open link in external browser.');
    } else {
      // Optionally show a success snackbar or wait for the user to complete KYC in external browser
      Get.snackbar('KYC', 'Opened in external browser');
    }
  } catch (e) {
    Get.snackbar('Video KYC Failed', e.toString());
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}

  void _goToDashboard() {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => Home()),
    (route) => false,   // remove all previous routes
  );
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
                  onPressed: _goToDashboard,
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

              // Start Video KYC button (shows spinner when loading)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.bPrimaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isLoading ? null : _startVideoKyc,
                  child: _isLoading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(AppColors.white),
                              ),
                            ),
                            const SizedBox(width: Gaps.sm),
                            CText(
                              "startingKyc".tr,
                              style: AppTypography.buttonPrimary.copyWith(
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        )
                      : CText(
                          "Start Video KYC",
                          style: AppTypography.buttonPrimary.copyWith(
                            color: AppColors.white,
                          ),
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
