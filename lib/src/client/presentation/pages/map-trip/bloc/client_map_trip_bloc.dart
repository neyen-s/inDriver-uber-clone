import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:indriver_uber_clone/core/domain/usecases/client-requests/client_requests_usecases.dart';
import 'package:indriver_uber_clone/src/driver/domain/entities/client_request_response_entity.dart';

part 'client_map_trip_event.dart';
part 'client_map_trip_state.dart';

class ClientMapTripBloc extends Bloc<ClientMapTripEvent, ClientMapTripState> {
  ClientMapTripBloc(this.clientRequestUsecases)
    : super(const ClientMapTripState()) {
    on<GetClientRequestById>(_onGetClientRequestById);
  }

  final ClientRequestsUsecases clientRequestUsecases;

  Future<void> _onGetClientRequestById(
    GetClientRequestById event,
    Emitter<ClientMapTripState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final response = await clientRequestUsecases.getClientRequestByIdUseCase(
      event.idClientRequest,
    );
    // Simulate fetched data
    response.fold(
      (failure) {
        emit(state.copyWith(isLoading: false, errorMessage: failure.message));
      },
      (fetchedRequest) => emit(
        state.copyWith(
          isLoading: false,
          clientRequestEntity: fetchedRequest,
          idClientRequest: event.idClientRequest,
          //Sets the errorMessage to null on success
          // ignore: avoid_redundant_argument_values
          errorMessage: null,
        ),
      ),
    );
  }
}
