import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:las_app/common_widgets/c_text.dart';
import 'package:las_app/core/theme/app_colors.dart';
import 'package:las_app/core/theme/app_spacing.dart';
import 'package:las_app/core/theme/app_typography.dart';
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
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Padding(
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
                          effect: ExpandingDotsEffect(
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
                            : const Icon(
                                Icons.arrow_forward,
                                size: 18,
                              ),
                      ),
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
