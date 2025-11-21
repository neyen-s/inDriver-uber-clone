part of 'client_map_trip_bloc.dart';

sealed class ClientMapTripEvent extends Equatable {
  const ClientMapTripEvent();

  @override
  List<Object> get props => [];
}

class GetClientRequestById extends ClientMapTripEvent {
  const GetClientRequestById(this.idClientRequest);
  final int idClientRequest;

  @override
  List<Object> get props => [idClientRequest];
}
