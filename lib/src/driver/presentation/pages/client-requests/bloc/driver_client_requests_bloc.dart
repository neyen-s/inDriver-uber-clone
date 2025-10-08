import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:indriver_uber_clone/core/domain/usecases/client-requests/client_requests_usecases.dart';
import 'package:indriver_uber_clone/core/utils/fold_or_emit_error.dart';
import 'package:indriver_uber_clone/src/auth/domain/usecase/auth_use_cases.dart';
import 'package:indriver_uber_clone/src/driver/domain/entities/client_request_response_entity.dart';
import 'package:indriver_uber_clone/src/driver/domain/usecases/drivers-position/driver_position_usecases.dart';

part 'driver_client_requests_event.dart';
part 'driver_client_requests_state.dart';

class DriverClientRequestsBloc
    extends Bloc<DriverClientRequestsEvent, DriverClientRequestsState> {
  DriverClientRequestsBloc(
    this.clientRequestsUsecases,
    this.driverPositionUsecases,
    this.authUseCases,
  ) : super(const DriverClientRequestsState()) {
    on<GetNearbyTripRequestEvent>(_onGetNearbyTripRequestEvent);
  }

  final ClientRequestsUsecases clientRequestsUsecases;
  final DriverPositionUsecases driverPositionUsecases;
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

    emit(
      state.copyWith(
        clientRequestResponseEntity: requestList,
        isLoading: false,
        hasError: false,
      ),
    );
  }
}
