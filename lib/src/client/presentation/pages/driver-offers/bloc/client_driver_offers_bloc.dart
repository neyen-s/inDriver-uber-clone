import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:indriver_uber_clone/core/domain/usecases/client-requests/client_requests_usecases.dart';
import 'package:indriver_uber_clone/src/driver/domain/entities/driver_trip_request_entity.dart';

part 'client_driver_offers_event.dart';
part 'client_driver_offers_state.dart';

class ClientDriverOffersBloc
    extends Bloc<ClientDriverOffersEvent, ClientDriverOffersState> {
  ClientDriverOffersBloc(this.clientRequestsUsecases)
    : super(const ClientDriverOffersState()) {
    on<GetDriverTripOffersByClientReques>(_onGetDriverTripOffersByClientReques);
  }

  final ClientRequestsUsecases clientRequestsUsecases;

  Future<void> _onGetDriverTripOffersByClientReques(
    GetDriverTripOffersByClientReques event,
    Emitter<ClientDriverOffersState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final response = await clientRequestsUsecases
        .getDriverTripOffersByClientRequestUseCase(event.idClientRequest);

    return response.fold(
      (failure) {
        print('failure ---> $failure');

        emit(state.copyWith(isLoading: false, hasError: true));
      },
      (request) {
        print('request ---> $request');
        emit(
          state.copyWith(
            isLoading: false,
            hasError: false,
            driverTripRequestEntity: request,
          ),
        );
      },
    );
  }
}
