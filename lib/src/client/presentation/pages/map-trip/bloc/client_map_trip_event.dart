part of 'client_map_trip_bloc.dart';

sealed class ClientMapTripEvent extends Equatable {
  const ClientMapTripEvent();

  @override
  List<Object?> get props => [];
}

class GetClientRequestById extends ClientMapTripEvent {
  const GetClientRequestById(this.idClientRequest);
  final int idClientRequest;

  @override
  List<Object> get props => [idClientRequest];
}

class DrawRouteForTrip extends ClientMapTripEvent {
  const DrawRouteForTrip({required this.origin, required this.destination});
  final LatLng origin;
  final LatLng destination;

  @override
  List<Object> get props => [origin, destination];
}

class SocketDriverPositionUpdated extends ClientMapTripEvent {
  const SocketDriverPositionUpdated(this.idSocket, this.lat, this.lng);
  final String idSocket;
  final double lat;
  final double lng;
}

class StartLocalEtaCountdown extends ClientMapTripEvent {
  const StartLocalEtaCountdown();
}

class StopLocalEtaCountdown extends ClientMapTripEvent {
  const StopLocalEtaCountdown();
}

class EtaTick extends ClientMapTripEvent {
  const EtaTick();
}
