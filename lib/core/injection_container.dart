import 'package:get_it/get_it.dart';
import 'package:las_app/core/network/api_client.dart';
import 'package:las_app/core/app_state_provider.dart';
import 'package:las_app/features/login/repository/login_repository.dart';
import 'package:las_app/features/new_user/repository/pan_veirfy_repo.dart';

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
}
