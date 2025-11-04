import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:las_app/core/network/api_client.dart';
import 'package:las_app/features/new_user/bloc/eligibility_bloc.dart';
import 'package:las_app/features/new_user/repository/lenders_data_repo.dart';
import 'package:las_app/features/new_user/repository/pan_veirfy_repo.dart';
import 'package:las_app/features/new_user/view/widgets/two_lender_selection/lender_selection.dart';
import 'package:las_app/features/welcome_screens/view/welcome_screen.dart';
import 'core/theme/app_theme.dart';
import 'localization/localization_service.dart';

final getIt = GetIt.instance;

class SliqApp extends StatelessWidget {
  const SliqApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'sLiQ'.tr,
      debugShowCheckedModeBanner: false,
      translations: LocalizationService(),
      locale: const Locale('en', 'US'),
      fallbackLocale: const Locale('en', 'US'),
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: BlocProvider(
        create: (_) => EligibilityBloc(
          lenderRepository: LenderRepository(getIt<ApiClient>()),
          repository: PanRepository(getIt<ApiClient>()),
        ),
        // child: const WelcomeScreen(),
        child: const WelcomeScreen(),
      ),
    );
  }
}
