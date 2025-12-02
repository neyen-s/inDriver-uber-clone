part of 'socket_bloc.dart';

sealed class SocketEvent extends Equatable {
  const SocketEvent();
  @override
  List<Object?> get props => [];
}

class ConnectSocket extends SocketEvent {}

class DisconnectSocket extends SocketEvent {}

class SocketDriverPositionReceived extends SocketEvent {
  const SocketDriverPositionReceived({
    required this.idSocket,
    required this.lat,
    required this.lng,
  });
  final String idSocket;
  final double lat;
  final double lng;

  @override
  List<Object?> get props => [idSocket, lat, lng];
}

class SendDriverPositionRequested extends SocketEvent {
  const SendDriverPositionRequested({
    required this.idDriver,
    required this.lat,
    required this.lng,
  });

  final int idDriver;
  final double lat;
  final double lng;

  @override
  List<Object?> get props => [idDriver, lat, lng];
}

final class SocketDriverDisconnectedReceived extends SocketEvent {
  const SocketDriverDisconnectedReceived({required this.idSocket});
  final String idSocket;

  @override
  List<Object?> get props => [idSocket];
}

// nuevo evento para snapshot inicial atómico
class SocketDriversSnapshotReceived extends SocketEvent {
  const SocketDriversSnapshotReceived(this.drivers);
  final Map<String, LatLng> drivers;

  @override
  List<Object?> get props => [drivers];
}

class SocketDriverRemovalTimeout extends SocketEvent {
  const SocketDriverRemovalTimeout(this.idSocket);
  final String idSocket;

  @override
  List<Object?> get props => [idSocket];
}

final class SocketClientRequestReceived extends SocketEvent {
  const SocketClientRequestReceived({required this.idClientRequest});
  final String idClientRequest;

  @override
  List<Object?> get props => [idClientRequest];
}

final class SendNewClientRequestRequested extends SocketEvent {
  const SendNewClientRequestRequested({required this.idClientRequest});
  final String idClientRequest;

  @override
  List<Object?> get props => [idClientRequest];
}

class ListenClientRequestChannel extends SocketEvent {
  const ListenClientRequestChannel(this.idClientRequest);
  final String idClientRequest;
  @override
  List<Object?> get props => [idClientRequest];
}

class StopListeningClientRequestChannel extends SocketEvent {
  const StopListeningClientRequestChannel(this.idClientRequest);
  final String idClientRequest;
  @override
  List<Object?> get props => [idClientRequest];
}

class SocketDriverOfferReceived extends SocketEvent {
  const SocketDriverOfferReceived({
    required this.idClientRequest,
    required this.payload,
  });
  final String idClientRequest;
  final Map<String, dynamic> payload;
  @override
  List<Object?> get props => [idClientRequest, payload];
}

class SendDriverOfferRequested extends SocketEvent {
  const SendDriverOfferRequested({
    required this.idClientRequest,
    required this.idDriver,
    required this.fare,
    required this.time,
    required this.distance,
  });
  final int idClientRequest;
  final int idDriver;
  final double fare;
  final double time;
  final double distance;
  @override
  List<Object?> get props => [idClientRequest, idDriver, fare, time, distance];
}

class RequestInitialDrivers extends SocketEvent {}

final class SocketRequestRemoved extends SocketEvent {
  const SocketRequestRemoved({required this.idClientRequest});
  final String idClientRequest;

  @override
  List<Object?> get props => [idClientRequest];
}

class SendDriverAssignedRequested extends SocketEvent {
  const SendDriverAssignedRequested({
    required this.idDriver,
    required this.idClientRequest,
  });
  final int idDriver;
  final String idClientRequest;

  @override
  List<Object?> get props => [idDriver, idClientRequest];
}

class SocketDriverAssignedEvent extends SocketEvent {
  const SocketDriverAssignedEvent({
    required this.idClientRequest,
    required this.idDriver,
  });
  final String idClientRequest;
  final String idDriver;
  @override
  List<Object?> get props => [idClientRequest, idDriver];
}

class StopListeningDriverAssignedChannel extends SocketEvent {
  const StopListeningDriverAssignedChannel(this.idDriver);
  final String idDriver;
  @override
  List<Object?> get props => [idDriver];
}

class ListenDriverAssignedChannel extends SocketEvent {
  const ListenDriverAssignedChannel(this.idDriver);
  final String idDriver;
  @override
  List<Object?> get props => [idDriver];
}

class SendTripDriverPositionRequested extends SocketEvent {
  const SendTripDriverPositionRequested({
    required this.idClient,
    required this.lat,
    required this.lng,
  });
  final int idClient;
  final double lat;
  final double lng;

  @override
  List<Object?> get props => [idClient, lat, lng];
}

class ListenTripDriverPositionChannel extends SocketEvent {
  const ListenTripDriverPositionChannel(this.idClient);
  final String idClient;
  @override
  List<Object?> get props => [idClient];
}

class StopListeningTripDriverPositionChannel extends SocketEvent {
  const StopListeningTripDriverPositionChannel(this.idClient);
  final String idClient;
  @override
  List<Object?> get props => [idClient];
}

class SocketTripDriverPositionReceived extends SocketEvent {
  const SocketTripDriverPositionReceived({
    required this.idSocket,
    required this.lat,
    required this.lng,
  });
  final String idSocket;
  final double lat;
  final double lng;
  @override
  List<Object?> get props => [idSocket, lat, lng];
}
