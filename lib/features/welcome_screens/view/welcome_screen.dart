import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:las_app/features/login/view/login_screen.dart';
import 'welcome_view.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  bool _isLastPage = false;

  static  List<Map<String, String>> onboardingPages = [
   {
      "image": "assets/images/welcome_one.png",
      "iconAsset": "assets/icons/compass.png",
      "subtitle": 'welcome1_subtitle'.tr, // <-- CHANGED
      "title": 'welcome1_title'.tr, // <-- CHANGED
    },
    {
      "image": "assets/images/welcome_two.png",
      "iconAsset": "assets/icons/bar.png",
      "subtitle": 'welcome2_subtitle'.tr, // <-- CHANGED
      "title": 'welcome2_title'.tr, // <-- CHANGED
    },
    {
      "image": "assets/images/welcome_three.png",
      "iconAsset": "assets/icons/lock.png",
      "subtitle": 'welcome3_subtitle'.tr, // <-- CHANGED
      "title": 'welcome3_title'.tr, // <-- CHANGED
    },
  ];
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _isLastPage = page == onboardingPages.length - 1;
    });
  }

  void _skip() {
Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );  }

  void _next() {
    if (_isLastPage) {
      _skip();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WelcomeView(
      pageController: _pageController,
      onPageChanged: _onPageChanged,
      onboardingPages: onboardingPages,
      isLastPage: _isLastPage,
      onSkip: _skip,
      onNext: _next,
    );
  }
}
