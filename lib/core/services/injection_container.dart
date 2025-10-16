import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:indriver_uber_clone/core/bloc/session-bloc/session_bloc.dart';
import 'package:indriver_uber_clone/core/bloc/socket-bloc/bloc/socket_bloc.dart';
import 'package:indriver_uber_clone/core/data/datasources/source/client_request_datasource.dart';
import 'package:indriver_uber_clone/core/data/repositories/client_request_repository_impl.dart';
import 'package:indriver_uber_clone/core/data/repositories/geolocator_repository_impl.dart';
import 'package:indriver_uber_clone/core/data/repositories/socket_repository_impl.dart';
import 'package:indriver_uber_clone/core/domain/repositories/client_request_repository.dart';
import 'package:indriver_uber_clone/core/domain/repositories/geolocator_repository.dart';
import 'package:indriver_uber_clone/core/domain/repositories/socket_repository.dart';
import 'package:indriver_uber_clone/core/domain/usecases/client-requests/client_requests_usecases.dart';
import 'package:indriver_uber_clone/core/domain/usecases/client-requests/get_time_and_distance_values_usecase.dart';
import 'package:indriver_uber_clone/core/domain/usecases/create_marker_use_case.dart';
import 'package:indriver_uber_clone/core/domain/usecases/find_position_use_case.dart';
import 'package:indriver_uber_clone/core/domain/usecases/geolocator_use_cases.dart';
import 'package:indriver_uber_clone/core/domain/usecases/get_marker_use_case.dart';
import 'package:indriver_uber_clone/core/domain/usecases/get_position_stream_use_case.dart';
import 'package:indriver_uber_clone/core/domain/usecases/socket/connect_socket_use_case.dart';
import 'package:indriver_uber_clone/core/domain/usecases/socket/disconnect_socket_use_case.dart';
import 'package:indriver_uber_clone/core/domain/usecases/socket/on_socket_message_use_case.dart';
import 'package:indriver_uber_clone/core/domain/usecases/socket/send_socket_message_use_case.dart';
import 'package:indriver_uber_clone/core/domain/usecases/socket/socket_use_cases.dart';
import 'package:indriver_uber_clone/core/network/api_client.dart';
import 'package:indriver_uber_clone/core/network/http_api_client.dart';
import 'package:indriver_uber_clone/core/network/socket_client.dart';
import 'package:indriver_uber_clone/core/services/app_navigator_service.dart';
import 'package:indriver_uber_clone/core/services/location_service.dart';
import 'package:indriver_uber_clone/core/services/map_maker_icon_service.dart';
import 'package:indriver_uber_clone/core/services/secure_storage_adapter.dart';
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
import 'package:indriver_uber_clone/src/client/domain/usecases/create_client_request_use_case.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/client-home/bloc/client_home_bloc.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/map/bloc/client_map_seeker_bloc.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/map/cubit/map_lyfe_cycle_cubit.dart';
import 'package:indriver_uber_clone/src/driver/data/datasource/source/driver_position_datasource.dart';
import 'package:indriver_uber_clone/src/driver/data/datasource/source/driver_trip_request_data_source.dart';
import 'package:indriver_uber_clone/src/driver/data/repositories/driver_position_repository_impl.dart';
import 'package:indriver_uber_clone/src/driver/data/repositories/driver_trip_request_repository_impl.dart';
import 'package:indriver_uber_clone/src/driver/domain/repositories/driver_position_repository.dart';
import 'package:indriver_uber_clone/src/driver/domain/repositories/driver_trip_request_repository.dart';
import 'package:indriver_uber_clone/src/driver/domain/usecases/client-requests/get_nearby_trip_request_use_case.dart';
import 'package:indriver_uber_clone/src/driver/domain/usecases/driver-trip-offers/create_driver_trip_request_use_case.dart';
import 'package:indriver_uber_clone/src/driver/domain/usecases/driver-trip-offers/driver_trip_offers_use_cases.dart';
import 'package:indriver_uber_clone/src/driver/domain/usecases/driver-trip-offers/get_driver_trip_request_use_case.dart';
import 'package:indriver_uber_clone/src/driver/domain/usecases/drivers-position/create_driver_position_usecase.dart';
import 'package:indriver_uber_clone/src/driver/domain/usecases/drivers-position/delete_driver_position_usecase.dart';
import 'package:indriver_uber_clone/src/driver/domain/usecases/drivers-position/driver_position_usecases.dart';
import 'package:indriver_uber_clone/src/driver/domain/usecases/drivers-position/get_driver_position_use_case.dart';
import 'package:indriver_uber_clone/src/driver/presentation/pages/bloc/bloc/driver_home_bloc.dart';
import 'package:indriver_uber_clone/src/driver/presentation/pages/client-requests/bloc/driver_client_requests_bloc.dart';
import 'package:indriver_uber_clone/src/driver/presentation/pages/map/bloc/driver_map_bloc.dart';
import 'package:indriver_uber_clone/src/profile/data/datasource/source/profile_remote_datasource.dart';
import 'package:indriver_uber_clone/src/profile/data/repositories/profile_repository_impl.dart';
import 'package:indriver_uber_clone/src/profile/domain/repository/profile_repository.dart';
import 'package:indriver_uber_clone/src/profile/domain/usecases/update_user_use_case.dart';
import 'package:indriver_uber_clone/src/profile/presentation/pages/info/bloc/profile_info_bloc.dart';
import 'package:indriver_uber_clone/src/profile/presentation/pages/update/bloc/profile_update_bloc.dart';
import 'package:indriver_uber_clone/src/roles/presentation/bloc/roles_bloc.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  await _initCore();
  await _initAuth();
  await _initClient();
  await _initDriver();
  await _initProfile();
  await _initClientMap();
  await _initDriverMap();
}

