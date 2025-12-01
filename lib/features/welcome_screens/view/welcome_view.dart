import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Import GetX for localization
import 'package:las_app/core/theme/app_colors.dart';
import 'package:las_app/core/theme/app_spacing.dart';

import 'package:las_app/features/welcome_screens/view/widgets/on_boarding_widget.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../common_widgets/c_button.dart';

class WelcomeView extends StatelessWidget {
  final PageController pageController;
  final ValueChanged<int> onPageChanged;
  final List<Map<String, String>> onboardingPages;
  final bool isLastPage;
  final VoidCallback onSkip;
  final VoidCallback onNext;

  const WelcomeView({
    super.key,
    required this.pageController,
    required this.onPageChanged,
    required this.onboardingPages,
    required this.isLastPage,
    required this.onSkip,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    // Check current language to display the *other* language on the button
    final bool isEnglish = Get.locale?.languageCode == 'en';
    final String buttonText = isEnglish ? 'हिंदी' : 'English';

    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        // Wrap the body in a Stack to overlay the language button
        child: Stack(
          children: [
            // --- Main Content ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  Expanded(
                    flex: 5,
                    child: Stack(
                      children: [
                        PageView.builder(
                          controller: pageController,
                          onPageChanged: onPageChanged,
                          itemCount: onboardingPages.length,
                          itemBuilder: (context, index) {
                            final page = onboardingPages[index];
                            return OnboardingPageContent(
                              imagePath: page["image"]!,
                              iconAssetPath: page["iconAsset"]!,
                              subtitle: page["subtitle"]!,
                              title: page["title"]!,
                            );
                          },
                        ),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            child: SmoothPageIndicator(
                              controller: pageController,
                              count: onboardingPages.length,
                              effect: const ExpandingDotsEffect(
                                activeDotColor: AppColors.bPrimaryColor,
                                dotColor: AppColors.kIndicatorInactiveColor,
                                dotHeight: 8,
                                dotWidth: 8,
                                spacing: 6,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Row(
                      children: [
                        const Spacer(),
                        SizedBox(
                          width: 90,
                          child: CButton(
                            text: "Skip".tr,
                            onPressed: onSkip,
                            type: ButtonType.secondary,
                          ),
                        ),
                        Gaps.wMd,
                        SizedBox(
                          width: 130,
                          child: CButton(
                            text: isLastPage ? "GetStarted".tr : "Next".tr,
                            onPressed: onNext,
                            suffixIcon: isLastPage
                                ? null
                                : const Icon(Icons.arrow_forward, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Row(children: [const Spacer()]),
                  ),
                ],
              ),
            ),

            // --- Language Switch Button (Overlay) ---
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0), // Padding from screen edge
                child: TextButton(
                  onPressed: () {
                    // Switch locale logic
                    if (isEnglish) {
                      Get.updateLocale(const Locale('hi', 'IN'));
                    } else {
                      Get.updateLocale(const Locale('en', 'US'));
                    }
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    buttonText,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            // --- End Language Button ---
          ],
        ),
      ),
    );
  }
}
