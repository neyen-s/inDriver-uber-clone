import 'package:get_it/get_it.dart';
import 'package:indriver_uber_clone/core/network/api_client.dart';
import 'package:indriver_uber_clone/core/network/http_api_client.dart';
import 'package:indriver_uber_clone/core/utils/constants.dart';
import 'package:indriver_uber_clone/src/auth/data/datasource/sign-in/source/sign_in_remote_datasource.dart';
import 'package:indriver_uber_clone/src/auth/data/datasource/sign-up/source/sign_up_remote_datasource.dart';
import 'package:indriver_uber_clone/src/auth/data/repositories/sign_in_repository_impl.dart';
import 'package:indriver_uber_clone/src/auth/data/repositories/sign_up_repository_impl.dart';
import 'package:indriver_uber_clone/src/auth/domain/repository/sign-in/sign_in_repository.dart';
import 'package:indriver_uber_clone/src/auth/domain/repository/sign-up/sign_up_repository.dart';
import 'package:indriver_uber_clone/src/auth/domain/usecase/sign_in_use_case.dart';
import 'package:indriver_uber_clone/src/auth/domain/usecase/sign_up_use_case.dart';
import 'package:indriver_uber_clone/src/auth/presentation/pages/sign-in/bloc/sign_in_bloc.dart';
import 'package:indriver_uber_clone/src/auth/presentation/pages/sign-up/bloc/sign_up_bloc.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  await _initAuth();
}

Future<void> _initAuth() async {
  sl
    ..registerLazySingleton<ApiClient>(
      () => HttpApiClient(baseUrl: API_PROJECT),
    )
    // Data source
    ..registerLazySingleton<SignInRemoteDataSource>(
      () => SignInRemoteDataSourceImpl(apiClient: sl()),
    )
    ..registerLazySingleton<SignUpRemoteDataSource>(
      () => SignUpRemoteDataSourceImpl(apiClient: sl()),
    )
    // Repository
    ..registerLazySingleton<SignInRepository>(
      () => SignInRepositoryImpl(signInRemoteDataSource: sl()),
    )
    ..registerLazySingleton<SignUpRepository>(
      () => SignUpRepositoryImpl(signUpRemoteDataSource: sl()),
    )
    // UseCase
    ..registerLazySingleton(() => SignInUseCase(sl()))
    ..registerLazySingleton(() => SignUpUseCase(sl()))
    // Bloc
    ..registerFactory(() => SignInBloc(sl()))
    ..registerFactory(() => SignUpBloc(sl()));
}