Future<void> _initCore() async {
  sl
    ..registerLazySingleton<ApiClient>(() => HttpApiClient(baseUrl: apiProject))
    ..registerLazySingleton<SecureStorageAdapter>(SecureStorageAdapter.new)
    ..registerLazySingleton<RolesBloc>(() => RolesBloc(sl()))
    ..registerLazySingleton<Client>(Client.new)
    ..registerLazySingleton<SessionBloc>(SessionBloc.new)
    ..registerLazySingleton<SocketBloc>(() => SocketBloc(sl()))
    ..registerLazySingleton(AppNavigatorService.new)
    ..registerLazySingleton(MapMarkerIconService.new)
    ..registerLazySingleton(LocationService.new)
    ..registerLazySingleton(SocketClient.new)
    //DataSource
    ..registerLazySingleton<ClientRequestDataSource>(
      () => ClientRequestDataSourceImpl(sl()),
    )
    // Repository
    ..registerLazySingleton<GeolocatorRepository>(GeolocatorRepositoryImpl.new)
    ..registerLazySingleton<SocketRepository>(
      () => SocketRepositoryImpl(socket: sl()),
    )
    ..registerLazySingleton<ClientRequestRepository>(
      () => ClientRequestRepositoryImpl(clientRequestDataSource: sl()),
    )
    // UseCases
    ..registerLazySingleton(() => GetTimeAndDistanceValuesUsecase(sl()))
    ..registerLazySingleton(() => CreateClientRequestUseCase(sl()))
    ..registerLazySingleton(() => GetNearbyTripRequestUseCase(sl()))
    ..registerLazySingleton(
      () => ClientRequestsUsecases(
        getTimeAndDistanceValuesUsecase: sl(),
        createClientRequestUseCase: sl(),
        getNearbyTripRequestUseCase: sl(),
      ),
    )
    //Socket
    ..registerLazySingleton(() => ConnectSocketUseCase(sl()))
    ..registerLazySingleton(() => DisconnectSocketUseCase(sl()))
    ..registerLazySingleton(() => SendSocketMessageUseCase(sl()))
    ..registerLazySingleton(() => OnSocketMessageUseCase(sl()))
    ..registerLazySingleton(
      () => SocketUseCases(
        connectSocketUseCase: sl(),
        disconnectSocketUseCase: sl(),
        sendSocketMessageUseCase: SendSocketMessageUseCase(sl()),
        onSocketMessageUseCase: OnSocketMessageUseCase(sl()),
      ),
    )
    //Map
    ..registerLazySingleton(() => FindPositionUseCase(sl()))
    ..registerLazySingleton(() => CreateMarkerUseCase(sl()))
    ..registerLazySingleton(() => GetMarkerUseCase(sl()))
    ..registerLazySingleton(() => GetPositionStreamUseCase(sl()))
    // UseCases group
    ..registerLazySingleton(
      () => GeolocatorUseCases(
        findPositionUseCase: FindPositionUseCase(sl()),
        createMarkerUseCase: CreateMarkerUseCase(sl()),
        getMarkerUseCase: GetMarkerUseCase(sl()),
        getPositionStreamUseCase: GetPositionStreamUseCase(sl()),
      ),
    );
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

// DRIVER
Future<void> _initDriver() async {
  sl.registerFactory(() => DriverHomeBloc(sl()));
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

// MAP
Future<void> _initClientMap() async {
  sl
    ..registerFactory(() => ClientMapSeekerBloc(sl(), sl(), sl(), sl()))
    ..registerFactory(MapLifecycleCubit.new);
}

// DRIVER MAP

Future<void> _initDriverMap() async {
  sl
    ..registerLazySingleton<DriverPositionDatasource>(
      () => DriverPositionDatasourceImpl(apiClient: sl()),
    )
    ..registerLazySingleton<DriverTripRequestDatasource>(
      () => DriverTripRequestDatasourceImpl(apiClient: sl()),
    )
    //repository
    ..registerLazySingleton<DriverPositionRepository>(
      () => DriverPositionRepositoryImpl(driverPositionDatasource: sl()),
    )
    ..registerLazySingleton<DriverTripRequestRepository>(
      () => DriverTripRequestRepositoryImpl(driverTripRequestDatasource: sl()),
    )
    // UseCases
    ..registerLazySingleton(() => CreateDriverPositionUsecase(sl()))
    ..registerLazySingleton(() => DeleteDriverPositionUsecase(sl()))
    ..registerLazySingleton(() => GetDriverPositionUseCase(sl()))
    ..registerLazySingleton(
      () => DriverPositionUsecases(
        createDriverPositionUsecase: sl(),
        deleteDriverPositionUsecase: sl(),
        getDriverPositionUseCase: sl(),
      ),
    )
    ..registerLazySingleton(() => CreateDriverTripRequestUseCase(sl()))
    ..registerLazySingleton(() => GetDriverTripRequestUseCase(sl()))
    ..registerLazySingleton(
      () => DriverTripOffersUseCases(
        createDriverTripOfferUseCase: sl(),
        getDriverTripOffersUseCase: sl(),
      ),
    )
    ..registerFactory(() => DriverMapBloc(sl(), sl(), sl(), sl()))
    ..registerFactory(() => DriverClientRequestsBloc(sl(), sl(), sl(), sl()));
}
