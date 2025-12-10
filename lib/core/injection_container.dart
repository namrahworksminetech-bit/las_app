import 'package:get_it/get_it.dart';
import 'package:las_app/core/network/api_client.dart';
import 'package:las_app/core/app_state_provider.dart';
import 'package:las_app/features/login/repository/login_repository.dart';
import 'package:las_app/features/new_user/repository/insurance_repo.dart';
import 'package:las_app/features/new_user/repository/pan_veirfy_repo.dart';
import 'package:las_app/features/new_user/digio_service.dart';
import 'package:las_app/features/portfolio/repository/statement_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;

Future<void> initDependencies() async {
  // ✅ Core singletons
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());
  getIt.registerLazySingleton<AppStateProvider>(() => AppStateProvider());


  // ✅ Feature repositories
  getIt.registerLazySingleton<LoginRepository>(
      () => LoginRepository(getIt<ApiClient>()));
  getIt.registerLazySingleton<PanRepository>(
      () => PanRepository(getIt<ApiClient>()));
        getIt.registerLazySingleton<InsuranceRepository>(() => InsuranceRepository());
  final prefs = await SharedPreferences.getInstance();
  final savedMobile = prefs.getString("mobile_number");
  final savedToken  = prefs.getString("auth_token");

  if (savedMobile != null) getIt<AppStateProvider>().setMobileNumber(savedMobile);
  if (savedToken != null) getIt<AppStateProvider>().setToken(savedToken);
  
  // ✅ Services
  getIt.registerLazySingleton<DigioService>(() => DigioService());
}
