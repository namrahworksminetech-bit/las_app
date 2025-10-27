import 'package:flutter/material.dart';
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

  static const List<Map<String, String>> onboardingPages = [
    {
      "image": "assets/images/welcome_one.png",
      "iconAsset": "assets/icons/compass.png",
      "subtitle": "Unlock Funds Instantly",
      "title":
          "Get Easy, Fast, & secured loans without selling your investments.",
    },
    {
      "image": "assets/images/welcome_two.png",
      "iconAsset": "assets/icons/bar.png",
      "subtitle": "Smart & Transparent Borrowing",
      "title": "Competitive Rates. Flexible. Transparent.",
    },
    {
      "image": "assets/images/welcome_three.png",
      "iconAsset": "assets/icons/lock.png",
      "subtitle": "Keep Your Assets, Unlock Value",
      "title": "Liquidate funds while your investments continue to grow.",
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
