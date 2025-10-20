import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/theme/app_theme.dart';
import 'localization/localization_service.dart';
import 'feature_demo/view/demo_screen.dart';

class SliqApp extends StatelessWidget {
  const SliqApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SLiQ',
      debugShowCheckedModeBanner: false,
      translations: LocalizationService(),
      locale: const Locale('en', 'US'),
      fallbackLocale: const Locale('en', 'US'),
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const DemoScreen(),
    );
  }
}
