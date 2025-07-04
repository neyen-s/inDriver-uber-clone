import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:indriver_uber_clone/core/bloc/session-bloc/session_bloc.dart';
import 'package:indriver_uber_clone/core/network/api_client.dart';
import 'package:indriver_uber_clone/core/network/http_api_client.dart';
import 'package:indriver_uber_clone/core/services/app_navigator_service.dart';
import 'package:indriver_uber_clone/core/services/shared_prefs_adapter.dart';
import 'package:indriver_uber_clone/core/utils/constants.dart';
import 'package:indriver_uber_clone/src/auth/data/datasource/source/auth_remote_datasource.dart';
import 'package:indriver_uber_clone/src/auth/data/repositories/auth_repository_impl.dart';
import 'package:indriver_uber_clone/src/auth/domain/repository/auth_repository.dart';
import 'package:indriver_uber_clone/src/auth/domain/usecase/auth_use_cases.dart';
import 'package:indriver_uber_clone/src/auth/domain/usecase/get_user_session_use_case.dart';
import 'package:indriver_uber_clone/src/auth/domain/usecase/save_user_session_use_case.dart';
import 'package:indriver_uber_clone/src/auth/domain/usecase/sign_in_use_case.dart';
import 'package:indriver_uber_clone/src/auth/domain/usecase/sign_out_use_case.dart';
import 'package:indriver_uber_clone/src/auth/domain/usecase/sign_up_use_case.dart';
import 'package:indriver_uber_clone/src/auth/presentation/pages/sign-in/bloc/sign_in_bloc.dart';
import 'package:indriver_uber_clone/src/auth/presentation/pages/sign-up/bloc/sign_up_bloc.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/bloc/client_home_bloc.dart';
import 'package:indriver_uber_clone/src/profile/data/datasource/source/profile_remote_datasource.dart';
import 'package:indriver_uber_clone/src/profile/data/repositories/profile_repository_impl.dart';
import 'package:indriver_uber_clone/src/profile/domain/repository/profile_repository.dart';
import 'package:indriver_uber_clone/src/profile/domain/usecases/update_user_use_case.dart';
import 'package:indriver_uber_clone/src/profile/presentation/pages/info/bloc/profile_info_bloc.dart';
import 'package:indriver_uber_clone/src/profile/presentation/pages/update/bloc/profile_update_bloc.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  await _initCore();
  await _initAuth();
  await _initClient();
  await _initProfile();
}

Future<void> _initCore() async {
  sl
    ..registerLazySingleton<ApiClient>(() => HttpApiClient(baseUrl: apiProject))
    ..registerLazySingleton<SharedPrefsAdapter>(SharedPrefsAdapter.new)
    ..registerLazySingleton<Client>(Client.new)
    ..registerLazySingleton<SessionBloc>(SessionBloc.new)
    ..registerLazySingleton(AppNavigatorService.new);
}

// AUTH

Future<void> _initAuth() async {
  // Data source
  sl
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(apiClient: sl()),
    )
    // Repository
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(authRemoteDataSource: sl()),
    )
    // UseCases
    ..registerLazySingleton<SignInUseCase>(() => SignInUseCase(sl()))
    ..registerLazySingleton<SignUpUseCase>(() => SignUpUseCase(sl()))
    ..registerLazySingleton<GetUserSessionUseCase>(
      () => GetUserSessionUseCase(sl()),
    )
    ..registerLazySingleton<SaveUserSessionUseCase>(
      () => SaveUserSessionUseCase(authRepository: sl()),
    )
    ..registerLazySingleton<SignOutUseCase>(
      () => SignOutUseCase(authRepository: sl()),
    )
    ..registerLazySingleton<AuthUseCases>(
      () => AuthUseCases(
        signInUseCase: sl(),
        signUpUseCase: sl(),
        getUserSessionUseCase: sl(),
        saveUserSessionUseCase: sl(),
        signOutUseCase: sl(),
      ),
    )
    // Bloc
    ..registerFactory(() => SignInBloc(sl()))
    ..registerFactory(() => SignUpBloc(sl()));
}

// CLIENT

Future<void> _initClient() async {
  sl.registerFactory(() => ClientHomeBloc(sl()));
}

// PROFILE

Future<void> _initProfile() async {
  sl
    //data source
    ..registerLazySingleton<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSourceImpl(apiClient: sl()),
    )
    //repository
    ..registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(profileRemoteDataSource: sl()),
    )
    //usecases
    ..registerLazySingleton<UpdateUserUseCase>(() => UpdateUserUseCase(sl()))
    //bloc
    ..registerFactory(() => ProfileInfoBloc(sl()))
    ..registerFactory(() => ProfileUpdateBloc(sl(), sl()));
}
