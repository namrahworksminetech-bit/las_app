import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:las_app/features/new_user/bloc/eligibility_bloc.dart';
import 'package:las_app/features/welcome_screens/view/welcome_screen.dart';
import 'core/theme/app_theme.dart';
import 'localization/localization_service.dart';

class SliqApp extends StatelessWidget {
  const SliqApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'sdddddddLiQ'.tr,
      debugShowCheckedModeBanner: false,
      translations: LocalizationService(),
      locale: const Locale('en', 'US'),
      fallbackLocale: const Locale('en', 'US'),
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: BlocProvider(
    create: (_) => EligibilityBloc(),
    child: const WelcomeScreen(),
  ),
    );
  }
}
