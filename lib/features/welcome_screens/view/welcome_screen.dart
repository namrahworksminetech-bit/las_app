import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:las_app/features/home/view_home.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  static const _kTokenKey = 'auth_token';
  static const _kReqIdKey = 'req_id';
  static const _kTokenSavedAtKey = 'token_saved_at_ms';
  static const Duration _kTokenExpiry = Duration(minutes: 30);

  List<Map<String, String>> get _onboardingPages => [
        {
          "image": "assets/images/welcome_one.png",
          "iconAsset": "assets/icons/compass.png",
          "subtitle": 'welcome1_subtitle'.tr,
          "title": 'welcome1_title'.tr,
        },
        {
          "image": "assets/images/welcome_two.png",
          "iconAsset": "assets/icons/bar.png",
          "subtitle": 'welcome2_subtitle'.tr,
          "title": 'welcome2_title'.tr,
        },
      ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _isLastPage = page == _onboardingPages.length - 1;
    });
  }

  /// Called when user taps Skip or taps Next on last page.
  Future<void> _handleProceed() async {
    final shouldGoToHome = await _hasValidTokenAndReqId();
    if (shouldGoToHome) {
      // navigate to home (Dashboard)
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const  Home()),
      );
    } else {
      // navigate to login
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  Future<bool> _hasValidTokenAndReqId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_kTokenKey);
      final reqId = prefs.getString(_kReqIdKey);
      final savedAtMs = prefs.getInt(_kTokenSavedAtKey);

      if (token == null || token.isEmpty) return false;
      if (reqId == null || reqId.isEmpty) return false;
      if (savedAtMs == null) return false;

      final savedAt = DateTime.fromMillisecondsSinceEpoch(savedAtMs);
      final now = DateTime.now();
      final age = now.difference(savedAt);

      // Token valid if age < expiry
      if (age < _kTokenExpiry) return true;

      // token expired -> optionally remove it
      await prefs.remove(_kTokenKey);
      await prefs.remove(_kReqIdKey);
      await prefs.remove(_kTokenSavedAtKey);
      return false;
    } catch (e) {
      debugPrint('Error checking saved token: $e');
      return false;
    }
  }

  void _skip() {
    _handleProceed();
  }

  void _next() {
    if (_isLastPage) {
      _handleProceed();
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
      onboardingPages: _onboardingPages,
      isLastPage: _isLastPage,
      onSkip: _skip,
      onNext: _next,
    );
  }
}
