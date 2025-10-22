import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:indriver_uber_clone/core/domain/usecases/client-requests/client_requests_usecases.dart';
import 'package:indriver_uber_clone/core/utils/fold_or_emit_error.dart';
import 'package:indriver_uber_clone/src/auth/domain/usecase/auth_use_cases.dart';
import 'package:indriver_uber_clone/src/driver/domain/entities/client_request_response_entity.dart';
import 'package:indriver_uber_clone/src/driver/domain/entities/driver_trip_request_entity.dart';
import 'package:indriver_uber_clone/src/driver/domain/usecases/driver-trip-offers/driver_trip_offers_use_cases.dart';
import 'package:indriver_uber_clone/src/driver/domain/usecases/drivers-position/driver_position_usecases.dart';

part 'driver_client_requests_event.dart';
part 'driver_client_requests_state.dart';

class DriverClientRequestsBloc
    extends Bloc<DriverClientRequestsEvent, DriverClientRequestsState> {
  DriverClientRequestsBloc(
    this.clientRequestsUsecases,
    this.driverPositionUsecases,
    this.authUseCases,
    this.driverTripOffersUseCases,
  ) : super(const DriverClientRequestsState()) {
    on<GetNearbyTripRequestEvent>(_onGetNearbyTripRequestEvent);
    on<CreateDriverTripRequestEvent>(_onCreateDriverTripRequestEvent);
  }

  final ClientRequestsUsecases clientRequestsUsecases;
  final DriverPositionUsecases driverPositionUsecases;
  final DriverTripOffersUseCases driverTripOffersUseCases;
  final AuthUseCases authUseCases;

  Future<void> _onGetNearbyTripRequestEvent(
    GetNearbyTripRequestEvent event,
    Emitter<DriverClientRequestsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, hasError: false));

    //gets the Driver id
    final authEither = await authUseCases.getUserSessionUseCase();
    final auth = await foldOrEmitError(
      authEither,
      emit,
      (msg) => state.copyWith(isLoading: false, hasError: true),
    );
    if (auth == null) return;

    //gets the driver position using the user id
    final driverPosEither = await driverPositionUsecases
        .getDriverPositionUseCase(idDriver: auth.user.id);
    final driverPos = await foldOrEmitError(
      driverPosEither,
      emit,
      (msg) => state.copyWith(isLoading: false, hasError: true),
    );
    if (driverPos == null) return;

    //gets the client requests
    final requestsEither = await clientRequestsUsecases
        .getNearbyTripRequestUseCase(driverPos.lat, driverPos.lng);
    final requestList = await foldOrEmitError(
      requestsEither,
      emit,
      (msg) => state.copyWith(isLoading: false, hasError: true),
    );
    if (requestList == null) return;
    print(' in bloc   **_onGetNearbyTripRequestEvent: $requestList');
    emit(
      state.copyWith(
        clientRequestResponseEntity: requestList,
        idDriver: auth.user.id,
        isLoading: false,
        hasError: false,
      ),
    );
  }

  Future<void> _onCreateDriverTripRequestEvent(
    CreateDriverTripRequestEvent event,
    Emitter<DriverClientRequestsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, hasError: false));
    print(
      ' en bloc   **_onCreateDriverTripRequestEvent: ${event.driverTripRequestEntity}',
    );
    final response = await driverTripOffersUseCases
        .createDriverTripOfferUseCase(event.driverTripRequestEntity);

    response.fold(
      (l) => emit(state.copyWith(isLoading: false, hasError: true)),
      (r) => emit(state.copyWith(isLoading: false, hasError: false)),
    );
  }
}
